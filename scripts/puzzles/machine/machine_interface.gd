class_name Interface
extends Control

@onready var _wire_buttons: WireButtons = $WireButtonsContainer


func get_wire_buttons() -> WireButtons:
	return _wire_buttons


func _on_jigsaw_pressed() -> void:
	$Control.visible = !$Control.visible
	pass # Replace with function body.
