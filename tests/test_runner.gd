extends SceneTree

const Projectile = preload("res://scripts/gameplay/projectile_system.gd")
const Wave = preload("res://scripts/gameplay/wave_manager.gd")
const Upgrade = preload("res://scripts/gameplay/upgrade_system.gd")
const Player = preload("res://scripts/gameplay/player_controller.gd")

var failures: int = 0

func _initialize() -> void:
	_check(Projectile.gate_output_count(100, 2) == 200, "x2 gate produces exactly 200 outputs from 100 inputs")
	_check(Projectile.gate_output_count(100, 3) == 300, "x3 gate cap")
	_check(Wave.budget_for_wave(1, false) == 16, "wave 1 budget")
	_check(Wave.budget_for_wave(20, false) == 158, "wave 20 budget")
	_check(Wave.budget_for_wave(30, false) == 291, "wave 30 budget")
	_check(Wave.is_rush_wave(24), "late campaign rush wave")
	_check(Wave.budget_for_wave(100, true) == 210, "endless budget cap")
	var upgrades: UpgradeSystem = Upgrade.new()
	for i in range(8):
		upgrades.apply("damage")
	_check(upgrades.counts["damage"] == 3, "damage upgrade cap")
	_check(absf(upgrades.damage_multiplier() - 1.45) < 0.001, "damage stacking is base-relative")
	var rng_a := RandomNumberGenerator.new()
	var rng_b := RandomNumberGenerator.new()
	rng_a.seed = 424242
	rng_b.seed = 424242
	var upgrade_a: UpgradeSystem = Upgrade.new()
	var upgrade_b: UpgradeSystem = Upgrade.new()
	var choices_a: Array[String] = upgrade_a.choices(rng_a, 100, 100)
	var choices_b: Array[String] = upgrade_b.choices(rng_b, 100, 100)
	_check(choices_a == choices_b, "upgrade choices use only the saved run RNG")
	var player: PlayerController = Player.new()
	player.set_active(true)
	player.set_firing(true)
	_check(player.firing_held, "manual fire can be held")
	player.set_active(false)
	_check(not player.firing_held, "pause/deactivation clears held fire")
	if failures == 0:
		print("ALL ENGINE TESTS PASSED")
		quit(0)
	else:
		push_error("ENGINE TEST FAILURES: %d" % failures)
		quit(1)

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: ", label)
	else:
		failures += 1
		push_error("FAIL: " + label)
