#!/usr/bin/env python3
from pathlib import Path
import json,re
root=Path(__file__).resolve().parents[1]
required=[
 '.gitignore','project.godot','export_presets.cfg','.github/workflows/android.yml','scenes/main.tscn',
 'scripts/core/main.gd','scripts/core/game_state.gd','scripts/core/save_manager.gd','scripts/core/audio_manager.gd',
 'scripts/gameplay/player_controller.gd','scripts/gameplay/enemy.gd','scripts/gameplay/projectile_system.gd',
 'scripts/gameplay/gate_system.gd','scripts/gameplay/wave_manager.gd','scripts/gameplay/grenade_system.gd','scripts/gameplay/upgrade_system.gd',
 'scripts/world/bridge_builder.gd','scripts/world/mesh_factory.gd','scripts/world/environment_fx.gd','scripts/ui/game_ui.gd','data/balance.json',
 'assets/icons/icon.png','docs/THIRD_PARTY_NOTICES.md','docs/DEBUG_CHECK_1_5_1.md','docs/UPDATE_1_1.md','docs/UPDATE_1_2.md','docs/UPDATE_1_3.md','docs/TEST_REPORT_1_3.md','docs/UPDATE_1_4.md','docs/TEST_REPORT_1_4.md','docs/UPDATE_1_5.md','docs/TEST_REPORT_1_5.md',
 'tests/test_runner.gd','tests/balance_simulation.py',
 'assets/audio/zombie_groan1.wav','assets/audio/zombie_groan2.wav','assets/audio/zombie_snarl.wav','assets/audio/zombie_death.wav','assets/audio/zombie_crowd.wav',
 'assets/models/survivor_head.obj','assets/models/survivor_torso.obj','assets/models/survivor_arm.obj','assets/models/survivor_leg.obj','assets/models/zombie_head.obj','assets/models/zombie_torso.obj','assets/models/zombie_arm.obj','assets/models/zombie_leg.obj','assets/models/combat_boot.obj','assets/models/wrecked_car.obj','tools/generate_models.py',
 'assets/textures/asphalt_albedo.png','assets/textures/asphalt_normal.png','assets/textures/concrete_albedo.png','assets/textures/concrete_normal.png',
 'assets/textures/zombie_skin_albedo.png','assets/textures/zombie_skin_normal.png','assets/textures/survivor_fabric_albedo.png','assets/textures/survivor_fabric_normal.png',
 'assets/textures/asphalt_roughness.png','assets/textures/concrete_roughness.png','assets/textures/rusty_metal_roughness.png','assets/textures/painted_metal_roughness.png',
 'assets/textures/survivor_fabric_roughness.png','assets/textures/dark_cloth_roughness.png','assets/textures/zombie_skin_roughness.png','assets/textures/charred_roughness.png','assets/textures/water_roughness.png',
 'assets/models/assault_rifle.obj','assets/models/smg.obj','assets/models/shotgun.obj','assets/models/piercer.obj',
 'assets/models/wrecked_bus.obj','assets/models/ambulance_wreck.obj','assets/models/military_truck.obj','assets/models/helicopter_wreck.obj','assets/models/crane_tower.obj',
 'assets/models/quarantine_booth.obj','assets/models/shipping_container.obj','assets/models/jersey_barrier.obj','assets/models/streetlight.obj','assets/models/sandbag.obj','assets/models/rooftop_tank.obj','assets/models/billboard_frame.obj','assets/models/utility_transformer.obj','assets/models/satellite_dish.obj',
 'assets/models/zombie_runner_torso.obj','assets/models/zombie_armored_torso.obj','assets/models/zombie_brute_torso.obj','assets/models/zombie_spitter_torso.obj','assets/models/zombie_colossus_torso.obj',
 'assets/textures/brick_albedo.png','assets/textures/brick_normal.png','assets/textures/brick_roughness.png','assets/textures/olive_canvas_albedo.png','assets/textures/olive_canvas_normal.png','assets/textures/olive_canvas_roughness.png','assets/textures/sandbag_albedo.png','assets/textures/sandbag_normal.png','assets/textures/sandbag_roughness.png','assets/textures/dirty_glass_albedo.png','assets/textures/dirty_glass_normal.png','assets/textures/dirty_glass_roughness.png','assets/textures/hazard_plastic_albedo.png','assets/textures/hazard_plastic_normal.png','assets/textures/hazard_plastic_roughness.png','assets/textures/rubber_albedo.png','assets/textures/rubber_normal.png','assets/textures/rubber_roughness.png',
 'tools/generate_environment_models.py','tools/generate_surface_textures_v14.py',

 'assets/models/survivor_backpack_v15.obj','assets/models/survivor_glove_v15.obj','assets/models/zombie_hand_v15.obj','assets/models/zombie_jaw_v15.obj',
 'assets/models/police_suv_wreck_v15.obj','assets/models/fire_engine_wreck_v15.obj','assets/models/rubble_chunk_v15.obj',
 'assets/textures/oil_decal_v15.png','assets/textures/blood_decal_v15.png','assets/textures/skid_decal_v15.png','assets/textures/scorch_decal_v15.png','tools/generate_graphics_v15.py',
]
missing=[p for p in required if not (root/p).exists()]
if missing:
    raise SystemExit('Missing required files: '+', '.join(missing))
