extends Node3D

const PlayerScript = preload("res://scripts/gameplay/player_controller.gd")
const EnemyScript = preload("res://scripts/gameplay/enemy.gd")
const ProjectileScript = preload("res://scripts/gameplay/projectile_system.gd")
const GateScript = preload("res://scripts/gameplay/gate_system.gd")
const WaveScript = preload("res://scripts/gameplay/wave_manager.gd")
const GrenadeScript = preload("res://scripts/gameplay/grenade_system.gd")
const UpgradeScript = preload("res://scripts/gameplay/upgrade_system.gd")
const UIScript = preload("res://scripts/ui/game_ui.gd")
const Bridge = preload("res://scripts/world/bridge_builder.gd")
const MF = preload("res://scripts/world/mesh_factory.gd")
const EnvironmentFXScript = preload("res://scripts/world/environment_fx.gd")

var balance: Dictionary = {}
var rng := RandomNumberGenerator.new()
var player: PlayerController
var projectile_system: ProjectileSystem
var gate_system: GateSystem
var wave_manager: WaveManager
var grenade_system: GrenadeSystem
var upgrade_system: UpgradeSystem
var ui: GameUI
var active_enemies: Array[ZombieEnemy] = []
var enemy_pool: Array[ZombieEnemy] = []
var hazards: Array[Dictionary] = []
var current_boss: ZombieEnemy
var current_wave: int = 1
var score: int = 0
var defense_health: int = 100
var max_defense_health: int = 100
var current_weapon: String = "assault_rifle"
var endless_mode: bool = false
var gate_countdown: float = -1.0
var gate_spawned_this_wave: bool = false
var pending_upgrade_choices: Array[String] = []
var pending_next_wave: int = 1
var run_started: bool = false
const CAMPAIGN_WAVES := 30

var sun_light: DirectionalLight3D
var world_environment: Environment
var sky_material: ProceduralSkyMaterial
var gameplay_camera: Camera3D
var environment_fx: EnvironmentFX
var separation_timer: float = 0.0
var zombie_voice_timer: float = 0.35
var resume_in_progress: bool = false
var background_paused_noncombat: bool = false

func _ready() -> void:
	get_tree().quit_on_go_back = false
	_load_balance()
	_build_world()
	_build_systems()
	_connect_ui()
	_apply_settings(SaveManager.profile.get("settings", {}))
	ui.show_menu(SaveManager.profile, SaveManager.has_checkpoint())
	GameState.set_state(GameState.State.MENU)

func _load_balance() -> void:
	var file := FileAccess.open("res://data/balance.json", FileAccess.READ)
	if file == null:
		push_error("Missing data/balance.json")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		balance = parsed

func _build_world() -> void:
	Bridge.build(self)
	environment_fx = EnvironmentFXScript.new()
	add_child(environment_fx)
	var env_node := WorldEnvironment.new()
	world_environment = Environment.new()
	var sky := Sky.new()
	sky_material = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("#344f6a")
	sky_material.sky_horizon_color = Color("#c18469")
	sky_material.ground_horizon_color = Color("#6d6060")
	sky_material.ground_bottom_color = Color("#242b32")
	sky_material.sky_curve = 0.24
	sky_material.ground_curve = 0.16
	sky_material.sun_angle_max = 12.0
	sky_material.sun_curve = 0.12
	sky.sky_material = sky_material
	world_environment.sky = sky
	world_environment.background_mode = Environment.BG_SKY
	world_environment.background_color = Color("#7790a2")
	world_environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world_environment.ambient_light_color = Color("#afc5d3")
	world_environment.ambient_light_energy = 0.65
	world_environment.fog_enabled = true
	world_environment.fog_light_color = Color("#8293a0")
	world_environment.fog_light_energy = 0.82
	world_environment.fog_density = 0.0085
	world_environment.fog_depth_begin = 18.0
	world_environment.fog_depth_end = 78.0
	world_environment.fog_depth_curve = 1.25
	world_environment.fog_sky_affect = 0.72
	world_environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	world_environment.tonemap_exposure = 1.05
	world_environment.tonemap_white = 6.0
	world_environment.adjustment_enabled = true
	world_environment.adjustment_brightness = 1.02
	world_environment.adjustment_contrast = 1.13
	world_environment.adjustment_saturation = 0.90
	env_node.environment = world_environment
	add_child(env_node)
	sun_light = DirectionalLight3D.new()
	sun_light.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	sun_light.light_color = Color("#ffd8a1")
	sun_light.light_energy = 1.32
	sun_light.shadow_enabled = true
	sun_light.directional_shadow_max_distance = 76.0
	sun_light.shadow_bias = 0.035
	sun_light.shadow_normal_bias = 1.0
	add_child(sun_light)
	var fill_light := DirectionalLight3D.new()
	fill_light.rotation_degrees = Vector3(-28.0, 148.0, 0.0)
	fill_light.light_color = Color("#789dcc")
	fill_light.light_energy = 0.30
	fill_light.shadow_enabled = false
	add_child(fill_light)
	gameplay_camera = Camera3D.new()
	gameplay_camera.position = Vector3(0.0, 8.1, 8.55)
	gameplay_camera.fov = 51.0
	gameplay_camera.keep_aspect = Camera3D.KEEP_WIDTH
	add_child(gameplay_camera)
	gameplay_camera.look_at(Vector3(0.0, 0.92, -13.0))
	gameplay_camera.current = true

