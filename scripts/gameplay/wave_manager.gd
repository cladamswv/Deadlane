extends Node
class_name WaveManager

signal spawn_requested(kind: String, spawn_x: float)
signal wave_cleared(wave: int)

const CAMPAIGN_WAVES := 30

var wave: int = 1
var endless: bool = false
var schedule: Array[Dictionary] = []
var schedule_index: int = 0
var elapsed: float = 0.0
var living_count: int = 0
var active: bool = false
var spawn_finished: bool = false
var resolved_emitted: bool = false
var concurrent_cap: int = 110
var enemy_costs: Dictionary = {"shambler": 1.0, "runner": 1.5, "armored": 4.0, "brute": 6.0, "spitter": 3.0}
var rng: RandomNumberGenerator

static func budget_for_wave(w: int, endless_mode: bool = false) -> int:
	var value := int(round(12.0 + 3.3 * float(w) + 0.20 * float(w * w)))
	if endless_mode:
		value = mini(value, 210)
	return value

static func is_rush_wave(w: int) -> bool:
	return [5, 8, 12, 16, 20, 24, 28, 30].has(w)

func start_wave(number: int, random: RandomNumberGenerator, endless_mode: bool) -> void:
	wave = number
	rng = random
	endless = endless_mode
	schedule = _build_schedule(number)
	schedule_index = 0
	elapsed = 0.0
	living_count = 0
	active = true
	spawn_finished = false
	resolved_emitted = false

func stop() -> void:
	active = false
	schedule.clear()
	living_count = 0

func register_enemy_removed() -> void:
	living_count = maxi(0, living_count - 1)
	_check_resolved()

func register_summoned_enemy() -> void:
	living_count += 1

func _process(delta: float) -> void:
	if not active:
		return
	elapsed += delta
	while schedule_index < schedule.size():
		if living_count >= concurrent_cap:
			break
		var item: Dictionary = schedule[schedule_index]
		if float(item["time"]) > elapsed:
			break
		spawn_requested.emit(String(item["type"]), float(item["x"]))
		living_count += 1
		schedule_index += 1
	if schedule_index >= schedule.size():
		spawn_finished = true
	_check_resolved()

func _check_resolved() -> void:
	if active and spawn_finished and living_count <= 0 and not resolved_emitted:
		resolved_emitted = true
		active = false
		wave_cleared.emit(wave)

func _build_schedule(number: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var regulars: Array[Dictionary] = []
	var is_boss := number % 10 == 0
	var budget := float(budget_for_wave(number, endless))
	if is_boss:
		var boss_budget_scale: float = 0.44 if number % 30 != 0 else 0.38
		budget *= boss_budget_scale
		result.append({"time": 1.8, "type": _boss_type_for_wave(number), "x": 0.0})
	var allowed := _allowed_types(number)
	var spent := 0.0
	var pattern := number % 6
	var spawn_index := 0
	while spent + 0.99 < budget:
		var kind := _pick_type(allowed, budget - spent, number)
		var cost := float(enemy_costs[kind])
		if spent + cost > budget + 0.01:
			kind = "shambler"
			cost = 1.0
		spent += cost
		regulars.append({"type": kind, "x": _formation_x(pattern, spawn_index)})
		spawn_index += 1
	# Spawn in visible packs instead of a thin conveyor belt. Every wave now arrives
	# as several compact surges; designated rush waves use even larger packs.
	var rush := is_rush_wave(number)
	var group_size := clampi(10 + int(number / 3), 10, 18)
	if rush:
		group_size = clampi(20 + int(number / 5), 20, 28)
	# Packs arrive as true surges: a dense burst, a short recovery beat, then
	# another burst. This makes the horde read as a crowd rather than a queue.
	var group_interval := 1.45 if rush else 2.15
	for i in range(regulars.size()):
		var item: Dictionary = regulars[i]
		var group_index := int(i / group_size)
		var slot := i % group_size
		var base_time := 0.40 + float(group_index) * group_interval
		var within_gap := 0.028 if rush else 0.040
		item["time"] = base_time + float(slot) * within_gap + rng.randf_range(-0.012, 0.012)
		result.append(item)
	result.sort_custom(_sort_by_time)
	return result

func _boss_type_for_wave(number: int) -> String:
	var cycle := number % 30
	if cycle == 0:
		return "overpass_colossus_boss"
	if cycle == 20:
		return "plague_giant_boss"
	return "bridge_brute_boss"

func _sort_by_time(a: Dictionary, b: Dictionary) -> bool:
	return float(a["time"]) < float(b["time"])

func _allowed_types(number: int) -> Array[String]:
	var types: Array[String] = ["shambler"]
	if number >= 3:
		types.append("runner")
	if number >= 5:
		types.append("armored")
	if number >= 7:
		types.append("spitter")
	if number >= 9:
		types.append("brute")
	return types

func _pick_type(allowed: Array[String], remaining: float, number: int) -> String:
	var candidates: Array[String] = []
	for kind in allowed:
		if float(enemy_costs[kind]) <= remaining + 0.01:
			candidates.append(kind)
	if candidates.is_empty():
		return "shambler"
	var roll := rng.randf()
	var shambler_weight := 0.46
	if number >= 13:
		shambler_weight = 0.36
	if number >= 21:
		shambler_weight = 0.27
	if candidates.has("shambler") and roll < shambler_weight:
		return "shambler"
	# Late campaign waves deliberately bias toward mixed pressure instead of HP inflation.
	if number >= 21 and candidates.has("brute") and roll > 0.84:
		return "brute"
	if number >= 21 and candidates.has("spitter") and roll > 0.68 and roll <= 0.84:
		return "spitter"
	return candidates[rng.randi_range(0, candidates.size() - 1)]

func _formation_x(pattern: int, index: int) -> float:
	if pattern == 0:
		var lanes: Array[float] = [-3.7, -2.3, -0.8, 0.8, 2.3, 3.7]
		return float(lanes[index % lanes.size()]) + rng.randf_range(-0.22, 0.22)
	if pattern == 1:
		return clampf(rng.randfn(0.0, 1.25), -3.8, 3.8)
	if pattern == 2:
		var side := -1.0 if int(wave / 2) % 2 == 0 else 1.0
		return clampf(side * rng.randf_range(1.8, 3.8) + rng.randf_range(-0.3, 0.3), -4.0, 4.0)
	if pattern == 3:
		return rng.randf_range(-4.0, 4.0)
	if pattern == 4:
		var split_side := -1.0 if index % 2 == 0 else 1.0
		return split_side * rng.randf_range(2.1, 3.9)
	var zig: Array[float] = [-3.6, 3.6, -2.4, 2.4, -1.1, 1.1]
	return float(zig[index % zig.size()]) + rng.randf_range(-0.18, 0.18)