json.loads((root/'data/balance.json').read_text())
refs=[]
for p in root.rglob('*'):
    if p.suffix.lower() not in {'.gd','.tscn','.godot'}: continue
    text=p.read_text(errors='ignore')
    refs += [(p, m) for m in re.findall(r'res://[A-Za-z0-9_./-]+',text)]
bad=[]
for src,ref in refs:
    rel=ref[6:]
    if rel.startswith('builds/'):
        continue
    if not (root/rel).exists(): bad.append((src.relative_to(root),ref))
if bad:
    raise SystemExit('Broken res:// references: '+repr(bad))
proj=(root/'project.godot').read_text()
for needle in ['Godot 4.7.2-stable','gl_compatibility','res://scenes/main.tscn','config/version="1.5.1"']:
    if needle not in proj: raise SystemExit('project.godot missing '+needle)

main_text=(root/'scripts/core/main.gd').read_text()
for needle in ['var player: PlayerController', 'var projectile_system: ProjectileSystem', 'var gate_system: GateSystem', 'var wave_manager: WaveManager', 'var grenade_system: GrenadeSystem', 'var upgrade_system: UpgradeSystem', 'var ui: GameUI', 'var current_boss: ZombieEnemy', 'var environment_fx: EnvironmentFX']:
    if needle not in main_text:
        raise SystemExit('main.gd system reference is not strongly typed: '+needle)
if 'projectile_system.find_target(' in main_text:
    raise SystemExit('main.gd still auto-targets zombies; 1.3 requires straight manual lane fire')
if 'func find_target(' in (root/'scripts/gameplay/projectile_system.gd').read_text():
    raise SystemExit('projectile_system.gd still contains auto-target helper; 1.3 removes targeting entirely')
for needle in ['projectile_system.fire_weapon(origin, null', '_on_fire_state_changed', 'NOTIFICATION_WM_GO_BACK_REQUEST', 'grenade_system.cancel_pending()', 'ProceduralSkyMaterial', 'fog_enabled = true', 'set_zombie_crowd']:
    if needle not in main_text:
        raise SystemExit('main.gd missing 1.3 feature '+needle)

player=(root/'scripts/gameplay/player_controller.gd').read_text()
for needle in ['var firing_held: bool', 'func set_firing(value: bool)', 'var wants_fire := firing_held or Input.is_key_pressed(KEY_SPACE)', 'survivor_torso.obj', 'survivor_head.obj', 'survivor_arm.obj', 'survivor_leg.obj']:
    if needle not in player:
        raise SystemExit('player_controller.gd missing 1.3 control/model feature '+needle)
ui_text=(root/'scripts/ui/game_ui.gd').read_text()
for needle in ['signal fire_state_changed(pressed: bool)', 'HOLD\\nFIRE', 'button_down.connect', 'button_up.connect', '/30']:
    if needle not in ui_text:
        raise SystemExit('UI missing manual fire feature '+needle)

wave_text=(root/'scripts/gameplay/wave_manager.gd').read_text()
for needle in ['CAMPAIGN_WAVES := 30','overpass_colossus_boss','mini(value, 210)','[5, 8, 12, 16, 20, 24, 28, 30]','var concurrent_cap: int = 110','group_size = clampi(20']:
    if needle not in wave_text:
        raise SystemExit('wave_manager.gd missing 1.3 horde feature '+needle)

