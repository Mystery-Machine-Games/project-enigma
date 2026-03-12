extends Node

const CONFIG_DIR: String = "user://"
const CONFIG_PATHS: Dictionary[String, String] = {
	"default": CONFIG_DIR + "default.cfg",
	"custom": CONFIG_DIR + "custom.cfg"
}

var current: Dictionary[String, Dictionary] = {}

var _config_file: ConfigFile = ConfigFile.new()

func _ready() -> void:
	initialize()

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
		string_input = "axis:%s:%s" % [
			str((event as InputEventJoypadMotion).axis),
			str((event as InputEventJoypadMotion).axis_value)
		]
	return string_input
	
func string_to_input(string_input: String) -> InputEvent:
	var event: InputEvent = null
	var slices: PackedStringArray = string_input.split(":", true, 3)
	var type: String = slices[0]
	var id: int = int(slices[1])
	var direction: float = float(slices[2]) if slices.size() > 2 else 1.0
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
			(event as InputEventJoypadMotion).axis_value = direction
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

func initialize() -> void:
	if not load_config("custom"):
		print("Falling back to default config")
		_config_file.set_value("General", "difficulty", Machine.Difficulty.EASY)
		_config_file.set_value("Audio", "master_volume", 0.7)
		_config_file.set_value("Controller", "cursor_sensitivity", 0.5)
		_config_file.set_value("Controller", "deadzone", 0.2)
		for action: String in InputMap.get_actions().filter(
			func (action: String) -> bool: return not action.begins_with("ui_")
		):
			_config_file.set_value(
				"Control Binds",
				action,
				InputMap.action_get_events(action).map(input_to_string)
			)
		var error: Error = _config_file.save(CONFIG_PATHS["default"])
		if error:
			print("Error creating default config: %s" % error_string(error))
		load_config("default")

func reset() -> void:
	DirAccess.remove_absolute(CONFIG_PATHS["custom"])
	initialize()

func _extract_input_id(string_input: String) -> String:
	return string_input.get_slice(":", 1)
