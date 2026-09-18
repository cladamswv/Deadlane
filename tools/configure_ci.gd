extends SceneTree

func _initialize() -> void:
	var android_home := OS.get_environment("ANDROID_HOME")
	var java_home := OS.get_environment("JAVA_HOME")
	if android_home.is_empty():
		push_error("ANDROID_HOME is not set")
		quit(1)
		return
	if java_home.is_empty():
		push_error("JAVA_HOME is not set")
		quit(1)
		return
	print("Android SDK: ", android_home)
	print("Java SDK: ", java_home)
	quit(0)
