extends Node3D
class_name ZombieEnemy

signal removed(enemy: ZombieEnemy, breached: bool, breach_damage: int)
signal aimed_attack(enemy: ZombieEnemy, target_x: float, damage: int, radius: float, delay: float, attack_kind: String)
signal summon_requested(enemy: ZombieEnemy)

const MF = preload("res://scripts/world/mesh_factory.gd")

var enemy_type: String = "shambler"
var max_hp: float = 40.0
var hp: float = 40.0
var speed: float = 1.8
var current_speed: float = 0.0
var breach_damage: int = 8
var hit_radius: float = 0.42
var active: bool = false
var dying: bool = false
var death_timer: float = 0.0
var reaction_timer: float = 0.0
var player: PlayerController
var ranged_timer: float = 3.5
var summon_timer: float = 7.0
var walk_phase: float = 0.0
var visual_root: Node3D
var lane_bias: float = 0.0
var point_value: int = 10
var left_leg: Node3D
var right_leg: Node3D
var left_arm: Node3D
var right_arm: Node3D
var body_scale: float = 1.0
var spawn_blend: float = 0.0
var idle_lean: float = 0.0
var detail_root: Node3D

func _ready() -> void:
	visual_root = Node3D.new()
	add_child(visual_root)

func setup(kind: String, stats: Dictionary, hp_scale: float, spawn_x: float, player_node: PlayerController, phase: float = 0.0) -> void:
	enemy_type = kind
	player = player_node
	position = Vector3(spawn_x, 0.02, -32.0)
	walk_phase = phase
	max_hp = float(stats.get("hp", 40.0)) * hp_scale
	if kind == "bridge_brute_boss":
		max_hp = 1800.0
	elif kind == "plague_giant_boss":
		max_hp = 3600.0
	elif kind == "overpass_colossus_boss":
		max_hp = 6200.0
	hp = max_hp
	speed = float(stats.get("speed", 1.8))
	if kind == "overpass_colossus_boss":
		speed = minf(speed, 0.95)
	current_speed = speed * 0.35
	breach_damage = int(stats.get("breach_damage", 8))
	hit_radius = float(stats.get("hit_radius", 0.42))
	point_value = int(stats.get("score", int(max_hp)))
	active = true
	dying = false
	death_timer = 0.0
	reaction_timer = 0.0
	ranged_timer = 2.6 + fmod(phase, 2.0)
	summon_timer = 6.5
	visible = true
	rotation = Vector3.ZERO
	scale = Vector3.ONE
	lane_bias = spawn_x
	spawn_blend = 0.0
	idle_lean = sin(phase * 1.73) * 0.035
	_rebuild_visual()

