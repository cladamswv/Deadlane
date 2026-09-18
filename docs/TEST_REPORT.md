# Verification Record — Version 1.2

## Checks performed in this artifact workspace

- Repository completeness and `res://` resource-reference validation: passed with `tools/static_validate.py`.
- Version 1.2 feature assertions: passed for the environment FX controller, quarantine checkpoint, wrecked bus/ambulance, fire groups, close-detail zombie node and rebuilt survivor/weapon markers.
- Deterministic balance/gate arithmetic: passed with `tests/balance_simulation.py`.
- Required gate invariant remains 100 input bullets -> exactly 200 x2 outputs, with the originals removed by implementation.
- Expanded 30-wave campaign arithmetic and the 180-point endless budget cap remain unchanged from 1.1.
- GitHub Actions YAML parses successfully in the local Python environment.
- Development keystore validates with `keytool`.
- Runtime WAV files and the project PNG icon are checked during final packaging.
- Final ZIP root layout is checked so `project.godot` and `.github/workflows/android.yml` are directly at archive root.

## Parser hardening retained

The earlier GitHub Actions cycle reached Godot 4.7.2 parsing and exposed a typed-GDScript inference error in `main.gd`. The explicit `Node3D` target fix remains in this source. Projectile and grenade enemy arrays remain explicitly typed, and CI checks each GDScript with `--check-only` before the complete project import.

Version 1.2 also uses explicit types in newly introduced environment/model code where values come from dynamic metadata or collection iteration, reducing the chance of repeating the earlier Variant-inference failure.

## Performance safeguards added in 1.2

- Close-range zombie detail is hidden while regular enemies are farther than roughly 19 meters from the defense area.
- Smoke and animated emergency-light presentation are reduced by the Low/Reduced Effects settings.
- Fire/smoke/beacon animation is centralized in one environment controller.
- New art continues to share the procedural material cache.

## Checks intentionally not claimed locally

This artifact workspace still does not contain an executable Godot 4.7.2 editor or Android SDK. Therefore this local pass does **not** claim a new Godot parser/import success, rendered gameplay screenshot, APK compilation, Android installation, touch test, or measured device FPS.

The included GitHub Actions workflow is the authoritative next compiler/export check. Human/device playtesting remains required to certify visual composition of the denser side scenery, readability of close-detail zombies in a full crowd, smoke/transparent-effect cost, final audio mix, campaign difficulty and 30/60 FPS behavior on representative Android hardware.


## GitHub CI hardening pass

The v1.2 debug pass replaced the fragile blocking all-script `--check-only` loop with an authoritative project-wide `--import` compile check, added APK signature verification, and added an always-uploaded `DEADLANE-CI-Diagnostics` artifact for failed runs. See `docs/DEBUG_CHECK_1_2.md`.
