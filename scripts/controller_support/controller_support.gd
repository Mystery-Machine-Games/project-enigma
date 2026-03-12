extends Node

const BASE_SENSITIVITY_MULTIPLIER: float = 10.0

var sensitivity: float
var joy_deadzone: float

var _was_pressed: bool = false

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

func _input(event: InputEvent) -> void:	
	# Intercept and process axis interact input for debouncing
	if event is InputEventJoypadMotion and event.is_action("interact_grab"):
		if not _was_pressed and event.is_action_pressed("interact_grab"):
			_was_pressed = true
			Input.action_press("interact_grab")
		elif _was_pressed and event.is_action_released("interact_grab"):
			_was_pressed = false
			Input.action_release("interact_grab")
		else:
			get_viewport().set_input_as_handled()
			
	if event.is_action_pressed("controller_click"):
		_click()
	if event.is_action_released("controller_click"):
		_click(false)
	


# Not currently used but can be called to create virtual clicks
func _click(pressed: bool = true) -> void:
	var click_event: InputEventMouseButton = InputEventMouseButton.new()
	click_event.button_index = MOUSE_BUTTON_LEFT
	click_event.pressed = pressed
	_was_pressed = pressed
	click_event.position = get_viewport().get_mouse_position()
	Input.parse_input_event(click_event)
