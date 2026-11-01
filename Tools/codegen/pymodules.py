"""Loads the upstream Python SDK's modules with `ast` and resolves names across imports.

Everything the transpiler knows about the Python source comes from here: the declarations
(classes and type aliases) of each module under `anthropic/types`, and a resolver that follows
`from x import y` chains (including package `__init__` re-exports) to the declaring module.
"""

from __future__ import annotations

import ast
import pathlib
from dataclasses import dataclass, field
from typing import Optional, Union

PKG = "anthropic"


@dataclass
class ClassDecl:
    module: str
    name: str
    node: ast.ClassDef
    bases: list[ast.expr]
    is_typeddict: bool
    total: bool
    doc: Optional[str]
    swift_name: str = ""
    # filled by the type converter
    generic: bool = False


@dataclass
class AliasDecl:
    module: str
    name: str
    value: ast.expr  # the annotation expression
    is_rename: bool  # `X = Y` (a plain re-binding of another name)
    doc: Optional[str] = None
    swift_name: str = ""


Decl = Union[ClassDecl, AliasDecl]


@dataclass
class Module:
    name: str  # dotted, e.g. anthropic.types.message
    path: pathlib.Path
    tree: ast.Module
    is_package: bool
    decls: dict[str, Decl] = field(default_factory=dict)
    imports: dict[str, tuple[str, Optional[str]]] = field(default_factory=dict)  # local -> (module, name|None)
    all: list[str] = field(default_factory=list)
    order: list[str] = field(default_factory=list)


def docstring_after(body: list[ast.stmt], index: int) -> Optional[str]:
    if index + 1 < len(body):
        nxt = body[index + 1]
        if isinstance(nxt, ast.Expr) and isinstance(nxt.value, ast.Constant) and isinstance(nxt.value.value, str):
            return nxt.value.value
    return None