func _rebuild_visual() -> void:
	for child in visual_root.get_children():
		child.queue_free()
	var skin := Color("#849a68")
	var skin_dark := Color("#667a53")
	var wound := Color("#6f3d42")
	var cloth := Color("#5c5264")
	var cloth_dark := Color("#393941")
	var boots := Color("#262b30")
	body_scale = 1.0
	if enemy_type == "runner":
		body_scale = 0.82
		cloth = Color("#70464e")
	elif enemy_type == "armored":
		body_scale = 1.05
		cloth = Color("#4a555f")
	elif enemy_type == "brute":
		body_scale = 1.35
		cloth = Color("#60485b")
	elif enemy_type == "spitter":
		body_scale = 1.0
		skin = Color("#80a653")
		skin_dark = Color("#5f7d42")
		cloth = Color("#57445f")
	elif enemy_type == "bridge_brute_boss":
		body_scale = 1.75
		skin = Color("#748a5b")
		cloth = Color("#51404a")
	elif enemy_type == "plague_giant_boss":
		body_scale = 2.05
		skin = Color("#6d974d")
		skin_dark = Color("#4e6c39")
		cloth = Color("#46374f")
	elif enemy_type == "overpass_colossus_boss":
		body_scale = 2.25
		skin = Color("#6f8055")
		skin_dark = Color("#4f5d3d")
		cloth = Color("#403a48")
		cloth_dark = Color("#242932")

	# Slight pooled variation prevents eighty identical copies without unique textures.
	var tint := 0.04 + 0.04 * absf(sin(walk_phase * 2.1))
	cloth = cloth.lerp(Color("#83808a"), tint)

	# v1.4 uses type-specific body meshes so the horde reads through silhouette, not only color.
	var torso_path := "res://assets/models/zombie_torso.obj"
	if enemy_type == "runner":
		torso_path = "res://assets/models/zombie_runner_torso.obj"
	elif enemy_type == "armored":
		torso_path = "res://assets/models/zombie_armored_torso.obj"
	elif enemy_type == "spitter" or enemy_type == "plague_giant_boss":
		torso_path = "res://assets/models/zombie_spitter_torso.obj"
	elif enemy_type == "brute" or enemy_type == "bridge_brute_boss":
		torso_path = "res://assets/models/zombie_brute_torso.obj"
	elif enemy_type == "overpass_colossus_boss":
		torso_path = "res://assets/models/zombie_colossus_torso.obj"
	MF.asset_mesh(visual_root, torso_path, Vector3(0.0, 1.07 * body_scale, 0.0), Vector3.ONE * body_scale, cloth, Vector3(idle_lean * 0.4, 0.0, idle_lean))
	MF.box(visual_root, Vector3(0.66, 0.16, 0.36) * body_scale, Vector3(0.0, 1.42 * body_scale, 0.0), cloth_dark, Vector3(0.0, 0.0, idle_lean))
	MF.box(visual_root, Vector3(0.52, 0.1, 0.34) * body_scale, Vector3(0.09 * body_scale, 0.78 * body_scale, 0.01), Color("#3b333c"), Vector3(0.0, 0.0, 0.12))

	# Head faces +Z toward the player. A projected jaw and brow keep the face readable.
	MF.asset_mesh(visual_root, "res://assets/models/zombie_head.obj", Vector3(0.0, 1.82 * body_scale, 0.02), Vector3.ONE * body_scale, skin, Vector3(0.03, 0.0, idle_lean * 0.8))
	MF.box(visual_root, Vector3(0.34, 0.14, 0.13) * body_scale, Vector3(0.02, 1.68 * body_scale, 0.26 * body_scale), skin_dark, Vector3(0.05, 0.0, 0.06))
	MF.box(visual_root, Vector3(0.25, 0.055, 0.025) * body_scale, Vector3(0.0, 1.72 * body_scale, 0.335 * body_scale), Color("#2e2527"))
	MF.tapered_cylinder(visual_root, 0.02 * body_scale, 0.05 * body_scale, 0.12 * body_scale, Vector3(0.0, 1.82 * body_scale, 0.29 * body_scale), skin_dark, Vector3(PI * 0.5, 0.0, 0.0), 8)
	for eye_x in [-0.105, 0.105]:
		MF.sphere(visual_root, 0.036 * body_scale, Vector3(eye_x * body_scale, 1.9 * body_scale, 0.255 * body_scale), Color("#d5dc72"), 8, 5)

	left_leg = _build_leg(-0.22 * body_scale, cloth_dark, boots)
	right_leg = _build_leg(0.22 * body_scale, cloth_dark, boots)
	left_arm = _build_arm(-0.36 * body_scale, skin, cloth, -1.0)
	right_arm = _build_arm(0.36 * body_scale, skin, cloth, 1.0)

	# Close-range detail lives under one node so distant crowds can hide it cheaply.
	detail_root = Node3D.new()
	visual_root.add_child(detail_root)
	MF.asset_mesh(detail_root, "res://assets/models/zombie_jaw_v15.obj", Vector3(0.0, 1.70 * body_scale, 0.28 * body_scale), Vector3.ONE * body_scale * 0.88, skin_dark, Vector3(-0.10, 0.0, 0.0))

	# Ears, cheek damage, brows, teeth and uneven hair sell an actual undead face.
	MF.sphere(detail_root, 0.052 * body_scale, Vector3(-0.27 * body_scale, 1.83 * body_scale, 0.02), skin_dark, 8, 5)
	MF.sphere(detail_root, 0.052 * body_scale, Vector3(0.27 * body_scale, 1.83 * body_scale, 0.02), skin_dark, 8, 5)
	MF.box(detail_root, Vector3(0.11, 0.026, 0.026) * body_scale, Vector3(-0.105 * body_scale, 1.97 * body_scale, 0.275 * body_scale), Color("#3c4432"), Vector3(0.0, 0.0, 0.12))
	MF.box(detail_root, Vector3(0.11, 0.026, 0.026) * body_scale, Vector3(0.105 * body_scale, 1.96 * body_scale, 0.275 * body_scale), Color("#3c4432"), Vector3(0.0, 0.0, -0.18))
	MF.box(detail_root, Vector3(0.12, 0.08, 0.028) * body_scale, Vector3(0.17 * body_scale, 1.8 * body_scale, 0.305 * body_scale), wound, Vector3(0.0, 0.0, 0.34))
	for tooth_x in [-0.075, -0.025, 0.025, 0.075]:
		MF.box(detail_root, Vector3(0.026, 0.055, 0.022) * body_scale, Vector3(tooth_x * body_scale, 1.735 * body_scale, 0.355 * body_scale), Color("#d5cfaa"), Vector3(0.0, 0.0, tooth_x * 1.2))
	for hair_i in range(4):
		var hx := -0.2 + float(hair_i) * 0.13
		MF.box(detail_root, Vector3(0.08, 0.13 + float(hair_i % 2) * 0.05, 0.12) * body_scale, Vector3(hx * body_scale, 2.08 * body_scale, -0.02), Color("#34342e"), Vector3(0.0, float(hair_i) * 0.3, (float(hair_i) - 1.5) * 0.12))

	# Torn fabric, exposed ribs and asymmetric wounds add breakup without textures.
	MF.box(detail_root, Vector3(0.22, 0.1, 0.035) * body_scale, Vector3(-0.2 * body_scale, 1.2 * body_scale, 0.34 * body_scale), Color("#2a292d"), Vector3(0.0, 0.0, 0.28))
	MF.box(detail_root, Vector3(0.18, 0.13, 0.036) * body_scale, Vector3(0.2 * body_scale, 0.94 * body_scale, 0.33 * body_scale), wound, Vector3(0.0, 0.0, -0.22))
	for rib_i in range(3):
		MF.box(detail_root, Vector3(0.23, 0.025, 0.028) * body_scale, Vector3(-0.1 * body_scale, (1.12 - float(rib_i) * 0.09) * body_scale, 0.355 * body_scale), Color("#b2a789"), Vector3(0.0, 0.0, 0.08 * float(rib_i)))

	# Type-specific silhouette/readability.
	if enemy_type == "runner":
		MF.box(visual_root, Vector3(0.42, 0.08, 0.28), Vector3(0.0, 1.02, -0.28), Color("#2a3036"))
		MF.box(detail_root, Vector3(0.54, 0.14, 0.08), Vector3(0.0, 1.55, 0.31), Color("#8a4b50"), Vector3(0.0, 0.0, 0.1))
		MF.box(detail_root, Vector3(0.12, 0.5, 0.08), Vector3(-0.29, 1.23, 0.02), Color("#3a3035"), Vector3(0.0, 0.0, 0.24))
	elif enemy_type == "armored":
		MF.box(visual_root, Vector3(0.78, 0.76, 0.28), Vector3(0.0, 1.22, 0.02), Color("#36434d"))
		MF.box(visual_root, Vector3(0.58, 0.18, 0.33), Vector3(0.0, 1.48, 0.04), Color("#566570"))
		MF.cylinder(visual_root, 0.32, 0.18, Vector3(0.0, 2.03, 0.0), Color("#46535e"), Vector3.ZERO, 12)
		MF.box(visual_root, Vector3(0.42, 0.07, 0.18), Vector3(0.0, 1.98, 0.29), Color("#313a42"))
		for x in [-0.22, 0.0, 0.22]:
			MF.box(detail_root, Vector3(0.17, 0.24, 0.1), Vector3(x, 1.18, 0.2), Color("#28333b"))
		for x in [-0.22, 0.22]:
			MF.box(detail_root, Vector3(0.24, 0.17, 0.12), Vector3(x, 0.54, 0.08), Color("#4a565e"))
	elif enemy_type == "spitter" or enemy_type == "plague_giant_boss":
		MF.sphere(visual_root, 0.2 * body_scale, Vector3(0.0, 1.52 * body_scale, 0.31 * body_scale), Color("#a3d84e"), 12, 8)
		MF.sphere(visual_root, 0.11 * body_scale, Vector3(0.0, 1.67 * body_scale, 0.32 * body_scale), Color("#c2ee61"), 10, 6)
		for i in range(5):
			var angle := float(i) * 1.25
			MF.sphere(detail_root, 0.055 * body_scale, Vector3(cos(angle) * 0.22 * body_scale, (1.42 + sin(angle * 0.7) * 0.16) * body_scale, 0.34 * body_scale), Color("#b7dc57"), 8, 5)
		MF.box(detail_root, Vector3(0.035, 0.28, 0.035) * body_scale, Vector3(0.03, 1.56 * body_scale, 0.46 * body_scale), Color("#a7d85b"), Vector3(0.18, 0.0, 0.0))
	if enemy_type == "brute" or enemy_type.ends_with("boss"):
		MF.box(visual_root, Vector3(1.0, 0.29, 0.38) * body_scale, Vector3(0.0, 1.45 * body_scale, 0.0), cloth)
		MF.sphere(visual_root, 0.2 * body_scale, Vector3(-0.5 * body_scale, 1.42 * body_scale, 0.0), skin, 10, 6)
		MF.sphere(visual_root, 0.2 * body_scale, Vector3(0.5 * body_scale, 1.42 * body_scale, 0.0), skin, 10, 6)
		MF.box(detail_root, Vector3(0.1, 0.85, 0.08) * body_scale, Vector3(-0.34 * body_scale, 1.2 * body_scale, 0.25 * body_scale), Color("#5b463a"), Vector3(0.0, 0.0, -0.22))
		MF.box(detail_root, Vector3(0.1, 0.85, 0.08) * body_scale, Vector3(0.34 * body_scale, 1.2 * body_scale, 0.25 * body_scale), Color("#5b463a"), Vector3(0.0, 0.0, 0.22))
	if enemy_type == "bridge_brute_boss":
		MF.box(detail_root, Vector3(1.1, 0.16, 0.18) * body_scale, Vector3(0.0, 1.1 * body_scale, 0.3 * body_scale), Color("#704a39"), Vector3(0.0, 0.0, 0.15))
		MF.cylinder(detail_root, 0.075 * body_scale, 1.05 * body_scale, Vector3(0.53 * body_scale, 1.23 * body_scale, 0.16), Color("#6f4e3c"), Vector3(0.0, 0.0, 0.85), 8)
	if enemy_type == "plague_giant_boss":
		for i in range(4):
			MF.sphere(detail_root, 0.12 * body_scale, Vector3((-0.3 + float(i) * 0.2) * body_scale, (1.0 + float(i % 2) * 0.28) * body_scale, 0.38 * body_scale), Color("#8fb744"), 8, 5)
	if enemy_type == "overpass_colossus_boss":
		# Highway scrap armor makes the final boss read as a moving wreck.
		MF.box(visual_root, Vector3(1.35, 0.82, 0.24) * body_scale, Vector3(0.0, 1.2 * body_scale, 0.15), Color("#3a4650"), Vector3(0.0, 0.0, 0.05))
		MF.box(visual_root, Vector3(0.82, 0.14, 0.32) * body_scale, Vector3(-0.42 * body_scale, 1.54 * body_scale, 0.03), Color("#8c7a50"), Vector3(0.0, 0.0, -0.22))
		MF.box(visual_root, Vector3(0.82, 0.14, 0.32) * body_scale, Vector3(0.42 * body_scale, 1.54 * body_scale, 0.03), Color("#8c7a50"), Vector3(0.0, 0.0, 0.22))
		MF.box(detail_root, Vector3(1.05, 0.12, 0.18) * body_scale, Vector3(0.0, 1.7 * body_scale, 0.22), Color("#b59a5b"), Vector3(0.0, 0.0, -0.08))
		for x in [-0.47, 0.47]:
			MF.cylinder(detail_root, 0.08 * body_scale, 0.9 * body_scale, Vector3(x * body_scale, 1.16 * body_scale, 0.32), Color("#774b39"), Vector3(0.0, 0.0, x), 8)

