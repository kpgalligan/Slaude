"""Transforms the declarations in `anthropic/types` into Swift types.

Python                                   Swift
------                                   -----
class X(BaseModel)                       struct X: Codable, Hashable, Sendable
class X(TypedDict)                       struct X: Codable, Hashable, Sendable (params)
X: TypeAlias = Literal["a", "b"]         enum X: OpenEnum (with `unknown(String)`)
X: TypeAlias = Union[A, B]               indirect enum X (with `unknown(JSONValue)`)
X: TypeAlias = Annotated[Union[..], UnionDiscriminator("type")]
                                         indirect enum X, decoded by its discriminator
X = Y                                    typealias X = Y
str/int/float/bool/object                String/Int/Double/Bool/JSONValue
datetime / date                          Date / ISODate
List[T] / Iterable[T] / Sequence[T]      [T]
Dict[str, T]                             [String: T]
Optional[T]                              T?  (T?? for nullable, not-required params)
"""

from __future__ import annotations

import ast
import re
from dataclasses import dataclass, field
from typing import Optional, Union

from pymodules import AliasDecl, ClassDecl, Decl, Module, ModuleSet
from swiftnames import (
    RESERVED_TOP_LEVEL,
    bare,
    camel,
    doc_comment,
    escape_ident,
    literal_case_name,
    lower_first,
    pascal,
    property_name,
    swift_string,
    type_name,
)

# ---------------------------------------------------------------------------------------------
# IR


@dataclass(frozen=True)
class Prim:
    kind: str  # str int float bool datetime date object none bytes file b64file


@dataclass(frozen=True)
class Ref:
    decl: object  # Decl (dataclass, hashed by id)

    def __hash__(self) -> int:
        return id(self.decl)

    def __eq__(self, other: object) -> bool:
        return isinstance(other, Ref) and other.decl is self.decl


@dataclass(frozen=True)
class ListT:
    item: object


@dataclass(frozen=True)
class DictT:
    value: object


@dataclass(frozen=True)
class LiteralT:
    values: tuple


@dataclass(frozen=True)
class UnionT:
    members: tuple
    discriminator: Optional[str] = None


@dataclass(frozen=True)
class NullableT:
    inner: object


IR = Union[Prim, Ref, ListT, DictT, LiteralT, UnionT, NullableT]

STR = Prim("str")
NONE = Prim("none")
OMIT = Prim("omit")
OBJECT = Prim("object")

PRIM_NAMES = {
    "str": "str", "int": "int", "float": "float", "bool": "bool", "object": "object", "bytes": "bytes",
    "Any": "object", "datetime": "datetime", "date": "date", "datetime.datetime": "datetime",
    "datetime.date": "date", "FileTypes": "file", "Base64FileInput": "b64file", "FileContent": "file",
}

# Hand-written helper types in `lib/` whose wire shape is a generated params type.
LIB_TYPE_PARAMS = {"BetaToolLike": "BetaToolUnionParam", "ToolLike": "ToolUnionParam"}

LIST_HEADS = {"List", "list", "Iterable", "SequenceNotStr", "Sequence", "Tuple", "tuple", "Set", "set"}
DICT_HEADS = {"Dict", "dict", "Mapping"}


@dataclass
class Field:
    py_name: str
    json_key: str
    ir: object
    required: bool
    nullable: bool
    doc: Optional[str]
    default: Optional[str] = None  # a Swift literal for constant fields


class ConvertError(Exception):
    pass


