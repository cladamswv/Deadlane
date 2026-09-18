extends Node3D
class_name EnvironmentFX

var fire_nodes: Array[Node3D] = []
var smoke_nodes: Array[Node3D] = []
var beacon_nodes: Array[OmniLight3D] = []
var ember_nodes: Array[Node3D] = []
var elapsed: float = 0.0

func _ready() -> void:
	for candidate in get_tree().get_nodes_in_group("deadlane_fire"):
		if candidate is Node3D:
			var node := candidate as Node3D
			node.set_meta("base_scale", node.scale)
			fire_nodes.append(node)
	for candidate in get_tree().get_nodes_in_group("deadlane_smoke"):
		if candidate is Node3D:
			var node := candidate as Node3D
			node.set_meta("base_position", node.position)
			smoke_nodes.append(node)
	for candidate in get_tree().get_nodes_in_group("deadlane_beacon"):
		if candidate is OmniLight3D:
			beacon_nodes.append(candidate as OmniLight3D)
	for candidate in get_tree().get_nodes_in_group("deadlane_ember"):
		if candidate is Node3D:
			ember_nodes.append(candidate as Node3D)

func _process(delta: float) -> void:
	elapsed += delta
	for i in range(fire_nodes.size()):
		var node: Node3D = fire_nodes[i]
		if not is_instance_valid(node):
			continue
		var phase := float(node.get_meta("phase", float(i) * 0.73))
		var base_scale: Vector3 = node.scale
		var scale_meta: Variant = node.get_meta("base_scale", node.scale)
		if scale_meta is Vector3:
			base_scale = scale_meta
		var flicker := 0.92 + sin(elapsed * 10.0 + phase) * 0.07 + sin(elapsed * 17.0 + phase * 1.7) * 0.035
		node.scale = Vector3(base_scale.x * (1.0 + sin(elapsed * 7.0 + phase) * 0.05), base_scale.y * flicker, base_scale.z * flicker)
		for child in node.get_children():
			if child is OmniLight3D:
				var light := child as OmniLight3D
				light.light_energy = 1.15 + flicker * 0.65

	for i in range(smoke_nodes.size()):
		var smoke: Node3D = smoke_nodes[i]
		if not is_instance_valid(smoke):
			continue
		var phase := float(smoke.get_meta("phase", float(i) * 0.51))
		var base_position: Vector3 = smoke.position
		var position_meta: Variant = smoke.get_meta("base_position", smoke.position)
		if position_meta is Vector3:
			base_position = position_meta
		smoke.position = base_position + Vector3(sin(elapsed * 0.55 + phase) * 0.16, sin(elapsed * 0.42 + phase) * 0.08, cos(elapsed * 0.48 + phase) * 0.12)
		smoke.rotation.y = sin(elapsed * 0.3 + phase) * 0.12

	for i in range(ember_nodes.size()):
		var ember: Node3D = ember_nodes[i]
		if not is_instance_valid(ember):
			continue
		var phase := float(ember.get_meta("phase", float(i) * 0.41))
		var base_position: Vector3 = ember.position
		var position_meta: Variant = ember.get_meta("base_position", ember.position)
		if position_meta is Vector3:
			base_position = position_meta
		var rise := fmod(elapsed * (0.45 + float(i % 4) * 0.08) + phase, 2.2)
		ember.position = base_position + Vector3(sin(elapsed * 1.4 + phase) * 0.18, rise, cos(elapsed * 1.1 + phase) * 0.10)
		ember.scale = Vector3.ONE * (0.65 + 0.35 * (1.0 - rise / 2.2))

	for i in range(beacon_nodes.size()):
		var beacon: OmniLight3D = beacon_nodes[i]
		if not is_instance_valid(beacon):
			continue
		var blink := fmod(elapsed + float(i) * 0.33, 1.15)
		beacon.light_energy = 2.3 if blink < 0.16 else 0.10

func set_quality(quality: String, reduced_effects: bool) -> void:
	var show_smoke := quality != "low" and not reduced_effects
	for smoke in smoke_nodes:
		if is_instance_valid(smoke):
			smoke.visible = show_smoke
	for fire in fire_nodes:
		if is_instance_valid(fire):
			fire.visible = quality != "low" or not reduced_effects
	for beacon in beacon_nodes:
		if is_instance_valid(beacon):
			beacon.visible = quality != "low"
	for ember in ember_nodes:
		if is_instance_valid(ember):
			ember.visible = quality != "low" and not reduced_effects
