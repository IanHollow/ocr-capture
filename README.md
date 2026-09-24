# OCR Capture

[![OpenSSF Baseline: not assessed](https://img.shields.io/badge/OpenSSF%20Baseline-not%20assessed-lightgrey)](https://baseline.openssf.org/)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/IanHollow/ocr-capture/badge)](https://scorecard.dev/viewer/?uri=github.com/IanHollow/ocr-capture)
[![OpenSSF Best Practices: not enrolled](https://img.shields.io/badge/OpenSSF%20Best%20Practices-not%20enrolled-lightgrey)](https://www.bestpractices.dev/)

OCR Capture copies text from a selected screen region to the macOS clipboard.
It runs locally and uses Apple's Screenshot and Vision services.

## Install

On macOS 14 or newer with Nix, install the package from this repository:

```console
nix profile install github:IanHollow/ocr-capture
```

The package is also available from
[`nixpkgs-personal`](https://github.com/nix-forge/nixpkgs-personal).
The [source releases](https://github.com/IanHollow/ocr-capture/releases) contain
versioned source archives; they do not contain a prebuilt app.

## Use

Press `Command-Shift-7`, select a region with the standard macOS Screenshot
interaction, and the recognized text replaces the captured image on the normal
system clipboard when the Nix/Home Manager shortcut is configured. To run it
directly:

```console
hm-ocr-capture capture
```

macOS handles selection, permission prompts, multiple displays, and Escape
cancellation. OCR Capture does not add its own overlay or review window.

## Implementation

The Swift app runs macOS's built-in `/usr/sbin/screencapture` in interactive
region and clipboard mode, decodes the resulting in-memory pasteboard image,
recognizes its text locally with Vision, and writes plain text back to the
pasteboard. It does not create an intermediate screenshot file, contact a
network service, or keep a resident process after the result is copied.

Image and standard-input commands remain available for testing and automation:

```console
hm-ocr-capture image scan.png --backend document \
  --render markdown --destination stdout
cat scan.png | hm-ocr-capture stdin --json
hm-ocr-capture languages
hm-ocr-capture diagnose
```

Run `hm-ocr-capture help` for OCR and rendering options.

## Privacy and security

- Capture and OCR remain local to the Mac.
- Screenshots pass through the standard clipboard and are not written to disk.
- OCR scans text only; QR actions, speech, history, review UI, custom feedback,
  and clipboard expiry have been removed.
- The final text uses the normal persistent macOS clipboard, including the
  system's standard Universal Clipboard behavior.
- Input bytes, recognition pixels, candidate counts, and OCR duration remain
  bounded.

## Compatibility

The app has a macOS 14 deployment target. Its legacy backend uses
`VNRecognizeTextRequest`. When the build compiler and Apple SDK expose the newer
structured document-recognition API, the automatic backend enables it at build
time while retaining the legacy fallback for older systems.

Nix probes the actual Vision module because nixpkgs can ship a newer Swift
compiler before a newer Apple SDK. Swift 5 builds compile the available adapter;
Swift 6 builds use strict concurrency and automatically include newer Vision
features when the SDK provides them.

## Development checks

From this repository on macOS with Xcode installed:

```console
Scripts/check-quality.sh
```

Use `nix develop` to supply SwiftLint and Periphery. Xcode supplies Swift and
swift-format. `swift test` runs the unit suite without those extra tools.

The suite runs swift-format, SwiftLint, compiler warnings and strict concurrency,
unit tests, strict-memory checks, Periphery, AddressSanitizer, and
ThreadSanitizer. The Nix package repeats its hermetic self-test, signature,
deployment-target, and dependency checks. The session-lock test uses a fresh
temporary directory so it cannot contend with an interactive capture. It checks
both concurrent rejection and reacquisition after the first owner releases.

Swift 6 toolchains also run parameterized Swift Testing cases for nonfinite
numeric inputs, integer overflow, and accepted option boundaries. Existing
XCTest coverage remains available with Swift 5.10. Run both suites with
`swift test`; the newer cases compile only when the toolchain supplies Testing.
The XCTest suite also runs 1,000 reproducible, bounded mutations of CLI
arguments against the production parser. These are fuzz smoke cases with a
fixed seed, so failures can be reproduced and routine CI runtime stays bounded.

The direct release build uses whole-module optimization. A bounded comparison
on arm64 macOS with Swift 5.10.1 and 6.3.3 reduced the legacy-backend executable
by 10.6% and 11.3%, respectively. Both variants passed the fixture selftest;
three-build medians also favored WMO. This measures compiled code and fixture
execution, not screen capture or Vision recognition latency.

Repeat the comparison with the current compiler and SDK:

```console
Scripts/benchmark-optimization.sh
```

The script probes document-API availability like the package recipe, alternates
baseline and WMO builds, and reports wall time, CPU time, peak resident memory,
and executable size. It runs only fixture selftests. `SWIFTC` selects a compiler;
`BENCHMARK_BUILD_RUNS` and `BENCHMARK_TEST_RUNS` control the default three builds
and twenty warm selftests per mode. Temporary binaries are removed on exit.

## Nix packaging

`package.nix` is the package recipe. `nixpkgs-personal` fetches a pinned
revision of this repository and calls that recipe.

The repository flake supplies the pinned quality tools. On a supported Mac,
run `nix develop --command bash Scripts/check-quality.sh` and
`nix flake check` before submitting a change. CI runs both commands.

## Project health

Security and release expectations are documented in [SECURITY.md](SECURITY.md),
[SUPPORT.md](SUPPORT.md), and [security and release process](docs/security-and-releases.md).
Releases provide checksums and provenance for the source archives. The first
release is `v0.1.0`. The gray OpenSSF badges above indicate that this project
has not been enrolled or assessed by the Best Practices service; they do not
claim a Baseline level or a passing Best Practices status. SLSA claims, if any,
apply only to verified release archives, not to Nix builds or the repository.