func _build_leg(x: float, trouser: Color, boot: Color) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = Vector3(x, 0.88 * body_scale, 0.0)
	visual_root.add_child(pivot)
	MF.asset_mesh(pivot, "res://assets/models/zombie_leg.obj", Vector3.ZERO, Vector3.ONE * body_scale, trouser)
	MF.asset_mesh(pivot, "res://assets/models/combat_boot.obj", Vector3(0.0, -0.75 * body_scale, 0.06 * body_scale), Vector3.ONE * body_scale * 0.86, boot)
	return pivot

func _build_arm(x: float, skin: Color, sleeve: Color, side: float) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = Vector3(x, 1.44 * body_scale, 0.0)
	pivot.rotation.z = 0.16 * side
	visual_root.add_child(pivot)
	MF.asset_mesh(pivot, "res://assets/models/zombie_arm.obj", Vector3.ZERO, Vector3.ONE * body_scale, sleeve)
	MF.asset_mesh(pivot, "res://assets/models/zombie_hand_v15.obj", Vector3(0.0, -0.66 * body_scale, 0.05 * body_scale), Vector3.ONE * body_scale * 0.96, skin, Vector3(0.14 * side, 0.0, 0.0))
	return pivot

func is_alive() -> bool:
	return active and not dying and hp > 0.0