class ModuleSet:
    def __init__(self, src_root: pathlib.Path) -> None:
        self.src_root = src_root  # .../src
        self.modules: dict[str, Module] = {}

    def load_tree(self, subdir: str) -> None:
        base = self.src_root / PKG / subdir
        for path in sorted(base.rglob("*.py")):
            self.load_file(path)

    def module_name(self, path: pathlib.Path) -> str:
        rel = path.relative_to(self.src_root).with_suffix("")
        parts = list(rel.parts)
        if parts[-1] == "__init__":
            parts = parts[:-1]
        return ".".join(parts)

    def load_file(self, path: pathlib.Path) -> Module:
        name = self.module_name(path)
        if name in self.modules:
            return self.modules[name]
        tree = ast.parse(path.read_text())
        mod = Module(name=name, path=path, tree=tree, is_package=path.name == "__init__.py")
        self.modules[name] = mod
        self._index(mod)
        return mod

    def _resolve_relative(self, mod: Module, level: int, target: Optional[str]) -> str:
        if level == 0:
            return target or ""
        parts = mod.name.split(".")
        if not mod.is_package:
            parts = parts[:-1]
        if level > 1:
            parts = parts[: len(parts) - (level - 1)]
        base = ".".join(parts)
        return f"{base}.{target}" if target else base

    def _index(self, mod: Module) -> None:
        body = mod.tree.body
        for i, node in enumerate(body):
            if isinstance(node, ast.ImportFrom):
                src = self._resolve_relative(mod, node.level, node.module)
                for alias in node.names:
                    local = alias.asname or alias.name
                    mod.imports[local] = (src, alias.name)
            elif isinstance(node, ast.Import):
                for alias in node.names:
                    mod.imports[alias.asname or alias.name] = (alias.name, None)
            elif isinstance(node, ast.ClassDef):
                is_td = any(ast.unparse(b) == "TypedDict" for b in node.bases) or any(
                    self._base_is_typeddict(mod, b) for b in node.bases
                )
                total = True
                for kw in node.keywords:
                    if kw.arg == "total" and isinstance(kw.value, ast.Constant):
                        total = bool(kw.value.value)
                doc = ast.get_docstring(node)
                generic = any("Generic" in ast.unparse(b) for b in node.bases)
                decl = ClassDecl(mod.name, node.name, node, list(node.bases), is_td, total, doc, generic=generic)
                mod.decls[node.name] = decl
                mod.order.append(node.name)
            elif isinstance(node, ast.AnnAssign) and isinstance(node.target, ast.Name):
                ann = ast.unparse(node.annotation)
                if ann in ("TypeAlias", "typing_extensions.TypeAlias") and node.value is not None:
                    mod.decls[node.target.id] = AliasDecl(mod.name, node.target.id, node.value, False, docstring_after(body, i))
                    mod.order.append(node.target.id)
            elif isinstance(node, ast.Assign) and len(node.targets) == 1 and isinstance(node.targets[0], ast.Name):
                name = node.targets[0].id
                if name == "__all__":
                    if isinstance(node.value, (ast.List, ast.Tuple)):
                        mod.all = [e.value for e in node.value.elts if isinstance(e, ast.Constant)]
                    continue
                v = node.value
                if isinstance(v, ast.Call):
                    continue  # TypeVar(...) etc.
                if isinstance(v, (ast.Name, ast.Attribute)):
                    mod.decls[name] = AliasDecl(mod.name, name, v, True, docstring_after(body, i))
                    mod.order.append(name)
                elif isinstance(v, ast.Subscript):
                    mod.decls[name] = AliasDecl(mod.name, name, v, False, docstring_after(body, i))
                    mod.order.append(name)

    def _base_is_typeddict(self, mod: Module, base: ast.expr) -> bool:
        # A class deriving from another TypedDict class in the same module.
        if isinstance(base, ast.Name):
            d = mod.decls.get(base.id)
            return isinstance(d, ClassDecl) and d.is_typeddict
        return False

    def ensure_module(self, name: str) -> Optional[Module]:
        if name in self.modules:
            return self.modules[name]
        parts = name.split(".")
        rel = pathlib.Path(*parts)
        for candidate in (self.src_root / rel.with_suffix(".py"), self.src_root / rel / "__init__.py"):
            if candidate.exists():
                return self.load_file(candidate)
        return None

    def resolve(self, module: str, name: str, _depth: int = 0) -> Optional[Union[Decl, Module, tuple[str, str]]]:
        """Resolves `name` as seen from `module` to a declaration, a module, or an external
        `(module, name)` pair for names declared outside the loaded tree (e.g. `typing.List`)."""
        if _depth > 30:
            return None
        mod = self.ensure_module(module)
        if mod is None:
            return (module, name)
        if name in mod.decls:
            return mod.decls[name]
        if name in mod.imports:
            src, orig = mod.imports[name]
            if orig is None:
                m = self.ensure_module(src)
                return m if m is not None else (src, name)
            if not src.startswith(PKG):
                return (src, orig)
            src_mod = self.ensure_module(src)
            if src_mod is not None and (orig in src_mod.decls or orig in src_mod.imports):
                return self.resolve(src, orig, _depth + 1)
            # `from pkg import submodule`
            sub = self.ensure_module(f"{src}.{orig}")
            if sub is not None:
                return sub
            return (src, orig)
        # a submodule of a package
        if mod.is_package:
            sub = self.ensure_module(f"{module}.{name}")
            if sub is not None:
                return sub
        return (module, name)

    def resolve_expr(self, module: str, node: ast.expr) -> Optional[Union[Decl, Module, tuple[str, str]]]:
        if isinstance(node, ast.Name):
            return self.resolve(module, node.id)
        if isinstance(node, ast.Attribute):
            base = self.resolve_expr(module, node.value)
            if isinstance(base, Module):
                return self.resolve(base.name, node.attr)
            if isinstance(base, tuple):
                return (f"{base[0]}.{base[1]}", node.attr)
            return None
        return None
