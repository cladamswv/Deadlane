extends Node3D
class_name GrenadeSystem

const MF = preload("res://scripts/world/mesh_factory.gd")

signal detonated(position: Vector3)

var cooldown_total: float = 15.0
var cooldown_remaining: float = 0.0
var pending: Array[Dictionary] = []
var enemies: Array[ZombieEnemy] = []
var reduced_effects: bool = false

func set_enemy_array(enemy_array: Array[ZombieEnemy]) -> void:
	enemies = enemy_array

func reset() -> void:
	cooldown_remaining = 0.0
	cancel_pending()

func cancel_pending() -> void:
	for item in pending:
		var node: Node3D = item["node"]
		if is_instance_valid(node):
			node.queue_free()
	pending.clear()

func request_throw(base_damage: float, multiplier: float) -> bool:
	if cooldown_remaining > 0.0:
		return false
	var target: ZombieEnemy = _find_best_cluster()
	if target == null:
		return false
	var pos := Vector3(target.global_position.x, 0.05, target.global_position.z)
	var warning: MeshInstance3D = _make_warning(pos)
	pending.append({"time": 0.35, "pos": pos, "damage": base_damage * multiplier, "radius": 3.0, "node": warning})
	cooldown_remaining = cooldown_total
	return true

func _process(delta: float) -> void:
	cooldown_remaining = maxf(0.0, cooldown_remaining - delta)
	var i := pending.size() - 1
	while i >= 0:
		pending[i]["time"] = float(pending[i]["time"]) - delta
		var warning: Node3D = pending[i]["node"]
		if is_instance_valid(warning):
			var warning_time := maxf(0.0, float(pending[i]["time"]))
			var pulse := 0.96 + sin(warning_time * 34.0) * 0.04
			warning.scale = Vector3(pulse, 1.0, pulse)
		if float(pending[i]["time"]) <= 0.0:
			_detonate(pending[i])
			pending.remove_at(i)
		i -= 1

func _find_best_cluster() -> ZombieEnemy:
	var best: ZombieEnemy = null
	var best_count := 0
	for candidate in enemies:
		if not is_instance_valid(candidate) or not candidate.is_alive():
			continue
		if candidate.global_position.z > -3.0:
			continue
		var count := 0
		for other in enemies:
			if is_instance_valid(other) and other.is_alive() and candidate.global_position.distance_to(other.global_position) <= 3.0:
				count += 1
		if count > best_count:
			best_count = count
			best = candidate
	return best

func _make_warning(pos: Vector3) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 3.0
	mesh.bottom_radius = 3.0
	mesh.height = 0.035
	mesh.radial_segments = 28
	mesh.material = MF.material(Color(1.0, 0.35, 0.18, 0.28), 0.8, 0.0, true)
	node.mesh = mesh
	node.position = pos
	add_child(node)
	return node

func _detonate(item: Dictionary) -> void:
	var pos: Vector3 = item["pos"]
	var radius: float = float(item["radius"])
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.is_alive() and enemy.global_position.distance_to(pos) <= radius:
			enemy.take_damage(float(item["damage"]))
	var node: Node3D = item["node"]
	if is_instance_valid(node):
		node.queue_free()
	if not reduced_effects:
		var flash := MF.emissive_sphere(self, 0.85, pos + Vector3(0.0, 0.25, 0.0), Color("#ff9d3b"), 3.2, 12, 8)
		var core := MF.emissive_sphere(self, 0.42, pos + Vector3(0.0, 0.35, 0.0), Color("#ffe1a1"), 4.0, 10, 6)
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(flash, "scale", Vector3(3.0, 2.1, 3.0), 0.18)
		tween.tween_property(core, "scale", Vector3(1.8, 1.8, 1.8), 0.11)
		tween.set_parallel(false)
		tween.tween_property(flash, "scale", Vector3.ZERO, 0.16)
		tween.set_parallel(true)
		tween.tween_property(core, "scale", Vector3.ZERO, 0.1)
		tween.set_parallel(false)
		tween.tween_callback(flash.queue_free)
		tween.tween_callback(core.queue_free)
	detonated.emit(pos)
