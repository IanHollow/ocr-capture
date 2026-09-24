# Contributing to ocr-capture

Open an issue before changing user-visible behavior. Include the affected
platform, a reproduction or use case, and the expected result. Keep changes
focused, add a test for behavior changes, and run the commands in `README.md`.

Do not commit credentials, generated build output, or vendor binaries. Preserve
upstream copyright notices and identify the source of imported code.

## Review and verification

Create a branch and pull request for each change. Sign off every commit with
`git commit --signoff` under the [Developer Certificate of Origin](DCO).
CI checks the sign-off and runs quality, CodeQL, and dependency review. Major
behavior changes need an automated regression test. Review dependency and
license changes and describe security effects in the pull request. See
[security and release process](docs/security-and-releases.md).
