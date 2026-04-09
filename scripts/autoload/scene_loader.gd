# SceneLoader.gd (Autoload)
extends Node

signal progress_changed(progress)
signal load_finished

var loading_screen: PackedScene = preload("uid://durl0k7ue4sqf")
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_sub_threads: bool = true

var scene_history: Array = []  # Track visited scenes
var scene_state: Dictionary = {}  # Store scene state

func _ready() -> void:
	set_process(false)

func save_current_scene_state():
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.has_method("save_state"):
		scene_state[current_scene.scene_file_path] = current_scene.save_state()
		print("Saved state for: ", current_scene.scene_file_path)

func load_scene(_scene_path: String, record_history: bool = true, preserve_state: bool = false) -> void:
	if record_history and get_tree().current_scene:
		# Save current scene state before leaving
		save_current_scene_state()
		scene_history.append(get_tree().current_scene.scene_file_path)
	
	scene_path = _scene_path
	
	var new_load_screen = loading_screen.instantiate()
	add_child(new_load_screen)
	progress_changed.connect(new_load_screen._on_progress_changed)
	load_finished.connect(new_load_screen._on_load_finished)
	
	await new_load_screen.loading_screen_ready
	
	start_load()

func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)

func go_back() -> void:
	if scene_history.is_empty():
		push_warning("No scene history to go back to")
		return
	
	save_current_scene_state()
	var previous_scene = scene_history.pop_back()
	load_scene(previous_scene, false)

func _process(delta: float) -> void:
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_changed.emit(progress[0])
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			var new_scene = loaded_resource.instantiate()
			get_tree().current_scene.queue_free()
			get_tree().root.add_child(new_scene)
			get_tree().current_scene = new_scene
			
			# Restore saved state if exists
			if scene_state.has(scene_path):
				if new_scene.has_method("load_state"):
					print("Restoring state for: ", scene_path)
					new_scene.load_state(scene_state[scene_path])
				else:
					print("Scene has no load_state method: ", scene_path)
			else:
				print("No saved state for: ", scene_path)
			
			load_finished.emit()
