extends Node

const MAIN_MENU_PATH: String = "res://scenes/ui/main_menu.tscn"
const GAMEPLAY_ENTRY_PATH: String = "res://scenes/playtest.tscn"
const PAUSE_MENU_PATH: String = "res://scenes/ui/pause_menu.tscn"

var _main_menu: MainMenu = preload(MAIN_MENU_PATH).instantiate()
var _gameplay_entry: Node
var _pause_menu: Node

var _is_playing: bool = false

func _ready() -> void:
	add_child(_main_menu)
	_main_menu.game_start_requested.connect(_on_game_start)

func _input(event: InputEvent) -> void:
	if _is_playing and event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		if get_tree().paused:
			add_child(_pause_menu)
		else:
			remove_child(_pause_menu)
		get_viewport().set_input_as_handled()

func _on_game_start() -> void:
	_is_playing = true
	
	if _gameplay_entry:
		_gameplay_entry.free()
	_gameplay_entry = load(GAMEPLAY_ENTRY_PATH).instantiate()
	_gameplay_entry.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	if _pause_menu:
		_pause_menu.free()
	_pause_menu = load(PAUSE_MENU_PATH).instantiate()
	_pause_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	add_child(_gameplay_entry)
	remove_child(_main_menu)
	
