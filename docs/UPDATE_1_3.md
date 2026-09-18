# DEADLANE 1.3 — Manual Fire, Horde Pressure & Art Upgrade

This update is built directly from player feedback after the first playable Android build.

## Combat changes

- Removed automatic target selection. Bullets now leave the muzzle straight down the survivor's current bridge lane.
- Removed nonstop automatic firing. The HUD now has a large HOLD FIRE button. Firing continues only while that button is held (Space on desktop).
- Grenade was moved to the opposite lower corner so movement + fire + grenade work naturally with two thumbs.
- The first-run tutorial and menu copy now teach manual aiming and hold-to-fire.

## Horde changes

- Enemy base movement speeds increased substantially: Shambler 2.6 m/s, Runner 4.8, Armored 2.0, Brute 1.7, Spitter 2.2.
- Later-wave speed scaling can reach 135% of base instead of 120%.
- Ordinary waves now arrive in compact 10–18 zombie surges rather than a thin stream.
- Rush waves use approximately 20–28 enemy packs with much tighter spawn spacing and shorter gaps between surges.
- Concurrent enemy cap increased to 110.
- Wave budget hypothesis updated to round(12 + 3.3w + 0.20w²), with endless capped at 210 budget points.
- Local crowd separation now adjusts lane targets smoothly instead of snapping transforms sideways.

## Zombie audio

- Added original synthesized zombie_groan1, zombie_groan2, zombie_snarl, zombie_death, and an 8-second crowd ambience loop.
- Spawn vocal chance increased dramatically and bosses always announce themselves.
- Zombie voices now have their own eight-player audio pool so rapid weapon fire cannot steal every available audio channel. The crowd layer is much louder and scales with the number of living zombies, so large packs sound like large packs.
- Audio still respects Master and SFX sliders; default SFX is raised to 95% while music is lowered to 25% so zombie vocals remain obvious during combat.

## Graphics / models

- Rebuilt the original OBJ art set at substantially higher geometric detail: sculpted survivor/zombie heads and torsos, dedicated modeled arms and legs, combat boots, and a more detailed wrecked car.
- Capsule-based character limbs were replaced with imported modeled arm/leg meshes while preserving the existing articulated movement pivots. Survivor torso is ~1.6K triangles, survivor head ~2.9K, zombie torso ~1.4K, zombie head ~3K before layered gear/details.
- Added a full original procedural PBR surface set with albedo, normal and roughness maps for asphalt, concrete, painted/rusted metal, survivor fabric, dark cloth, zombie skin, charred surfaces, and water.
- MeshFactory automatically applies triplanar albedo + normal + roughness detail to matching bridge and character materials.
- Added a procedural sky, atmospheric depth fog, cool fill light, stronger tonal contrast, and changing sky/fog color across campaign phases.
- Wrecked sedans now use an actual custom vehicle silhouette instead of stacked rectangular body blocks.

## Verification boundary

Static/resource/archive tests can be run in the build workspace. Godot import, rendering, Android performance and APK behavior still require the pinned GitHub Actions Godot 4.7.2 build or real hardware.
