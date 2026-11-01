"""Transforms `anthropic/resources` (the `Async*` resource classes) into Swift resource structs.

Each Python method body is a short sequence of statements in a small, regular dialect
(path-param checks, header layers, a `self._post(...)` call). Those statements are interpreted
here and re-emitted as Swift. A method using a statement outside that dialect is reported as
unsupported; those are ported by hand in `Sources/Anthropic/Lib`.
"""

from __future__ import annotations

import ast
import pathlib
import re
from dataclasses import dataclass, field
from typing import Optional

from pymodules import AliasDecl, ClassDecl, Module
from swiftnames import bare, camel, doc_comment, escape_ident, pascal, swift_string
from typesgen import (
    ConvertError,
    DictT,
    ListT,
    LiteralT,
    NullableT,
    Prim,
    Ref,
    Scope,
    UnionT,
    indent_src,
)

SKIP_ARGS = {"self", "extra_headers", "extra_query", "extra_body", "timeout"}


class Unsupported(Exception):
    pass


@dataclass
class Arg:
    py: str
    swift: str
    type: str  # full Swift type including optionality
    base_type: str
    required: bool
    positional: bool
    ir: object
    nullable: bool
    default: Optional[str] = None


@dataclass
class MethodPlan:
    name: str
    swift_name: str
    doc: Optional[str]
    args: list[Arg]
    pre: list[str]  # Swift statements before building options
    method: str
    path_expr: str
    body_entries: list[tuple[str, str, str]]  # (json key, swift expr, kind: value|file|files)
    query_entries: list[tuple[str, str]]
    header_expr: str
    result_kind: str  # json|page|stream|binary|jsonl|empty
    result_type: str  # Swift element type
    span_name: Optional[str]
    span_route: Optional[str]
    multipart: bool
    streaming_variant: bool  # create + createStreaming pair
    stream_only: bool
    nonstreaming_timeout: Optional[str] = None
    qualifiers: Optional[dict] = None


def resource_swift_name(module: str, cls: str) -> str:
    parts = module.split(".")[2:]  # after anthropic.resources
    base = cls[len("Async"):] if cls.startswith("Async") else cls
    names = [pascal(p) for p in parts]
    if names and names[-1].lower() == base.lower():
        names = names[:-1]
    out: list[str] = []
    for n in names + [base]:
        if not out or out[-1] != n:
            out.append(n)
    return "".join(out) + "Resource"


