# Android SDK CI Fix

## Failure observed

GitHub Actions stopped at the **Android SDK** step before Godot was installed. `android-actions/setup-android@v3` found the runner's command-line tools 12.0, downloaded command-line tools 16.0, then `/cmdline-tools/16.0/bin/sdkmanager --licenses` exited with status 1. The later Godot/import/export steps never ran.

## Repair

The workflow now avoids `android-actions/setup-android` entirely. It downloads the current official Android command-line tools for Linux directly from Google:

- Package: `commandlinetools-linux-15859902_latest.zip`
- SHA-256: `4e4c464f145a7512b57d088ac6c278c03c9eea610886b35a5e0804e74eedf583`

The download is checksum-verified before use. Its `sdkmanager` targets the GitHub runner's existing `ANDROID_HOME` and installs/verifies:

- `platform-tools`
- `build-tools;35.0.1`
- `platforms;android-35`
- `cmake;3.10.2.4988404`
- `ndk;28.1.13356709`

The license step captures **sdkmanager's** exit status instead of accidentally failing on the `yes` process receiving SIGPIPE. SDK setup logs are retained in the diagnostics artifact.

## Why this is safer

This removes the action version that failed before the project could compile, removes its Node runtime warning from the Android setup path, avoids updating `cmdline-tools` through a running `sdkmanager`, and makes the downloaded CLI package reproducible via a published checksum.
