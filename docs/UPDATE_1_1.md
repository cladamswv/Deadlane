# DEADLANE 1.1 Update

This update expands the small campaign and focuses on visual readability and motion quality without changing the core one-finger/auto-fire control scheme.

## Campaign expansion

- Campaign length increased from 20 to **30 waves**.
- Three visual phases now mark progression: **Evacuation** (1-10), **Sunset Siege** (11-20), and **Nightfall** (21-30).
- Wave 30 adds the **Overpass Colossus**, a third boss with 6,200 HP, wide warned slam attacks, summons, scrap armor, and a larger silhouette.
- Upgrade selections now also occur after waves 20, 24, and 28.
- Dense rush waves occur at 6, 14, 22, and 28, with a warning before the pressure spike.
- Endless spawn-budget growth remains bounded, now capped at 180 budget points so the expanded roster pressure does not grow without limit.

## Graphics pass

- Rebuilt survivor with layered jacket/collar, backpack, straps, belt, face/ears/nose, boots, knee protection, articulated legs, gloved hands, and more detailed weapon silhouettes.
- Rebuilt zombie presentation with camera-facing faces, eyes, jaws, noses, torn clothing layers, articulated arms and legs, visible hands/fingers, type-specific gear, and stronger boss silhouettes.
- Added final-boss highway-scrap armor.
- Expanded bridge with a deeper slab, denser guardrails, road repairs, reflectors, drains, grates, cracks, cones, a sign gantry, street lights, an abandoned van, more wrecks, textured water strips, detailed piers, and a two-layer skyline with windows.
- Shared procedural materials reduce unnecessary duplicate material resources.
- Added small pooled projectile impact flashes, animated gate pulsing, and a layered grenade blast.
- Lighting/ambient colors shift across the three campaign phases.

## Fluidity pass

- Player movement now uses bounded acceleration and velocity instead of an unbounded proportional response, improving reversals and reducing jitter.
- Drag sensitivity adapts to the visible viewport width.
- Player legs animate during lateral movement and the body leans naturally into movement.
- Recoil now eases smoothly back to rest instead of snapping after a timer.
- Auto-fire catches up safely across 30/60 FPS frames while capping per-frame backlog.
- Zombies accelerate into movement, use articulated walk cycles, bob/lean by type, ease into hit reactions, and decelerate for ranged attacks.
- Projectile tracers now orient to their actual flight vector.
- Gate and grenade warning effects animate without changing gameplay timing.

The project remains offline, Compatibility renderer, arm64-first, and pinned to Godot 4.7.2-stable.
