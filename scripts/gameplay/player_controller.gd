extends Node3D
class_name PlayerController

signal fire_requested(origin: Vector3)

const MF = preload("res://scripts/world/mesh_factory.gd")

var active: bool = false
var min_x: float = -4.25
var max_x: float = 4.25
var target_x: float = 0.0
var move_velocity: float = 0.0
var max_move_speed: float = 8.6
var move_acceleration: float = 42.0
var fire_rate: float = 7.0
var fire_timer: float = 0.0
var firing_held: bool = false
var drag_finger: int = -1
var mouse_dragging: bool = false
var muzzle: Node3D
var weapon_root: Node3D
var body_root: Node3D
var flash: MeshInstance3D
var flash_timer: float = 0.0
var recoil_amount: float = 0.0
var weapon_name: String = "assault_rifle"
var left_leg: Node3D
var right_leg: Node3D
var aim_guide: MeshInstance3D
var motion_phase: float = 0.0

func _ready() -> void:
	_build_visual()
	target_x = position.x

func _build_visual() -> void:
	body_root = Node3D.new()
	add_child(body_root)
	var skin := Color("#c89a78")
	var skin_shadow := Color("#9e7259")
	var jacket := Color("#d87936")
	var jacket_dark := Color("#9f4f2c")
	var jacket_edge := Color("#e98c48")
	var dark := Color("#242b33")
	var dark_light := Color("#39434d")
	var boot := Color("#171c21")
	var leather := Color("#4d392e")
	var gear := Color("#34414a")

	# Layered torso: jacket body, zipper, collar, chest seams and shoulder armor.
	MF.asset_mesh(body_root, "res://assets/models/survivor_torso.obj", Vector3(0.0, 1.27, 0.0), Vector3(1.08, 1.03, 1.08), jacket)
	MF.box(body_root, Vector3(0.64, 0.18, 0.34), Vector3(0.0, 1.7, 0.03), jacket_dark)
	MF.box(body_root, Vector3(0.045, 0.64, 0.025), Vector3(0.0, 1.34, -0.32), Color("#5b372b"))
	MF.box(body_root, Vector3(0.26, 0.11, 0.035), Vector3(-0.2, 1.39, -0.325), jacket_edge, Vector3(0.0, 0.0, 0.08))
	MF.box(body_root, Vector3(0.26, 0.11, 0.035), Vector3(0.2, 1.39, -0.325), jacket_edge, Vector3(0.0, 0.0, -0.08))
	MF.box(body_root, Vector3(0.72, 0.16, 0.38), Vector3(0.0, 1.62, 0.02), jacket_dark)
	for side in [-1.0, 1.0]:
		MF.box(body_root, Vector3(0.24, 0.16, 0.38), Vector3(side * 0.34, 1.6, 0.0), Color("#39434a"), Vector3(0.0, 0.0, side * 0.16))

	# Belt, pouches, holster and survival gear.
	MF.box(body_root, Vector3(0.62, 0.09, 0.34), Vector3(0.0, 1.0, 0.02), leather)
	MF.box(body_root, Vector3(0.14, 0.12, 0.08), Vector3(0.0, 1.0, -0.19), Color("#8b7450"))
	for x in [-0.24, 0.24]:
		MF.box(body_root, Vector3(0.18, 0.2, 0.11), Vector3(x, 0.91, -0.18), Color("#4c4939"))
	MF.box(body_root, Vector3(0.13, 0.42, 0.12), Vector3(0.37, 0.79, 0.03), Color("#342d29"), Vector3(0.0, 0.0, 0.08))
	MF.cylinder(body_root, 0.105, 0.31, Vector3(-0.38, 0.82, 0.08), Color("#657052"), Vector3.ZERO, 10)

	# v1.5 backpack: imported modeled shell with layered pockets, MOLLE rows, straps,
	# bedroll and radio silhouette. It is the part of the survivor seen most often.
	MF.asset_mesh(body_root, "res://assets/models/survivor_backpack_v15.obj", Vector3(0.0, 1.43, 0.31), Vector3(0.94, 0.94, 0.94), gear, Vector3(0.0, PI, 0.0))
	MF.box(body_root, Vector3(0.48, 0.07, 0.035), Vector3(0.0, 1.72, 0.46), Color("#657052"))
	MF.box(body_root, Vector3(0.17, 0.31, 0.13), Vector3(0.34, 1.45, 0.48), Color("#222d34"))
	MF.box(body_root, Vector3(0.025, 0.64, 0.025), Vector3(0.39, 1.86, 0.49), Color("#20262b"), Vector3(0.0, 0.0, -0.08))
	for strap_x in [-0.22, 0.22]:
		MF.box(body_root, Vector3(0.065, 0.78, 0.045), Vector3(strap_x, 1.45, 0.13), Color("#212a31"), Vector3(0.18, 0.0, -0.12 if strap_x < 0.0 else 0.12))

	# Head with ears, nose, eyes, brow, mouth and a rugged cap/hair silhouette.
	MF.asset_mesh(body_root, "res://assets/models/survivor_head.obj", Vector3(0.0, 2.05, -0.03), Vector3.ONE, skin, Vector3(0.0, PI, 0.0))
	MF.sphere(body_root, 0.055, Vector3(-0.27, 2.05, -0.02), skin_shadow, 10, 6)
	MF.sphere(body_root, 0.055, Vector3(0.27, 2.05, -0.02), skin_shadow, 10, 6)
	MF.tapered_cylinder(body_root, 0.025, 0.055, 0.15, Vector3(0.0, 2.04, -0.29), skin_shadow, Vector3(PI * 0.5, 0.0, 0.0), 8)
	for eye_x in [-0.095, 0.095]:
		MF.sphere(body_root, 0.028, Vector3(eye_x, 2.1, -0.27), Color("#332a25"), 8, 5)
		MF.box(body_root, Vector3(0.13, 0.025, 0.025), Vector3(eye_x, 2.17, -0.265), Color("#553a2e"), Vector3(0.0, 0.0, -eye_x * 0.7))
	MF.box(body_root, Vector3(0.17, 0.035, 0.025), Vector3(0.0, 1.94, -0.285), Color("#70483a"))
	MF.box(body_root, Vector3(0.5, 0.17, 0.36), Vector3(0.0, 2.27, 0.01), Color("#332b25"))
	MF.box(body_root, Vector3(0.36, 0.05, 0.28), Vector3(0.0, 2.26, -0.25), Color("#29231f"))
	MF.box(body_root, Vector3(0.42, 0.065, 0.08), Vector3(0.0, 2.2, 0.245), Color("#2a2420"), Vector3(0.12, 0.0, 0.0))

	# Legs with kneepads and boot soles.
	left_leg = _build_leg(body_root, -0.2, dark, boot)
	right_leg = _build_leg(body_root, 0.2, dark, boot)
	for x in [-0.2, 0.2]:
		MF.box(body_root, Vector3(0.24, 0.18, 0.11), Vector3(x, 0.58, -0.18), dark_light)
		MF.box(body_root, Vector3(0.19, 0.07, 0.12), Vector3(x, 0.52, -0.205), Color("#1e252b"))

	# Articulated-looking arms, elbow pads and gloves around the weapon.
	var left_arm := Node3D.new()
	left_arm.position = Vector3(-0.34, 1.65, -0.03)
	left_arm.rotation = Vector3(-0.72, 0.0, -0.22)
	body_root.add_child(left_arm)
	MF.asset_mesh(left_arm, "res://assets/models/survivor_arm.obj", Vector3.ZERO, Vector3.ONE, jacket)
	MF.box(left_arm, Vector3(0.17, 0.14, 0.13), Vector3(0.0, -0.38, -0.07), dark_light)
	MF.asset_mesh(left_arm, "res://assets/models/survivor_glove_v15.obj", Vector3(0.0, -0.62, -0.04), Vector3(0.86, 0.86, 0.86), Color("#303840"), Vector3(0.10, 0.0, 0.0))
	var right_arm := Node3D.new()
	right_arm.position = Vector3(0.34, 1.65, -0.03)
	right_arm.rotation = Vector3(-0.66, 0.0, 0.22)
	body_root.add_child(right_arm)
	MF.asset_mesh(right_arm, "res://assets/models/survivor_arm.obj", Vector3.ZERO, Vector3.ONE, jacket)
	MF.box(right_arm, Vector3(0.17, 0.14, 0.13), Vector3(0.0, -0.38, -0.07), dark_light)
	MF.asset_mesh(right_arm, "res://assets/models/survivor_glove_v15.obj", Vector3(0.0, -0.62, -0.04), Vector3(0.86, 0.86, 0.86), Color("#303840"), Vector3(0.10, PI, 0.0))

	weapon_root = Node3D.new()
	weapon_root.position = Vector3(0.0, 1.42, -0.49)
	body_root.add_child(weapon_root)
	muzzle = Node3D.new()
	weapon_root.add_child(muzzle)
	flash = MF.emissive_sphere(muzzle, 0.105, Vector3.ZERO, Color("#ffd35f"), 3.8, 10, 6)
	flash.visible = false
	set_weapon_visual("assault_rifle")

	# A subtle straight lane guide replaces hidden aim assistance. It moves with
	# the survivor and makes the manual shooting line obvious without selecting
	# or magnetizing toward any zombie.
	aim_guide = MF.box(self, Vector3(0.055, 0.014, 15.0), Vector3(0.0, 0.026, -7.55), Color(1.0, 0.65, 0.19, 0.20))
	var guide_mesh := aim_guide.mesh as BoxMesh
	if guide_mesh != null:
		guide_mesh.material = MF.material(Color(1.0, 0.66, 0.2, 0.20), 0.55, 0.0, true)
	aim_guide.visible = false

