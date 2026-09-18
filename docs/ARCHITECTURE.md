# Architecture

`main.gd` is the run orchestrator and the only system allowed to advance high-level run state. `GameState` owns the explicit state enum so duplicate callbacks cannot independently start waves or reward wave completion.

Gameplay systems are split by responsibility:

- `player_controller.gd`: relative touch/mouse movement, bounded acceleration, procedural lateral footwork, recoil easing, and frame-rate-stable automatic firing cadence.
- `projectile_system.gd`: pooled oriented tracers, pooled impact flashes, swept segment hit tests, penetration, and one-generation gate multiplication.
- `enemy.gd`: pooled zombie setup, articulated procedural animation, movement/ranged attack/hit/death/breach states, and three boss behaviors.
- `wave_manager.gd`: 30-wave campaign budgets, six formation families, warned rush waves, spawn deferral, three rotating bosses, endless caps, and the 80-enemy concurrency cap.
- `gate_system.gd`: timed x2/x3 gate placement, crossing geometry, and presentation pulse/lifetime display.
- `grenade_system.gd`: target-cluster selection, warning area, cooldown, radial damage, and layered blast presentation.
- `upgrade_system.gd`: capped run upgrades and derived percentage modifiers.
- `save_manager.gd`: versioned profile/checkpoint JSON with temporary-file replacement and backup recovery.
- `game_ui.gd`: responsive menus, campaign progress HUD, pause/settings, tutorials, upgrade selection, and result/credits screens.
- `bridge_builder.gd`: self-contained procedural bridge, props, water, street furniture, wrecks, skyline, and depth cues.
- `mesh_factory.gd`: shared primitive-mesh helpers and cached common materials.

The world and characters are generated from Godot primitive meshes so the repository remains self-contained and has no model-import dependency. Gameplay rules remain separate from low/medium/high visual settings.
