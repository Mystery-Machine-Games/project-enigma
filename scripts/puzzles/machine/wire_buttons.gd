class_name WireButtons
extends Node

signal wire_changed


func _on_wire_i_button_pressed() -> void:
	emit_signal("wire_changed", "I")


func _on_wire_ii_button_pressed() -> void:
	emit_signal("wire_changed", "II")


func _on_wire_iii_button_pressed() -> void:
	emit_signal("wire_changed", "III")