class ResourceGen:
    def __init__(self, ctx) -> None:
        self.ctx = ctx
        self.ms = ctx.ms
        self.conv = ctx.conv
        self.emitter = ctx.emitter
        self.unsupported: list[str] = []
        self.class_names: dict[tuple[str, str], str] = {}
        # swift resource name -> {"subs": {py: swift}, "methods": {py: MethodPlan}, "module": name}
        self.registry: dict[str, dict] = {}
        self.client_accessors: dict[str, str] = {}

    # ------------------------------------------------------------------ types

    def contains_inline(self, ir: object) -> bool:
        if isinstance(ir, NullableT):
            return self.contains_inline(ir.inner)
        if isinstance(ir, LiteralT):
            return len(ir.values) > 1 and all(isinstance(v, str) for v in ir.values)
        if isinstance(ir, UnionT):
            return True
        if isinstance(ir, ListT):
            return self.contains_inline(ir.item)
        if isinstance(ir, DictT):
            return self.contains_inline(ir.value)
        return False

    @staticmethod
    def norm_ann(text: str) -> str:
        t = text.replace(" ", "").replace("'", '"')
        t = re.sub(r"\|(Omit|NotGiven)", "", t)
        m = re.fullmatch(r"(Required|NotRequired)\[(.*)\]", t)
        if m:
            t = m.group(2)
        return t

    def params_index(self) -> dict:
        idx = getattr(self, "_pidx", None)
        if idx is not None:
            return idx
        idx = {}
        for m in self.ctx.type_modules:
            if not m.name.endswith("_params"):
                continue
            for d in m.decls.values():
                if not isinstance(d, ClassDecl) or not d.is_typeddict:
                    continue
                for st in d.node.body:
                    if isinstance(st, ast.AnnAssign) and isinstance(st.target, ast.Name):
                        key = (st.target.id, self.norm_ann(ast.unparse(st.annotation)))
                        idx.setdefault(key, []).append(d)
        self._pidx = idx
        return idx

    def params_type(self, mod: Module, method: str, py_name: str, ann: str) -> Optional[str]:
        """Finds the Swift type the matching `*_params` TypedDict gives a field."""
        cands = self.params_index().get((py_name, self.norm_ann(ann)), [])
        if not cands:
            return None
        res_parts = mod.name.split(".")[2:]
        is_beta = res_parts[:1] == ["beta"]
        stem = res_parts[-1].rstrip("s")

        def score(d: ClassDecl) -> tuple:
            mparts = d.module.split(".")[2:]
            leaf = mparts[-1]
            return (
                (mparts[:1] == ["beta"]) != is_beta,
                f"_{method}_params" not in f"_{leaf}" and not leaf.endswith(f"{method}_params"),
                stem not in leaf,
                len(mparts),
                d.module,
            )

        d = sorted(cands, key=score)[0]
        base = getattr(d, "_base_types", {}).get(py_name)
        if base is None:
            return None
        nested = getattr(d, "_nested_names", set())
        owner = d.swift_name

        def qualify(m: re.Match) -> str:
            return f"{owner}.{m.group(0)}" if m.group(0) in nested else m.group(0)

        return re.sub(r"\b[A-Z][A-Za-z0-9_]*\b", qualify, base)

    def arg_type(self, mod: Module, method: str, a: ast.arg, default: Optional[ast.expr], scope: Scope) -> Arg:
        ann = ast.unparse(a.annotation)
        omittable = "Omit" in ann or "NotGiven" in ann or (default is not None)
        ir = self.conv.conv(a.annotation, mod.name)
        nullable = isinstance(ir, NullableT)
        inner = ir.inner if nullable else ir
        if self.contains_inline(inner):
            t = self.params_type(mod, method, a.arg, ann)
            if t is None:
                t = self.emitter.swift_type(inner, scope, pascal(method) + pascal(a.arg))
        else:
            t = self.emitter.swift_type(inner, None, a.arg)
        if t.endswith("?"):  # a nullable type alias
            t = t[:-1]
            nullable = True
        base = t
        if omittable and nullable:
            full = t + "??"
        elif omittable or nullable:
            full = t + "?"
        else:
            full = t
        return Arg(a.arg, escape_ident(camel(a.arg)), full, base, not omittable, False, inner, nullable,
                   "nil" if omittable else None)

    # ------------------------------------------------------------- expressions

    def header_value(self, node: ast.expr, args: dict[str, Arg]) -> str:
        """A Swift `String?` expression for one header entry."""
        if isinstance(node, ast.Constant):
            return swift_string(str(node.value))
        if isinstance(node, ast.Name):
            a = args.get(node.id)
            if a is None:
                raise Unsupported(f"header from {node.id}")
            return self.stringify(a)
        if isinstance(node, ast.IfExp):
            test = ast.unparse(node.test)
            m = re.match(r"is_given\((\w+)\)", test)
            if not m or ast.unparse(node.orelse) != "not_given":
                raise Unsupported(f"header ifexp {test}")
            a = args[m.group(1)]
            body = node.body
            # ",".join(chain((str(e) for e in betas), ["x"])) or ",".join(str(e) for e in betas)
            extra: list[str] = []
            if isinstance(body, ast.Call) and body.args:
                inner = body.args[0]
                if isinstance(inner, ast.Call) and ast.unparse(inner.func) == "chain":
                    for lst in inner.args[1:]:
                        if isinstance(lst, ast.List):
                            extra += [e.value for e in lst.elts]
            sep = body.func.value.value if isinstance(body, ast.Call) and isinstance(body.func, ast.Attribute) else ","
            extra_s = ", ".join(swift_string(e) for e in extra)
            val = f"({a.swift} ?? nil)" if a.type.endswith("??") else a.swift
            return f"joinHeaderValues({val}, extra: [{extra_s}], separator: {swift_string(sep)})"
        raise Unsupported(f"header value {ast.unparse(node)}")

    def stringify(self, a: Arg) -> str:
        if a.base_type == "String":
            return a.swift if not a.type.endswith("??") else f"({a.swift} ?? nil)"
        if a.base_type in ("Int", "Double", "Bool"):
            return f"{a.swift}.map {{ String($0) }}" if a.type.endswith("?") else f"String({a.swift})"
        return f"{a.swift}.map {{ $0.rawValue }}" if a.type.endswith("?") else f"{a.swift}.rawValue"

    def header_layers(self, node: ast.expr, args: dict[str, Arg]) -> list[str]:
        """Translates an `extra_headers = ...` expression into an ordered list of Swift header layers."""
        if isinstance(node, ast.Dict):
            layers: list[str] = []
            const: list[str] = []
            for k, v in zip(node.keys, node.values):
                if k is None:
                    if const:
                        layers.append("[" + ", ".join(const) + "]")
                        const = []
                    layers += self.header_layers(v, args)
                else:
                    if not isinstance(v, ast.Constant):
                        raise Unsupported("non-constant plain header")
                    const.append(f"{swift_string(k.value)}: {swift_string(str(v.value))}")
            if const:
                layers.append("[" + ", ".join(const) + "]")
            return layers
        if isinstance(node, ast.BoolOp) and isinstance(node.op, ast.Or):
            if ast.unparse(node) == "extra_headers or {}":
                return ["extraHeaders"]
        if isinstance(node, ast.Name) and node.id == "extra_headers":
            return ["extraHeaders"]
        if isinstance(node, ast.Call):
            fname = ast.unparse(node.func)
            if fname == "strip_not_given":
                d = node.args[0]
                if not isinstance(d, ast.Dict):
                    raise Unsupported("strip_not_given arg")
                pairs = [f"({swift_string(k.value)}, {self.header_value(v, args)})" for k, v in zip(d.keys, d.values)]
                return [f"stripNotGiven([{', '.join(pairs)}])"]
            if fname == "merge_headers":
                out: list[str] = []
                for a in node.args:
                    out += self.header_layers(a, args)
                return [f"mergeHeaders({', '.join(out)})"]
            if fname in ("_stainless_helper_header", "_stainless_helper_header_from_file", "helper_header"):
                return []
        raise Unsupported(f"headers {ast.unparse(node)[:80]}")

    def value_expr(self, node: ast.expr, args: dict[str, Arg]) -> tuple[str, str]:
        """(swift expr, kind) for a body/query dict value."""
        if isinstance(node, ast.Name) and node.id in ("merged_output_config",):
            node = ast.Name(id="output_config")
        if isinstance(node, ast.Name) and node.id in args:
            a = args[node.id]
            if a.base_type == "FileUpload":
                return a.swift, "file"
            if a.base_type == "[FileUpload]":
                return a.swift, "files"
            return a.swift, "value"
        if isinstance(node, ast.Constant):
            v = node.value
            if isinstance(v, bool):
                return ("true" if v else "false"), "value"
            if isinstance(v, (int, float)):
                return repr(v), "value"
            if isinstance(v, str):
                return swift_string(v), "value"
            if v is None:
                return "JSONValue.null", "value"
        raise Unsupported(f"body value {ast.unparse(node)}")

    def dict_entries(self, node: ast.expr, args: dict[str, Arg]) -> list[tuple[str, str, str]]:
        if not isinstance(node, ast.Dict):
            raise Unsupported(f"dict {ast.unparse(node)[:60]}")
        out = []
        for k, v in zip(node.keys, node.values):
            if k is None or not isinstance(k, ast.Constant):
                raise Unsupported("dict splat")
            expr, kind = self.value_expr(v, args)
            out.append((k.value, expr, kind))
        return out

    def path_expr(self, node: ast.expr, args: dict[str, Arg]) -> tuple[str, str]:
        if isinstance(node, ast.Constant):
            return swift_string(node.value), node.value
        if isinstance(node, ast.Call) and ast.unparse(node.func) == "path_template":
            tmpl = node.args[0].value
            pairs = []
            for kw in node.keywords:
                a = args.get(ast.unparse(kw.value))
                if a is None:
                    raise Unsupported("path value")
                val = a.swift if a.base_type == "String" else f'"\\({a.swift})"'
                if a.type.endswith("?"):
                    val = f'"\\({a.swift}.map {{ "\\($0)" }} ?? "null")"'
                pairs.append(f"{swift_string(kw.arg)}: {val}")
            return f"try pathTemplate({swift_string(tmpl)}, [{', '.join(pairs)}])", tmpl
        raise Unsupported("path")

    def swift_ref_type(self, node: ast.expr, mod: Module) -> str:
        """The Swift type for a `cast_to=` / `model=` expression."""
        if isinstance(node, ast.Call) and ast.unparse(node.func) == "cast":
            return self.swift_ref_type(node.args[1], mod)
        txt = ast.unparse(node)
        if txt in ("NoneType", "type(None)"):
            return "EmptyResponse"
        if txt in ("str",):
            return "String"
        if txt in ("object",):
            return "JSONValue"
        ir = self.conv.conv(node, mod.name)
        self.last_ir = ir
        return self.emitter.swift_type(ir, None, "Result")

    # ---------------------------------------------------------------- methods

    def plan_method(self, mod: Module, cls_swift: str, fn: ast.AsyncFunctionDef | ast.FunctionDef, scope: Scope) -> MethodPlan:
        a = fn.args
        positional = [x for x in a.args if x.arg != "self"]
        defaults = [None] * (len(a.args) - len(a.defaults)) + list(a.defaults)
        pos_defaults = dict(zip([x.arg for x in a.args], defaults))
        args: dict[str, Arg] = {}
        order: list[Arg] = []
        for x in positional:
            if x.arg in SKIP_ARGS:
                continue
            arg = self.arg_type(mod, fn.name, x, pos_defaults.get(x.arg), scope)
            arg.positional = True
            args[x.arg] = arg
            order.append(arg)
        dropped: set[str] = set()
        for x, d in zip(a.kwonlyargs, a.kw_defaults):
            if x.arg in SKIP_ARGS:
                continue
            if re.fullmatch(r"(Optional\[type\]|type)(\s*\|\s*(Omit|NotGiven))*", ast.unparse(x.annotation)):
                dropped.add(x.arg)
                continue
            arg = self.arg_type(mod, fn.name, x, d, scope)
            args[x.arg] = arg
            order.append(arg)

        pre: list[str] = []
        header_expr = "extraHeaders"
        body_entries: list[tuple[str, str, str]] = []
        query_entries: list[tuple[str, str]] = []
        multipart = False
        call: Optional[ast.Call] = None
        nonstreaming_timeout = None
        aliases = {"merged_output_config": "output_config"}
        for st in fn.body:
            if isinstance(st, ast.Expr) and isinstance(st.value, ast.Constant):
                continue
            names = {n.id for n in ast.walk(st) if isinstance(n, ast.Name)}
            if not isinstance(st, ast.Return) and (names & dropped or names & {"transformed_output_format", "merged_output_config"}):
                continue
            if isinstance(st, ast.Assign) and isinstance(st.targets[0], ast.Subscript) and ast.unparse(st.targets[0]) == "extra_headers['Content-Type']":
                multipart = True
                continue
            if isinstance(st, ast.If):
                test = ast.unparse(st.test)
                m = re.fullmatch(r"not (\w+)", test)
                if m and len(st.body) == 1 and isinstance(st.body[0], ast.Raise) and "ValueError" in ast.unparse(st.body[0]):
                    arg = args[m.group(1)]
                    if arg.type.endswith("?"):
                        pre.append(f"if let v = {arg.swift} {{ try requireNonEmpty(v, {swift_string(m.group(1))}) }}")
                    else:
                        pre.append(f"try requireNonEmpty({arg.swift}, {swift_string(m.group(1))})")
                    continue
                if test == "model in DEPRECATED_MODELS":
                    pre.append("warnIfDeprecatedModel(model.rawValue)")
                    continue
                if test.startswith("model in MODELS_TO_WARN_WITH_THINKING_ENABLED"):
                    th = args.get("thinking")
                    pre.append(f"warnIfThinkingEnabledDeprecated(model.rawValue, thinking: {th.swift})" if th else "")
                    continue
                if "_calculate_nonstreaming_timeout" in ast.unparse(st):
                    nonstreaming_timeout = "if timeout == nil && client.timeout == DEFAULT_TIMEOUT && !client.timeoutOverridden { timeout = try client.calculateNonstreamingTimeout(maxTokens: maxTokens, maxNonstreamingTokens: MODEL_NONSTREAMING_TOKENS[model.rawValue]) }"
                    continue
                raise Unsupported(f"if {test[:60]}")
            if isinstance(st, ast.Assign) and isinstance(st.targets[0], ast.Name):
                tgt = st.targets[0].id
                if tgt == "extra_headers":
                    layers = self.header_layers(st.value, args)
                    # each assignment replaces extra_headers with a new combined layer
                    header_expr = self.substitute(layers, header_expr)
                    continue
                if tgt == "tools" and ast.unparse(st.value) == "_to_tool_params(tools)":
                    continue
                if tgt == "body" and isinstance(st.value, ast.Call) and ast.unparse(st.value.func) == "deepcopy_with_paths":
                    body_entries = self.dict_entries(st.value.args[0], args)
                    continue
                if tgt in ("files", "extracted_files") and isinstance(st.value, ast.Call) and ast.unparse(st.value.func) == "extract_files":
                    multipart = True
                    continue
                raise Unsupported(f"assign {tgt} = {ast.unparse(st.value)[:60]}")
            if isinstance(st, ast.Return):
                v = st.value
                if isinstance(v, ast.Call) and ast.unparse(v.func) == "cast" and len(v.args) == 2:
                    v = v.args[1]
                if isinstance(v, ast.Await):
                    v = v.value
                if isinstance(v, ast.Call) and isinstance(v.func, ast.Attribute) and isinstance(v.func.value, ast.Name) and v.func.value.id == "self" and v.func.attr in ("_get", "_post", "_patch", "_put", "_delete", "_get_api_list"):
                    call = v
                    continue
                raise Unsupported(f"return {ast.unparse(v)[:60]}")
            raise Unsupported(f"statement {type(st).__name__}: {ast.unparse(st)[:60]}")
        if call is None:
            raise Unsupported("no request call")

        http = call.func.attr.lstrip("_")
        kws = {k.arg: k.value for k in call.keywords}
        if http == "get_api_list":
            http = ast.unparse(kws["method"]).strip("'\"") if "method" in kws else "get"
            result_kind = "page"
        else:
            result_kind = "json"
        path_swift, route = self.path_expr(call.args[0], args)
        if "body" in kws:
            bv = kws["body"]
            if isinstance(bv, ast.Name) and bv.id == "body":
                pass
            elif isinstance(bv, ast.Name) and bv.id in args:
                # the whole body is one params object (`body=target`)
                body_entries = [("", args[bv.id].swift, "whole")]
            else:
                body_entries = self.dict_entries(bv, args)
        if "files" in kws:
            multipart = True
        span_name = span_route = None
        qualifiers = None
        opts = kws.get("options")
        if isinstance(opts, ast.Call):
            for k in opts.keywords:
                if k.arg == "query":
                    query_entries = [(key, expr) for key, expr, _ in self.dict_entries(k.value, args)]
                elif k.arg == "span_name" and isinstance(k.value, ast.Constant):
                    span_name = k.value.value
                elif k.arg == "span_route" and isinstance(k.value, ast.Constant):
                    span_route = k.value.value
                elif k.arg == "qualifiers":
                    qualifiers = ast.literal_eval(k.value)
                elif k.arg == "post_parser":
                    raise Unsupported("post_parser")
        stream_flag = kws.get("stream")
        streaming_variant = False
        stream_only = False
        if result_kind == "page":
            page = kws["page"]
            page_cls = ast.unparse(page.value).replace("Async", "")
            item = self.swift_ref_type(kws["model"], mod)
            item_ir = getattr(self, "last_ir", None)
            result_type = f"{page_cls}<{item}>"
        else:
            cast = kws.get("cast_to")
            cast_txt = ast.unparse(cast) if cast is not None else "NoneType"
            if "BinaryAPIResponse" in cast_txt:
                result_kind = "binary"
                result_type = "BinaryResponse"
            elif "JSONLDecoder" in cast_txt:
                result_kind = "jsonl"
                result_type = self.swift_ref_type(cast.slice, mod)
            else:
                self.last_ir = None
                result_type = self.swift_ref_type(cast, mod)
            result_ir = getattr(self, "last_ir", None)
            if stream_flag is not None:
                st_txt = ast.unparse(stream_flag)
                elem = self.swift_ref_type(kws["stream_cls"].slice, mod)
                stream_ir = self.last_ir
                if st_txt == "True":
                    stream_only = True
                    result_kind = "stream"
                    result_type = elem
                elif st_txt == "stream or False":
                    streaming_variant = True
                    self._stream_elem = elem
                else:
                    raise Unsupported(f"stream={st_txt}")
        if "stream" in args and streaming_variant:
            order = [x for x in order if x.py != "stream"]
            body_entries = [(k, e, kind) for k, e, kind in body_entries if k != "stream"]
        plan = MethodPlan(
            name=fn.name, swift_name=escape_ident(camel(fn.name)), doc=ast.get_docstring(fn), args=order, pre=[p for p in pre if p],
            method=http, path_expr=path_swift, body_entries=body_entries, query_entries=query_entries,
            header_expr=header_expr, result_kind=result_kind, result_type=result_type, span_name=span_name,
            span_route=span_route, multipart=multipart, streaming_variant=streaming_variant, stream_only=stream_only,
            nonstreaming_timeout=nonstreaming_timeout, qualifiers=qualifiers,
        )
        if streaming_variant:
            plan.stream_elem = self._stream_elem  # type: ignore[attr-defined]
        plan.result_ir = locals().get("result_ir")  # type: ignore[attr-defined]
        plan.item_ir = locals().get("item_ir")  # type: ignore[attr-defined]
        plan.stream_ir = locals().get("stream_ir")  # type: ignore[attr-defined]
        if plan.stream_only:
            plan.result_ir = plan.stream_ir  # type: ignore[attr-defined]
        return plan

    @staticmethod
    def substitute(layers: list[str], previous: str) -> str:
        out = []
        for l in layers:
            out.append(l.replace("extraHeaders", "__prev__"))
        if not out:
            return previous
        expr = out[0] if len(out) == 1 else f"mergeHeaderLayers({', '.join(out)})"
        return expr.replace("__prev__", previous)

    # ------------------------------------------------------------------- emit

    def signature(self, plan: MethodPlan, extra: str = "") -> str:
        parts = []
        for a in plan.args:
            label = f"_ {a.swift}" if a.positional else a.swift
            parts.append(f"{label}: {a.type}" + (f" = {a.default}" if a.default else ""))
        parts += ["extraHeaders: Headers? = nil", "extraQuery: Query? = nil", "extraBody: Body? = nil", "timeout: Timeout? = nil"]
        if extra:
            parts.append(extra)
        return ", ".join(parts)

    def forward(self, plan: MethodPlan) -> str:
        parts = [a.swift if a.positional else f"{bare(a.swift)}: {a.swift}" for a in plan.args]
        parts += ["extraHeaders: extraHeaders", "extraQuery: extraQuery", "extraBody: extraBody", "timeout: timeout"]
        return ", ".join(parts)

    def impl_body(self, plan: MethodPlan, streaming: bool) -> str:
        lines = list(plan.pre)
        if plan.nonstreaming_timeout and not streaming:
            lines.append("var timeout = timeout")
            lines.append(plan.nonstreaming_timeout)
        if plan.body_entries or streaming:
            lines.append("var body = ParamsBuilder()")
            for key, expr, kind in plan.body_entries:
                if kind == "whole":
                    lines.append(f"try body.merge({expr})")
                elif kind == "file":
                    lines.append(f"body.setFile({swift_string(key)}, {expr})")
                elif kind == "files":
                    lines.append(f"body.setFiles({swift_string(key)}, {expr})")
                else:
                    lines.append(f"try body.set({swift_string(key)}, {expr})")
            if streaming:
                lines.append('body.put("stream", true)')
        if plan.query_entries:
            lines.append("var query = ParamsBuilder()")
            for key, expr in plan.query_entries:
                lines.append(f"try query.set({swift_string(key)}, {expr})")
        headers = plan.header_expr
        if plan.multipart:
            headers = f'mergeHeaderLayers(["Content-Type": "multipart/form-data"], {headers})'
        opts = [f"method: {swift_string(plan.method)}", f"url: {plan.path_expr}"]
        if plan.body_entries or streaming:
            opts.append("body: body")
        if plan.query_entries:
            opts.append("query: query")
        opts += [f"headers: {headers}", "extraQuery: extraQuery", "extraBody: extraBody", "timeout: timeout", "mode: _mode"]
        if plan.span_name:
            opts.append(f"spanName: {swift_string(plan.span_name)}")
        if plan.qualifiers:
            entries = ", ".join(f"{swift_string(k)}: {swift_string(v)}" for k, v in sorted(plan.qualifiers.items()))
            opts.append(f"qualifiers: [{entries}]")
        lines.append(f"let options = try client.makeRequestOptions({', '.join(opts)})")
        kind = "stream" if streaming or plan.stream_only else plan.result_kind
        if kind == "json":
            lines.append(f"return try await client.requestResponse({plan.result_type}.self, options, stream: _mode == .stream)")
        elif kind == "page":
            lines.append(f"return try await client.requestPageResponse({plan.result_type}.self, options, stream: _mode == .stream)")
        elif kind == "stream":
            elem = plan.stream_elem if streaming else plan.result_type  # type: ignore[attr-defined]
            lines.append(f"return try await client.requestStreamResponse({elem}.self, options)")
        elif kind == "binary":
            lines.append("return try await client.requestBinaryResponse(options, stream: _mode == .stream)")
        elif kind == "jsonl":
            lines.append(f"return try await client.requestJSONLResponse({plan.result_type}.self, options)")
        return "\n".join(lines)

    def return_type(self, plan: MethodPlan, streaming: bool) -> str:
        if streaming:
            return f"Stream<{plan.stream_elem}>"  # type: ignore[attr-defined]
        if plan.stream_only:
            return f"Stream<{plan.result_type}>"
        if plan.result_kind == "jsonl":
            return f"JSONLDecoder<{plan.result_type}>"
        return plan.result_type

    def emit_method(self, plan: MethodPlan) -> tuple[str, str, str]:
        """(main struct source, raw-response wrapper source, streaming-response wrapper source)."""
        variants = [(plan.swift_name, False)]
        if plan.streaming_variant:
            variants.append((escape_ident(bare(plan.swift_name) + "Streaming"), True))
        main = raw = strm = ""
        for name, streaming in variants:
            rt = self.return_type(plan, streaming)
            impl = f"_{bare(name)}"
            sig = self.signature(plan)
            doc = doc_comment(plan.doc, "    ")
            main += f"\n{doc}    public func {name}({sig}) async throws -> {rt} {{\n"
            main += f"        try await {impl}({self.forward(plan)}, _mode: .parsed).parse()\n    }}\n"
            main += f"\n    func {impl}({self.signature(plan, '_mode: ResponseMode')}) async throws -> APIResponse<{rt}> {{\n"
            main += indent_src(self.impl_body(plan, streaming), "        ") + "\n    }\n"
            raw += f"\n{doc}        public func {name}({sig}) async throws -> APIResponse<{rt}> {{\n"
            raw += f"            try await resource.{impl}({self.forward(plan)}, _mode: .raw)\n        }}\n"
            strm += f"\n{doc}        public func {name}<R: Sendable>({self.signature(plan, 'body: (APIResponse<' + rt + '>) async throws -> R')}) async throws -> R {{\n"
            strm += f"            let response = try await resource.{impl}({self.forward(plan)}, _mode: .stream)\n"
            strm += "            defer { response.close() }\n            return try await body(response)\n        }\n"
        return main, raw, strm

    # -------------------------------------------------------------- resources

    def emit_class(self, mod: Module, cls: ast.ClassDef) -> str:
        name = resource_swift_name(mod.name, cls.name)
        scope = Scope(name)
        subs: list[tuple[str, str, Optional[str]]] = []
        reg = self.registry.setdefault(name, {"subs": {}, "methods": {}, "module": mod.name})
        mains, raws, strms = [], [], []
        for m in cls.body:
            if not isinstance(m, (ast.FunctionDef, ast.AsyncFunctionDef)):
                continue
            decos = [ast.unparse(d) for d in m.decorator_list]
            if "overload" in decos or m.name.startswith("_"):
                continue
            if "cached_property" in decos:
                if m.name in ("with_raw_response", "with_streaming_response"):
                    continue
                ret = m.returns
                target = self.ms.resolve_expr(mod.name, ret) if ret is not None else None
                if isinstance(target, ClassDecl):
                    subs.append((m.name, resource_swift_name(target.module, target.name), ast.get_docstring(m)))
                else:
                    self.unsupported.append(f"{mod.name}.{cls.name}.{m.name}: sub-resource")
                continue
            try:
                plan = self.plan_method(mod, name, m, scope)
            except (Unsupported, ConvertError, KeyError) as e:
                self.unsupported.append(f"{mod.name}.{cls.name}.{m.name}: {e}")
                continue
            plan.resource = name  # type: ignore[attr-defined]
            plan.module = mod  # type: ignore[attr-defined]
            reg["methods"][m.name] = plan
            a, b, c = self.emit_method(plan)
            mains.append(a)
            raws.append(b)
            strms.append(c)
        out = doc_comment(ast.get_docstring(cls), "")
        out += f"public struct {name}: Sendable {{\n    public let client: BaseClient\n\n    public init(client: BaseClient) {{ self.client = client }}\n\n"
        out += "    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.\n"
        out += "    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }\n\n"
        out += "    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.\n"
        out += "    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }\n"
        for py, swift_t, doc in subs:
            reg["subs"][py] = swift_t
            out += "\n" + doc_comment(doc, "    ") + f"    public var {escape_ident(camel(py))}: {swift_t} {{ {swift_t}(client: client) }}\n"
        out += "".join(mains)
        out += "\n    public struct WithRawResponse: Sendable {\n        let resource: " + name + "\n"
        for py, swift_t, _ in subs:
            out += f"\n        public var {escape_ident(camel(py))}: {swift_t}.WithRawResponse {{ resource.{escape_ident(camel(py))}.withRawResponse }}\n"
        out += "".join(raws) + "    }\n"
        out += "\n    public struct WithStreamingResponse: Sendable {\n        let resource: " + name + "\n"
        for py, swift_t, _ in subs:
            out += f"\n        public var {escape_ident(camel(py))}: {swift_t}.WithStreamingResponse {{ resource.{escape_ident(camel(py))}.withStreamingResponse }}\n"
        out += "".join(strms) + "    }\n"
        for nname, nsrc in scope.nested:
            out += "\n" + indent_src(nsrc, "    ")
        out += "}\n"
        return out

    def emit_module(self, mod: Module) -> str:
        classes = [c for c in mod.tree.body if isinstance(c, ast.ClassDef) and c.name.startswith("Async") and not c.name.endswith("Response")]
        if not classes:
            return ""
        out = f"// Transformed from `{mod.name}` ({mod.path.name}).\n\nimport Foundation\n"
        for c in classes:
            out += "\n" + self.emit_class(mod, c)
        return out

    def emit_client_accessors(self) -> str:
        client = self.ms.ensure_module("anthropic._client")
        out = "// Transformed from `anthropic._client` (the AsyncAnthropic resource accessors).\n\nimport Foundation\n\nextension Anthropic {\n"
        raw = "\n    public struct WithRawResponse: Sendable {\n        let client: Anthropic\n"
        strm = "\n    public struct WithStreamingResponse: Sendable {\n        let client: Anthropic\n"
        for c in client.tree.body:
            if isinstance(c, ast.ClassDef) and c.name == "AsyncAnthropic":
                for m in c.body:
                    if isinstance(m, ast.FunctionDef) and any(ast.unparse(d) == "cached_property" for d in m.decorator_list):
                        if m.name in ("with_raw_response", "with_streaming_response"):
                            continue
                        # the import is local to the method body
                        target = None
                        for st in m.body:
                            if isinstance(st, ast.ImportFrom):
                                src = self.ms._resolve_relative(client, st.level, st.module)
                                target = self.ms.resolve(src, st.names[0].name)
                        if not isinstance(target, ClassDecl):
                            continue
                        t = resource_swift_name(target.module, target.name)
                        self.client_accessors[m.name] = t
                        p = escape_ident(camel(m.name))
                        out += f"    public var {p}: {t} {{ {t}(client: self) }}\n"
                        raw += f"        public var {p}: {t}.WithRawResponse {{ {t}(client: client).withRawResponse }}\n"
                        strm += f"        public var {p}: {t}.WithStreamingResponse {{ {t}(client: client).withStreamingResponse }}\n"
        out += "\n    public var withRawResponse: WithRawResponse { WithRawResponse(client: self) }\n"
        out += "    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(client: self) }\n"
        out += raw + "    }\n" + strm + "    }\n}\n"
        return out


