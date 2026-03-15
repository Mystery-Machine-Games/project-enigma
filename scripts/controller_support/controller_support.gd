class_name ControllerSupport
extends Node

const BASE_SENSITIVITY_MULTIPLIER: float = 10.0

static var _axis_pressed: Dictionary[String, bool]

var sensitivity: float
var joy_deadzone: float

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var controller_config: Dictionary = Config.current["Controller"]
	sensitivity = controller_config["cursor_sensitivity"]
	joy_deadzone = controller_config["deadzone"]

func _process(_delta: float) -> void:
	sensitivity = Config.current["Controller"]["cursor_sensitivity"]
	joy_deadzone = Config.current["Controller"]["deadzone"]
	var cursor_velocity: Vector2 = Input.get_vector(
		"cursor_left",
		"cursor_right",
		"cursor_up",
		"cursor_down",
		joy_deadzone
	) * BASE_SENSITIVITY_MULTIPLIER * sensitivity
	var viewport: Viewport = get_viewport()
	
	viewport.warp_mouse(viewport.get_mouse_position() + cursor_velocity)


static func event_is_action_pressed(event: InputEvent, action: String) -> bool:
	# Return normal behavior if not controller axis
	if not (event is InputEventJoypadMotion and event.is_action(action)):
		return event.is_action_pressed(action)
	
	# Get name then register axis on first encounter
	var axis: String = Config.input_to_string(event)
	if not _axis_pressed.has(axis):
		_axis_pressed[axis] = false
	# Intercept and process axis input for debouncing
	if not _axis_pressed[axis] and event.is_action_pressed(action):
		_axis_pressed[axis] = true
	elif _axis_pressed[axis] and event.is_action_released(action):
		_axis_pressed[axis] = false
	else:
		return false
		
	print(_axis_pressed[axis])
	return _axis_pressed[axis]