func _build_leg(parent: Node3D, x: float, trouser: Color, boot: Color) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = Vector3(x, 0.92, 0.0)
	parent.add_child(pivot)
	MF.asset_mesh(pivot, "res://assets/models/survivor_leg.obj", Vector3.ZERO, Vector3.ONE, trouser)
	MF.asset_mesh(pivot, "res://assets/models/combat_boot.obj", Vector3(0.0, -0.79, -0.06), Vector3(0.95, 0.95, 0.95), boot, Vector3(0.0, PI, 0.0))
	return pivot

func set_weapon_visual(name: String) -> void:
	weapon_name = name
	for child in weapon_root.get_children():
		if child != muzzle:
			child.queue_free()
	var gunmetal := Color("#29323a")
	var dark_metal := Color("#161c21")
	var steel := Color("#566771")
	var polymer := Color("#333b43")
	var wood := Color("#6b4b32")
	var length := 1.18

	if name == "assault_rifle":
		length = 1.78
		MF.asset_mesh(weapon_root, "res://assets/models/assault_rifle.obj", Vector3.ZERO, Vector3.ONE, gunmetal)
		MF.box(weapon_root, Vector3(0.16, 0.045, 0.44), Vector3(0.0, 0.11, -0.83), Color("#59636a"))
		MF.cylinder(weapon_root, 0.055, 0.28, Vector3(0.0, 0.22, -0.67), Color("#171c21"), Vector3(PI * 0.5, 0.0, 0.0), 12)
	elif name == "smg":
		length = 1.14
		MF.asset_mesh(weapon_root, "res://assets/models/smg.obj", Vector3.ZERO, Vector3.ONE, Color("#354753"))
		MF.box(weapon_root, Vector3(0.20, 0.04, 0.30), Vector3(0.0, 0.13, -0.55), Color("#59636a"))
	elif name == "shotgun":
		length = 1.67
		MF.asset_mesh(weapon_root, "res://assets/models/shotgun.obj", Vector3.ZERO, Vector3.ONE, Color("#342b27"))
		MF.box(weapon_root, Vector3(0.21, 0.18, 0.38), Vector3(0.0, -0.04, -0.95), wood)
		for rib in [-0.10, -0.04, 0.02, 0.08]:
			MF.box(weapon_root, Vector3(0.215, 0.035, 0.026), Vector3(0.0, -0.03, -0.95 + rib), Color("#4b3425"))
	else:
		length = 2.14
		MF.asset_mesh(weapon_root, "res://assets/models/piercer.obj", Vector3.ZERO, Vector3.ONE, Color("#405d6b"))
		MF.cylinder(weapon_root, 0.068, 0.46, Vector3(0.0, 0.19, -0.54), dark_metal, Vector3(PI * 0.5, 0.0, 0.0), 14)
		MF.box(weapon_root, Vector3(0.08, 0.11, 0.65), Vector3(0.0, 0.11, -0.72), Color("#89aab8"))

	# Small contrasting controls survive phone-size viewing without turning the gun into boxes.
	MF.box(weapon_root, Vector3(0.055, 0.035, 0.12), Vector3(0.09, 0.05, -0.42), steel)
	MF.box(weapon_root, Vector3(0.035, 0.10, 0.045), Vector3(0.0, 0.13, -length + 0.12), dark_metal)
	muzzle.position = Vector3(0.0, 0.0, -length)