func _build_systems() -> void:
	player = PlayerScript.new()
	player.position = Vector3(0.0, 0.0, 0.0)
	add_child(player)
	player.fire_requested.connect(_on_player_fire)
	projectile_system = ProjectileScript.new()
	add_child(projectile_system)
	gate_system = GateScript.new()
	add_child(gate_system)
	projectile_system.set_gate_system(gate_system)
	wave_manager = WaveScript.new()
	add_child(wave_manager)
	wave_manager.spawn_requested.connect(_on_spawn_requested)
	wave_manager.wave_cleared.connect(_on_wave_cleared)
	grenade_system = GrenadeScript.new()
	add_child(grenade_system)
	grenade_system.detonated.connect(_on_grenade_detonated)
	grenade_system.set_process(false)
	upgrade_system = UpgradeScript.new()
	add_child(upgrade_system)
	ui = UIScript.new()
	add_child(ui)
	projectile_system.set_enemy_array(active_enemies)
	grenade_system.set_enemy_array(active_enemies)
	player.set_active(false)

func _connect_ui() -> void:
	ui.new_run_requested.connect(_on_new_run_requested)
	ui.continue_requested.connect(_on_continue_requested)
	ui.endless_requested.connect(_on_endless_requested)
	ui.weapon_selected.connect(_on_weapon_selected)
	ui.pause_requested.connect(_on_pause_requested)
	ui.resume_requested.connect(_on_resume_requested)
	ui.grenade_requested.connect(_on_grenade_requested)
	ui.fire_state_changed.connect(_on_fire_state_changed)
	ui.upgrade_selected.connect(_on_upgrade_selected)
	ui.restart_requested.connect(_on_restart_requested)
	ui.menu_requested.connect(_return_to_menu)
	ui.credits_requested.connect(_on_credits_requested)
	ui.settings_changed.connect(_on_settings_changed)

func _process(delta: float) -> void:
	if GameState.state == GameState.State.PLAYING:
		AudioManager.set_zombie_crowd(active_enemies.size(), current_boss != null)
		if not active_enemies.is_empty():
			zombie_voice_timer -= delta
			if zombie_voice_timer <= 0.0:
				zombie_voice_timer = rng.randf_range(0.75, 1.55) if active_enemies.size() >= 10 else rng.randf_range(1.25, 2.4)
				var ambient_voice := String(["zombie_groan1", "zombie_groan2", "zombie_snarl"][rng.randi_range(0, 2)])
				AudioManager.play_sfx(ambient_voice, rng.randf_range(0.83, 1.14), 0.94)
		if gate_countdown >= 0.0 and not gate_spawned_this_wave:
			gate_countdown -= delta
			if gate_countdown <= 0.0:
				gate_system.activate(rng, current_wave)
				gate_spawned_this_wave = true
				AudioManager.play_sfx("gate")
		_process_hazards(delta)
		separation_timer -= delta
		if separation_timer <= 0.0:
			separation_timer = 0.10
			_apply_local_separation()
		_update_boss_bar()
	else:
		AudioManager.set_zombie_crowd(0, false)
	ui.update_hud(defense_health, max_defense_health, current_wave, score, grenade_system.cooldown_remaining, endless_mode)

