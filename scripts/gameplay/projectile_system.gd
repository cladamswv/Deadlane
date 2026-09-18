extends Node3D
class_name ProjectileSystem

const MF = preload("res://scripts/world/mesh_factory.gd")

var bullets: Array[Dictionary] = []
var visual_pool: Array[MeshInstance3D] = []
var impact_pool: Array[MeshInstance3D] = []
var impacts: Array[Dictionary] = []
var enemies: Array[ZombieEnemy] = []
var gate_system: GateSystem
var family_counter: int = 1
var reduced_effects: bool = false

static func gate_output_count(input_count: int, multiplier: int) -> int:
	return input_count * clampi(multiplier, 1, 3)

func set_gate_system(gate: GateSystem) -> void:
	gate_system = gate

func set_enemy_array(enemy_array: Array[ZombieEnemy]) -> void:
	enemies = enemy_array

func set_reduced_effects(value: bool) -> void:
	reduced_effects = value

func fire_weapon(origin: Vector3, target: Node3D, stats: Dictionary, damage_mult: float, extra_pen: int) -> void:
	var pellets := int(stats.get("pellets", 1))
	var spread := float(stats.get("spread", 0.0))
	for pellet in range(pellets):
		var direction := Vector3(0.0, 0.0, -1.0)
		if target != null:
			direction = (target.global_position + Vector3(0.0, 1.0, 0.0) - origin).normalized()
		var offset := 0.0
		if pellets > 1:
			offset = (float(pellet) - float(pellets - 1) * 0.5) * spread
		direction.x += offset
		direction = direction.normalized()
		_spawn_bullet(origin, direction, float(stats.get("damage", 20.0)) * damage_mult, float(stats.get("range", 34.0)), int(stats.get("penetration", 0)) + extra_pen, family_counter, false)
		family_counter += 1

func _spawn_bullet(origin: Vector3, direction: Vector3, damage: float, travel_range: float, penetration: int, family_id: int, multiplied: bool) -> void:
	var visual := _get_visual()
	visual.global_position = origin
	visual.visible = true
	visual.scale = Vector3(1.0, 1.0, 1.18 if multiplied else 1.0)
	visual.look_at(origin + direction, Vector3.UP)
	var hit_ids: Dictionary = {}
	bullets.append({
		"visual": visual,
		"pos": origin,
		"dir": direction,
		"damage": damage,
		"range_left": travel_range,
		"penetration": penetration,
		"family": family_id,
		"multiplied": multiplied,
		"hit_ids": hit_ids
	})

func _get_visual() -> MeshInstance3D:
	if not visual_pool.is_empty():
		return visual_pool.pop_back()
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.045, 0.045, 0.34)
	box.material = MF.emissive_material(Color("#ffd765"), 2.7, false)
	mesh.mesh = box
	add_child(mesh)
	return mesh

func _release_visual(visual: MeshInstance3D) -> void:
	visual.visible = false
	visual.scale = Vector3.ONE
	visual_pool.append(visual)

func _get_impact_visual() -> MeshInstance3D:
	if not impact_pool.is_empty():
		return impact_pool.pop_back()
	var spark := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.095
	mesh.height = 0.19
	mesh.radial_segments = 8
	mesh.rings = 5
	mesh.material = MF.emissive_material(Color("#ffbd4a"), 3.2, false)
	spark.mesh = mesh
	add_child(spark)
	return spark

func _spawn_impact(pos: Vector3) -> void:
	if reduced_effects:
		return
	var spark := _get_impact_visual()
	spark.global_position = pos
	spark.scale = Vector3.ONE
	spark.visible = true
	impacts.append({"visual": spark, "time": 0.11, "life": 0.11})

func _release_impact(spark: MeshInstance3D) -> void:
	spark.visible = false
	spark.scale = Vector3.ONE
	impact_pool.append(spark)

func clear_all() -> void:
	for b in bullets:
		var visual: MeshInstance3D = b["visual"]
		_release_visual(visual)
	bullets.clear()
	for impact in impacts:
		var spark: MeshInstance3D = impact["visual"]
		_release_impact(spark)
	impacts.clear()

