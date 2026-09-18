# DEADLANE 1.2 Art & Atmosphere Update

Version 1.2 is a focused model-detail and environmental storytelling pass. The game rules and 30-wave campaign remain compatible with 1.1 saves and the Android application ID stays unchanged.

## Character model upgrade

- Rebuilt survivor presentation around the actual third-person gameplay camera. The backpack now has a flap, lower pouch, rolled blanket, radio, antenna, straps and additional shape breakup.
- Added jacket zipper/seams, shoulder protection, belt buckle, utility pouches, holster, canteen, kneepads, boot detail, elbow pads and more readable glove/finger shapes.
- Added additional head/face geometry including brows, eyes, mouth and stronger cap/hair silhouette.
- Rebuilt all four weapon models with more recognizable stocks, receivers, handguards, magazines, barrels, pump/tube pieces, scope/rail shapes and sights.
- Zombies now use a two-tier procedural model. The inexpensive base silhouette is always rendered, while close-range detail becomes visible around the final 19 meters.
- Close zombie detail adds ears, brows, cheek wounds, individual teeth, uneven hair clumps, torn fabric, exposed-rib shapes and asymmetric torso wounds.
- Runner, armored, spitter, brute and all three bosses receive unique detail pieces so the roster reads by silhouette rather than only color.
- Armored zombies now have equipment pouches and knee protection. Spitters have additional throat pustules/drool detail. Bosses have extra straps, scrap, growths or rebar-like pieces.

## Post-apocalyptic bridge-side pass

The bridge is now framed as a failed quarantine evacuation corridor rather than a generic abandoned roadway.

- Replaced continuous pristine guardrails with segmented rails and visible broken sections.
- Added an abandoned ambulance and a large crashed bus beyond the firing corridor.
- Added quarantine checkpoint booths, concrete/sandbag protection, flashing emergency beacons and a damaged overhead quarantine sign.
- Added survivor barricade nests, shipping-container stacks, tire/concrete/rebar debris and additional wreck damage.
- Added burning barrels, burning wreck effects, animated fire light, smoke clusters and distant smoke columns.
- Added bent/broken streetlights, damaged gantry signage and more scattered traffic-control debris.
- Added exposed bridge-side structural pieces and hanging rusted elements below the deck.
- Rebuilt the distant skyline as damaged buildings with broken roof lines, dark window cavities, occasional warm fire-lit windows and rooftop structures.
- Expanded water detail and bridge understructure so broken edges reveal obvious height and depth.

## Performance safeguards

- Extra zombie detail is grouped under a dedicated close-detail node and hidden for distant enemies.
- Smoke is disabled by Low visual quality and by Reduced Effects.
- Low quality also suppresses animated emergency lights while preserving gameplay-identical geometry and collision rules.
- Fire, smoke and beacons use a single lightweight environment animation controller instead of per-prop scripts.
- All new game art remains procedural/original and uses the existing shared material cache.

## Compatibility

- Engine remains pinned to Godot 4.7.2-stable.
- Compatibility renderer remains the default Android renderer.
- Android package remains `com.deadlane.zombiebridge`.
- Campaign remains 30 waves and permanent progression/save format is unchanged.
