extends CanvasLayer
class_name GameUI

signal new_run_requested()
signal continue_requested()
signal endless_requested()
signal weapon_selected(weapon: String, mode: String)
signal pause_requested()
signal resume_requested()
signal grenade_requested()
signal fire_state_changed(pressed: bool)
signal upgrade_selected(upgrade_id: String)
signal restart_requested()
signal menu_requested()
signal credits_requested()
signal settings_changed(settings: Dictionary)

var root: Control
var menu_panel: Control
var weapon_panel: Control
var hud: Control
var pause_panel: Control
var upgrade_panel: Control
var result_panel: Control
var credits_panel: Control
var banner: Label
var tutorial: Label
var health_bar: ProgressBar
var health_label: Label
var wave_label: Label
var score_label: Label
var campaign_progress: ProgressBar
var grenade_button: Button
var fire_button: Button
var boss_wrap: VBoxContainer
var boss_label: Label
var boss_bar: ProgressBar
var menu_continue: Button
var menu_endless: Button
var result_title: Label
var result_body: Label
var upgrade_box: VBoxContainer
var weapon_box: VBoxContainer
var pending_weapon_mode: String = "campaign"
var current_settings: Dictionary = {}
var master_slider: HSlider
var music_slider: HSlider
var sfx_slider: HSlider
var vibration_check: CheckButton
var reduced_check: CheckButton
var fps_option: OptionButton
var quality_option: OptionButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()

func _build_ui() -> void:
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(root)
	var vignette := ColorRect.new()
	vignette.color = Color(0.025, 0.045, 0.075, 0.16)
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(vignette)
	menu_panel = _build_menu()
	weapon_panel = _build_weapon_panel()
	hud = _build_hud()
	pause_panel = _build_pause()
	upgrade_panel = _build_upgrade()
	result_panel = _build_result()
	credits_panel = _build_credits()
	banner = Label.new()
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner.add_theme_font_size_override("font_size", 34)
	banner.add_theme_color_override("font_color", Color("#f4e6bb"))
	banner.set_anchors_preset(Control.PRESET_CENTER_TOP)
	banner.position = Vector2(-260, 180)
	banner.size = Vector2(520, 70)
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.visible = false
	root.add_child(banner)
	tutorial = Label.new()
	tutorial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial.add_theme_font_size_override("font_size", 22)
	tutorial.add_theme_color_override("font_color", Color.WHITE)
	tutorial.set_anchors_preset(Control.PRESET_CENTER_TOP)
	tutorial.position = Vector2(-290, 250)
	tutorial.size = Vector2(580, 120)
	tutorial.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tutorial.visible = false
	root.add_child(tutorial)
	show_only(menu_panel)

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.018, 0.038, 0.064, 0.94)
	style.border_color = Color(0.26, 0.48, 0.61, 0.88)
	style.set_border_width_all(2)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	style.shadow_size = 12
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 22
	style.content_margin_bottom = 22
	return style

func _button_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#102b43")
	style.border_color = Color(0.26, 0.48, 0.61, 0.75)
	style.set_border_width_all(1)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.28)
	style.shadow_size = 5
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_top = 13
	style.content_margin_bottom = 13
	style.content_margin_left = 18
	style.content_margin_right = 18
	return style

func _grenade_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#9d4f27")
	style.border_color = Color("#e9a55a")
	style.set_border_width_all(3)
	style.corner_radius_top_left = 70
	style.corner_radius_top_right = 70
	style.corner_radius_bottom_left = 70
	style.corner_radius_bottom_right = 70
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	style.content_margin_left = 14
	style.content_margin_right = 14
	return style

func _make_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 64)
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_stylebox_override("normal", _button_style())
	var hover := _button_style()
	hover.bg_color = Color("#205070")
	button.add_theme_stylebox_override("hover", hover)
	var pressed := _button_style()
	pressed.bg_color = Color("#2a6788")
	button.add_theme_stylebox_override("pressed", pressed)
	return button

func _make_center_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 54
	panel.offset_right = -54
	panel.offset_top = 150
	panel.offset_bottom = -150
	panel.add_theme_stylebox_override("panel", _panel_style())
	root.add_child(panel)
	return panel

