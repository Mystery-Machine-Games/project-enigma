class_name Interface
extends Control

const WIRE_VIEW_INDEX: int = 1

@onready var _wire_buttons: WireButtons = $WireButtonsContainer

func _process(_delta: float) -> void:
	_wire_buttons.visible = $"../LyleFocusBox".focus_index == WIRE_VIEW_INDEX

func get_wire_buttons() -> WireButtons:
	return _wire_buttons

func _on_jigsaw_pressed() -> void:
	$Control.visible = !$Control.visible
