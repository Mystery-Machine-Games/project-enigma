class_name WireButton
extends Button

@export var wire_type: String

signal wire_changed


func _ready() -> void:
	text = "Wire " + wire_type


func _on_pressed() -> void:
	emit_signal("wire_changed", wire_type)