func _title(text: String, size: int = 42) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color("#f4e6bb"))
	return label

func _build_menu() -> Control:
	var panel := _make_center_panel()
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	panel.add_child(box)
	box.add_child(_title("DEADLANE", 50))
	box.add_child(_title("ZOMBIE BRIDGE", 30))
	var campaign_tag := Label.new()
	campaign_tag.text = "30-WAVE BRIDGE DEFENSE"
	campaign_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	campaign_tag.add_theme_font_size_override("font_size", 16)
	campaign_tag.add_theme_color_override("font_color", Color("#e5a86d"))
	box.add_child(campaign_tag)
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 22
	box.add_child(spacer)
	var start := _make_button("START CAMPAIGN")
	start.pressed.connect(func() -> void: new_run_requested.emit())
	box.add_child(start)
	menu_continue = _make_button("CONTINUE CHECKPOINT")
	menu_continue.pressed.connect(func() -> void: continue_requested.emit())
	box.add_child(menu_continue)
	menu_endless = _make_button("ENDLESS MODE")
	menu_endless.pressed.connect(func() -> void: endless_requested.emit())
	box.add_child(menu_endless)
	var credits := _make_button("CREDITS / LICENSES")
	credits.pressed.connect(func() -> void: credits_requested.emit())
	box.add_child(credits)
	var footer := Label.new()
	footer.text = "Offline • 30-wave campaign • drag to move • hold FIRE to shoot"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_color_override("font_color", Color("#9fb4c6"))
	box.add_child(footer)
	return panel

func _build_weapon_panel() -> Control:
	var panel := _make_center_panel()
	weapon_box = VBoxContainer.new()
	weapon_box.alignment = BoxContainer.ALIGNMENT_CENTER
	weapon_box.add_theme_constant_override("separation", 12)
	panel.add_child(weapon_box)
	return panel

func _build_hud() -> Control:
	var layer := Control.new()
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_PASS
	root.add_child(layer)
	var top := PanelContainer.new()
	top.anchor_right = 1.0
	top.offset_left = 18
	top.offset_right = -18
	top.offset_top = 24
	top.offset_bottom = 178
	top.add_theme_stylebox_override("panel", _panel_style())
	layer.add_child(top)
	var vb := VBoxContainer.new()
	top.add_child(vb)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	vb.add_child(row)
	wave_label = Label.new()
	wave_label.text = "WAVE 1/30"
	wave_label.add_theme_font_size_override("font_size", 21)
	wave_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(wave_label)
	score_label = Label.new()
	score_label.text = "SCORE 0"
	score_label.add_theme_font_size_override("font_size", 20)
	row.add_child(score_label)
	var pause := _make_button("Ⅱ")
	pause.custom_minimum_size = Vector2(62, 52)
	pause.pressed.connect(func() -> void: pause_requested.emit())
	row.add_child(pause)
	campaign_progress = ProgressBar.new()
	campaign_progress.min_value = 0
	campaign_progress.max_value = 30
	campaign_progress.value = 1
	campaign_progress.show_percentage = false
	campaign_progress.custom_minimum_size.y = 8
	vb.add_child(campaign_progress)
	var health_row := HBoxContainer.new()
	vb.add_child(health_row)
	health_label = Label.new()
	health_label.text = "DEFENSE 100/100"
	health_label.custom_minimum_size.x = 170
	health_row.add_child(health_label)
	health_bar = ProgressBar.new()
	health_bar.min_value = 0
	health_bar.max_value = 100
	health_bar.value = 100
	health_bar.show_percentage = false
	health_bar.custom_minimum_size = Vector2(0, 28)
	health_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	health_row.add_child(health_bar)
	boss_wrap = VBoxContainer.new()
	boss_wrap.visible = false
	vb.add_child(boss_wrap)
	boss_label = Label.new()
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_wrap.add_child(boss_label)
	boss_bar = ProgressBar.new()
	boss_bar.show_percentage = false
	boss_bar.custom_minimum_size.y = 20
	boss_wrap.add_child(boss_bar)
	grenade_button = _make_button("GRENADE\nREADY")
	grenade_button.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	grenade_button.position = Vector2(30, -195)
	grenade_button.size = Vector2(150, 132)
	grenade_button.add_theme_font_size_override("font_size", 19)
	grenade_button.add_theme_stylebox_override("normal", _grenade_style())
	var grenade_pressed := _grenade_style()
	grenade_pressed.bg_color = Color("#c96a31")
	grenade_button.add_theme_stylebox_override("pressed", grenade_pressed)
	var grenade_hover := _grenade_style()
	grenade_hover.bg_color = Color("#b85d2b")
	grenade_button.add_theme_stylebox_override("hover", grenade_hover)
	grenade_button.pressed.connect(func() -> void: grenade_requested.emit())
	layer.add_child(grenade_button)

	fire_button = _make_button("HOLD\nFIRE")
	fire_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	fire_button.position = Vector2(-200, -205)
	fire_button.size = Vector2(170, 150)
	fire_button.add_theme_font_size_override("font_size", 27)
	var fire_normal := _grenade_style()
	fire_normal.bg_color = Color("#7e2630")
	fire_normal.border_color = Color("#ef8a79")
	fire_button.add_theme_stylebox_override("normal", fire_normal)
	var fire_pressed_style := _grenade_style()
	fire_pressed_style.bg_color = Color("#d13b32")
	fire_pressed_style.border_color = Color("#ffd08a")
	fire_button.add_theme_stylebox_override("pressed", fire_pressed_style)
	var fire_hover := _grenade_style()
	fire_hover.bg_color = Color("#a92f34")
	fire_hover.border_color = Color("#f1a189")
	fire_button.add_theme_stylebox_override("hover", fire_hover)
	fire_button.button_down.connect(func() -> void: fire_state_changed.emit(true))
	fire_button.button_up.connect(func() -> void: fire_state_changed.emit(false))
	layer.add_child(fire_button)
	return layer