func _on_new_run_requested() -> void:
	ui.show_weapon_select(SaveManager.profile.get("unlocked_weapons", ["assault_rifle"]), "campaign")
	GameState.set_state(GameState.State.WEAPON_SELECT)

func _on_endless_requested() -> void:
	if not bool(SaveManager.profile.get("campaign_completed", false)):
		return
	ui.show_weapon_select(SaveManager.profile.get("unlocked_weapons", ["assault_rifle"]), "endless")
	GameState.set_state(GameState.State.WEAPON_SELECT)

func _on_weapon_selected(weapon: String, mode: String) -> void:
	_start_new_run(weapon, mode == "endless")

func _start_new_run(weapon: String, is_endless: bool) -> void:
	_cleanup_runtime()
	SaveManager.clear_checkpoint()
	current_weapon = weapon
	endless_mode = is_endless
	current_wave = 1
	score = 0
	defense_health = 100
	max_defense_health = 100
	upgrade_system.reset()
	grenade_system.reset()
	rng.randomize()
	run_started = true
	player.position.x = 0.0
	player.target_x = 0.0
	player.set_weapon_visual(current_weapon)
	_start_wave(current_wave)

func _on_continue_requested() -> void:
	var data := SaveManager.load_checkpoint()
	if data.is_empty():
		ui.show_menu(SaveManager.profile, false)
		return
	_cleanup_runtime()
	current_weapon = String(data.get("weapon", "assault_rifle"))
	endless_mode = String(data.get("mode", "campaign")) == "endless"
	current_wave = maxi(1, int(data.get("next_wave", 1)))
	score = maxi(0, int(data.get("score", 0)))
	defense_health = maxi(0, int(data.get("health", 100)))
	upgrade_system.restore(data.get("upgrades", {}))
	max_defense_health = 100 + upgrade_system.max_health_bonus()
	defense_health = clampi(defense_health, 0, max_defense_health)
	grenade_system.reset()
	grenade_system.cooldown_remaining = clampf(float(data.get("grenade_cooldown", 0.0)), 0.0, grenade_system.cooldown_total)
	var saved_seed := String(data.get("rng_seed", "0"))
	var saved_state := String(data.get("rng_state", "0"))
	if saved_seed.is_valid_int():
		rng.seed = int(saved_seed)
	else:
		rng.randomize()
	if saved_state.is_valid_int():
		rng.state = int(saved_state)
	player.set_weapon_visual(current_weapon)
	run_started = true
	if bool(data.get("pending_upgrade", false)):
		pending_next_wave = current_wave
		pending_upgrade_choices.clear()
		for value in data.get("pending_upgrade_choices", []):
			pending_upgrade_choices.append(String(value))
		if pending_upgrade_choices.is_empty():
			pending_upgrade_choices = upgrade_system.choices(rng, defense_health, max_defense_health)
		GameState.set_state(GameState.State.UPGRADE_SELECTION)
		ui.show_upgrades(pending_upgrade_choices)
	else:
		_start_wave(current_wave)

