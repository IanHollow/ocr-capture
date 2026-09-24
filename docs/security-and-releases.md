# Security and release process

This project's review target is [OSPS Baseline version 2026.08.28](https://baseline.openssf.org/versions/2026-08-28). The baseline is a self-attested control set; this document records the process, not a certification. The independent human approval required by OSPS-QA-07.01 is not yet satisfied. No Level 3 claim or badge is authorized until every applicable control is checked with evidence.

## Source and CI

All changes enter through a pull request with tests and a DCO sign-off on each commit. CI runs the project's format, lint, type/static analysis, tests, and Nix flake checks on the supported platform. CodeQL and dependency review run on pull requests. Workflows use pinned actions, minimal job permissions, and no persisted checkout credentials. Maintainers review new dependencies, source changes, licenses, lockfile changes, and CI permissions before merging. Major behavior changes require an automated regression test. Tests run on each pull request and on `main`; see [CONTRIBUTING.md](../CONTRIBUTING.md) for local commands.

## Secrets and dependencies

Do not store credentials in source, issue text, logs, or CI artifacts. Prefer GitHub's short-lived OIDC credentials for external services. If a long-lived secret becomes necessary, store it only in GitHub Actions secrets with the narrowest scope, restrict its environment, rotate it after exposure or personnel changes, and remove unused grants. Pull request code never receives a privileged token. Dependabot tracks GitHub Actions and Nix inputs. New dependencies must have compatible licenses and no known unresolved low-or-higher severity finding; any exception needs a documented risk decision before merging. Existing findings are triaged before a release. A finding judged not to affect a release must have a VEX record with evidence.

## Releases

The `v0.1.0` release is a source archive, with no prebuilt application or shared
library. The tag must name a commit on protected `main`, match the version in
`package.nix`, and include reviewed [release notes](releases/v0.1.0.md) with a
changelog, supported platform, and support end date. Prebuilt macOS assets
would also require a stable Apple signing identity, notarization, and a separate
security review; a Nix-built package is not a general-purpose binary release.

A tag push calls the pinned
[`nix-forge/ci` source-release builder](https://github.com/nix-forge/ci/blob/bb1b39a9082f72dc6c7ce596103ce7a5e4d29b01/.github/workflows/slsa-source-release.yml)
as a reusable workflow. That isolated workflow creates the exact source archive,
SHA-256 checksum, manifest, and Sigstore SLSA provenance. A separate release
job checks the tag, version, source commit, archive digest, builder identity,
builder revision, and signed provenance before publishing a draft release.
GitHub's immutable-release setting locks the published tag and assets. The
release job has no path from an untrusted pull request and is the only job with
`contents: write`.

A verified source archive may support a **SLSA Build Level 3 claim for that
archive alone**, using GitHub's reusable-workflow method. The claim depends on
the actual published release and successful verification of its provenance;
it does not cover Nix-built binaries, macOS application bundles, arbitrary
GitHub-generated archives, or the repository as a whole. See the
[SLSA build requirements](https://slsa.dev/spec/v1.2/build-track-basics) and
[GitHub's reusable-workflow guidance](https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/increase-security-rating).

## Verify a source release

Download the release assets and check the archive's checksum and provenance:

```sh
gh release download v0.1.0 --repo IanHollow/ocr-capture --dir release
cd release
shasum -a 256 -c ocr-capture-v0.1.0.tar.gz.sha256
gh attestation verify ocr-capture-v0.1.0.tar.gz \
  --repo IanHollow/ocr-capture \
  --bundle ocr-capture-v0.1.0.intoto.jsonl \
  --signer-workflow nix-forge/ci/.github/workflows/slsa-source-release.yml \
  --signer-digest bb1b39a9082f72dc6c7ce596103ce7a5e4d29b01 \
  --source-ref refs/tags/v0.1.0
```

The `release-manifest.txt` asset records the exact source commit and archive
SHA-256. Compare those values with the tag and the checksum before building.
For private vulnerability reports, use [SECURITY.md](../SECURITY.md).