func _process(delta: float) -> void:
	var i := bullets.size() - 1
	while i >= 0:
		_advance_bullet(i, delta)
		i -= 1
	var impact_index := impacts.size() - 1
	while impact_index >= 0:
		impacts[impact_index]["time"] = float(impacts[impact_index]["time"]) - delta
		var spark: MeshInstance3D = impacts[impact_index]["visual"]
		var remaining := float(impacts[impact_index]["time"])
		var lifetime := float(impacts[impact_index].get("life", 0.11))
		var age01 := clampf(1.0 - remaining / lifetime, 0.0, 1.0)
		var pulse := 0.45 + sin(age01 * PI) * 1.25
		spark.scale = Vector3.ONE * pulse
		if float(impacts[impact_index]["time"]) <= 0.0:
			_release_impact(spark)
			impacts.remove_at(impact_index)
		impact_index -= 1

func _advance_bullet(index: int, delta: float) -> void:
	if index < 0 or index >= bullets.size():
		return
	var b: Dictionary = bullets[index]
	var prev: Vector3 = b["pos"]
	var direction: Vector3 = b["dir"]
	var distance := minf(55.0 * delta, float(b["range_left"]))
	var next := prev + direction * distance
	var gate_t := -1.0
	if gate_system != null and not bool(b["multiplied"]):
		gate_t = gate_system.segment_cross_t(prev, next)
	var hit := _earliest_enemy_hit(prev, next, b["hit_ids"])
	var hit_t := float(hit.get("t", -1.0))
	if gate_t >= 0.0 and (hit_t < 0.0 or gate_t < hit_t):
		var split_point := prev.lerp(next, gate_t)
		var count := clampi(gate_system.multiplier, 1, 3)
		var base_dir: Vector3 = b["dir"]
		for n in range(count):
			var child_dir := base_dir
			child_dir.x += (float(n) - float(count - 1) * 0.5) * 0.045
			child_dir = child_dir.normalized()
			_spawn_bullet(split_point + child_dir * 0.04, child_dir, float(b["damage"]), float(b["range_left"]) - distance * gate_t, int(b["penetration"]), int(b["family"]), true)
		_remove_bullet(index)
		return
	if hit_t >= 0.0:
		var enemy: ZombieEnemy = hit.get("enemy") as ZombieEnemy
		if is_instance_valid(enemy) and enemy.is_alive():
			var contact: Vector3 = prev.lerp(next, hit_t)
			_spawn_impact(contact)
			enemy.take_damage(float(b["damage"]))
			var hit_ids: Dictionary = b["hit_ids"]
			hit_ids[enemy.get_instance_id()] = true
			b["hit_ids"] = hit_ids
			if int(b["penetration"]) <= 0:
				_remove_bullet(index)
				return
			b["penetration"] = int(b["penetration"]) - 1
			var hit_pos := prev.lerp(next, hit_t)
			b["pos"] = hit_pos + direction * 0.04
			b["range_left"] = float(b["range_left"]) - prev.distance_to(hit_pos)
			bullets[index] = b
			var visual: MeshInstance3D = b["visual"]
			var current_pos: Vector3 = b["pos"]
			visual.global_position = current_pos
			visual.look_at(current_pos + direction, Vector3.UP)
			return
	b["pos"] = next
	b["range_left"] = float(b["range_left"]) - distance
	bullets[index] = b
	var visual: MeshInstance3D = b["visual"]
	visual.global_position = next
	visual.look_at(next + direction, Vector3.UP)
	if float(b["range_left"]) <= 0.0:
		_remove_bullet(index)

func _earliest_enemy_hit(from_pos: Vector3, to_pos: Vector3, hit_ids: Dictionary) -> Dictionary:
	var best_t := 2.0
	var best_enemy: ZombieEnemy = null
	var dz := to_pos.z - from_pos.z
	if absf(dz) < 0.0001:
		return {}
	for enemy in enemies:
		if not is_instance_valid(enemy) or not enemy.is_alive():
			continue
		var id := enemy.get_instance_id()
		if hit_ids.has(id):
			continue
		var ez := enemy.global_position.z
		var t := (ez - from_pos.z) / dz
		if t < 0.0 or t > 1.0 or t >= best_t:
			continue
		var x_at := lerpf(from_pos.x, to_pos.x, t)
		if absf(x_at - enemy.global_position.x) <= float(enemy.hit_radius):
			best_t = t
			best_enemy = enemy
	if best_enemy == null:
		return {}
	return {"enemy": best_enemy, "t": best_t}

func _remove_bullet(index: int) -> void:
	if index < 0 or index >= bullets.size():
		return
	var visual: MeshInstance3D = bullets[index]["visual"]
	_release_visual(visual)
	bullets.remove_at(index)