audio=(root/'scripts/core/audio_manager.gd').read_text()
for needle in ['zombie_crowd.wav','zombie_groan1','zombie_groan2','zombie_snarl','func set_zombie_crowd','var zombie_players: Array[AudioStreamPlayer]','0.94']:
    if needle not in audio:
        raise SystemExit('audio_manager.gd missing zombie audio '+needle)

mesh=(root/'scripts/world/mesh_factory.gd').read_text()
for needle in ['uv1_triplanar = true','normal_enabled = true','roughness_texture','func asset_mesh','zombie_skin','survivor_fabric','water']:
    if needle not in mesh:
        raise SystemExit('mesh_factory.gd missing 1.3 material/model feature '+needle)
bridge=(root/'scripts/world/bridge_builder.gd').read_text()
for needle in ['_build_quarantine_checkpoint','_build_bus_wreck','_build_ambulance','deadlane_fire','QUARANTINE  •  EVAC ROUTE','wrecked_car.obj']:
    if needle not in bridge:
        raise SystemExit('bridge_builder.gd missing art feature '+needle)
enemy=(root/'scripts/gameplay/enemy.gd').read_text()
for needle in ['var detail_root: Node3D','detail_root.visible','zombie_torso.obj','zombie_head.obj','zombie_arm.obj','zombie_leg.obj','combat_boot.obj']:
    if needle not in enemy:
        raise SystemExit('enemy.gd missing 1.3 model feature '+needle)

for needle in ['zombie_runner_torso.obj','zombie_armored_torso.obj','zombie_brute_torso.obj','zombie_spitter_torso.obj','zombie_colossus_torso.obj']:
    if needle not in enemy:
        raise SystemExit('enemy.gd missing v1.4 silhouette mesh '+needle)
for needle in ['_build_broken_flyover','_build_helicopter_crash','_build_crane_ruin','_build_rooftop_silhouettes','deadlane_ember','military_truck.obj','quarantine_booth.obj']:
    if needle not in bridge:
        raise SystemExit('bridge_builder.gd missing v1.4 peripheral feature '+needle)
for needle in ['brick','olive_canvas','sandbag','dirty_glass','hazard_plastic','rubber','emissive_material','emissive_tapered_cylinder']:
    if needle not in mesh:
        raise SystemExit('mesh_factory.gd missing v1.4 material feature '+needle)
for needle in ['assault_rifle.obj','smg.obj','shotgun.obj','piercer.obj']:
    if needle not in player:
        raise SystemExit('player_controller.gd missing v1.4 weapon mesh '+needle)

for rel in ['scripts/gameplay/projectile_system.gd','scripts/gameplay/grenade_system.gd']:
    text=(root/rel).read_text()
    if 'var enemies: Array[ZombieEnemy] = []' not in text:
        raise SystemExit(f'{rel} enemy collection must remain strongly typed for Godot 4.7 parser safety')

# Guard the higher-detail model pass against accidentally shipping the old placeholder geometry.
model_min_faces = {
    'assets/models/survivor_head.obj': 2500,
    'assets/models/survivor_torso.obj': 1400,
    'assets/models/survivor_arm.obj': 650,
    'assets/models/survivor_leg.obj': 650,
    'assets/models/zombie_head.obj': 2500,
    'assets/models/zombie_torso.obj': 1200,
    'assets/models/zombie_arm.obj': 700,
    'assets/models/zombie_leg.obj': 700,
    'assets/models/wrecked_car.obj': 650,
}
for rel, minimum in model_min_faces.items():
    faces=sum(1 for line in (root/rel).read_text(errors='ignore').splitlines() if line.startswith('f '))
    if faces < minimum:
        raise SystemExit(f'{rel} regressed to placeholder geometry: {faces} faces < {minimum}')

workflow=(root/'.github/workflows/android.yml').read_text()
for needle in ['godot --headless --path . --import --quit','apksigner','if: always()','DEADLANE-CI-Diagnostics','curl -fL --retry 4','python3 -m py_compile','continue-on-error: true','commandlinetools-linux-${CLI_BUILD}_latest.zip']:
    if needle not in workflow:
        raise SystemExit('CI workflow missing reliability check '+needle)
