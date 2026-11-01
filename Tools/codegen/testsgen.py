"""Transforms `tests/api_resources` (the `TestAsync*` classes) into swift-testing suites.

The Python suite runs against a mock server that answers from the OpenAPI spec. That spec is
not shipped with the SDK, so each Swift test gets a `MockRoute` instead: it checks the request's
method and path, round-trips the JSON body through the matching `*Params` type (so a body that
doesn't match the params schema fails), and answers with a sample built from the response type.
"""

from __future__ import annotations

import ast
import json
import pathlib
import re
import shutil
from typing import Optional

from pymodules import AliasDecl, ClassDecl, Module
from swiftnames import bare, camel, escape_ident, swift_string
from typesgen import NONE, ConvertError, DictT, ListT, LiteralT, NullableT, Prim, Ref, UnionT


class Skip(Exception):
    pass


SAMPLE_DATETIME = "2024-01-01T00:00:00Z"


class Samples:
    """Builds schema-valid sample JSON for response types."""

    def __init__(self, ctx) -> None:
        self.ctx = ctx
        self.conv = ctx.conv
        self.emitter = ctx.emitter

    def value(self, ir: object, depth: int = 0, stack: tuple = ()) -> object:
        if isinstance(ir, NullableT):
            return self.value(ir.inner, depth, stack)
        if isinstance(ir, Prim):
            return {
                "str": "string", "int": 0, "float": 0, "bool": True, "datetime": SAMPLE_DATETIME,
                "date": "2024-01-01", "object": {"key": "value"}, "none": None, "b64file": "aGVsbG8=",
                "file": "aGVsbG8=", "bytes": "aGVsbG8=",
            }[ir.kind]
        if isinstance(ir, LiteralT):
            return ir.values[0]
        if isinstance(ir, ListT):
            if depth > 4:
                return []
            return [self.value(ir.item, depth + 1, stack)]
        if isinstance(ir, DictT):
            if depth > 4:
                return {}
            return {"key": self.value(ir.value, depth + 1, stack)}
        if isinstance(ir, UnionT):
            return self.value(self.pick_member(ir), depth, stack)
        if isinstance(ir, Ref):
            d = ir.decl
            if isinstance(d, AliasDecl):
                if d.is_rename:
                    target = self.ctx.ms.resolve_expr(d.module, d.value)
                    return self.value(Ref(target), depth, stack)
                return self.value(self.conv.alias_ir(d), depth, stack)
            if isinstance(d, ClassDecl):
                if d.generic:
                    return {}
                out: dict = {}
                recursive = id(d) in stack
                for f in self.conv.fields(d):
                    if not f.required and (depth > 1 or recursive):
                        continue
                    if f.required and f.nullable and (recursive or depth > 3):
                        out[f.json_key] = None
                        continue
                    out[f.json_key] = self.value(f.ir, depth + 1, stack + (id(d),))
                return out
        raise ConvertError(f"no sample for {ir}")

    def pick_member(self, ir: UnionT) -> object:
        # Prefer a variant that decodes unambiguously (a struct or a non-object value).
        return ir.members[0]


