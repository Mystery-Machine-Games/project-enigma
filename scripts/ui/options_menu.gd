class_name OptionsMenu
extends PanelContainer

signal options_close_requested

@onready var focus_entry: Control = %Return

func _enter_tree() -> void:
	var can_change_difficulty: bool = not get_parent().is_playing
	(%Difficulty/SpinBox as SpinBox).editable = can_change_difficulty
	%Difficulty/EditWarning.visible = not can_change_difficulty

func _ready() -> void:
	_get_options_from_config()
	focus_entry.grab_focus.call_deferred()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		options_close_requested.emit()

func _get_options_from_config() -> void:
	(%Difficulty/SpinBox as SpinBox).value = Config.current["General"]["difficulty"]
	(%MasterVolume/HSlider as HSlider).value = Config.current["Audio"]["master_volume"]
	(%Sensitivity/HSlider as HSlider).value = Config.current["Controller"]["cursor_sensitivity"]
	(%Deadzone/HSlider as HSlider).value = Config.current["Controller"]["deadzone"]
	var bindings: Dictionary = Config.current["Control Binds"]
	for action: String in bindings:
		InputMap.action_erase_events(action)
		for input: String in bindings[action]:
			InputMap.action_add_event(action, Config.string_to_input(input))
	for im: InputMapper in %Binds.get_children():
		im._update_display()

func _on_reset_pressed() -> void:
	Config.reset()
	_get_options_from_config()
	
func _on_difficulty_changed(value: float) -> void:
	Config.set_config_value("General", "difficulty", int(value) as Machine.Difficulty)

func _on_return_pressed() -> void:
	options_close_requested.emit()

func _on_master_volume_value_changed(value: float) -> void:
	Config.set_config_value("Audio", "master_volume", value)
	(%MasterVolume/Value as Label).text = "%3.2f%%" % (value * 100.0)

func _on_sensitivity_value_changed(value: float) -> void:
	Config.set_config_value("Controller", "cursor_sensitivity", value)
	(%Sensitivity/Value as Label).text =  "%3.2f%%" % (value * 100.0)
	
func _on_deadzone_value_changed(value: float) -> void:
	Config.set_config_value("Controller", "deadzone", value)
	(%Deadzone/Value as Label).text = "%1.2f" % value
