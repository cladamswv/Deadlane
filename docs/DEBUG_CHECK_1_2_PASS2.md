# DEADLANE v1.2 Debug Check - Pass 2

Date: 2026-09-14

## Scope

This pass focused on failures that can block GitHub Actions or Android export, plus nearby runtime-state bugs discovered during the audit. The source remains pinned to Godot 4.7.2-stable.

## Fixes applied

1. **Strongly typed core system references.** `main.gd` now uses the project classes (`PlayerController`, `ProjectileSystem`, `GateSystem`, `WaveManager`, `GrenadeSystem`, `UpgradeSystem`, `GameUI`, `ZombieEnemy`, and `EnvironmentFX`) instead of generic `Node`/`Node3D` types. This reduces Variant return paths like the one that caused the earlier Godot 4.7.2 target-inference parser failure.
2. **Strongly typed enemy collections.** Projectile and grenade systems now use `Array[ZombieEnemy]`, and `ZombieEnemy` uses a typed `PlayerController` reference.
3. **Optional screenshot tooling can no longer kill the APK job.** The Xvfb/Mesa installation step is now `continue-on-error`; screenshot capture was already non-blocking.
4. **Python CI helpers are syntax-checked first.** GitHub runs `python3 -m py_compile` on the validator and deterministic balance simulation before executing them.
5. **Android Back handling added.** `NOTIFICATION_WM_GO_BACK_REQUEST` opens pause during play and resumes from the pause screen.
6. **Grenade transition bug fixed.** Pending grenade warnings are cancelled when a wave ends, and grenade processing/cooldowns are frozen outside active combat. The cooldown value itself is preserved across wave/upgrade transitions and checkpoints.

## Checks actually run in this workspace

- ZIP extraction/integrity of the input fresh install: PASS.
- Static project/resource validation: PASS (`26` required files and `32` `res://` references checked before this report was added).
- Deterministic balance simulation: PASS.
- Gate invariant: `100` input bullets -> exactly `200` x2 outputs: PASS.
- GitHub Actions YAML parses as YAML: PASS.
- All 12 embedded `run:` shell blocks pass `bash -n`: PASS.
- Python validator/simulation pass `py_compile`: PASS.
- No merge-conflict markers, UTF-8 BOMs, NULs, or CRLF in checked source/config text: PASS.
- Global `class_name` names are unique: PASS.
- Development keystore alias and private-key password validate: PASS.
- 512x512 launcher PNG validation: PASS.
- 11 generated WAV files open and contain audio frames: PASS.

## Android/Godot CI review

The workflow remains pinned to Java 17, Android Build-Tools 35.0.1, Android Platform 35, CMake 3.10.2.4988404, and NDK r28b (28.1.13356709), matching the Godot 4.7 Android export documentation. It downloads the exact Godot 4.7.2 editor and matching export templates, verifies their SHA-256 hashes, imports the project, runs engine tests, exports the debug APK, and verifies the resulting APK signature with `apksigner`.

## Still not verified locally

This workspace does not contain a runnable Godot 4.7.2 binary or Android SDK and could not fetch the engine binary from the external host. Therefore this pass does **not** claim a local Godot parser/import, Android export, APK launch, rendered screenshot, or physical-device test. GitHub Actions remains the authoritative engine/compiler/export check.