func _start_wave(number: int) -> void:
	current_wave = number
	GameState.set_state(GameState.State.PLAYING)
	ui.show_hud()
	ui.hide_boss()
	grenade_system.set_process(true)
	player.set_active(true)
	var weapon_stats: Dictionary = balance.get("weapons", {}).get(current_weapon, {})
	player.configure_fire_rate(float(weapon_stats.get("fire_rate", 7.0)) * upgrade_system.rate_multiplier())
	wave_manager.start_wave(number, rng, endless_mode)
	_apply_wave_atmosphere(number)
	gate_spawned_this_wave = false
	gate_countdown = 3.2 if number >= 3 and number % 3 == 0 else -1.0
	AudioManager.play_music()
	ui.flash_banner("WAVE %d  •  %s" % [number, _stage_name(number)], 1.4)
	if WaveScript.is_rush_wave(number):
		_warn_rush()
	if number == 1:
		ui.show_tutorial("DRAG LEFT OR RIGHT TO AIM YOUR LANE. HOLD FIRE TO SHOOT STRAIGHT AHEAD.\nANY ZOMBIE THAT REACHES THE LINE DAMAGES DEFENSE. TAP GRENADE FOR A CLUSTER ATTACK.", 6.0)
	elif number == 3:
		ui.show_tutorial("MOVE YOUR SHOTS THROUGH ×2 / ×3 GATES. ZOMBIES WALK THROUGH GATES NORMALLY.", 4.0)
	elif number == 7:
		ui.show_tutorial("GREEN WARNING ZONES LOCK YOUR POSITION WHEN THEY APPEAR. MOVE BEFORE THE ATTACK LANDS.", 4.0)
	elif number == 21:
		ui.show_tutorial("NIGHTFALL: HEAVIER MIXED HORDES ARRIVE FASTER. KEEP MOVING AND SAVE GRENADES FOR SURGES.", 4.2)
	elif number == 30:
		ui.show_tutorial("FINAL WAVE: THE OVERPASS COLOSSUS SLAMS WIDE AREAS. DODGE THE WARNING ZONE BEFORE IMPACT.", 4.6)

func _stage_name(number: int) -> String:
	if number <= 10:
		return "EVACUATION"
	if number <= 20:
		return "SUNSET SIEGE"
	if number <= 30:
		return "NIGHTFALL"
	return "ENDLESS"

func _boss_title(kind: String) -> String:
	if kind == "bridge_brute_boss":
		return "BRIDGE BRUTE"
	if kind == "plague_giant_boss":
		return "PLAGUE GIANT"
	if kind == "overpass_colossus_boss":
		return "OVERPASS COLOSSUS"
	return "BOSS"

func _apply_wave_atmosphere(number: int) -> void:
	if world_environment == null or sun_light == null:
		return
	if number <= 10:
		world_environment.background_color = Color("#7790a2")
		if sky_material != null:
			sky_material.sky_top_color = Color("#344f6a")
			sky_material.sky_horizon_color = Color("#c18469")
		world_environment.ambient_light_color = Color("#afc5d3")
		world_environment.ambient_light_energy = 0.65
		world_environment.fog_light_color = Color("#8293a0")
		world_environment.fog_density = 0.0085
		sun_light.light_color = Color("#ffd8a1")
		sun_light.light_energy = 1.25
	elif number <= 20:
		world_environment.background_color = Color("#6e7282")
		if sky_material != null:
			sky_material.sky_top_color = Color("#3e455f")
			sky_material.sky_horizon_color = Color("#c56b51")
		world_environment.ambient_light_color = Color("#a8a9bb")
		world_environment.ambient_light_energy = 0.59
		world_environment.fog_light_color = Color("#776f78")
		world_environment.fog_density = 0.0105
		sun_light.light_color = Color("#f5b477")
		sun_light.light_energy = 1.15
	else:
		world_environment.background_color = Color("#3f4b61")
		if sky_material != null:
			sky_material.sky_top_color = Color("#18273d")
			sky_material.sky_horizon_color = Color("#5d4552")
		world_environment.ambient_light_color = Color("#7e91ad")
		world_environment.ambient_light_energy = 0.54
		world_environment.fog_light_color = Color("#465368")
		world_environment.fog_density = 0.0135
		sun_light.light_color = Color("#d39a82")
		sun_light.light_energy = 0.92

func _warn_rush() -> void:
	await get_tree().create_timer(2.0, false).timeout
	if GameState.state == GameState.State.PLAYING:
		ui.flash_banner("⚠ DENSE RUSH INCOMING", 1.7)

func _on_player_fire(origin: Vector3) -> void:
	if GameState.state != GameState.State.PLAYING:
		return
	var weapon_stats: Dictionary = balance.get("weapons", {}).get(current_weapon, {})
	# No auto-targeting: every projectile starts straight down the survivor's
	# current lane. Positioning is the aim mechanic.
	projectile_system.fire_weapon(origin, null, weapon_stats, upgrade_system.damage_multiplier(), upgrade_system.extra_penetration())
	player.kick_recoil()
	AudioManager.play_sfx(String(weapon_stats.get("sound", "rifle")), rng.randf_range(0.96, 1.04))