func configure_fire_rate(value: float) -> void:
	fire_rate = maxf(0.1, value)

func set_active(value: bool) -> void:
	active = value
	if is_instance_valid(aim_guide):
		aim_guide.visible = value
	if not value:
		firing_held = false
		clear_touches()

func set_firing(value: bool) -> void:
	firing_held = value and active
	if firing_held:
		fire_timer = minf(fire_timer, 0.0)
	else:
		fire_timer = 0.0

func clear_touches() -> void:
	drag_finger = -1
	mouse_dragging = false

func kick_recoil() -> void:
	recoil_amount = minf(0.13, recoil_amount + 0.075)
	flash.visible = true
	flash_timer = 0.052

func _pixels_to_world() -> float:
	var viewport_width := maxf(360.0, get_viewport().get_visible_rect().size.x)
	return 9.2 / viewport_width

func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and drag_finger < 0:
			drag_finger = touch.index
		elif not touch.pressed and touch.index == drag_finger:
			drag_finger = -1
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == drag_finger:
			target_x = clampf(target_x + drag.relative.x * _pixels_to_world(), min_x, max_x)
	elif event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			mouse_dragging = mouse_button.pressed
	elif event is InputEventMouseMotion and mouse_dragging:
		var mouse_motion := event as InputEventMouseMotion
		target_x = clampf(target_x + mouse_motion.relative.x * _pixels_to_world(), min_x, max_x)