class TypeConverter:
    """Converts annotation ASTs into IR, resolving names through the module set."""

    def __init__(self, ms: ModuleSet) -> None:
        self.ms = ms

    def conv(self, node: ast.expr, module: str) -> object:
        if isinstance(node, ast.Constant):
            if node.value is None:
                return NONE
            if isinstance(node.value, str):
                return self.conv(ast.parse(node.value, mode="eval").body, module)
            raise ConvertError(f"constant annotation {node.value!r}")
        if isinstance(node, ast.BinOp) and isinstance(node.op, ast.BitOr):
            return self.union([self.conv(node.left, module), self.conv(node.right, module)])
        if isinstance(node, (ast.Name, ast.Attribute)):
            text = ast.unparse(node)
            target = self.ms.resolve_expr(module, node)
            if isinstance(target, (ClassDecl, AliasDecl)) and not target.module.startswith("anthropic.types"):
                if target.name in ("Omit", "NotGiven"):
                    return OMIT
                if target.name in PRIM_NAMES:
                    return Prim(PRIM_NAMES[target.name])
                if target.name in LIB_TYPE_PARAMS:
                    return Ref(self.ms.resolve("anthropic.types.beta" if target.name.startswith("Beta") else "anthropic.types", LIB_TYPE_PARAMS[target.name]))
                raise ConvertError(f"unsupported runtime type {target.module}.{target.name}")
            if isinstance(target, (ClassDecl, AliasDecl)):
                if isinstance(target, ClassDecl) and target.generic:
                    return OBJECT
                return Ref(target)
            leaf = text.split(".")[-1]
            if text in PRIM_NAMES:
                return Prim(PRIM_NAMES[text])
            if isinstance(target, tuple):
                src, nm = target
                key = f"{nm}"
                if key in PRIM_NAMES:
                    if nm == "date" and src.endswith("datetime"):
                        return Prim("date")
                    return Prim(PRIM_NAMES[key])
            if leaf in PRIM_NAMES:
                return Prim(PRIM_NAMES[leaf])
            raise ConvertError(f"unresolved name {text} in {module}")
        if isinstance(node, ast.Subscript):
            head = ast.unparse(node.value).split(".")[-1]
            args = list(node.slice.elts) if isinstance(node.slice, ast.Tuple) else [node.slice]
            if head == "Optional":
                return self.union([self.conv(args[0], module), NONE])
            if head == "Union":
                return self.union([self.conv(a, module) for a in args])
            if head in LIST_HEADS:
                return ListT(self.conv(args[0], module))
            if head in DICT_HEADS:
                return DictT(self.conv(args[-1], module))
            if head == "Literal":
                vals = []
                for a in args:
                    if isinstance(a, ast.Constant):
                        vals.append(a.value)
                    else:
                        # Literal[OtherLiteralAlias]
                        inner = self.conv(a, module)
                        inner = self.deref_literal(inner)
                        vals.extend(inner.values)
                return LiteralT(tuple(vals))
            if head in ("Required", "NotRequired", "ReadOnly"):
                return self.conv(args[0], module)
            if head == "Annotated":
                inner = self.conv(args[0], module)
                disc = None
                for meta in args[1:]:
                    if isinstance(meta, ast.Call):
                        fname = ast.unparse(meta.func).split(".")[-1]
                        if fname == "UnionDiscriminator" and meta.args:
                            disc = meta.args[0].value
                        for kw in meta.keywords:
                            if kw.arg == "discriminator":
                                disc = kw.value.value
                if disc and isinstance(inner, UnionT):
                    return UnionT(inner.members, disc)
                return inner
            if head in ("Type", "type"):
                return OBJECT
            target = self.ms.resolve_expr(module, node.value)
            if isinstance(target, ClassDecl) and target.generic:
                return OBJECT
            raise ConvertError(f"unknown subscript head {head}")
        raise ConvertError(f"unsupported annotation {ast.unparse(node)}")

    def deref_literal(self, ir: object) -> LiteralT:
        if isinstance(ir, LiteralT):
            return ir
        if isinstance(ir, Ref) and isinstance(ir.decl, AliasDecl):
            return self.deref_literal(self.alias_ir(ir.decl))
        raise ConvertError(f"not a literal: {ir}")

    def union(self, members: list) -> object:
        flat: list = []
        for m in members:
            if isinstance(m, UnionT) and m.discriminator is None:
                flat.extend(m.members)
            else:
                flat.append(m)
        nullable = any(m == NONE for m in flat)
        rest = [m for m in flat if m != NONE and m != OMIT]
        # Merge literals; Union[Literal[...], str] is an open enum.
        lits = [m for m in rest if isinstance(m, LiteralT) and all(isinstance(v, str) for v in m.values)]
        if lits:
            others = [m for m in rest if m not in lits]
            if all(o == STR for o in others):
                vals: list = []
                for l in lits:
                    for v in l.values:
                        if v not in vals:
                            vals.append(v)
                rest = [LiteralT(tuple(vals))]
        dedup: list = []
        for m in rest:
            if m not in dedup:
                dedup.append(m)
        result = dedup[0] if len(dedup) == 1 else UnionT(tuple(dedup))
        return NullableT(result) if nullable else result

    def alias_ir(self, decl: AliasDecl) -> object:
        cached = getattr(decl, "_ir", None)
        if cached is not None:
            return cached
        ir = self.conv(decl.value, decl.module)
        decl._ir = ir  # type: ignore[attr-defined]
        return ir

    # ------------------------------------------------------------------ fields

    def fields(self, decl: ClassDecl) -> list[Field]:
        cached = getattr(decl, "_fields", None)
        if cached is not None:
            return cached
        out: list[Field] = []
        # base classes first
        for b in decl.bases:
            target = self.ms.resolve_expr(decl.module, b)
            if isinstance(target, ClassDecl) and not target.generic:
                for f in self.fields(target):
                    out = [x for x in out if x.py_name != f.py_name] + [f]
        body = decl.node.body
        for i, st in enumerate(body):
            if not isinstance(st, ast.AnnAssign) or not isinstance(st.target, ast.Name):
                continue
            name = st.target.id
            ann_text = ast.unparse(st.annotation)
            if ann_text.startswith("ClassVar"):
                continue
            doc = None
            if i + 1 < len(body):
                nx = body[i + 1]
                if isinstance(nx, ast.Expr) and isinstance(nx.value, ast.Constant) and isinstance(nx.value.value, str):
                    doc = nx.value.value
            json_key = name
            has_default = st.value is not None
            if isinstance(st.value, ast.Call):
                for kw in st.value.keywords:
                    if kw.arg == "alias" and isinstance(kw.value, ast.Constant):
                        json_key = kw.value.value
            # Annotated[..., PropertyInfo(alias=...)]
            for sub in ast.walk(st.annotation):
                if isinstance(sub, ast.Call) and ast.unparse(sub.func).endswith("PropertyInfo"):
                    for kw in sub.keywords:
                        if kw.arg == "alias":
                            json_key = kw.value.value
            ir = self.conv(st.annotation, decl.module)
            nullable = isinstance(ir, NullableT)
            if nullable:
                ir = ir.inner
            if decl.is_typeddict:
                if "NotRequired[" in ann_text:
                    required = False
                elif "Required[" in ann_text:
                    required = True
                else:
                    required = decl.total
            else:
                required = not has_default
            out = [x for x in out if x.py_name != name]
            out.append(Field(name, json_key, ir, required, nullable, doc))
        decl._fields = out  # type: ignore[attr-defined]
        return out


