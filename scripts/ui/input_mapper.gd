class_name InputMapper
extends HBoxContainer

@export var action: String

@onready var _action_name_label: Label = $"./ActionName"
@onready var _event_map_button: Button = $"./EventMapButton"
@onready var _event_map_button2: Button = $"./EventMapButton2"

func _ready() -> void:
	_update_display()

func _input(event: InputEvent) -> void:
	# Ignore non-valid events for mapping
	if not (event is InputEventKey or event is InputEventMouseButton
				or event is InputEventJoypadButton):
		return
	
	# Check if button is toggled (listening)
	if _event_map_button.button_pressed:
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		if (not InputMap.action_has_event(action, event)
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
		_event_map_button.button_pressed = false
		return
			
		
	if _event_map_button2.button_pressed:
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		if (not InputMap.action_has_event(action, event)
			and not event.is_action_pressed("ui_cancel")
			and events.size() > 1
		):
			InputMap.action_erase_event(action, events[1])
			if event is InputEventKey:
				# mapped event will fallback to physical keycode
				(event as InputEventKey).keycode = KEY_NONE
			InputMap.action_add_event(action, event)
			_update_display()
		_event_map_button2.button_pressed = false
		return


	if event.is_action_pressed("test_remap"):
		print("%s pressed!" % action)


func _update_display() -> void:
	_action_name_label.text = action
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	_event_map_button.text = events[0].as_text() if events.size() > 0 else "None"
	_event_map_button2.text  = events[1].as_text() if events.size() > 1 else "None"
