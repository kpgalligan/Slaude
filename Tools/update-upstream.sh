#!/usr/bin/env bash
# Moves the tracked Python SDK to a new version and regenerates the Swift sources and tests.
#
#   Tools/update-upstream.sh 2.4.0
#
# Downloads the `anthropic` sdist (which, unlike the wheel, includes the test suite) from PyPI,
# replaces upstream/anthropic-sdk-python with it, and reruns the transpiler. Review the diff of
# upstream/ to see what changed in hand-written Python code (lib/, core modules) that needs a
# matching hand-port in Sources/Anthropic/{Core,Lib}.
set -euo pipefail

version="${1:?usage: $0 <anthropic version>}"
root="$(cd "$(dirname "$0")/.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

python3 -m pip download "anthropic==${version}" --no-deps --no-binary :all: -d "$work" -q
tar xzf "$work/anthropic-${version}.tar.gz" -C "$work"

rm -rf "$root/upstream/anthropic-sdk-python"
mv "$work/anthropic-${version}" "$root/upstream/anthropic-sdk-python"
rm -f "$root/upstream/anthropic-sdk-python/uv.lock" "$root/upstream/anthropic-sdk-python/requirements-dev.lock"

sed -i.bak -E "s/^public let ANTHROPIC_SDK_VERSION = \".*\"/public let ANTHROPIC_SDK_VERSION = \"${version}\"/" "$root/Sources/Anthropic/Client.swift"
rm -f "$root/Sources/Anthropic/Client.swift.bak"

cd "$root"
python3 -I Tools/codegen/generate.py
echo
echo "Upstream is now anthropic ${version}. Next:"
echo "  git diff --stat upstream/            # what changed upstream"
echo "  cat docs/porting/UNSUPPORTED_METHODS.txt"
echo "  swift test"
