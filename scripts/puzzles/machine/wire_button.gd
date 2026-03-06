class_name WireButton
extends Button

@export var wire_type: String

signal wire_changed


func _ready() -> void:
	text = "Wire " + wire_type


func _on_pressed() -> void:
	print("[WIRE_BUTTON][ON_PRESSED] Now holding wire ", wire_type)
	emit_signal("wire_changed", wire_type)