func take_damage(amount: float) -> bool:
	if not is_alive():
		return false
	hp -= amount
	reaction_timer = 0.11
	if hp <= 0.0:
		dying = true
		death_timer = 0.52 if not enemy_type.ends_with("boss") else 0.8
	return true

func _process(delta: float) -> void:
	if not active:
		return
	if dying:
		death_timer -= delta
		current_speed = move_toward(current_speed, 0.0, delta * 8.0)
		rotation.z = lerp(rotation.z, -1.36, minf(1.0, delta * 7.0))
		rotation.x = lerp(rotation.x, 0.22, minf(1.0, delta * 5.0))
		position.y = maxf(-0.42, position.y - delta * 0.8)
		if death_timer <= 0.0:
			active = false
			visible = false
			removed.emit(self, false, 0)
		return

	spawn_blend = minf(1.0, spawn_blend + delta * 4.5)
	if is_instance_valid(detail_root):
		detail_root.visible = enemy_type.ends_with("boss") or position.z > -19.0
	var reaction_scale := 1.0
	if reaction_timer > 0.0:
		reaction_timer -= delta
		reaction_scale = 0.94
	visual_root.scale = visual_root.scale.lerp(Vector3(1.06, reaction_scale, 1.06) if reaction_timer > 0.0 else Vector3.ONE, minf(1.0, delta * 16.0))
	visual_root.scale *= 0.86 + 0.14 * spawn_blend

	current_speed = move_toward(current_speed, speed, delta * maxf(2.0, speed * 3.2))
	if reaction_timer > 0.0:
		current_speed *= 0.82
	walk_phase += delta * maxf(0.6, current_speed) * 4.2
	var stride := 0.38
	if enemy_type == "runner":
		stride = 0.68
	elif enemy_type == "brute" or enemy_type.ends_with("boss"):
		stride = 0.28
	left_leg.rotation.x = sin(walk_phase) * stride
	right_leg.rotation.x = -sin(walk_phase) * stride
	left_arm.rotation.x = -sin(walk_phase) * stride * 0.72 - 0.18
	right_arm.rotation.x = sin(walk_phase) * stride * 0.72 - 0.08
	visual_root.position.y = absf(sin(walk_phase * 0.5)) * 0.035 * minf(1.0, current_speed)
	var base_lean := -0.16 if enemy_type == "runner" else 0.0
	visual_root.rotation.x = lerp(visual_root.rotation.x, base_lean, minf(1.0, delta * 7.0))
	visual_root.rotation.z = sin(walk_phase * 0.5) * (0.025 if enemy_type.ends_with("boss") else 0.045) + idle_lean

	var stop_for_ranged := false
	if enemy_type == "spitter" and position.z >= -12.0:
		stop_for_ranged = true
		ranged_timer -= delta
		if ranged_timer <= 0.0:
			ranged_timer = 5.0
			aimed_attack.emit(self, player.position.x, 10, 0.85, 1.2, "acid")
	elif enemy_type == "bridge_brute_boss" and position.z >= -14.0:
		stop_for_ranged = true
		ranged_timer -= delta
		if ranged_timer <= 0.0:
			ranged_timer = 5.5
			aimed_attack.emit(self, player.position.x, 20, 1.25, 1.25, "charge")
	elif enemy_type == "plague_giant_boss" and position.z >= -15.0:
		stop_for_ranged = true
		ranged_timer -= delta
		summon_timer -= delta
		if ranged_timer <= 0.0:
			ranged_timer = 5.0
			aimed_attack.emit(self, player.position.x, 15, 1.35, 1.25, "boss_acid")
		if summon_timer <= 0.0:
			summon_timer = 7.0
			summon_requested.emit(self)
	elif enemy_type == "overpass_colossus_boss" and position.z >= -13.5:
		stop_for_ranged = true
		ranged_timer -= delta
		summon_timer -= delta
		if ranged_timer <= 0.0:
			ranged_timer = 4.6
			aimed_attack.emit(self, player.position.x, 25, 1.55, 1.35, "colossus_slam")
		if summon_timer <= 0.0:
			summon_timer = 6.2
			summon_requested.emit(self)

	if not stop_for_ranged:
		position.z += current_speed * delta
		var sway := sin(walk_phase * 0.43) * (0.08 if enemy_type.ends_with("boss") else 0.14)
		position.x = lerp(position.x, lane_bias + sway, minf(1.0, delta * 1.25))
	else:
		current_speed = move_toward(current_speed, 0.0, delta * 5.0)

	if position.z >= -1.5:
		active = false
		visible = false
		removed.emit(self, true, breach_damage)