func _build_pause() -> Control:
	var panel := _make_center_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	box.add_child(_title("PAUSED", 38))
	var resume := _make_button("RESUME")
	resume.pressed.connect(func() -> void: resume_requested.emit())
	box.add_child(resume)
	master_slider = _add_slider(box, "Master", 1.0)
	music_slider = _add_slider(box, "Music", 0.25)
	sfx_slider = _add_slider(box, "SFX", 0.95)
	vibration_check = CheckButton.new()
	vibration_check.text = "Vibration"
	vibration_check.add_theme_font_size_override("font_size", 20)
	vibration_check.toggled.connect(_on_setting_control_changed)
	box.add_child(vibration_check)
	reduced_check = CheckButton.new()
	reduced_check.text = "Reduced effects"
	reduced_check.add_theme_font_size_override("font_size", 20)
	reduced_check.toggled.connect(_on_setting_control_changed)
	box.add_child(reduced_check)
	quality_option = OptionButton.new()
	quality_option.add_item("Low visuals")
	quality_option.add_item("Medium visuals")
	quality_option.add_item("High visuals")
	quality_option.item_selected.connect(_on_quality_selected)
	box.add_child(quality_option)
	fps_option = OptionButton.new()
	fps_option.add_item("30 FPS", 30)
	fps_option.add_item("60 FPS", 60)
	fps_option.item_selected.connect(_on_fps_selected)
	box.add_child(fps_option)
	var menu := _make_button("RETURN TO MENU")
	menu.pressed.connect(func() -> void: menu_requested.emit())
	box.add_child(menu)
	return panel

func _add_slider(box: VBoxContainer, text: String, value: float) -> HSlider:
	var label := Label.new()
	label.text = text
	box.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = value
	slider.custom_minimum_size.y = 36
	slider.value_changed.connect(_on_slider_changed)
	box.add_child(slider)
	return slider

func _build_upgrade() -> Control:
	var panel := _make_center_panel()
	upgrade_box = VBoxContainer.new()
	upgrade_box.alignment = BoxContainer.ALIGNMENT_CENTER
	upgrade_box.add_theme_constant_override("separation", 14)
	panel.add_child(upgrade_box)
	return panel

