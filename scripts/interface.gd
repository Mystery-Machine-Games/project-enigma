extends Control

@onready var _wire_buttons: WireButtons = $WireButtonsContainer


func get_wire_buttons() -> WireButtons:
	return _wire_buttons
