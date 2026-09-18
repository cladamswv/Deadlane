# DEADLANE v1.4 — World & Graphics Overhaul

This update is a rendering/content pass on top of v1.3's manual-fire combat rebuild.

## Character and weapon art

- Added type-specific zombie torso meshes for runners, armored zombies, brutes, spitters and the Overpass Colossus, so silhouettes differ before color/equipment detail is considered.
- Replaced the last box-built primary weapon bodies with original imported OBJ weapon meshes for the assault rifle, SMG, shotgun and piercer.
- Retained layered survivor equipment, modeled arms/legs/head/boots, close-range zombie facial damage, teeth, hair and wounds.

## Surface rendering

- Added six new original PBR-style texture families: brick, olive canvas, sandbag fabric, dirty glass, hazard plastic and rubber.
- Retained asphalt, concrete, painted/rusted metal, survivor cloth, dark cloth, zombie skin, charred metal and water texture families.
- Added emissive materials for fires, emergency lights, lit windows and warning elements.
- ACES tonemapping, higher contrast/color tuning, quality-dependent MSAA and refined directional shadows are configured in runtime.

## Peripheral scenery

- New modeled wrecked evacuation bus and damaged ambulance presentation.
- Wrecked military utility trucks on the bridge shoulders.
- Crashed helicopter with local fire/smoke.
- Collapsed adjacent flyover spans with fractured concrete and exposed rebar.
- Broken construction crane and dangling load frame in the far city.
- Rooftop tanks and satellite dishes.
- Utility transformers, containers, damaged billboards and denser flooded debris.
- More detailed quarantine booths, sandbags, Jersey barriers, streetlights and shipping containers.
- Lit/dark ruined-building windows, brick variants, rooftop equipment and stronger skyline silhouettes.
- Fire embers now drift above major wreck fires and disappear with reduced-effects/low-quality settings.

## Performance controls

- Low quality disables MSAA, shadows, smoke-heavy presentation and embers.
- Medium quality uses 2x MSAA.
- High quality uses 4x MSAA and a longer directional shadow range.
- Zombie close-range detail remains distance-gated and gameplay rules do not change with visual quality.

## Tooling

- `tools/generate_environment_models.py` deterministically regenerates the new original weapon/environment OBJ assets.
- `tools/generate_surface_textures_v14.py` deterministically regenerates the v1.4 PBR-style texture sets.
- Existing static validation and deterministic balance tests remain part of CI.

No downloaded third-party game art was added in this pass.
