extends SceneTree

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	change_scene_to_file("res://scenes/main.tscn")
	for i in range(12):
		await process_frame
	var menu_image := root.get_viewport().get_texture().get_image()
	menu_image.save_png("res://builds/screenshots/menu-720x1280.png")
	var main = current_scene
	if main != null:
		main._start_new_run("assault_rifle", false)
		await create_timer(2.0).timeout
		var gameplay_image := root.get_viewport().get_texture().get_image()
		gameplay_image.save_png("res://builds/screenshots/gameplay-720x1280.png")
	quit(0)
