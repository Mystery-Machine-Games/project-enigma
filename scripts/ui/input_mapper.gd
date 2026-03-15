class_name InputMapper
extends HBoxContainer

const AXIS_REMAP_DEADZONE = 0.5

@export var action: String

@onready var _action_name_label: Label = $"./ActionName"
@onready var _event_map_button: Button = $"./EventMapButton"
@onready var _event_map_button2: Button = $"./EventMapButton2"

func _ready() -> void:
	_update_display()

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey
		or event is InputEventMouseButton
		or event is InputEventJoypadButton
		or event is InputEventJoypadMotion
	):
		return
	
	# Keyboard/Mouse binding
	if _event_map_button.button_pressed:
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		if ((event is InputEventKey or event is InputEventMouseButton)
			and not InputMap.action_has_event(action, event)
			and not event.is_action_pressed("ui_cancel")
			and events.size() > 0
		):
			InputMap.action_erase_events(action)
			if event is InputEventKey:
				# mapped event will fallback to physical keycode
				(event as InputEventKey).keycode = KEY_NONE
			InputMap.action_add_event(action, event)
			InputMap.action_add_event(action, events[1])
			_update_display()
			Config.set_config_value("Control Binds", action, [event, events[1]])
		_event_map_button.button_pressed = false
	# Controller binding
	elif _event_map_button2.button_pressed:
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		if ((event is InputEventJoypadButton or event is InputEventJoypadMotion)
			and not InputMap.action_has_event(action, event)
			and not event.is_action_pressed("ui_cancel")
			and events.size() > 1
		):
			if event is InputEventJoypadMotion:
				var joy_axis: InputEventJoypadMotion = event 
				if abs(joy_axis.axis_value) < AXIS_REMAP_DEADZONE:
					return
				joy_axis.axis_value = 1.0 if joy_axis.axis_value > 0 else -1.0
			InputMap.action_erase_event(action, events[1])
			InputMap.action_add_event(action, event)
			_update_display()
			Config.set_config_value("Control Binds", action, [events[0], event])
		_event_map_button2.button_pressed = false


func _update_display() -> void:
	_action_name_label.text = action
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	_event_map_button.text = events[0].as_text() if events.size() > 0 else "None"
	_event_map_button2.text  = events[1].as_text() if events.size() > 1 else "None"
