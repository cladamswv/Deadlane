extends Node

const PROFILE_PATH := "user://profile_v1.json"
const PROFILE_BACKUP := "user://profile_v1.bak"
const CHECKPOINT_PATH := "user://run_checkpoint_v1.json"
const CHECKPOINT_BACKUP := "user://run_checkpoint_v1.bak"
const SAVE_VERSION := 1

var profile: Dictionary = {}

func _ready() -> void:
	profile = load_profile()

func default_profile() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"campaign_completed": false,
		"best_wave": 0,
		"best_score": 0,
		"unlocked_weapons": ["assault_rifle"],
		"settings": {
			"master": 1.0,
			"music": 0.25,
			"sfx": 0.95,
			"vibration": true,
			"reduced_effects": false,
			"quality": "medium",
			"fps": 60,
			"damage_numbers": false
		}
	}

func load_profile() -> Dictionary:
	var data: Dictionary = _read_valid_json(PROFILE_PATH)
	if data.is_empty():
		data = _read_valid_json(PROFILE_BACKUP)
	if data.is_empty() or int(data.get("version", 0)) != SAVE_VERSION:
		data = default_profile()
	_merge_profile_defaults(data)
	return data

func _merge_profile_defaults(data: Dictionary) -> void:
	var defaults := default_profile()
	for key in defaults.keys():
		if not data.has(key):
			data[key] = defaults[key]
	var settings: Dictionary = data.get("settings", {})
	var default_settings: Dictionary = defaults["settings"]
	for key in default_settings.keys():
		if not settings.has(key):
			settings[key] = default_settings[key]
	data["settings"] = settings

func save_profile() -> bool:
	profile["version"] = SAVE_VERSION
	return _atomic_write(PROFILE_PATH, PROFILE_BACKUP, profile)

func has_checkpoint() -> bool:
	return not load_checkpoint().is_empty()

func load_checkpoint() -> Dictionary:
	var data: Dictionary = _read_valid_json(CHECKPOINT_PATH)
	if _validate_checkpoint(data):
		return data
	data = _read_valid_json(CHECKPOINT_BACKUP)
	if _validate_checkpoint(data):
		return data
	return {}


func _validate_checkpoint(data: Dictionary) -> bool:
	if data.is_empty() or int(data.get("version", 0)) != SAVE_VERSION:
		return false
	if bool(data.get("finished", false)):
		return false
	var next_wave := int(data.get("next_wave", 0))
	if next_wave < 1 or next_wave > 100000:
		return false
	if int(data.get("health", -1)) < 0 or int(data.get("score", -1)) < 0:
		return false
	if float(data.get("grenade_cooldown", -1.0)) < 0.0:
		return false
	var weapon := String(data.get("weapon", ""))
	if not ["assault_rifle", "smg", "shotgun", "piercer"].has(weapon):
		return false
	var mode := String(data.get("mode", ""))
	if mode != "campaign" and mode != "endless":
		return false
	if mode == "campaign" and next_wave > 30:
		return false
	if not (data.get("upgrades", {}) is Dictionary):
		return false
	if not (data.get("pending_upgrade_choices", []) is Array):
		return false
	return true

func save_checkpoint(data: Dictionary) -> bool:
	var out := data.duplicate(true)
	out["version"] = SAVE_VERSION
	out["finished"] = false
	return _atomic_write(CHECKPOINT_PATH, CHECKPOINT_BACKUP, out)

func clear_checkpoint() -> void:
	if FileAccess.file_exists(CHECKPOINT_PATH):
		DirAccess.remove_absolute(CHECKPOINT_PATH)
	if FileAccess.file_exists(CHECKPOINT_BACKUP):
		DirAccess.remove_absolute(CHECKPOINT_BACKUP)

func _read_valid_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	var parsed: Variant = JSON.parse_string(text)
	if parsed is Dictionary:
		return parsed
	return {}

func _atomic_write(path: String, backup_path: String, data: Dictionary) -> bool:
	var temp_path := path + ".tmp"
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.flush()
	file.close()
	if FileAccess.file_exists(backup_path):
		DirAccess.remove_absolute(backup_path)
	if FileAccess.file_exists(path):
		var backup_error := DirAccess.rename_absolute(path, backup_path)
		if backup_error != OK:
			DirAccess.remove_absolute(temp_path)
			return false
	var replace_error := DirAccess.rename_absolute(temp_path, path)
	if replace_error != OK:
		if FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(backup_path, path)
		return false
	return true
