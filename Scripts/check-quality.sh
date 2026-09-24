#!/usr/bin/env bash
set -euo pipefail

package_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
cd -- "$package_root"

nixfmt --check flake.nix package.nix
for nix_source in flake.nix package.nix; do
  statix check "$nix_source"
  deadnix --fail "$nix_source"
  nixf-diagnose "$nix_source"
done
shellcheck --shell=bash --severity=style Scripts/check-quality.sh Scripts/benchmark-optimization.sh
shfmt -d -i 2 Scripts/check-quality.sh Scripts/benchmark-optimization.sh
rumdl check README.md CONTRIBUTING.md SECURITY.md
typos --format brief Package.swift Sources Tests Scripts README.md CONTRIBUTING.md SECURITY.md package.nix flake.nix

xcrun swift-format lint --configuration .swift-format --parallel --strict --recursive Sources Tests
swiftlint lint --no-cache --strict --config .swiftlint.yml
swift test --parallel
swift test -Xswiftc -strict-memory-safety
swift test -Xswiftc -D -Xswiftc OCR_CAPTURE_NIX_BUILD
index_build=$(mktemp -d "${TMPDIR:-/tmp}/ocr-periphery.XXXXXX")
trap 'rm -rf -- "$index_build"' EXIT
swift build --scratch-path "$index_build" --enable-index-store
index_store=$(find "$index_build" -type d -path '*/index/store' -print -quit)
test -n "$index_store"
periphery scan --index-store-path "$index_store" --skip-build

if [[ ${OCR_CAPTURE_RUN_SANITIZERS:-1} == 1 ]]; then
  swift test --sanitize address
  swift test --sanitize thread
fi