func _on_spawn_requested(kind: String, spawn_x: float) -> void:
	_spawn_enemy(kind, spawn_x, false)

func _spawn_enemy(kind: String, spawn_x: float, summoned: bool) -> void:
	var enemy: ZombieEnemy
	if not enemy_pool.is_empty():
		enemy = enemy_pool.pop_back()
	else:
		enemy = EnemyScript.new()
		add_child(enemy)
		enemy.removed.connect(_on_enemy_removed)
		enemy.aimed_attack.connect(_on_aimed_attack)
		enemy.summon_requested.connect(_on_summon_requested)
	var source_kind := kind
	if kind == "bridge_brute_boss":
		source_kind = "brute"
	elif kind == "plague_giant_boss":
		source_kind = "spitter"
	elif kind == "overpass_colossus_boss":
		source_kind = "brute"
	var stats: Dictionary = balance.get("enemies", {}).get(source_kind, {}).duplicate(true)
	var hp_scale := 1.0
	if not kind.ends_with("boss"):
		hp_scale = 1.0 + 0.04 * float(current_wave - 1)
		var speed_scale := minf(1.35, 1.0 + 0.015 * float(current_wave - 1))
		stats["speed"] = float(stats.get("speed", 1.8)) * speed_scale
	else:
		stats["breach_damage"] = 35 if kind == "overpass_colossus_boss" else 30
		if kind == "bridge_brute_boss":
			stats["hit_radius"] = 0.8
		elif kind == "plague_giant_boss":
			stats["hit_radius"] = 1.0
		else:
			stats["hit_radius"] = 1.15
	enemy.setup(kind, stats, hp_scale, spawn_x, player, rng.randf_range(0.0, TAU))
	active_enemies.append(enemy)
	if not kind.ends_with("boss") and rng.randf() < 0.72:
		var zombie_voice := String(["zombie_groan1", "zombie_groan2", "zombie_snarl"][rng.randi_range(0, 2)])
		AudioManager.play_sfx(zombie_voice, rng.randf_range(0.88, 1.12), 1.12)
	if kind.ends_with("boss"):
		AudioManager.play_sfx("zombie_groan2", 0.70, 1.35)
		current_boss = enemy
		ui.show_boss(_boss_title(kind), enemy.hp, enemy.max_hp)
	if summoned:
		projectile_system.set_enemy_array(active_enemies)
		grenade_system.set_enemy_array(active_enemies)

func _on_enemy_removed(enemy: ZombieEnemy, breached: bool, damage: int) -> void:
	if not active_enemies.has(enemy):
		return
	active_enemies.erase(enemy)
	if breached:
		_damage_defense(damage)
	else:
		score += int(enemy.point_value)
		AudioManager.play_sfx("death", rng.randf_range(0.92, 1.08), 0.72)
		if rng.randf() < 0.60:
			AudioManager.play_sfx("zombie_death", rng.randf_range(0.82, 1.08), 1.08)
	if current_boss == enemy:
		current_boss = null
		ui.hide_boss()
	wave_manager.register_enemy_removed()
	enemy_pool.append(enemy)
	projectile_system.set_enemy_array(active_enemies)
	grenade_system.set_enemy_array(active_enemies)

func _on_summon_requested(enemy: ZombieEnemy) -> void:
	if GameState.state != GameState.State.PLAYING or wave_manager.living_count >= wave_manager.concurrent_cap:
		return
	for offset in [-1.0, 0.0, 1.0]:
		if wave_manager.living_count >= wave_manager.concurrent_cap:
			break
		wave_manager.register_summoned_enemy()
		_spawn_enemy("shambler", clampf(enemy.position.x + offset * 1.2 + rng.randf_range(-0.25, 0.25), -4.0, 4.0), true)

func _on_aimed_attack(_enemy: ZombieEnemy, target_x: float, damage: int, radius: float, delay: float, attack_kind: String) -> void:
	if GameState.state != GameState.State.PLAYING:
		return
	var warning := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.035
	mesh.radial_segments = 28
	var color := Color(0.52, 0.95, 0.25, 0.30) if attack_kind.contains("acid") else Color(1.0, 0.27, 0.18, 0.32)
	mesh.material = MF.material(color, 0.8, 0.0, true)
	warning.mesh = mesh
	warning.position = Vector3(target_x, 0.06, -0.75)
	add_child(warning)
	hazards.append({"time": delay, "x": target_x, "damage": damage, "radius": radius, "node": warning, "kind": attack_kind})

