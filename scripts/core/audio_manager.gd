extends Node

var music_player: AudioStreamPlayer
var crowd_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var zombie_players: Array[AudioStreamPlayer] = []
var sfx_streams: Dictionary = {}
var master_volume: float = 1.0
var music_volume: float = 0.25
var sfx_volume: float = 0.95
var crowd_count: int = 0
var crowd_boss: bool = false
var crowd_pitch_phase: float = 0.0

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.finished.connect(_on_music_finished)
	crowd_player = AudioStreamPlayer.new()
	add_child(crowd_player)
	crowd_player.finished.connect(_on_crowd_finished)
	# Weapon/impact sounds and zombie voices have separate pools so rapid gunfire
	# can never starve the horde voices of an available audio player.
	for i in range(14):
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)
	for i in range(8):
		var p := AudioStreamPlayer.new()
		add_child(p)
		zombie_players.append(p)
	_load_streams()

func _load_streams() -> void:
	var music_path := "res://assets/audio/action_loop.wav"
	if ResourceLoader.exists(music_path):
		music_player.stream = load(music_path)
	var crowd_path := "res://assets/audio/zombie_crowd.wav"
	if ResourceLoader.exists(crowd_path):
		crowd_player.stream = load(crowd_path)
	var names: Array[String] = ["rifle", "smg", "shotgun", "piercer", "hit", "death", "gate", "grenade", "ui", "zombie", "zombie_groan1", "zombie_groan2", "zombie_snarl", "zombie_death"]
	for name in names:
		var path := "res://assets/audio/%s.wav" % name
		if ResourceLoader.exists(path):
			sfx_streams[name] = load(path)
	_apply_volumes()

func configure(settings: Dictionary) -> void:
	master_volume = float(settings.get("master", 1.0))
	music_volume = float(settings.get("music", 0.25))
	sfx_volume = float(settings.get("sfx", 0.95))
	_apply_volumes()
	_update_crowd_volume()

func _apply_volumes() -> void:
	if music_player != null:
		music_player.volume_db = _safe_db(master_volume * music_volume)
	for p in sfx_players:
		p.volume_db = _safe_db(master_volume * sfx_volume)
	for p in zombie_players:
		p.volume_db = _safe_db(master_volume * sfx_volume)

func play_music() -> void:
	if music_player.stream != null and not music_player.playing:
		music_player.play()

func stop_music() -> void:
	music_player.stop()

func play_sfx(name: String, pitch: float = 1.0, gain: float = 1.0) -> void:
	if not sfx_streams.has(name):
		return
	var pool: Array[AudioStreamPlayer] = zombie_players if name.begins_with("zombie") else sfx_players
	for p in pool:
		if not p.playing:
			p.stream = sfx_streams[name]
			p.pitch_scale = pitch
			p.volume_db = _safe_db(master_volume * sfx_volume * clampf(gain, 0.0, 1.5))
			p.play()
			return
	# For zombie voices, replace the oldest/first voice rather than silently
	# dropping the sound during a dense surge.
	if name.begins_with("zombie") and not pool.is_empty():
		var p := pool[0]
		p.stop()
		p.stream = sfx_streams[name]
		p.pitch_scale = pitch
		p.volume_db = _safe_db(master_volume * sfx_volume * clampf(gain, 0.0, 1.5))
		p.play()

func set_zombie_crowd(count: int, boss_active: bool = false) -> void:
	crowd_count = maxi(0, count)
	crowd_boss = boss_active
	if crowd_count <= 0 or crowd_player.stream == null:
		if crowd_player.playing:
			crowd_player.stop()
		return
	_update_crowd_volume()
	if not crowd_player.playing:
		crowd_player.play()

func _update_crowd_volume() -> void:
	if crowd_player == null:
		return
	# The crowd bed is intentionally obvious. Individual groans sit above it,
	# so even heavy automatic weapon audio cannot erase the zombie presence.
	var intensity := clampf(0.42 + float(crowd_count) / 70.0 * 0.42 + (0.10 if crowd_boss else 0.0), 0.0, 0.94)
	crowd_player.volume_db = _safe_db(master_volume * sfx_volume * intensity)
	crowd_player.pitch_scale = 0.98 if not crowd_boss else 0.90

func _on_music_finished() -> void:
	if music_player.stream != null:
		music_player.play()

func _on_crowd_finished() -> void:
	if crowd_count > 0 and crowd_player.stream != null:
		crowd_player.play()

func _safe_db(value: float) -> float:
	if value <= 0.001:
		return -80.0
	return linear_to_db(value)