# ---------------------------------------------------------------------------------------------
# Naming of declarations


def module_primary(mod: Module) -> Optional[str]:
    stem = mod.name.split(".")[-1]
    expected = stem.replace("_", "").lower()
    for n in mod.all:
        if n.lower() == expected and n in mod.decls:
            return n
    for n in mod.all:
        if n in mod.decls:
            return n
    for n in mod.order:
        return n
    return None


@dataclass
class Placement:
    """Where a declaration lives in Swift: a top-level name, or nested in a parent."""

    swift_name: str  # fully qualified (Parent.Child)
    parent: Optional[object] = None  # parent Decl, if nested


class Namer:
    def __init__(self, ms: ModuleSet, type_modules: list[Module]) -> None:
        self.ms = ms
        self.mods = type_modules
        self.primary: dict[str, str] = {}
        self.placements: dict[int, Placement] = {}

    def assign(self) -> None:
        top: dict[str, list[tuple[Module, Decl]]] = {}
        for mod in self.mods:
            if mod.is_package:
                continue
            p = module_primary(mod)
            if p is None:
                continue
            self.primary[mod.name] = p
            top.setdefault(p, []).append((mod, mod.decls[p]))
        # Resolve collisions: the shallowest module keeps the name.
        final: dict[str, Decl] = {}
        for name, entries in top.items():
            entries.sort(key=lambda e: (e[0].name.count("."), e[0].name))
            for idx, (mod, decl) in enumerate(entries):
                swift = name
                if idx > 0 or name in RESERVED_TOP_LEVEL:
                    pkg_parts = mod.name.split(".")[2:-1]  # after anthropic.types
                    prefix = "".join(pascal(p) for p in pkg_parts)
                    swift = prefix + name if not name.startswith(prefix) or not prefix else name
                    n = 2
                    while swift in final or swift in RESERVED_TOP_LEVEL:
                        swift = f"{prefix}{name}{n}" if prefix else f"{name}{n}"
                        n += 1
                final[swift] = decl
                decl.swift_name = swift
                self.placements[id(decl)] = Placement(swift)
        # Nested helpers.
        for mod in self.mods:
            if mod.is_package or mod.name not in self.primary:
                continue
            pdecl = mod.decls[self.primary[mod.name]]
            parent_name = pdecl.swift_name
            nestable = self.is_nominal(pdecl)
            used: set[str] = set()
            for n in mod.order:
                d = mod.decls[n]
                if d is pdecl:
                    continue
                child = type_name(n)
                if nestable:
                    while child in used:
                        child += "_"
                    used.add(child)
                    d.swift_name = f"{parent_name}.{child}"
                    self.placements[id(d)] = Placement(d.swift_name, pdecl)
                else:
                    d.swift_name = f"{parent_name}{child}"
                    self.placements[id(d)] = Placement(d.swift_name)

    def is_nominal(self, decl: Decl) -> bool:
        """Whether the decl becomes a Swift struct/enum (and so can hold nested types)."""
        if isinstance(decl, ClassDecl):
            return not decl.generic
        if decl.is_rename:
            return False
        return getattr(decl, "_kind", None) in ("enum", "union")