if re.search(r'uses:\s*android-actions/setup-android', workflow):
    raise SystemExit('CI workflow regressed to broken android-actions/setup-android path')
if 'find scripts tests tools -type f' in workflow:
    raise SystemExit('CI workflow still uses fragile per-script runtime scan')
export=(root/'export_presets.cfg').read_text()
for needle in ['architectures/arm64-v8a=true','package/unique_name="com.deadlane.zombiebridge"','launcher_icons/main_192x192="res://assets/icons/icon.png"','version/code=6','version/name="1.5.1"']:
    if needle not in export:
        raise SystemExit('Android export preset missing '+needle)

print(f'STATIC VALIDATION PASSED: {len(required)} required files, {len(refs)} resource references checked')
# v1.5 graphics checks
for needle in ['survivor_backpack_v15.obj','survivor_glove_v15.obj']:
    if needle not in player:
        raise SystemExit('player_controller.gd missing v1.5 model '+needle)
for needle in ['zombie_hand_v15.obj','zombie_jaw_v15.obj']:
    if needle not in enemy:
        raise SystemExit('enemy.gd missing v1.5 model '+needle)
for needle in ['decal_material','decal_quad','TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC']:
    if needle not in mesh:
        raise SystemExit('mesh_factory.gd missing v1.5 rendering feature '+needle)
for needle in ['_build_police_wreck_v15','_build_fire_engine_wreck_v15','_build_rubble_cluster_v15','blood_decal_v15.png','skid_decal_v15.png']:
    if needle not in bridge:
        raise SystemExit('bridge_builder.gd missing v1.5 world feature '+needle)

v15_model_min_faces = {
    'assets/models/survivor_backpack_v15.obj': 200,
    'assets/models/survivor_glove_v15.obj': 450,
    'assets/models/zombie_hand_v15.obj': 500,
    'assets/models/zombie_jaw_v15.obj': 450,
    'assets/models/police_suv_wreck_v15.obj': 2300,
    'assets/models/fire_engine_wreck_v15.obj': 4000,
}
for rel, minimum in v15_model_min_faces.items():
    faces=sum(1 for line in (root/rel).read_text(errors='ignore').splitlines() if line.startswith('f '))
    if faces < minimum:
        raise SystemExit(f'{rel} v1.5 geometry too simple: {faces} faces < {minimum}')


projectiles=(root/'scripts/gameplay/projectile_system.gd').read_text()
for needle in ['MF.emissive_material(Color("#ffd765"), 2.7', 'MF.emissive_material(Color("#ffbd4a"), 3.2', '"life": 0.11', 'var pulse :=']:
    if needle not in projectiles:
        raise SystemExit('projectile_system.gd missing v1.5 combat VFX feature '+needle)
for needle in ['MF.emissive_sphere(muzzle', 'survivor_backpack_v15.obj', 'survivor_glove_v15.obj']:
    if needle not in player:
        raise SystemExit('player_controller.gd missing v1.5 visual feature '+needle)

print('UPDATE 1.5 GRAPHICS / WORLD / MANUAL-FIRE CHECKS PASSED')

# v1.5.1 debug regression checks.
if 'config/quit_on_go_back=false' not in proj:
    raise SystemExit('Android back handling requires application/config/quit_on_go_back=false')
if 'eligible.shuffle()' in (root/'scripts/gameplay/upgrade_system.gd').read_text():
    raise SystemExit('Upgrade RNG must not use global Array.shuffle(); checkpoint determinism would break')
for needle in ['player.set_active(false)', 'var resume_in_progress: bool', 'background_paused_noncombat', 'create_timer(3.0, false)', 'create_timer(2.0, false)']:
    if needle not in main_text:
        raise SystemExit('main.gd missing v1.5.1 debug fix '+needle)
ui_debug=(root/'scripts/ui/game_ui.gd').read_text()
if 'create_timer(seconds, true)' in ui_debug:
    raise SystemExit('UI tutorial/banner timers must freeze with gameplay pause')
save_text=(root/'scripts/core/save_manager.gd').read_text()
for needle in ['func _validate_checkpoint', 'return not load_checkpoint().is_empty()']:
    if needle not in save_text:
        raise SystemExit('save_manager.gd missing checkpoint validation '+needle)