func _process(delta: float) -> void:
	if flash_timer > 0.0:
		flash_timer -= delta
		if flash_timer <= 0.0:
			flash.visible = false
	recoil_amount = move_toward(recoil_amount, 0.0, delta * 1.9)
	weapon_root.position.z = -0.49 + recoil_amount
	if not active:
		return

	var keyboard_axis := 0.0
	if Input.is_key_pressed(KEY_A):
		keyboard_axis -= 1.0
	if Input.is_key_pressed(KEY_D):
		keyboard_axis += 1.0
	if absf(keyboard_axis) > 0.01:
		target_x = clampf(target_x + keyboard_axis * 5.8 * delta, min_x, max_x)

	# Bounded spring-like motion feels responsive without the overshoot/jitter of
	# an unbounded proportional controller when the finger reverses direction.
	var error := target_x - position.x
	var desired_velocity := clampf(error * 10.5, -max_move_speed, max_move_speed)
	move_velocity = move_toward(move_velocity, desired_velocity, move_acceleration * delta)
	if absf(error) < 0.008 and absf(move_velocity) < 0.08:
		move_velocity = 0.0
		position.x = target_x
	else:
		position.x = clampf(position.x + move_velocity * delta, min_x, max_x)

	# Visible footwork, body lean and a tiny vertical settle sell the movement.
	motion_phase += delta * (2.2 + absf(move_velocity) * 1.4)
	var motion_strength := clampf(absf(move_velocity) / max_move_speed, 0.0, 1.0)
	left_leg.rotation.x = sin(motion_phase) * 0.42 * motion_strength
	right_leg.rotation.x = -sin(motion_phase) * 0.42 * motion_strength
	body_root.rotation.z = lerp(body_root.rotation.z, -move_velocity * 0.027, minf(1.0, delta * 10.0))
	body_root.position.y = absf(sin(motion_phase * 0.5)) * 0.035 * motion_strength

	# Manual firing only. Holding the on-screen FIRE button (or Space during
	# desktop development) produces shots at the weapon's real fire rate.
	var wants_fire := firing_held or Input.is_key_pressed(KEY_SPACE)
	if not wants_fire:
		fire_timer = 0.0
		return
	fire_timer -= delta
	var shots_this_frame := 0
	while fire_timer <= 0.0 and shots_this_frame < 3:
		fire_timer += 1.0 / fire_rate
		fire_requested.emit(muzzle.global_position)
		shots_this_frame += 1
