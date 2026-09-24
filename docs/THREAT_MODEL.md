# Threat model

OCR Capture receives a user-selected screen region or an image path or standard input. It invokes macOS `screencapture`, reads the system pasteboard, performs recognition through the local Vision framework, and writes recognized text to the pasteboard or requested output. The image and its text may contain secrets.

The trust boundaries are the macOS screen-capture permission prompt, image decoding, command-line paths and output destinations, and the system pasteboard. A malicious image may try to exhaust memory or exploit an image decoder; arbitrary output paths could overwrite data if the user explicitly chooses them. Screen content can be exposed to another local process with clipboard access after capture. The process does not send images to a network service and does not persist them by default.

Security review should verify bounded image handling, no accidental screenshot files or log disclosure, permission and cancellation behavior, and safe output path handling. Tests cover input and configuration boundaries; live macOS permission and clipboard behavior needs manual review before a release.
