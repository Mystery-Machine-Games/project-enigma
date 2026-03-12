extends Node

const CONFIG_PATHS: Dictionary[String, String] = {
	"default": "res://_dev/default.cfg",
	"custom":  "res://_dev/custom.cfg"
}

var current: Dictionary[String, Dictionary] = {}

var _config_file: ConfigFile = ConfigFile.new()

func _ready() -> void:
	if not _load_config("custom"):
		print("Falling back to default")
		_load_config("default")

func set_config_value(section: String, key: String, value: Variant) -> bool:
	if section == "Control Binds" and value is Array:
		@warning_ignore("unsafe_cast")
		value = (value as Array).map(input_to_string)
	if section in current and key in current[section] and current[section][key] != value:
		current[section][key] = value
		_config_file.set_value(section, key, value)
		_config_file.save(CONFIG_PATHS["custom"])
	return false

func input_to_string(event: InputEvent) -> String:
	var string_input: String = ""
	if event is InputEventKey:
		string_input = "key:" + str((event as InputEventKey).physical_keycode)
	elif event is InputEventMouseButton:
		string_input = "mouse:" + str((event as InputEventMouseButton).button_index)
	elif event is InputEventJoypadButton:
		string_input = "button:" + str((event as InputEventJoypadButton).button_index)
	elif event is InputEventJoypadMotion:
		string_input = "axis:"  + str((event as InputEventJoypadMotion).axis)
	return string_input
	
func string_to_input(string_input: String) -> InputEvent:
	var event: InputEvent = null
	var type: String = string_input.get_slice(":", 0)
	var id: int = int(string_input.get_slice(":", 1))
	match type:
		"key":
			event = InputEventKey.new()
			(event as InputEventKey).physical_keycode = id as Key
		"mouse":
			event = InputEventMouseButton.new()
			(event as InputEventMouseButton).button_index = id as MouseButton
		"button":
			event = InputEventJoypadButton.new()
			(event as InputEventJoypadButton).button_index = id as JoyButton
		"axis":
			event = InputEventJoypadMotion.new()
			(event as InputEventJoypadMotion).axis = id as JoyAxis
	return event

func load_config(config_name: String) -> bool:
	if _config_file.load(CONFIG_PATHS[config_name]) != OK:
		return false
	for s: String in _config_file.get_sections():
		for k: String in _config_file.get_section_keys(s):
			if s not in current:
				current[s] = {}
			current[s][k] = _config_file.get_value(s, k)
	return true

func _extract_input_id(string_input: String) -> String:
	return string_input.get_slice(":", 1)