func _process_hazards(delta: float) -> void:
	var i := hazards.size() - 1
	while i >= 0:
		hazards[i]["time"] = float(hazards[i]["time"]) - delta
		if float(hazards[i]["time"]) <= 0.0:
			if absf(player.position.x - float(hazards[i]["x"])) <= float(hazards[i]["radius"]):
				_damage_defense(int(hazards[i]["damage"]))
			var node: Node3D = hazards[i]["node"]
			if is_instance_valid(node):
				node.queue_free()
			hazards.remove_at(i)
		i -= 1

func _damage_defense(amount: int) -> void:
	if GameState.state != GameState.State.PLAYING:
		return
	defense_health = maxi(0, defense_health - amount)
	AudioManager.play_sfx("hit")
	if defense_health <= 0:
		_game_over()


func _on_fire_state_changed(pressed: bool) -> void:
	if GameState.state == GameState.State.PLAYING:
		player.set_firing(pressed)
	else:
		player.set_firing(false)

func _on_grenade_requested() -> void:
	if GameState.state != GameState.State.PLAYING:
		return
	if grenade_system.request_throw(160.0, upgrade_system.grenade_multiplier()):
		var settings: Dictionary = SaveManager.profile.get("settings", {})
		if bool(settings.get("vibration", true)):
			Input.vibrate_handheld(45)

func _on_grenade_detonated(_position: Vector3) -> void:
	AudioManager.play_sfx("grenade")

func _apply_local_separation() -> void:
	# Separation steers each zombie's lane target instead of snapping its transform.
	# That keeps dense packs readable without the side-to-side jitter of hard pushes.
	var ordered: Array[ZombieEnemy] = []
	for enemy in active_enemies:
		if is_instance_valid(enemy) and enemy.is_alive():
			ordered.append(enemy)
	ordered.sort_custom(_sort_enemy_z)
	for i in range(ordered.size()):
		var a: ZombieEnemy = ordered[i]
		for j in range(i + 1, ordered.size()):
			var b: ZombieEnemy = ordered[j]
			if b.position.z - a.position.z > 0.72:
				break
			if absf(a.position.x - b.position.x) < 0.50:
				var push: float = 0.12 if a.position.x >= b.position.x else -0.12
				a.lane_bias = clampf(a.lane_bias + push, -4.05, 4.05)
				b.lane_bias = clampf(b.lane_bias - push, -4.05, 4.05)

func _sort_enemy_z(a: ZombieEnemy, b: ZombieEnemy) -> bool:
	return a.position.z < b.position.z

func _update_boss_bar() -> void:
	if current_boss != null and is_instance_valid(current_boss) and current_boss.active:
		ui.show_boss(_boss_title(String(current_boss.enemy_type)), current_boss.hp, current_boss.max_hp)

func _on_wave_cleared(number: int) -> void:
	if GameState.state != GameState.State.PLAYING or number != current_wave:
		return
	GameState.set_state(GameState.State.WAVE_TRANSITION)
	player.set_active(false)
	grenade_system.cancel_pending()
	grenade_system.set_process(false)
	gate_system.deactivate()
	projectile_system.clear_all()
	_clear_hazards()
	_unlock_for_wave(number)
	SaveManager.profile["best_wave"] = maxi(int(SaveManager.profile.get("best_wave", 0)), number)
	SaveManager.profile["best_score"] = maxi(int(SaveManager.profile.get("best_score", 0)), score)
	SaveManager.save_profile()
	ui.flash_banner("WAVE %d CLEARED" % number, 2.0)
	if not endless_mode and number >= CAMPAIGN_WAVES:
		await get_tree().create_timer(3.0, false).timeout
		_victory()
		return
	var next_wave := number + 1
	if [4, 8, 12, 16, 20, 24, 28].has(number):
		pending_upgrade_choices = upgrade_system.choices(rng, defense_health, max_defense_health)
		pending_next_wave = next_wave
		_save_checkpoint(next_wave, true, pending_upgrade_choices)
		await get_tree().create_timer(3.0, false).timeout
		if GameState.state != GameState.State.WAVE_TRANSITION:
			return
		GameState.set_state(GameState.State.UPGRADE_SELECTION)
		ui.show_upgrades(pending_upgrade_choices)
	else:
		_save_checkpoint(next_wave, false, [])
		await get_tree().create_timer(3.0, false).timeout
		if GameState.state == GameState.State.WAVE_TRANSITION:
			_start_wave(next_wave)