def gen_resources(ctx, out_dir: pathlib.Path) -> list[str]:
    import shutil

    if out_dir.exists():
        shutil.rmtree(out_dir)
    out_dir.mkdir(parents=True)
    ctx.ms.load_tree("resources")
    # Types must have been rendered so params lookups work.
    if not any(getattr(d, "_base_types", None) for m in ctx.type_modules for d in m.decls.values()):
        for m in ctx.type_modules:
            if not m.is_package:
                try:
                    ctx.emitter.render_module(m)
                except ConvertError:
                    pass
    gen = ResourceGen(ctx)
    count = 0
    for name, mod in sorted(ctx.ms.modules.items()):
        if not name.startswith("anthropic.resources") or mod.is_package:
            continue
        src = gen.emit_module(mod)
        if src:
            (out_dir / (".".join(name.split(".")[2:]) + ".swift")).write_text(src)
            count += 1
    (out_dir / "_client.swift").write_text(gen.emit_client_accessors())
    report = out_dir.parent.parent.parent.parent / "docs" / "porting" / "UNSUPPORTED_METHODS.txt"
    report.write_text("Methods not handled by the transpiler (ported by hand in Sources/Anthropic/Lib):\n\n" + "\n".join(gen.unsupported) + "\n")
    print(f"resources: wrote {count} files, {len(gen.unsupported)} methods need hand-porting (see {report.name})")
    ctx.resource_gen = gen
    return []
