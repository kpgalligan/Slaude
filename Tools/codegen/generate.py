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


class Context:
    def __init__(self) -> None:
        self.ms = ModuleSet(SRC)
        self.ms.load_tree("types")
        self.type_modules = [m for n, m in sorted(self.ms.modules.items()) if n.startswith("anthropic.types")]
        self.conv = TypeConverter(self.ms)
        self.namer = Namer(self.ms, self.type_modules)
        self.emitter = SwiftEmitter(self.conv, self.namer)
        precompute_kinds(self.emitter, self.type_modules)
        self.namer.assign()


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
        (OUT_TYPES / file_name_for(mod.name, "types")).write_text(src)
        count += 1
    print(f"types: wrote {count} files, {len(errors)} errors")
    return errors


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", choices=["types", "resources", "tests"])
    args = ap.parse_args()
    ctx = Context()
    errors: list[str] = []
    if args.only in (None, "types"):
        errors += gen_types(ctx)
    if args.only in (None, "resources"):
        from resourcesgen import gen_resources

        errors += gen_resources(ctx, OUT_RESOURCES)
    if args.only in (None, "tests"):
        from testsgen import gen_tests

        errors += gen_tests(ctx, OUT_TESTS)
    for e in errors:
        print("ERROR", e)
    if errors:
        sys.exit(1)


if __name__ == "__main__":
    main()
