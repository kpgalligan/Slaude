#!/usr/bin/env python3
"""Regenerates the Swift sources and tests transformed from the upstream Python SDK.

Usage: python3 Tools/codegen/generate.py [--only types|resources|tests]

Reads `upstream/anthropic-sdk-python` and writes:
  Sources/Anthropic/Generated/Types/*.swift      (from src/anthropic/types)
  Sources/Anthropic/Generated/Resources/*.swift  (from src/anthropic/resources)
  Tests/AnthropicTests/Generated/*.swift         (from tests/api_resources)
"""

from __future__ import annotations

import argparse
import pathlib
import shutil
import sys

HERE = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from pymodules import ModuleSet  # noqa: E402
from typesgen import ConvertError, Namer, SwiftEmitter, TypeConverter, precompute_kinds  # noqa: E402

ROOT = HERE.parent.parent
UPSTREAM = ROOT / "upstream" / "anthropic-sdk-python"
SRC = UPSTREAM / "src"
OUT_TYPES = ROOT / "Sources" / "Anthropic" / "Generated" / "Types"
OUT_RESOURCES = ROOT / "Sources" / "Anthropic" / "Generated" / "Resources"
OUT_TESTS = ROOT / "Tests" / "AnthropicTests" / "Generated"
# The SwiftPM targets the generated directories live in.
TARGETS = [ROOT / "Sources" / "Anthropic", ROOT / "Tests" / "AnthropicTests"]


class TargetFileNames:
    """Refuses a Swift file name equal, ignoring case, to another file's in the same SwiftPM target.

    SwiftPM names a target's object files after its sources' basenames, so on a case-insensitive volume (macOS's
    default APFS) `Generated/Types/diagnostics.swift` and a hand-written `Lib/Tools/Diagnostics.swift` compile to
    one `.o` and one of them silently drops out of the link. swiftc rejects only exact duplicates.
    `PackageLayoutTests` checks the same rule over the whole tree.
    """

    def __init__(self, regenerated: list[pathlib.Path]) -> None:
        self.claimed: dict[tuple[pathlib.Path, str], pathlib.Path] = {}
        self.errors: list[str] = []
        for target in TARGETS:
            for path in sorted(target.rglob("*.swift")):
                if not any(path.is_relative_to(d) for d in regenerated):
                    self.claimed[(target, path.name.lower())] = path

    def claim(self, path: pathlib.Path) -> bool:
        target = next(t for t in TARGETS if path.is_relative_to(t))
        key = (target, path.name.lower())
        other = self.claimed.get(key)
        if other is not None and other != path:
            self.errors.append(
                f"{path.relative_to(ROOT)}: not written, its name differs only in case from "
                f"{other.relative_to(ROOT)} in the same target (rename the hand-written file)"
            )
            return False
        self.claimed[key] = path
        return True


class Context:
    def __init__(self, regenerated: list[pathlib.Path]) -> None:
        self.ms = ModuleSet(SRC)
        self.ms.load_tree("types")
        self.type_modules = [m for n, m in sorted(self.ms.modules.items()) if n.startswith("anthropic.types")]
        self.conv = TypeConverter(self.ms)
        self.namer = Namer(self.ms, self.type_modules)
        self.emitter = SwiftEmitter(self.conv, self.namer)
        precompute_kinds(self.emitter, self.type_modules)
        self.namer.assign()
        self.file_names = TargetFileNames(regenerated)

    def write_swift(self, path: pathlib.Path, src: str) -> bool:
        """Writes one generated Swift file unless `TargetFileNames` refuses its name."""
        if not self.file_names.claim(path):
            return False
        path.write_text(src)
        return True


def file_name_for(module: str, prefix: str) -> str:
    parts = module.split(".")[2:]  # drop anthropic.types / anthropic.resources
    return ".".join(parts) + ".swift"


def reset_dir(path: pathlib.Path) -> None:
    if path.exists():
        shutil.rmtree(path)
    path.mkdir(parents=True)


def gen_types(ctx: Context) -> list[str]:
    reset_dir(OUT_TYPES)
    errors: list[str] = []
    count = 0
    for mod in ctx.type_modules:
        if mod.is_package:
            continue
        try:
            src = ctx.emitter.render_module(mod)
        except ConvertError as e:
            errors.append(f"{mod.name}: {e}")
            continue
        if not src:
            continue
        if ctx.write_swift(OUT_TYPES / file_name_for(mod.name, "types"), src):
            count += 1
    print(f"types: wrote {count} files, {len(errors)} errors")
    return errors


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", choices=["types", "resources", "tests"])
    args = ap.parse_args()
    # The directories this run resets (`--only tests` regenerates the resources too).
    resets = {OUT_TYPES: ("types",), OUT_RESOURCES: ("resources", "tests"), OUT_TESTS: ("tests",)}
    ctx = Context([d for d, only in resets.items() if args.only in (None, *only)])
    errors: list[str] = []
    if args.only in (None, "types"):
        errors += gen_types(ctx)
    if args.only in (None, "resources", "tests") and not any(getattr(d, "_base_types", None) for m in ctx.type_modules for d in m.decls.values()):
        for m in ctx.type_modules:
            if not m.is_package:
                ctx.emitter.render_module(m)
    if args.only in (None, "resources"):
        from resourcesgen import gen_resources

        errors += gen_resources(ctx, OUT_RESOURCES)
    if args.only in (None, "tests"):
        if not hasattr(ctx, "resource_gen"):
            from resourcesgen import gen_resources

            gen_resources(ctx, OUT_RESOURCES)
        from testsgen import gen_tests

        errors += gen_tests(ctx, OUT_TESTS)
    errors += ctx.file_names.errors
    for e in errors:
        print("ERROR", e)
    if errors:
        sys.exit(1)


if __name__ == "__main__":
    main()
