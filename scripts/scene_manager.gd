extends Node

enum Scene {
	NONE,
	MAIN_MENU,
	GAMEPLAY,
	PAUSE,
	OPTIONS,
}

const SCENE_PATHS: Dictionary[Scene, String] = {
	Scene.MAIN_MENU: "res://scenes/ui/main_menu.tscn",
	Scene.PAUSE: "res://scenes/ui/pause_menu.tscn",
	Scene.OPTIONS: "res://scenes/ui/options_menu.tscn",
	Scene.GAMEPLAY: "res://scenes/playtest.tscn",
}

var _scenes: Dictionary[Scene, Node] = {
	Scene.NONE: null,
	Scene.MAIN_MENU: preload(SCENE_PATHS[Scene.MAIN_MENU]).instantiate(),
	Scene.GAMEPLAY: null,
	Scene.PAUSE: preload(SCENE_PATHS[Scene.PAUSE]).instantiate(),
	Scene.OPTIONS: preload(SCENE_PATHS[Scene.OPTIONS]).instantiate(),
}
var _scene_stack: Array[Scene] = [Scene.NONE, Scene.NONE, Scene.NONE, Scene.NONE]
var _stack_level: int = 0:
	get:
		return _stack_level
	set(level):
		_stack_level = clampi(level, 0, _scene_stack.size())
var _current_scene: Scene:
	get:
		return _scene_stack[_stack_level]
	set(scene):
		_scene_stack[_stack_level] = scene
var _is_playing: bool:
	get:
		return _scenes[Scene.GAMEPLAY] != null

func _ready() -> void:
	var _main_menu: MainMenu = _scenes[Scene.MAIN_MENU]
	_main_menu.game_start_requested.connect(_on_request_game_start)
	_main_menu.options_menu_requested.connect(_on_request_options_menu)
	_open_as_current_scene(Scene.MAIN_MENU)
	
	var _pause_menu: PauseMenu = _scenes[Scene.PAUSE]
	_pause_menu.main_menu_requested.connect(_on_request_main_menu)
	_pause_menu.options_requested.connect(_on_request_options_menu)
	_pause_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	var _options_menu: OptionsMenu = _scenes[Scene.OPTIONS]
	_options_menu.options_close_requested.connect(_on_request_options_close)

func _input(event: InputEvent) -> void:
	if _is_playing and event.is_action_pressed("pause"):
		if _stack_level > 1:
			return
		
		if _current_scene == Scene.PAUSE:
			_pop_scene()
			get_tree().paused = false
		else:
			get_tree().paused = true
			_push_scene(Scene.PAUSE)
		
		get_viewport().set_input_as_handled()

func _on_request_game_start() -> void:
	if _is_playing:
		_scenes[Scene.GAMEPLAY].free()
	_scenes[Scene.GAMEPLAY] = (load(SCENE_PATHS[Scene.GAMEPLAY]) as PackedScene).instantiate()
	_scenes[Scene.GAMEPLAY].process_mode = Node.PROCESS_MODE_PAUSABLE
	_switch_current_scene(Scene.GAMEPLAY)

func _on_request_main_menu() -> void:
	_switch_current_scene(Scene.MAIN_MENU)
	get_tree().paused = false
	_scenes[Scene.GAMEPLAY].queue_free()
	_scenes[Scene.GAMEPLAY] = null

func _on_request_options_menu() -> void:
	if _current_scene != Scene.OPTIONS:
		_push_scene(Scene.OPTIONS)
	
func _on_request_options_close() -> void:
	if _current_scene == Scene.OPTIONS:
		_pop_scene()

func _open_as_current_scene(scene: Scene) -> void:
	var next_scene: Variant = _scenes.get(scene)
	if not next_scene:
		push_error("[scene_manager] Scene does not exist")
		return

	@warning_ignore("unsafe_cast")
	add_child(next_scene as Node)
	_current_scene = scene
	
func _push_scene(scene: Scene) -> void:
	add_child(_scenes[scene])
	_stack_level += 1
	_current_scene = scene

func _pop_scene() -> void:
	remove_child(_scenes[_current_scene])
	_current_scene = Scene.NONE
	_stack_level -= 1

func _close_current_scene() -> void:
	remove_child(_scenes[_current_scene])
	_current_scene = Scene.NONE

func _switch_current_scene(scene: Scene) -> void:
	_close_current_scene()
	_open_as_current_scene(scene)
	_current_scene = scene