func _build_result() -> Control:
	var panel := _make_center_panel()
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	panel.add_child(box)
	result_title = _title("RUN OVER", 44)
	box.add_child(result_title)
	result_body = Label.new()
	result_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_body.add_theme_font_size_override("font_size", 22)
	box.add_child(result_body)
	var retry := _make_button("START ANOTHER RUN")
	retry.pressed.connect(func() -> void: restart_requested.emit())
	box.add_child(retry)
	var menu := _make_button("MAIN MENU")
	menu.pressed.connect(func() -> void: menu_requested.emit())
	box.add_child(menu)
	return panel

func _build_credits() -> Control:
	var panel := _make_center_panel()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	box.add_child(_title("CREDITS / LICENSES", 34))
	var text := RichTextLabel.new()
	text.bbcode_enabled = true
	text.fit_content = true
	text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text.text = "[center][b]DEADLANE: ZOMBIE BRIDGE[/b]\nOriginal procedural art, interface, and generated audio for this project.\n\n[b]Engine[/b]\nGodot Engine 4.7.2-stable, MIT License.\nCopyright © 2014-present Godot Engine contributors.\nCopyright © 2007-2014 Juan Linietsky, Ariel Manzur.\n\nFull license and third-party notices are included with the source package.[/center]"
	box.add_child(text)
	var back := _make_button("BACK")
	back.pressed.connect(func() -> void: menu_requested.emit())
	box.add_child(back)
	return panel

func show_only(panel: Control) -> void:
	for p in [menu_panel, weapon_panel, hud, pause_panel, upgrade_panel, result_panel, credits_panel]:
		p.visible = p == panel
	banner.visible = false
	if panel != hud:
		tutorial.visible = false

func show_menu(profile: Dictionary, has_checkpoint: bool) -> void:
	show_only(menu_panel)
	menu_continue.disabled = not has_checkpoint
	menu_endless.disabled = not bool(profile.get("campaign_completed", false))

func show_weapon_select(unlocked: Array, mode: String) -> void:
	pending_weapon_mode = mode
	for child in weapon_box.get_children():
		child.queue_free()
	weapon_box.add_child(_title("CHOOSE YOUR WEAPON", 34))
	var descriptions := {
		"assault_rifle": "ASSAULT RIFLE  •  balanced",
		"smg": "SMG  •  rapid fire",
		"shotgun": "SHOTGUN  •  close spread",
		"piercer": "PIERCER  •  line penetration"
	}
	for name in ["assault_rifle", "smg", "shotgun", "piercer"]:
		var b := _make_button(String(descriptions[name]))
		b.disabled = not unlocked.has(name)
		b.pressed.connect(_on_weapon_button.bind(name))
		weapon_box.add_child(b)
	var back := _make_button("BACK")
	back.pressed.connect(func() -> void: menu_requested.emit())
	weapon_box.add_child(back)
	show_only(weapon_panel)

func _on_weapon_button(name: String) -> void:
	weapon_selected.emit(name, pending_weapon_mode)

func show_hud() -> void:
	show_only(hud)

func update_hud(health: int, max_health: int, wave: int, score: int, grenade_cd: float, endless_mode: bool) -> void:
	health_bar.max_value = max_health
	health_bar.value = health
	health_label.text = "DEFENSE %d/%d" % [health, max_health]
	var stage := "EVAC" if wave <= 10 else ("SUNSET" if wave <= 20 else ("NIGHTFALL" if wave <= 30 else "ENDLESS"))
	wave_label.text = "WAVE %d%s  •  %s" % [wave, "" if endless_mode else "/30", stage]
	campaign_progress.visible = not endless_mode
	campaign_progress.value = mini(wave, 30)
	score_label.text = "SCORE %d" % score
	if grenade_cd <= 0.0:
		grenade_button.text = "GRENADE\nREADY"
		grenade_button.disabled = false
	else:
		grenade_button.text = "GRENADE\n%.1fs" % grenade_cd
		grenade_button.disabled = true

