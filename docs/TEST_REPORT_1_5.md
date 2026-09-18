# DEADLANE v1.5 Verification Report

## Static/source validation performed

The v1.5 source was checked before final packaging. The checks actually executed in this workspace were:

- `tools/static_validate.py`: **PASS** — 121 required project/art files and 93 textual `res://` references checked.
- `tests/balance_simulation.py`: **PASS** — 30-wave campaign budgets, endless budget cap, faster-horde constants and gate multiplication invariant checked. The required gate test remains **100 input bullets → 200 ×2 outputs**, with the original projectiles removed.
- Python syntax: **PASS** for the validator, simulation and all four deterministic asset generators.
- Deterministic v1.5 art regeneration: **PASS** — hashes of the v1.5 generated meshes/decals were identical before and after rerunning `tools/generate_graphics_v15.py`.
- GitHub Actions YAML parse: **PASS**.
- Embedded workflow shell syntax: **PASS** for all 13 `run:` blocks using `bash -n`.
- Android development keystore: **PASS** for alias `deadlane-dev`, password and private-key readability.
- Runtime images: **50 PNG files PASS** container/readability validation.
- Runtime audio: **16 WAV files PASS** channel/rate/frame validation.
- Runtime models: **40 OBJ files PASS** non-empty vertex/face validation; explicit minimum face-count guards protect the high-detail character/wreck assets from placeholder regressions.
- GDScript class names: **11 unique `class_name` declarations PASS** duplicate scan.
- Repository hygiene: **PASS** for merge-conflict markers, UTF-8 BOMs, inappropriate NULs and generated-cache exclusion.
- Typed-script hardening: projectile enemy references and grenade cluster targets remain explicitly `ZombieEnemy` rather than generic `Node3D` values.

## v1.5 visual-system checks

The validator explicitly verifies that the shipped source references:

- survivor backpack and glove meshes;
- zombie hand and jaw meshes;
- police-SUV, fire-engine and rubble/rebar peripheral models;
- skid, oil, blood and scorch road decals;
- anisotropic mipmapped material filtering;
- emissive muzzle flash, bullet tracers and impact sparks;
- existing v1.4 type-specific zombie silhouettes, modeled weapons and ruined-city peripheral scenery;
- manual lane fire with no auto-target helper.

## Update-package verification

The final UPDATE ZIP is applied over the exact released v1.4 fresh-install source in a clean temporary directory and the resulting tree is byte-compared against the v1.5 source tree. The release is not considered ready until that reconstruction reports **0 missing, 0 extra and 0 different files**. Both final ZIPs are also CRC/integrity tested after creation.

## Engine-level limitation

This execution environment could not run Godot 4.7.2 locally. Direct access to the pinned GitHub release binary is unavailable from the container; a direct download attempt failed because the environment could not resolve `github.com`. Therefore this report does **not** claim a successful local Godot parser/import/export or a locally compiled APK.

The repository's GitHub Actions workflow remains the authoritative engine/build verification path. It installs the pinned Godot 4.7.2 editor and matching export templates, imports the complete project, runs targeted engine tests, executes the deterministic balance check, exports the signed arm64 development APK, verifies its APK signature, and uploads CI diagnostics even on failure.

## Device/visual limitation

Static checks and mesh statistics cannot establish phone-scale visual quality, touch usability, or real Android frame rate. The final v1.5 art should be judged from the actual APK, particularly during 80–110-enemy crowds, multiplied shotgun fire, grenades, bosses, smoke and fire together.
