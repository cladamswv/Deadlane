extends Node
class_name UpgradeSystem

const CAPS := {"damage": 3, "fire_rate": 3, "health": 2, "grenade": 2, "penetration": 1}
var counts: Dictionary = {"damage": 0, "fire_rate": 0, "health": 0, "grenade": 0, "penetration": 0}

func reset() -> void:
	counts = {"damage": 0, "fire_rate": 0, "health": 0, "grenade": 0, "penetration": 0}

func restore(saved: Dictionary) -> void:
	reset()
	for key in counts.keys():
		counts[key] = clampi(int(saved.get(key, 0)), 0, int(CAPS[key]))

func choices(rng: RandomNumberGenerator, current_health: int, max_health: int) -> Array[String]:
	var eligible: Array[String] = []
	for key in CAPS.keys():
		if int(counts[key]) < int(CAPS[key]):
			eligible.append(String(key))
	var result: Array[String] = []
	while not eligible.is_empty() and result.size() < 3:
		var idx := rng.randi_range(0, eligible.size() - 1)
		result.append(eligible[idx])
		eligible.remove_at(idx)
	if result.size() < 3 and current_health < max_health:
		result.append("repair")
	return result

func apply(id: String) -> void:
	if id == "repair":
		return
	if counts.has(id):
		counts[id] = mini(int(counts[id]) + 1, int(CAPS[id]))

func damage_multiplier() -> float:
	return 1.0 + 0.15 * float(counts["damage"])

func rate_multiplier() -> float:
	return 1.0 + 0.10 * float(counts["fire_rate"])

func max_health_bonus() -> int:
	return 20 * int(counts["health"])

func grenade_multiplier() -> float:
	return 1.0 + 0.25 * float(counts["grenade"])

func extra_penetration() -> int:
	return int(counts["penetration"])