# ---------------------------------------------------------------------------------------------
# Swift emission


class Scope:
    """Collects the anonymous nested types created while rendering one declaration."""

    def __init__(self, owner_swift: str) -> None:
        self.owner = owner_swift
        self.nested: list[tuple[str, str]] = []  # (name, swift source)
        self.names: set[str] = set()

    def reserve(self, hint: str) -> str:
        name = type_name(hint)
        while name in self.names:
            name += "_"
        self.names.add(name)
        return name


class SwiftEmitter:
    def __init__(self, conv: TypeConverter, namer: Namer) -> None:
        self.conv = conv
        self.namer = namer
        self.warnings: list[str] = []

    # ------------------------------------------------------------- type kinds

    def alias_kind(self, decl: AliasDecl) -> str:
        if decl.is_rename:
            return "rename"
        ir = self.conv.alias_ir(decl)
        if isinstance(ir, NullableT) and isinstance(ir.inner, (LiteralT, UnionT)):
            decl._nullable = True  # type: ignore[attr-defined]
            ir = ir.inner
        if isinstance(ir, LiteralT) and all(isinstance(v, str) for v in ir.values) and len(ir.values) > 0:
            return "enum"
        if isinstance(ir, UnionT):
            return "union"
        return "typealias"

    def ref_name(self, decl: Decl) -> str:
        if not decl.swift_name:
            raise ConvertError(f"decl without a Swift name: {decl.module}.{decl.name}")
        return decl.swift_name

    # ---------------------------------------------------------------- render

    def swift_type(self, ir: object, scope: Optional[Scope], hint: str) -> str:
        """The Swift spelling of an IR type, creating nested types in `scope` as needed."""
        if isinstance(ir, NullableT):
            return self.swift_type(ir.inner, scope, hint) + "?"
        if isinstance(ir, Prim):
            return {
                "str": "String", "int": "Int", "float": "Double", "bool": "Bool", "datetime": "Date",
                "date": "ISODate", "object": "JSONValue", "none": "JSONValue", "bytes": "Data",
                "file": "FileUpload", "b64file": "Base64FileInput",
            }[ir.kind]
        if isinstance(ir, Ref):
            d = ir.decl
            if isinstance(d, AliasDecl):
                kind = self.alias_kind(d)
                if kind == "typealias":
                    inner = self.conv.alias_ir(d)
                    if isinstance(inner, LiteralT):  # single non-string literal
                        return self.swift_type(inner, scope, hint)
                if getattr(d, "_nullable", False):
                    return self.ref_name(d) + "?"
            return self.ref_name(d)
        if isinstance(ir, ListT):
            return f"[{self.swift_type(ir.item, scope, hint)}]"
        if isinstance(ir, DictT):
            return f"[String: {self.swift_type(ir.value, scope, hint)}]"
        if isinstance(ir, LiteralT):
            if len(ir.values) == 1 or not all(isinstance(v, str) for v in ir.values):
                v = ir.values[0]
                return "Bool" if isinstance(v, bool) else "Int" if isinstance(v, int) else "Double" if isinstance(v, float) else "String"
            if scope is None:
                raise ConvertError("inline enum without scope")
            name = scope.reserve(pascal(hint))
            scope.nested.append((name, self.render_enum(name, ir.values, None, "")))
            return name
        if isinstance(ir, UnionT):
            if scope is None:
                raise ConvertError("inline union without scope")
            name = scope.reserve(pascal(hint))
            sub = Scope(f"{scope.owner}.{name}")
            src = self.render_union(name, ir, None, "", sub)
            scope.nested.append((name, src))
            return name
        raise ConvertError(f"cannot render {ir}")

    def constant_default(self, ir: object) -> Optional[str]:
        if isinstance(ir, LiteralT) and len(ir.values) == 1:
            v = ir.values[0]
            if isinstance(v, bool):
                return "true" if v else "false"
            if isinstance(v, (int, float)):
                return repr(v)
            return swift_string(str(v))
        return None

    # ------------------------------------------------------------------ enum

    def render_enum(self, name: str, values: tuple, doc: Optional[str], indent: str) -> str:
        cases: list[tuple[str, str]] = []
        seen: set[str] = set()
        for v in values:
            c = literal_case_name(v)
            base = bare(c)
            while base in seen or base == "unknown":
                base += "_"
            seen.add(base)
            cases.append((escape_ident(base) if base == bare(c) else base, str(v)))
        i = indent
        out = doc_comment(doc, i)
        out += f"{i}public enum {name}: OpenEnum, CaseIterable {{\n"
        for c, v in cases:
            out += f"{i}    case {c}\n"
        out += f"{i}    /// A value this version of the SDK doesn't know about.\n"
        out += f"{i}    case unknown(String)\n\n"
        out += f"{i}    public static let allCases: [{name}] = [{', '.join('.' + c for c, _ in cases)}]\n\n"
        out += f"{i}    public init(rawValue: String) {{\n{i}        switch rawValue {{\n"
        for c, v in cases:
            out += f"{i}        case {swift_string(v)}: self = .{c}\n"
        out += f"{i}        default: self = .unknown(rawValue)\n{i}        }}\n{i}    }}\n\n"
        out += f"{i}    public var rawValue: String {{\n{i}        switch self {{\n"
        for c, v in cases:
            out += f"{i}        case .{c}: return {swift_string(v)}\n"
        out += f"{i}        case .unknown(let value): return value\n{i}        }}\n{i}    }}\n"
        out += f"{i}}}\n"
        return out

    # ----------------------------------------------------------------- union

    def member_discriminator_value(self, member: object, key: str) -> Optional[str]:
        if isinstance(member, Ref) and isinstance(member.decl, ClassDecl) and not member.decl.generic:
            for f in self.conv.fields(member.decl):
                if f.json_key == key and isinstance(f.ir, LiteralT) and len(f.ir.values) == 1 and isinstance(f.ir.values[0], str):
                    return f.ir.values[0]
        if isinstance(member, Ref) and isinstance(member.decl, AliasDecl) and member.decl.is_rename:
            target = self.conv.ms.resolve_expr(member.decl.module, member.decl.value)
            if isinstance(target, (ClassDecl, AliasDecl)):
                return self.member_discriminator_value(Ref(target), key)
        return None

    def constant_keys(self, member: object) -> set:
        """JSON keys of the single-value `Literal` (constant) fields of a model/params variant."""
        out = set()
        target = member
        if isinstance(target, Ref) and isinstance(target.decl, AliasDecl) and target.decl.is_rename:
            t = self.conv.ms.resolve_expr(target.decl.module, target.decl.value)
            if isinstance(t, (ClassDecl, AliasDecl)):
                target = Ref(t)
        if isinstance(target, Ref) and isinstance(target.decl, ClassDecl) and not target.decl.generic:
            for f in self.conv.fields(target.decl):
                if isinstance(f.ir, LiteralT) and len(f.ir.values) == 1 and isinstance(f.ir.values[0], str):
                    out.add(f.json_key)
        return out

    def constants_of(self, member: object) -> dict:
        target = member
        if isinstance(target, Ref) and isinstance(target.decl, AliasDecl) and target.decl.is_rename:
            t = self.conv.ms.resolve_expr(target.decl.module, target.decl.value)
            if isinstance(t, (ClassDecl, AliasDecl)):
                target = Ref(t)
        out = {}
        if isinstance(target, Ref) and isinstance(target.decl, ClassDecl) and not target.decl.generic:
            for f in self.conv.fields(target.decl):
                if f.required and isinstance(f.ir, LiteralT) and len(f.ir.values) == 1 and isinstance(f.ir.values[0], str):
                    out[f.json_key] = f.ir.values[0]
        return out

    def member_case_name(self, member: object) -> str:
        if isinstance(member, Prim):
            return {"str": "string", "int": "int", "float": "double", "bool": "bool", "object": "json",
                    "datetime": "date", "date": "date", "b64file": "file", "file": "file", "bytes": "data"}.get(member.kind, member.kind)
        if isinstance(member, Ref):
            return lower_first(member.decl.swift_name.split(".")[-1])
        if isinstance(member, ListT):
            if isinstance(member.item, UnionT):
                return "items"
            inner = self.member_case_name(member.item)
            return inner + ("s" if not inner.endswith("s") else "List")
        if isinstance(member, DictT):
            return "dictionary"
        if isinstance(member, LiteralT):
            return literal_case_name(member.values[0]).strip("`") if len(member.values) == 1 else "literal"
        if isinstance(member, UnionT):
            return "union"
        return "value"

    def union_cases(self, ir: UnionT, scope: Optional[Scope]) -> tuple[Optional[str], list]:
        """The discriminator key (if any) and `(case, swift type, member IR, discriminator value)` per variant."""
        members = list(ir.members)
        disc = ir.discriminator
        auto_disc = None
        if disc is None and all(isinstance(m, Ref) for m in members):
            for cand in ["type"] + sorted(self.constant_keys(members[0]) - {"type"}):
                vals = [self.member_discriminator_value(m, cand) for m in members]
                if all(v is not None for v in vals) and len(set(vals)) == len(vals):
                    auto_disc = cand
                    break
        key = disc or auto_disc
        cases: list[tuple[str, str, object, Optional[str]]] = []  # (case, swift type, member, disc value)
        used: set[str] = {"unknown"}
        for idx, m in enumerate(members):
            dv = self.member_discriminator_value(m, key) if key else None
            cname = bare(literal_case_name(dv)) if dv is not None else self.member_case_name(m)
            while cname in used:
                cname += "_"
            used.add(cname)
            hint = "item" if cname == "items" else cname
            if scope is None:
                try:
                    stype = self.swift_type(m, None, "item" if cname == "items" else cname)
                except ConvertError:
                    stype = None
            else:
                stype = self.swift_type(m, scope, hint)
            cases.append((escape_ident(cname), stype, m, dv))
        return key, cases

    def render_union(self, name: str, ir: UnionT, doc: Optional[str], indent: str, scope: Scope) -> str:
        members = list(ir.members)
        key, cases = self.union_cases(ir, scope)
        i = indent
        out = doc_comment(doc, i)
        has_string = any(m == STR for m in members)
        arrays = [c for c in cases if isinstance(c[2], ListT)]
        conformances = ["Codable", "Hashable", "Sendable"]
        if has_string:
            conformances.append("ExpressibleByStringLiteral")
        if len(arrays) == 1:
            conformances.append("ExpressibleByArrayLiteral")
        out += f"{i}public indirect enum {name}: {', '.join(conformances)} {{\n"
        for c, t, _, _ in cases:
            out += f"{i}    case {c}({t})\n"
        out += f"{i}    /// A value that matched none of the known variants.\n{i}    case unknown(JSONValue)\n\n"
        if has_string:
            sc = [c for c, _, m, _ in cases if m == STR][0]
            out += f"{i}    public init(stringLiteral value: String) {{ self = .{bare(sc)}(value) }}\n\n"
        if len(arrays) == 1:
            ac, at, _, _ = arrays[0]
            elem = at[1:-1]
            out += f"{i}    public init(arrayLiteral elements: {elem}...) {{ self = .{bare(ac)}(elements) }}\n\n"
        # decoding
        out += f"{i}    public init(from decoder: Decoder) throws {{\n"
        if key and all(dv is not None for _, _, _, dv in cases):
            out += f"{i}        switch _Coding.discriminator(decoder, {swift_string(key)}) {{\n"
            for c, t, _, dv in cases:
                out += f"{i}        case {swift_string(dv)}: self = .{bare(c)}(try {t}(from: decoder))\n"
            out += f"{i}        default: self = .unknown(try _Coding.raw(decoder))\n{i}        }}\n"
        else:
            if key:
                # partial discriminators: use them first
                out += f"{i}        let tag = _Coding.discriminator(decoder, {swift_string(key)})\n"
                for c, t, _, dv in cases:
                    if dv is not None:
                        out += f"{i}        if tag == {swift_string(dv)} {{ self = .{bare(c)}(try {t}(from: decoder)); return }}\n"
            for c, t, m, dv in cases:
                if key and dv is not None:
                    continue
                consts = self.constants_of(m)
                if consts:
                    pairs = ", ".join(f"{swift_string(k)}: {swift_string(v)}" for k, v in sorted(consts.items()))
                    out += f"{i}        if _Coding.constantsMatch(decoder, [{pairs}]), let v = try? {t}(from: decoder) {{ self = .{bare(c)}(v); return }}\n"
                else:
                    out += f"{i}        if let v = try? {t}(from: decoder) {{ self = .{bare(c)}(v); return }}\n"
            out += f"{i}        self = .unknown(try _Coding.raw(decoder))\n"
        out += f"{i}    }}\n\n"
        out += f"{i}    public func encode(to encoder: Encoder) throws {{\n{i}        switch self {{\n"
        for c, _, _, _ in cases:
            out += f"{i}        case .{bare(c)}(let v): try v.encode(to: encoder)\n"
        out += f"{i}        case .unknown(let v): try v.encode(to: encoder)\n{i}        }}\n{i}    }}\n"
        for nname, nsrc in scope.nested:
            out += "\n" + indent_src(nsrc, i + "    ")
        out += f"{i}}}\n"
        return out

    # ---------------------------------------------------------------- struct

    def render_struct(self, decl: ClassDecl, indent: str, nested_named: list[str]) -> str:
        name = decl.swift_name.split(".")[-1]
        fields = self.conv.fields(decl)
        scope = Scope(decl.swift_name)
        for n in nested_named:
            scope.names.add(n)
        props: list[tuple[Field, str, str, Optional[str]]] = []  # field, swift name, swift type, default
        base_types: dict[str, str] = {}
        used_names: set[str] = set()
        for f in fields:
            pname = property_name(f.py_name)
            while bare(pname) in used_names:
                pname = escape_ident(bare(pname) + "_")
            used_names.add(bare(pname))
            base = self.swift_type(f.ir, scope, f.py_name)
            if base.endswith("?"):  # a nullable type alias
                base = base[:-1]
                f.nullable = True
            default = self.constant_default(f.ir) if f.required and not f.nullable else None
            if decl.is_typeddict:
                if f.required and not f.nullable:
                    t = base
                elif f.required and f.nullable:
                    t = base + "?"
                elif not f.required and not f.nullable:
                    t = base + "?"
                else:
                    t = base + "??"
            else:
                if f.required and not f.nullable:
                    t = base
                else:
                    t = base + "?"
            props.append((f, pname, t, default))
            base_types[f.py_name] = base
        i = indent
        out = doc_comment(decl.doc, i)
        out += f"{i}public struct {name}: Codable, Hashable, Sendable {{\n"
        for f, pname, t, default in props:
            out += doc_comment(f.doc, i + "    ")
            out += f"{i}    public var {pname}: {t}\n"
        # init
        params = []
        for f, pname, t, default in props:
            d = default
            if d is None and t.endswith("?"):
                d = "nil"
            params.append(f"{pname}: {t}" + (f" = {d}" if d is not None else ""))
        out += "\n" if props else ""
        out += f"{i}    public init({', '.join(params)}) {{\n"
        for f, pname, t, default in props:
            out += f"{i}        self.{bare(pname)} = {pname}\n"
        out += f"{i}    }}\n"
        if props:
            out += f"\n{i}    enum CodingKeys: String, CodingKey {{\n"
            for f, pname, t, default in props:
                if bare(pname) == f.json_key:
                    out += f"{i}        case {pname}\n"
                else:
                    out += f"{i}        case {pname} = {swift_string(f.json_key)}\n"
            out += f"{i}    }}\n"
        else:
            out += f"\n{i}    public init(from decoder: Decoder) throws {{}}\n{i}    public func encode(to encoder: Encoder) throws {{\n{i}        _ = encoder.container(keyedBy: AnyCodingKey.self)\n{i}    }}\n"
        if any(f.required and f.nullable for f, _, _, _ in props):
            out += f"\n{i}    public func encode(to encoder: Encoder) throws {{\n"
            out += f"{i}        var c = encoder.container(keyedBy: CodingKeys.self)\n"
            for f, pname, t, default in props:
                if f.required:
                    out += f"{i}        try c.encode({pname}, forKey: .{bare(pname)})\n"
                else:
                    out += f"{i}        try c.encodeIfPresent({pname}, forKey: .{bare(pname)})\n"
            out += f"{i}    }}\n"
        for nname, nsrc in scope.nested:
            out += "\n" + indent_src(nsrc, i + "    ")
        out += f"{i}}}\n"
        decl._props = props  # type: ignore[attr-defined]
        decl._base_types = base_types  # type: ignore[attr-defined]
        decl._nested_names = {n for n, _ in scope.nested}  # type: ignore[attr-defined]
        return out

    # ---------------------------------------------------------------- module

    def render_decl(self, decl: Decl, indent: str, nested_named: list[str]) -> str:
        name = decl.swift_name.split(".")[-1]
        if isinstance(decl, ClassDecl):
            if decl.generic:
                return ""
            return self.render_struct(decl, indent, nested_named)
        kind = self.alias_kind(decl)
        if kind == "rename":
            target = self.conv.ms.resolve_expr(decl.module, decl.value)
            if isinstance(target, (ClassDecl, AliasDecl)) and target.swift_name:
                if target.swift_name == decl.swift_name:
                    return ""
                return doc_comment(decl.doc, indent) + f"{indent}public typealias {name} = {target.swift_name}\n"
            ir = self.conv.conv(decl.value, decl.module)
            return f"{indent}public typealias {name} = {self.swift_type(ir, None, name)}\n"
        ir = self.conv.alias_ir(decl)
        if isinstance(ir, NullableT):
            ir = ir.inner
        if kind == "enum":
            return self.render_enum(name, ir.values, decl.doc, indent)
        if kind == "union":
            scope = Scope(decl.swift_name)
            for n in nested_named:
                scope.names.add(n)
            return self.render_union(name, ir, decl.doc, indent, scope)
        scope = Scope(decl.swift_name)
        t = self.swift_type(ir, scope, name)
        if scope.nested:
            raise ConvertError(f"typealias {decl.module}.{decl.name} needs nested types")
        return doc_comment(decl.doc, indent) + f"{indent}public typealias {name} = {t}\n"

    def render_module(self, mod: Module) -> str:
        primary = self.namer.primary.get(mod.name)
        if primary is None:
            return ""
        pdecl = mod.decls[primary]
        nested = [d for n, d in ((n, mod.decls[n]) for n in mod.order) if d is not pdecl]
        nested_in_parent = [d for d in nested if self.namer.placements[id(d)].parent is pdecl]
        top_nested = [d for d in nested if self.namer.placements[id(d)].parent is None]
        nested_names = [d.swift_name.split(".")[-1] for d in nested_in_parent]
        out = f"// Transformed from `{mod.name}` ({mod.path.name}).\n\nimport Foundation\n\n"
        out += self.render_decl(pdecl, "", nested_names)
        if nested_in_parent:
            out += f"\nextension {pdecl.swift_name} {{\n"
            for d in nested_in_parent:
                out += "\n" + self.render_decl(d, "    ", [])
            out += "}\n"
        for d in top_nested:
            out += "\n" + self.render_decl(d, "", [])
        return out


def indent_src(src: str, prefix: str) -> str:
    return "".join((prefix + l if l.strip() else l) for l in src.splitlines(keepends=True))


def precompute_kinds(emitter: SwiftEmitter, mods: list[Module]) -> None:
    for mod in mods:
        for d in mod.decls.values():
            if isinstance(d, AliasDecl):
                try:
                    d._kind = emitter.alias_kind(d)  # type: ignore[attr-defined]
                except ConvertError:
                    d._kind = "typealias"  # type: ignore[attr-defined]