func show_boss(name: String, hp: float, max_hp: float) -> void:
	boss_wrap.visible = true
	boss_label.text = name
	boss_bar.max_value = max_hp
	boss_bar.value = maxf(0.0, hp)

func hide_boss() -> void:
	boss_wrap.visible = false

func show_pause(settings: Dictionary) -> void:
	current_settings = settings.duplicate(true)
	master_slider.value = float(current_settings.get("master", 1.0))
	music_slider.value = float(current_settings.get("music", 0.25))
	sfx_slider.value = float(current_settings.get("sfx", 0.95))
	vibration_check.button_pressed = bool(current_settings.get("vibration", true))
	reduced_check.button_pressed = bool(current_settings.get("reduced_effects", false))
	var quality := String(current_settings.get("quality", "medium"))
	quality_option.select(0 if quality == "low" else (2 if quality == "high" else 1))
	var fps := int(current_settings.get("fps", 60))
	fps_option.select(0 if fps == 30 else 1)
	show_only(pause_panel)

func show_upgrades(ids: Array[String]) -> void:
	for child in upgrade_box.get_children():
		child.queue_free()
	upgrade_box.add_child(_title("CHOOSE A RUN UPGRADE", 31))
	for id in ids:
		var b := _make_button(_upgrade_text(id))
		b.pressed.connect(_on_upgrade_button.bind(id))
		upgrade_box.add_child(b)
	show_only(upgrade_panel)

func _upgrade_text(id: String) -> String:
	match id:
		"damage": return "+15% WEAPON DAMAGE"
		"fire_rate": return "+10% FIRE RATE"
		"health": return "+20 MAX + CURRENT DEFENSE"
		"grenade": return "+25% GRENADE DAMAGE"
		"penetration": return "+1 PROJECTILE PENETRATION"
		"repair": return "REPAIR UP TO 30 DEFENSE"
	return id.to_upper()

func _on_upgrade_button(id: String) -> void:
	upgrade_selected.emit(id)

func show_result(victory: bool, wave: int, score: int, endless_mode: bool) -> void:
	result_title.text = "BRIDGE SECURED" if victory else "THE LINE FELL"
	var victory_line := "\nAll 30 campaign waves cleared." if victory and not endless_mode else ""
	var unlock_line := "\nEndless Mode Unlocked" if victory and not endless_mode else ""
	result_body.text = "Wave %d\nScore %d%s%s" % [wave, score, victory_line, unlock_line]
	show_only(result_panel)

func show_credits() -> void:
	show_only(credits_panel)

func flash_banner(text: String, seconds: float = 1.8) -> void:
	banner.text = text
	banner.visible = true
	var token := Time.get_ticks_msec()
	banner.set_meta("token", token)
	await get_tree().create_timer(seconds, false).timeout
	if banner.get_meta("token", 0) == token:
		banner.visible = false

func show_tutorial(text: String, seconds: float = 4.0) -> void:
	tutorial.text = text
	tutorial.visible = true
	var token := Time.get_ticks_msec()
	tutorial.set_meta("token", token)
	await get_tree().create_timer(seconds, false).timeout
	if tutorial.get_meta("token", 0) == token:
		tutorial.visible = false

func show_resume_count(value: int) -> void:
	banner.text = "RESUMING IN %d" % value
	banner.visible = true

func hide_banner() -> void:
	banner.visible = false

func _on_slider_changed(_value: float) -> void:
	_emit_settings()

func _on_setting_control_changed(_value: bool) -> void:
	_emit_settings()

func _on_fps_selected(_index: int) -> void:
	_emit_settings()

func _on_quality_selected(_index: int) -> void:
	_emit_settings()

func _emit_settings() -> void:
	if current_settings.is_empty():
		return
	current_settings["master"] = master_slider.value
	current_settings["music"] = music_slider.value
	current_settings["sfx"] = sfx_slider.value
	current_settings["vibration"] = vibration_check.button_pressed
	current_settings["reduced_effects"] = reduced_check.button_pressed
	current_settings["quality"] = ["low", "medium", "high"][quality_option.selected]
	current_settings["fps"] = 30 if fps_option.selected == 0 else 60
	settings_changed.emit(current_settings.duplicate(true))