class Values:
    """Translates Python literal arguments into Swift expressions, directed by the target type."""

    def __init__(self, ctx) -> None:
        self.ctx = ctx
        self.conv = ctx.conv
        self.emitter = ctx.emitter

    def resolve(self, ir: object) -> object:
        while isinstance(ir, Ref) and isinstance(ir.decl, AliasDecl):
            d = ir.decl
            if d.is_rename:
                target = self.ctx.ms.resolve_expr(d.module, d.value)
                if not isinstance(target, (ClassDecl, AliasDecl)):
                    raise Skip("rename target")
                ir = Ref(target)
                continue
            kind = self.emitter.alias_kind(d)
            if kind in ("enum", "union"):
                return ir
            ir = self.conv.alias_ir(d)
        if isinstance(ir, NullableT):
            return self.resolve(ir.inner)
        return ir

    def literal_python(self, node: ast.expr) -> object:
        return ast.literal_eval(node)

    def json_literal(self, node: ast.expr) -> str:
        if isinstance(node, ast.Dict):
            if not node.keys:
                return "[:]"
            items = ", ".join(f"{swift_string(str(k.value))}: {self.json_literal(v)}" for k, v in zip(node.keys, node.values))
            return f"[{items}]"
        if isinstance(node, (ast.List, ast.Tuple)):
            return "[" + ", ".join(self.json_literal(e) for e in node.elts) + "]"
        if isinstance(node, ast.Constant):
            v = node.value
            if v is None:
                return "JSONValue.null"
            if isinstance(v, bool):
                return "true" if v else "false"
            if isinstance(v, (int, float)):
                return repr(v)
            if isinstance(v, str):
                return swift_string(v)
        if isinstance(node, ast.Call):
            fn = ast.unparse(node.func)
            if fn in ("parse_datetime", "parse_date") and node.args:
                return swift_string(node.args[0].value)
        raise Skip(f"json literal {ast.unparse(node)[:40]}")

    def expr(self, node: ast.expr, ir: object, swift_t: Optional[str] = None) -> str:
        """Swift expression for `node` where a value of type `ir` is expected."""
        if isinstance(node, ast.Constant) and node.value is None:
            return "nil"
        r = self.resolve(ir)
        if isinstance(r, Prim):
            k = r.kind
            if k == "object" or k == "none":
                return self.json_literal(node)
            if k == "datetime":
                if isinstance(node, ast.Call) and node.args:
                    return f"AnthropicJSON.parseISO8601({swift_string(node.args[0].value)})!"
                raise Skip("datetime value")
            if k == "date":
                if isinstance(node, ast.Call) and node.args:
                    y, mo, da = node.args[0].value[:10].split("-")
                    return f"ISODate(year: {int(y)}, month: {int(mo)}, day: {int(da)})"
                raise Skip("date value")
            if k in ("file", "b64file", "bytes"):
                if isinstance(node, ast.Constant) and isinstance(node.value, bytes):
                    data = f"Data({swift_string(node.value.decode())}.utf8)"
                    if k == "file":
                        return f"FileUpload(data: {data}, filename: \"upload\")"
                    if k == "b64file":
                        return f"Base64FileInput(data: {data})"
                    return data
                raise Skip("file value")
            if isinstance(node, ast.Constant):
                v = node.value
                if k == "str" and isinstance(v, str):
                    return swift_string(v)
                if k == "bool" and isinstance(v, bool):
                    return "true" if v else "false"
                if k in ("int", "float") and isinstance(v, (int, float)) and not isinstance(v, bool):
                    return repr(v)
            if isinstance(node, ast.UnaryOp) and isinstance(node.op, ast.USub) and k in ("int", "float"):
                return "-" + self.expr(node.operand, ir)
            raise Skip(f"prim {k} from {ast.unparse(node)[:40]}")
        if isinstance(r, LiteralT):
            if isinstance(node, ast.Constant):
                v = node.value
                if isinstance(v, bool):
                    return "true" if v else "false"
                if isinstance(v, (int, float)):
                    return repr(v)
                return swift_string(str(v))
            raise Skip("literal value")
        if isinstance(r, ListT):
            if not isinstance(node, (ast.List, ast.Tuple)):
                raise Skip(f"list from {ast.unparse(node)[:40]}")
            return "[" + ", ".join(self.expr(e, r.item) for e in node.elts) + "]"
        if isinstance(r, DictT):
            if not isinstance(node, ast.Dict):
                raise Skip("dict value")
            if not node.keys:
                return "[:]"
            return "[" + ", ".join(f"{swift_string(str(k.value))}: {self.expr(v, r.value)}" for k, v in zip(node.keys, node.values)) + "]"
        if isinstance(r, UnionT):
            return self.union_expr(node, r)
        if isinstance(r, Ref):
            d = r.decl
            if isinstance(d, ClassDecl):
                return self.struct_expr(node, d)
            if isinstance(d, AliasDecl):
                kind = self.emitter.alias_kind(d)
                inner = self.conv.alias_ir(d)
                if isinstance(inner, NullableT):
                    inner = inner.inner
                if kind == "enum":
                    if isinstance(node, ast.Constant) and isinstance(node.value, str):
                        return f"{d.swift_name}(rawValue: {swift_string(node.value)})"
                    raise Skip("enum value")
                if kind == "union":
                    return f"{d.swift_name}" + self.union_expr(node, inner)
        raise Skip(f"value for {r}")

    def union_expr(self, node: ast.expr, u: UnionT) -> str:
        key, cases = self.emitter.union_cases(u, None)
        def wrap(c: str, inner: str) -> str:
            return f".{bare(c)}({inner})"
        if isinstance(node, ast.Constant):
            v = node.value
            for c, _, m, _ in cases:
                rm = self.resolve(m)
                if isinstance(v, str) and isinstance(rm, Prim) and rm.kind == "str":
                    return wrap(c, swift_string(v))
            for c, _, m, _ in cases:
                rm = self.resolve(m)
                if isinstance(v, str) and isinstance(rm, LiteralT) and v in rm.values:
                    return wrap(c, swift_string(v))
                if isinstance(v, str) and isinstance(rm, Ref) and isinstance(rm.decl, AliasDecl) and self.emitter.alias_kind(rm.decl) == "enum":
                    return wrap(c, f"{rm.decl.swift_name}(rawValue: {swift_string(v)})")
            for c, _, m, _ in cases:
                rm = self.resolve(m)
                if isinstance(rm, Prim):
                    if isinstance(v, bool) and rm.kind == "bool":
                        return wrap(c, "true" if v else "false")
                    if isinstance(v, int) and not isinstance(v, bool) and rm.kind in ("int", "float"):
                        return wrap(c, repr(v))
                    if isinstance(v, float) and rm.kind == "float":
                        return wrap(c, repr(v))
                    if isinstance(v, bytes) and rm.kind in ("file", "b64file"):
                        return wrap(c, self.expr(node, rm))
            for c, _, m, _ in cases:
                rm = self.resolve(m)
                if isinstance(rm, Prim) and rm.kind == "object":
                    return wrap(c, self.json_literal(node))
            raise Skip(f"union constant {v!r}")
        if isinstance(node, (ast.List, ast.Tuple)):
            for c, _, m, _ in cases:
                if isinstance(self.resolve(m), ListT):
                    try:
                        return wrap(c, self.expr(node, m))
                    except Skip:
                        continue
            raise Skip("union list")
        if isinstance(node, ast.Dict):
            keys = {k.value for k in node.keys if isinstance(k, ast.Constant)}
            tag = None
            for k, v in zip(node.keys, node.values):
                if isinstance(k, ast.Constant) and k.value == (key or "type") and isinstance(v, ast.Constant):
                    tag = v.value
            if tag is not None:
                for c, _, m, dv in cases:
                    if dv == tag:
                        return wrap(c, self.expr(node, m))
                for c, _, m, _ in cases:
                    if self.emitter.member_discriminator_value(m, key or "type") == tag:
                        return wrap(c, self.expr(node, m))
            # structural match
            for c, _, m, _ in cases:
                rm = self.resolve(m)
                if isinstance(rm, Ref) and isinstance(rm.decl, ClassDecl):
                    fields = {f.json_key: f for f in self.conv.fields(rm.decl)}
                    required = {k for k, f in fields.items() if f.required and getattr(f, "default", None) is None and not (isinstance(f.ir, LiteralT) and len(f.ir.values) == 1)}
                    if keys <= set(fields) and required <= keys:
                        try:
                            return wrap(c, self.expr(node, m))
                        except Skip:
                            continue
            for c, _, m, _ in cases:
                rm = self.resolve(m)
                if isinstance(rm, DictT) or (isinstance(rm, Prim) and rm.kind == "object"):
                    return wrap(c, self.expr(node, m))
            raise Skip(f"union dict {sorted(keys)}")
        if isinstance(node, ast.Call):
            for c, _, m, _ in cases:
                try:
                    return wrap(c, self.expr(node, m))
                except Skip:
                    continue
        raise Skip(f"union value {ast.unparse(node)[:40]}")

    def struct_expr(self, node: ast.expr, d: ClassDecl) -> str:
        if not isinstance(node, ast.Dict):
            raise Skip(f"struct {d.name} from {ast.unparse(node)[:40]}")
        props = getattr(d, "_props", None)
        if props is None:
            raise Skip(f"struct {d.name} not rendered")
        given = {}
        for k, v in zip(node.keys, node.values):
            if not isinstance(k, ast.Constant):
                raise Skip("splat in struct")
            given[k.value] = v
        args = []
        for f, pname, t, default in props:
            if f.json_key not in given and f.py_name not in given:
                continue
            v = given.pop(f.json_key, None) or given.pop(f.py_name, None)
            if isinstance(v, ast.Constant) and v.value is None:
                if t.endswith("??"):
                    args.append(f"{bare(pname)}: .some(nil)")
                else:
                    args.append(f"{bare(pname)}: nil")
                continue
            args.append(f"{bare(pname)}: {self.expr(v, f.ir)}")
        if given:
            raise Skip(f"unknown keys {list(given)} for {d.name}")
        return f"{d.swift_name}({', '.join(args)})"


