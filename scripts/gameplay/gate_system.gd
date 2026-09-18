extends Node3D
class_name GateSystem

const MF = preload("res://scripts/world/mesh_factory.gd")

var active: bool = false
var gate_x: float = 0.0
var gate_z: float = -5.0
var multiplier: int = 2
var half_width: float = 1.15
var remaining: float = 0.0
var total_time: float = 8.0
var visual_root: Node3D
var lifetime_bar: MeshInstance3D
var label: Label3D
var pulse_phase: float = 0.0

func _ready() -> void:
	visible = false

func activate(rng: RandomNumberGenerator, wave: int) -> void:
	if active:
		deactivate()
	active = true
	remaining = total_time
	pulse_phase = 0.0
	var lanes: Array[float] = [-2.7, 0.0, 2.7]
	gate_x = float(lanes[rng.randi_range(0, lanes.size() - 1)])
	multiplier = 3 if rng.randf() < 0.18 else 2
	position = Vector3(gate_x, 0.0, gate_z)
	visible = true
	_build_visual(wave)

func _build_visual(_wave: int) -> void:
	for child in get_children():
		child.queue_free()
	visual_root = Node3D.new()
	add_child(visual_root)
	var frame_color := Color("#5fc7d7") if multiplier == 2 else Color("#bb78dc")
	MF.emissive_box(visual_root, Vector3(0.12, 2.7, 0.12), Vector3(-half_width, 1.35, 0.0), frame_color, 2.1)
	MF.emissive_box(visual_root, Vector3(0.12, 2.7, 0.12), Vector3(half_width, 1.35, 0.0), frame_color, 2.1)
	MF.emissive_box(visual_root, Vector3(half_width * 2.0 + 0.12, 0.12, 0.12), Vector3(0.0, 2.65, 0.0), frame_color, 2.1)
	label = Label3D.new()
	label.text = "×%d SHOTS" % multiplier
	label.font_size = 48
	label.modulate = Color.WHITE
	label.position = Vector3(0.0, 2.25, 0.02)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	visual_root.add_child(label)
	lifetime_bar = MF.emissive_box(visual_root, Vector3(2.2, 0.08, 0.10), Vector3(0.0, 2.87, 0.0), Color("#e7edf2"), 1.7)

func deactivate() -> void:
	active = false
	remaining = 0.0
	visible = false

func _process(delta: float) -> void:
	if not active:
		return
	remaining -= delta
	pulse_phase += delta * 4.2
	if visual_root != null:
		var pulse := 1.0 + sin(pulse_phase) * 0.018
		visual_root.scale = Vector3(pulse, 1.0 + sin(pulse_phase * 0.85) * 0.012, 1.0)
	if label != null:
		label.modulate.a = 0.88 + 0.12 * sin(pulse_phase * 1.15)
	if lifetime_bar != null:
		lifetime_bar.scale.x = clampf(remaining / total_time, 0.0, 1.0)
	if remaining <= 0.0:
		deactivate()

func segment_cross_t(from_pos: Vector3, to_pos: Vector3) -> float:
	if not active:
		return -1.0
	if from_pos.z <= gate_z or to_pos.z > gate_z:
		return -1.0
	var denom := to_pos.z - from_pos.z
	if absf(denom) < 0.0001:
		return -1.0
	var t := (gate_z - from_pos.z) / denom
	if t < 0.0 or t > 1.0:
		return -1.0
	var x_at := lerpf(from_pos.x, to_pos.x, t)
	if absf(x_at - gate_x) > half_width:
		return -1.0
	return t
