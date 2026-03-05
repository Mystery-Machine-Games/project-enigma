class_name InputMapper
extends HBoxContainer

@export var action: String

@onready var _action_name_label: Label = $"./ActionName"
@onready var _event_map_button: Button = $"./EventMapButton"

func _ready() -> void:
	_update_display()

func _input(event: InputEvent) -> void:
	# Ignore non-valid events for mapping
	if not (event is InputEventKey or event is InputEventMouseButton
				or event is InputEventJoypadButton):
		return
	
	# Check if button is toggled (listening)
	if _event_map_button.button_pressed:
		if not event.is_action_pressed("ui_cancel"):
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)
			_update_display()
		
		_event_map_button.button_pressed = false


	if event.is_action_pressed("test_remap"):
		print("%s pressed!" % action)
			

func _update_display() -> void:
	_action_name_label.text = action
	var events: Array = InputMap.action_get_events(action)
	_event_map_button.text = InputMap.action_get_events(action)[0].as_text() if events else "None"