class TestGen:
    def __init__(self, ctx) -> None:
        self.ctx = ctx
        self.gen = ctx.resource_gen
        self.samples = Samples(ctx)
        self.values = Values(ctx)
        self.skipped: list[str] = []
        self.counts = {"tests": 0}

    # ------------------------------------------------------------ resolution

    def resolve_call(self, call: ast.Call) -> tuple[list[str], str, str, object]:
        """For `async_client.a.b.with_raw_response.method(...)`: (swift path, mode, method, plan)."""
        chain = []
        f = call.func
        while isinstance(f, ast.Attribute):
            chain.append(f.attr)
            f = f.value
        if not (isinstance(f, ast.Name) and f.id in ("async_client", "client")):
            raise Skip("not a client call")
        chain.reverse()
        method = chain[-1]
        mode = "parsed"
        path = chain[:-1]
        if path and path[-1] in ("with_raw_response", "with_streaming_response"):
            mode = "raw" if path[-1] == "with_raw_response" else "stream"
            path = path[:-1]
        if not path:
            raise Skip("no resource")
        res = self.gen.client_accessors.get(path[0])
        if res is None:
            raise Skip(f"accessor {path[0]}")
        for p in path[1:]:
            res = self.gen.registry.get(res, {}).get("subs", {}).get(p)
            if res is None:
                raise Skip(f"sub-resource {p}")
        plan = self.gen.registry.get(res, {}).get("methods", {}).get(method)
        if plan is None:
            raise Skip(f"method {res}.{method} not generated")
        return [escape_ident(camel(p)) for p in path], mode, method, plan

    def call_args(self, call: ast.Call, plan) -> tuple[str, bool]:
        kwargs = {k.arg: k.value for k in call.keywords}
        positional_args = [a for a in plan.args if a.positional]
        for i, node in enumerate(call.args):
            if i >= len(positional_args):
                raise Skip("too many positional args")
            kwargs[positional_args[i].py] = node
        extras = []
        for key, label in (("extra_headers", "extraHeaders"), ("extra_query", "extraQuery"), ("extra_body", "extraBody")):
            if key in kwargs:
                node = kwargs.pop(key)
                if key == "extra_headers":
                    if not isinstance(node, ast.Dict):
                        raise Skip("extra_headers shape")
                    items = ", ".join(f"{swift_string(k.value)}: {swift_string(v.value)}" for k, v in zip(node.keys, node.values))
                    extras.append(f"{label}: [{items or ':'}]")
                else:
                    extras.append(f"{label}: {self.values.json_literal(node)}")
        streaming = False
        if "stream" in kwargs:
            v = kwargs.pop("stream")
            streaming = isinstance(v, ast.Constant) and v.value is True
        parts = []
        for a in plan.args:
            if a.py not in kwargs:
                if a.required:
                    raise Skip(f"missing {a.py}")
                continue
            node = kwargs.pop(a.py)
            if isinstance(node, ast.Constant) and node.value is None:
                expr = ".some(nil)" if a.type.endswith("??") else "nil"
            else:
                expr = self.values.expr(node, a.ir)
            parts.append(expr if a.positional else f"{bare(a.swift)}: {expr}")
        if kwargs:
            raise Skip(f"unknown kwargs {list(kwargs)}")
        return ", ".join(parts + extras), streaming

    # --------------------------------------------------------------- samples

    def response_sample(self, plan, streaming: bool) -> tuple[str, str]:
        """(kind, Swift literal of the mock response body)."""
        kind = "stream" if streaming or plan.stream_only else plan.result_kind
        ir = getattr(plan, "result_ir", None)
        if kind == "stream":
            elem_ir = plan.stream_ir if streaming else ir
            ev = self.sample_event(elem_ir)
            return "sse", raw_literal(ev)
        if kind == "binary":
            return "binary", raw_literal("binary content")
        if kind == "jsonl":
            return "jsonl", raw_literal(json.dumps(self.samples.value(ir)) + "\n")
        if kind == "page":
            item = self.samples.value(plan.item_ir)
            page = {"data": [item], "has_more": False, "first_id": "first", "last_id": "last", "next_page": None, "prev_page": None}
            return "json", raw_literal(json.dumps(page))
        if plan.result_type == "EmptyResponse":
            return "json", raw_literal("{}")
        return "json", raw_literal(json.dumps(self.samples.value(ir)))

    def sample_event(self, ir: object) -> str:
        r = self.values.resolve(ir)
        if isinstance(r, Ref) and isinstance(r.decl, AliasDecl):
            r = self.conv_union(r.decl)
        if isinstance(r, UnionT):
            member = r.members[0]
            data = self.samples.value(member)
            name = self.ctx.emitter.member_discriminator_value(member, r.discriminator or "type") or "message"
        else:
            data = self.samples.value(ir)
            name = data.get("type", "message") if isinstance(data, dict) else "message"
        return f"event: {name}\ndata: {json.dumps(data)}\n\n"

    def conv_union(self, d: AliasDecl) -> object:
        ir = self.ctx.conv.alias_ir(d)
        return ir.inner if isinstance(ir, NullableT) else ir

    def params_type_for(self, plan) -> Optional[str]:
        if plan.multipart or not plan.body_entries:
            return None
        keys = {k for k, _, _ in plan.body_entries}
        best = None
        for m in self.ctx.type_modules:
            if not m.name.endswith("_params"):
                continue
            for d in m.decls.values():
                if not isinstance(d, ClassDecl) or not d.is_typeddict or not getattr(d, "_props", None):
                    continue
                fl = self.ctx.conv.fields(d)
                fields = {f.json_key for f in fl}
                # header params (`betas`, `workspace_id`, ...) are fields of the params TypedDict too
                required_extra = {f.json_key for f in fl if f.required and f.json_key not in keys and f.json_key != "stream"}
                if not keys <= fields or required_extra:
                    continue
                res_parts = plan.module.name.split(".")[2:]
                mparts = m.name.split(".")[2:]
                score = (
                    (mparts[:1] == ["beta"]) != (res_parts[:1] == ["beta"]),
                    not mparts[-1].endswith(f"{plan.name}_params"),
                    res_parts[-1].rstrip("s") not in mparts[-1],
                    fields != keys,
                    m.name,
                )
                if best is None or score < best[0]:
                    best = (score, d)
        if best is None:
            return None
        if best[0][0] or best[0][1]:
            return None
        return best[1].swift_name

    # -------------------------------------------------------------- emission

    def route(self, plan, streaming: bool) -> str:
        kind, body = self.response_sample(plan, streaming)
        path = re.sub(r"\?.*$", "", plan.span_route or "")
        if not path:
            raise Skip("no route")
        validate = self.params_type_for(plan)
        drop = ', dropKeys: ["stream"]' if streaming else ""
        v = f", validateBody: {{ try MockRoute.roundTrip({validate}.self, $0{drop}) }}" if validate else ""
        return f'MockRoute(method: {swift_string(plan.method.upper())}, path: {swift_string(path)}, {kind}: {body}{v})'

    def verify_expr(self, plan, var: str, streaming: bool) -> str:
        kind = "stream" if streaming or plan.stream_only else plan.result_kind
        if kind == "json" and plan.result_type not in ("EmptyResponse", "JSONValue", "String"):
            return f"try route.verifyRoundTrip({var})"
        if kind == "page":
            return f"#expect({var}.items.count == 1)"
        if kind == "stream":
            return f"try await route.drain({var})"
        if kind == "binary":
            return f'#expect(try await {var}.read() == Data("binary content".utf8))'
        if kind == "jsonl":
            return f"try await route.drain({var})"
        return f"_ = {var}"

    def emit_test(self, fn: ast.AsyncFunctionDef) -> str:
        name = fn.name
        if not name.startswith("test_"):
            raise Skip("not a test")
        skip_reason = None
        for d in fn.decorator_list:
            t = ast.unparse(d)
            if t.startswith("pytest.mark.skip"):
                m = re.search(r"reason=['\"](.*)['\"]", t)
                skip_reason = m.group(1) if m else "skipped upstream"
            if "respx" in t:
                raise Skip("respx-mocked test")
        if any(a.arg == "respx_mock" for a in fn.args.args):
            raise Skip("respx-mocked test")
        swift_name = camel(name[len("test_"):])
        body = [s for s in fn.body if not (isinstance(s, ast.Expr) and isinstance(s.value, ast.Constant))]
        attrs = f'@Test(.disabled({swift_string(skip_reason)}))' if skip_reason else "@Test"
        lines: list[str] = []
        # path params
        if name.startswith("test_path_params_"):
            for st in body:
                if not isinstance(st, ast.With):
                    raise Skip("path params shape")
                ctxe = st.items[0].context_expr
                msg = None
                for k in ctxe.keywords:
                    if k.arg == "match":
                        msg = k.value.value
                inner = st.body[0]
                call = inner.value.value if isinstance(inner.value, ast.Await) else inner.value
                path, mode, method, plan = self.resolve_call(call)
                args, streaming = self.call_args(call, plan)
                sname = self.method_name(plan, streaming)
                acc = ".".join(path) + (".withRawResponse" if mode == "raw" else "")
                lines.append(f"try await expectValueError({swift_string(unregex(msg))}) {{ _ = try await client.{acc}.{sname}({args}) }}")
            return self.wrap(attrs, swift_name, "let client = try mockClient()", lines)
        # method / raw / streaming
        first = body[0]
        if isinstance(first, ast.AsyncWith):
            call = first.items[0].context_expr
            path, mode, method, plan = self.resolve_call(call)
            args, streaming = self.call_args(call, plan)
            sname = self.method_name(plan, streaming)
            acc = ".".join(path)
            sep = ", " if args else ""
            lines.append(f"let (response, value) = try await client.{acc}.withStreamingResponse.{sname}({args}{sep}body: {{ response in")
            lines.append("    #expect(!response.isClosed)")
            lines.append('    #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")')
            lines.append("    return (response, try await response.parse())")
            lines.append("})")
            lines.append(self.verify_expr(plan, "value", streaming))
            lines.append("#expect(response.isClosed)")
            return self.wrap(attrs, swift_name, f"let route = {self.route(plan, streaming)}\n        let client = try route.client()", lines)
        if isinstance(first, ast.Assign) and isinstance(first.value, ast.Await) and isinstance(first.value.value, ast.Call):
            call = first.value.value
            path, mode, method, plan = self.resolve_call(call)
            args, streaming = self.call_args(call, plan)
            sname = self.method_name(plan, streaming)
            acc = ".".join(path)
            if mode == "raw":
                lines.append(f"let response = try await client.{acc}.withRawResponse.{sname}({args})")
                if any(ast.unparse(st) == "assert response.is_closed is True" for st in body):
                    lines.append("#expect(response.isClosed == true)")
                lines.append('#expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")')
                lines.append("let value = try await response.parse()")
            else:
                lines.append(f"let value = try await client.{acc}.{sname}({args})")
            lines.append(self.verify_expr(plan, "value", streaming))
            return self.wrap(attrs, swift_name, f"let route = {self.route(plan, streaming)}\n        let client = try route.client()", lines)
        raise Skip(f"test shape {type(first).__name__}")

    @staticmethod
    def method_name(plan, streaming: bool) -> str:
        if streaming:
            if not plan.streaming_variant:
                if plan.stream_only:
                    return plan.swift_name
                raise Skip("stream=True on a non-streaming method")
            return escape_ident(bare(plan.swift_name) + "Streaming")
        return plan.swift_name

    @staticmethod
    def wrap(attrs: str, name: str, setup: str, lines: list[str]) -> str:
        body = "\n".join("        " + l for l in "\n".join(lines).split("\n"))
        return f"    {attrs} func {escape_ident(name)}() async throws {{\n        {setup}\n{body}\n    }}\n"

    def emit_file(self, path: pathlib.Path, rel: str) -> Optional[str]:
        tree = ast.parse(path.read_text())
        classes = [c for c in tree.body if isinstance(c, ast.ClassDef) and c.name.startswith("TestAsync")]
        if not classes:
            return None
        out = f"// Transformed from `tests/{rel}`.\n\nimport Foundation\nimport Testing\n@testable import Anthropic\n"
        for cls in classes:
            parts = rel.removesuffix(".py").split("/")[1:-1]
            suite = "Test" + "".join(p[:1].upper() + camel(p)[1:] for p in parts) + cls.name.replace("TestAsync", "")
            tests = []
            for fn in cls.body:
                if not isinstance(fn, ast.AsyncFunctionDef):
                    continue
                try:
                    tests.append(self.emit_test(fn))
                    self.counts["tests"] += 1
                except (Skip, ConvertError, KeyError, AttributeError) as e:
                    self.skipped.append(f"{rel}::{cls.name}::{fn.name}: {e}")
            out += f"\n@Suite struct {suite} {{\n" + "\n".join(tests) + "}\n"
        return out


