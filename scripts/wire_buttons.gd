class_name WireButtons
extends Node

signal wire_changed


func _on_wire_a_button_pressed() -> void:
	emit_signal("wire_changed", "A")


func _on_wire_b_button_pressed() -> void:
	emit_signal("wire_changed", "B")


func _on_wire_c_button_pressed() -> void:
	emit_signal("wire_changed", "C")
