class_name OptionsMenu
extends PanelContainer

signal options_close_requested

func _ready() -> void:
	var bindings: Dictionary = Config.current["Control Binds"]
	for action: String in bindings:
		InputMap.action_erase_events(action)
		for input: String in bindings[action]:
			prints(action, input)
			InputMap.action_add_event(action, Config.string_to_input(input))
	
	for im: InputMapper in %Binds.get_children():
		im._update_display()

func _on_return_pressed() -> void:
	options_close_requested.emit()
