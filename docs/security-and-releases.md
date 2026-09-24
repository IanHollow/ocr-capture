# Security and release process

This project's review target is [OSPS Baseline version 2026.08.28](https://baseline.openssf.org/versions/2026-08-28). The baseline is a self-attested control set; this document records the process, not a certification. The independent human approval required by OSPS-QA-07.01 is not yet satisfied. No Level 3 claim or badge is authorized until every applicable control is checked with evidence.

## Source and CI

All changes enter through a pull request with tests and a DCO sign-off on each commit. CI runs the project's format, lint, type/static analysis, tests, and Nix flake checks on the supported platform. CodeQL and dependency review run on pull requests. Workflows use pinned actions, minimal job permissions, and no persisted checkout credentials. Maintainers review new dependencies, source changes, licenses, lockfile changes, and CI permissions before merging. Major behavior changes require an automated regression test. Tests run on each pull request and on `main`; see [CONTRIBUTING.md](../CONTRIBUTING.md) for local commands.

## Secrets and dependencies

Do not store credentials in source, issue text, logs, or CI artifacts. Prefer GitHub's short-lived OIDC credentials for external services. If a long-lived secret becomes necessary, store it only in GitHub Actions secrets with the narrowest scope, restrict its environment, rotate it after exposure or personnel changes, and remove unused grants. Pull request code never receives a privileged token. Dependabot tracks GitHub Actions and Nix inputs. New dependencies must have compatible licenses and no known unresolved low-or-higher severity finding; any exception needs a documented risk decision before merging. Existing findings are triaged before a release. A finding judged not to affect a release must have a VEX record with evidence.

## Releases

No official releases or compiled release assets exist yet. Before the first release, document the supported platforms and end-of-support date, review security findings, assign a unique version, publish a change log, and ensure user and build instructions are current. Every binary asset must carry an SBOM, cryptographic digest, and signed provenance or signed manifest. Keep the release workflow separate from untrusted pull request jobs, use an immutable source revision and a reviewed, pinned build environment, and verify the expected release identity and hashes in the user guide. A SLSA Build Level 3 claim requires an actual release and verification of its provenance against the [SLSA v1.2 specification](https://slsa.dev/spec/v1.2/); the current source-only workflow makes no SLSA level claim.
