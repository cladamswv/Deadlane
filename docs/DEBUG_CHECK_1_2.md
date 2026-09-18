# DEADLANE v1.2 GitHub/CI Debug Check

This pass focuses on failures that can prevent GitHub Actions from reaching or uploading an Android APK.

## Checks completed locally

- Project ZIP extracted cleanly with `project.godot` and `.github/workflows/android.yml` at repository root.
- Required file and `res://` reference validation passed.
- `data/balance.json` parses successfully.
- Deterministic 30-wave/endless balance simulation passed.
- Gate invariant remains 100 input bullets -> exactly 200 x2 descendants.
- No merge-conflict markers, zero-byte project files, symlink surprises, mixed indentation, duplicate `class_name` declarations, or delimiter mismatches were found by the local static scan.
- All embedded Bash blocks in the GitHub Actions workflow pass `bash -n` syntax checking.
- The workflow YAML parses successfully in the local validation environment.
- Development keystore opens with the configured password and contains alias `deadlane-dev`.
- Launcher icon is a valid 512x512 PNG and runtime audio files are valid PCM WAV files.
- Godot 4.7.2 Linux/editor and export-template SHA-256 values used by CI were cross-checked against published 4.7.2 artifacts.

## CI risks fixed

1. Removed the fragile blocking scan that attempted to run every runtime `Node`/`Node3D` script individually through `--script --check-only`. The authoritative runtime compile check is now a project-wide Godot `--import`, while only actual command-line `SceneTree` scripts receive individual `--check-only` checks.
2. Changed editor import to the explicit `--import --quit` command so CI waits for imports instead of relying on a generic editor launch/quit cycle.
3. Added retry/fail-fast flags to Godot/template downloads and retained exact SHA-256 verification.
4. Removed an unnecessary runtime download of Godot copyright text. The required MIT notice is already stored in `docs/THIRD_PARTY_NOTICES.md`, eliminating an extra network failure point.
5. Added exact Godot-version and template-directory checks.
6. Added Java, SDK, keystore-alias and `apksigner` availability checks before export.
7. Added Android APK signature verification after export.
8. Added `DEADLANE-CI-Diagnostics`, uploaded with `if: always()`, so import/export logs remain downloadable even if the build fails.
9. Added explicit Android export defaults (launcher icon, XR off, shader baker off, launcher visibility and custom permissions array) to reduce exporter-default ambiguity.

## Still requires GitHub/Godot execution

This container does not have an executable Godot 4.7.2 binary or Android SDK and cannot download them directly. Therefore this check does not claim that Godot has compiled the project or that an APK has been produced. The next GitHub Actions run remains the authoritative Godot parser/import/export test.
