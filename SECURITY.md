# Security Model

## Trust Boundary

The local Agent is an installer operator, not a source of release truth. Release
metadata comes only from this repository's manifest. The installer independently
checks the downloaded bytes and Apple distribution identity.

## Required Release Properties

- Developer ID Application signature
- Hardened Runtime
- Secure timestamp
- Apple notarization accepted by Gatekeeper
- Exact SHA-256 recorded in `release-manifest.plist`
- Universal macOS binary unless a manifest explicitly declares architecture variants

## Local Access

Now Look Far:

- reads only elapsed time since keyboard, mouse, or scroll activity;
- stores preferences in `com.zhangmingliang.nowlookfar`;
- does not record input content;
- does not inspect application, browser, document, or screen content;
- does not expose a network listener;
- installs without root privileges.

## Reporting Security Issues

Do not post sensitive machine details in a public issue. Until a private reporting
address is published, open a minimal GitHub issue requesting a private contact channel.