def raw_literal(s: str) -> str:
    if "\n" in s:
        return swift_string(s)
    hashes = "#"
    while f'"{hashes}' in s:
        hashes += "#"
    if "\n" in s:
        return f'{hashes}"""\n{s}\n"""{hashes}' if not s.endswith("\n") else f'{hashes}"""\n{s}"""{hashes}'
    return f'{hashes}"{s}"{hashes}'


def unregex(pattern: str) -> str:
    return re.sub(r"\\(.)", r"\1", pattern)


def gen_tests(ctx, out_dir: pathlib.Path) -> list[str]:
    if out_dir.exists():
        shutil.rmtree(out_dir)
    out_dir.mkdir(parents=True)
    root = ctx.ms.src_root.parent / "tests"
    tg = TestGen(ctx)
    files = 0
    for path in sorted((root / "api_resources").rglob("test_*.py")):
        rel = str(path.relative_to(root))
        src = tg.emit_file(path, rel)
        if src:
            name = rel.replace("/", ".").removesuffix(".py") + ".swift"
            (out_dir / name).write_text(src)
            files += 1
    (out_dir.parent.parent.parent / "docs" / "porting" / "GENERATED_TESTS_SKIPPED.txt").write_text("Upstream tests not transformed (see reasons):\n\n" + "\n".join(tg.skipped) + "\n")
    print(f"tests: wrote {files} files, {tg.counts['tests']} tests, {len(tg.skipped)} skipped")
    return []