func _unlock_for_wave(number: int) -> void:
	var unlocked: Array = SaveManager.profile.get("unlocked_weapons", ["assault_rifle"])
	var changed := false
	if number >= 4 and not unlocked.has("smg"):
		unlocked.append("smg")
		changed = true
	if number >= 8 and not unlocked.has("shotgun"):
		unlocked.append("shotgun")
		changed = true
	if number >= 12 and not unlocked.has("piercer"):
		unlocked.append("piercer")
		changed = true
	if changed:
		SaveManager.profile["unlocked_weapons"] = unlocked
		SaveManager.save_profile()

func _on_upgrade_selected(id: String) -> void:
	if GameState.state != GameState.State.UPGRADE_SELECTION:
		return
	if id == "repair":
		defense_health = mini(max_defense_health, defense_health + 30)
	elif id == "health":
		upgrade_system.apply(id)
		max_defense_health = 100 + upgrade_system.max_health_bonus()
		defense_health = mini(max_defense_health, defense_health + 20)
	else:
		upgrade_system.apply(id)
	max_defense_health = 100 + upgrade_system.max_health_bonus()
	pending_upgrade_choices.clear()
	var next_wave := pending_next_wave
	_save_checkpoint(next_wave, false, [])
	_start_wave(next_wave)

func _save_checkpoint(next_wave: int, pending_upgrade: bool, choices: Array[String]) -> void:
	SaveManager.save_checkpoint({
		"next_wave": next_wave,
		"health": defense_health,
		"weapon": current_weapon,
		"upgrades": upgrade_system.counts.duplicate(true),
		"score": score,
		"grenade_cooldown": grenade_system.cooldown_remaining,
		"rng_seed": str(rng.seed),
		"rng_state": str(rng.state),
		"pending_upgrade": pending_upgrade,
		"pending_upgrade_choices": choices,
		"mode": "endless" if endless_mode else "campaign"
	})

func _game_over() -> void:
	if GameState.state == GameState.State.GAME_OVER:
		return
	GameState.set_state(GameState.State.GAME_OVER)
	player.set_active(false)
	grenade_system.cancel_pending()
	grenade_system.set_process(false)
	wave_manager.stop()
	gate_system.deactivate()
	projectile_system.clear_all()
	_clear_hazards()
	SaveManager.profile["best_wave"] = maxi(int(SaveManager.profile.get("best_wave", 0)), current_wave)
	SaveManager.profile["best_score"] = maxi(int(SaveManager.profile.get("best_score", 0)), score)
	SaveManager.save_profile()
	SaveManager.clear_checkpoint()
	ui.show_result(false, current_wave, score, endless_mode)

func _victory() -> void:
	GameState.set_state(GameState.State.VICTORY)
	player.set_active(false)
	grenade_system.cancel_pending()
	grenade_system.set_process(false)
	SaveManager.profile["campaign_completed"] = true
	SaveManager.profile["best_wave"] = maxi(int(SaveManager.profile.get("best_wave", 0)), CAMPAIGN_WAVES)
	SaveManager.profile["best_score"] = maxi(int(SaveManager.profile.get("best_score", 0)), score)
	SaveManager.save_profile()
	SaveManager.clear_checkpoint()
	ui.show_result(true, current_wave, score, false)

func _on_restart_requested() -> void:
	var mode := "endless" if endless_mode else "campaign"
	ui.show_weapon_select(SaveManager.profile.get("unlocked_weapons", ["assault_rifle"]), mode)
	GameState.set_state(GameState.State.WEAPON_SELECT)

func _on_pause_requested() -> void:
	if GameState.state != GameState.State.PLAYING:
		return
	# Hard-stop held-fire state before hiding the HUD. Without this, a touch
	# interrupted by pause/focus loss can resume firing with no finger down.
	player.set_active(false)
	AudioManager.set_zombie_crowd(0, false)
	resume_in_progress = false
	GameState.set_state(GameState.State.PAUSED)
	ui.show_pause(SaveManager.profile.get("settings", {}))
	get_tree().paused = true

