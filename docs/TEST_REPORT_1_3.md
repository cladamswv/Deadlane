# DEADLANE 1.3 Verification Record

## Feedback addressed

- Auto-targeting removed. `main.gd` always passes `null` as the projectile target and the old projectile target-finder helper has been removed.
- Shooting is manual. Android HUD exposes a lower-right HOLD FIRE button; desktop uses Space.
- Zombie pressure increased. Ordinary packs target 10–18 simultaneous spawn bursts, rush packs target 20–28, the concurrent cap is 110, and base speeds were increased substantially.
- Zombie audio was rebuilt around a dedicated 8-player zombie voice pool plus a continuously scaled crowd layer. Weapon/impact SFX cannot consume those zombie voice players.
- Art pass upgraded to original modeled OBJ heads, torsos, arms, legs, boots, and wrecked vehicles, plus triplanar albedo/normal/roughness surfaces.
- A straight lane guide communicates manual aim without selecting or magnetizing toward zombies.

## Checks executed in the packaging workspace

- `tools/static_validate.py`: required files, `res://` references, manual-fire/no-target invariants, horde constants, audio wiring, model-detail thresholds, CI workflow safeguards, Android export identity/version.
- `tests/balance_simulation.py`: campaign budget values, endless cap, speed cap, and x2/x3 gate arithmetic.
- Python syntax compilation for authoring/test scripts.
- GitHub Actions YAML parsing and `bash -n` checks for every workflow `run:` block.
- WAV container/header validation for every generated audio file.
- PNG decoding for icon and all PBR maps.
- OBJ loading/geometry validation and minimum face-count checks.
- Development keystore alias/password validation.
- Merge-marker, BOM, NUL and generated-cache scan.
- ZIP CRC/integrity and root-layout verification after packaging.

## Art geometry snapshot

Approximate OBJ face counts before the extra layered in-engine gear/face pieces:

- survivor head: ~2,880
- survivor torso: ~1,612
- survivor arm: ~720 each
- survivor leg: ~720 each
- zombie head: ~2,960
- zombie torso: ~1,372
- zombie arm: ~800 each
- zombie leg: ~800 each
- wrecked car: ~708

These are deliberately more detailed than the placeholder geometry. Distant close-detail nodes are still hidden to reduce crowded-scene cost, but real Android profiling remains required because the larger 1.3 horde also increases rendering pressure.

## Verification boundary

This workspace cannot resolve/download or execute the pinned Godot 4.7.2 binary, so it cannot truthfully claim a Godot parser/import success, rendered screenshots, an APK, or measured Android FPS for this exact 1.3 source. The included GitHub Actions workflow is the authoritative next stage: it imports/compiles with Godot 4.7.2, runs engine tests, attempts screenshots, exports the signed development APK, verifies the APK signature, and uploads diagnostics even on failure.
