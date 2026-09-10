extends Control

const MAIN_SCENE_PATH := "res://main.tscn"
@onready var startup: Control = $SAMStartupBackground

func _ready() -> void:
	# Load the heavy application behind the five-second branded animation. This
	# keeps Godot's boot splash brief and prevents a second poster-only wait.
	ResourceLoader.load_threaded_request(MAIN_SCENE_PATH)
	await get_tree().create_timer(5.0).timeout
	await startup.transition_to_loading(0.55)
	while ResourceLoader.load_threaded_get_status(MAIN_SCENE_PATH) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
	var packed := ResourceLoader.load_threaded_get(MAIN_SCENE_PATH) as PackedScene
	if packed == null:
		push_error("SAM-AI could not load the main interface.")
		return
	ProjectSettings.set_setting("sam_ai/intro_completed", true)
	# Do not use change_scene_to_packed here: it removes this rendered boot scene
	# before instantiating the heavy UI, exposing the window's gray clear color.
	# Keep the final poster on screen until the new loading scene has drawn.
	var main_scene := packed.instantiate()
	get_tree().root.add_child(main_scene)
	get_tree().current_scene = main_scene
	await get_tree().process_frame
	await get_tree().process_frame
	queue_free()
