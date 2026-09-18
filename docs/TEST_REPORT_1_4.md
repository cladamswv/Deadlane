# DEADLANE v1.4 Verification Record

## Verified in this workspace

- Project/static file validation and all `res://` references.
- Python source compilation for test/generator scripts.
- Deterministic campaign/endless balance simulation.
- Gate invariant remains 100 incoming bullets -> exactly 200 x2 descendants.
- New OBJ assets load successfully with Trimesh and contain geometry.
- All PNG texture assets open successfully and have valid dimensions/modes.
- All WAV assets parse successfully.
- GitHub Actions YAML parses and embedded Bash script blocks pass `bash -n`.
- Development keystore exists and validates with `keytool` when available.
- Final update and fresh-install ZIPs pass CRC/integrity checks.

## Not verified here

The workspace still has no runnable Godot 4.7.2 editor/export binary. Therefore the following require GitHub Actions and/or real Android hardware:

- Godot GDScript parser/import execution.
- Compatibility-renderer visual inspection.
- Android APK compilation/install.
- Real 30/60 FPS profiling and thermal behavior.
- Final phone-scale evaluation of materials, shadows, skyline detail and peripheral composition.

No APK or rendered screenshot should be claimed unless a later CI/device run actually produces it.
