class_name OptionsMenu
extends PanelContainer

signal options_close_requested

func _ready() -> void:
	%MasterVolume/HSlider.value = Config.current["Audio"]["master_volume"]
	%Sensitivity/HSlider.value = Config.current["Controller"]["cursor_sensitivity"]
	%Deadzone/HSlider.value = Config.current["Controller"]["deadzone"]
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

func _on_master_volume_value_changed(value: float) -> void:
	Config.set_config_value("Audio", "master_volume", value)
	%MasterVolume/Value.text = "%3.2f%%" % (value * 100.0)

func _on_sensitivity_value_changed(value: float) -> void:
	Config.set_config_value("Controller", "cursor_sensitivity", value)
	%Sensitivity/Value.text =  "%3.2f%%" % (value * 100.0)
	
func _on_deadzone_value_changed(value: float) -> void:
	Config.set_config_value("Controller", "deadzone", value)
	%Deadzone/Value.text = "%1.2f" % value
