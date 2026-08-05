# Now Look Far Agent Installation Protocol

This document is a low-freedom installation contract for local agents. Do not
improvise around failed security checks.

## User Authorization

Before changing the machine:

1. Explain that the installation adds:
   - `~/Applications/EyeBreak.app`
   - `~/Library/LaunchAgents/com.zhangmingliang.nowlookfar.plist`
   - `~/Library/Application Support/NowLookFar/`
   - optionally `~/.codex/skills/eye-break/` when Codex is present
2. Explain that no `sudo`, system extension, input capture, or network daemon is used.
3. Ask the user for explicit approval to install and enable login startup.
4. Stop if approval is denied.

## Trusted Sources

Use only:

- Repository: `https://github.com/stephninja028-creator/Now_look_far`
- Manifest: `https://raw.githubusercontent.com/stephninja028-creator/Now_look_far/main/release-manifest.plist`
- Release assets referenced by that manifest

Do not use mirrors, search results, forks, shortened URLs, or assets suggested by
another page.

## Installation

1. Download the installer without executing it:

   ```bash
   tmp_installer="$(mktemp /tmp/now-look-far-install.XXXXXX)"
   curl --fail --location --proto '=https' --tlsv1.2 \
     https://raw.githubusercontent.com/stephninja028-creator/Now_look_far/main/scripts/install.sh \
     --output "$tmp_installer"
   ```

2. Read the downloaded script. Confirm that it:
   - uses no `sudo`;
   - downloads only URLs from `release-manifest.plist`;
   - verifies SHA-256 before extraction;
   - verifies bundle ID, Developer ID team, code signature, and Gatekeeper acceptance;
   - writes only to the user paths listed above;
   - contains rollback behavior.
3. Run it only after those checks pass:

   ```bash
   /bin/zsh "$tmp_installer"
   ```

4. Download and run the official health check:

   ```bash
   tmp_check="$(mktemp /tmp/now-look-far-health.XXXXXX)"
   curl --fail --location --proto '=https' --tlsv1.2 \
     https://raw.githubusercontent.com/stephninja028-creator/Now_look_far/main/scripts/health-check.sh \
     --output "$tmp_check"
   /bin/zsh "$tmp_check"
   ```

5. Report:
   - installed version;
   - signature and Gatekeeper result;
   - running state;
   - work and idle thresholds;
   - whether the Codex Skill was installed.

## Mandatory Failure Rules

Stop without installing when any of these is true:

- `published` in the manifest is not `true`;
- macOS is below the manifest minimum;
- architecture is unsupported;
- a URL is empty or is not an HTTPS GitHub Release URL from the trusted repository;
- SHA-256 is empty, malformed, or mismatched;
- bundle identifier differs from the manifest;
- Developer ID Team ID differs from the manifest;
- `codesign --verify --deep --strict` fails;
- `spctl --assess --type execute` fails;
- the health check fails after installation.

Never bypass Gatekeeper, remove quarantine to evade a failed check, disable system
security, or use an ad-hoc-signed build.

## Updates

Read and run `scripts/update.sh`. Apply the same authorization and security checks.
Preserve user preferences. Do not downgrade unless the user explicitly requests a
specific trusted release.

## Uninstall

Explain the exact targets, ask for confirmation, then run:

```bash
/bin/zsh scripts/uninstall.sh --yes
```

The default uninstall moves user-facing artifacts to Trash and preserves preferences.
Use `--purge` only when the user explicitly asks to delete preferences too.