func _on_resume_requested() -> void:
	if GameState.state != GameState.State.PAUSED or resume_in_progress:
		return
	resume_in_progress = true
	for value in [3, 2, 1]:
		ui.show_resume_count(value)
		await get_tree().create_timer(0.75, true).timeout
	ui.hide_banner()
	get_tree().paused = false
	GameState.set_state(GameState.State.PLAYING)
	ui.show_hud()
	player.set_active(true)
	resume_in_progress = false

func _on_settings_changed(settings: Dictionary) -> void:
	SaveManager.profile["settings"] = settings
	SaveManager.save_profile()
	_apply_settings(settings)

func _apply_settings(settings: Dictionary) -> void:
	AudioManager.configure(settings)
	Engine.max_fps = int(settings.get("fps", 60))
	var quality := String(settings.get("quality", "medium"))
	var reduced := bool(settings.get("reduced_effects", false)) or quality == "low"
	if sun_light != null:
		sun_light.shadow_enabled = quality != "low"
		sun_light.directional_shadow_max_distance = 88.0 if quality == "high" else 68.0
	var viewport := get_viewport()
	if viewport != null:
		viewport.msaa_3d = Viewport.MSAA_4X if quality == "high" else (Viewport.MSAA_2X if quality == "medium" else Viewport.MSAA_DISABLED)
	if world_environment != null:
		world_environment.fog_density = 0.0092 if quality != "low" else 0.0065
		world_environment.adjustment_contrast = 1.15 if quality == "high" else 1.11
	if projectile_system != null:
		projectile_system.set_reduced_effects(reduced)
	if grenade_system != null:
		grenade_system.reduced_effects = reduced
	if environment_fx != null and environment_fx.has_method("set_quality"):
		environment_fx.call("set_quality", quality, reduced)

func _on_credits_requested() -> void:
	GameState.set_state(GameState.State.MENU)
	ui.show_credits()

func _return_to_menu() -> void:
	resume_in_progress = false
	background_paused_noncombat = false
	get_tree().paused = false
	_cleanup_runtime()
	GameState.set_state(GameState.State.MENU)
	ui.show_menu(SaveManager.profile, SaveManager.has_checkpoint())

func _cleanup_runtime() -> void:
	resume_in_progress = false
	background_paused_noncombat = false
	player.set_active(false)
	wave_manager.stop()
	gate_system.deactivate()
	projectile_system.clear_all()
	grenade_system.set_process(false)
	grenade_system.reset()
	_clear_hazards()
	for enemy in active_enemies.duplicate():
		enemy.active = false
		enemy.visible = false
		if not enemy_pool.has(enemy):
			enemy_pool.append(enemy)
	active_enemies.clear()
	current_boss = null
	projectile_system.set_enemy_array(active_enemies)
	grenade_system.set_enemy_array(active_enemies)

func _clear_hazards() -> void:
	for item in hazards:
		var node: Node3D = item["node"]
		if is_instance_valid(node):
			node.queue_free()
	hazards.clear()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if is_instance_valid(player):
			player.set_firing(false)
			player.clear_touches()
		if is_instance_valid(ui) and GameState.state == GameState.State.PLAYING:
			_on_pause_requested()
		elif GameState.state in [GameState.State.WAVE_TRANSITION, GameState.State.UPGRADE_SELECTION]:
			background_paused_noncombat = true
			get_tree().paused = true
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		if background_paused_noncombat:
			background_paused_noncombat = false
			get_tree().paused = false
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if GameState.state == GameState.State.PLAYING:
			_on_pause_requested()
		elif GameState.state == GameState.State.PAUSED:
			_on_resume_requested()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var key := event as InputEventKey
		if key.keycode == KEY_ESCAPE:
			if GameState.state == GameState.State.PLAYING:
				_on_pause_requested()
			elif GameState.state == GameState.State.PAUSED:
				_on_resume_requested()
		elif key.keycode == KEY_G and GameState.state == GameState.State.PLAYING:
			_on_grenade_requested()
