class_name MachinePort
extends StaticBody3D

var _mouse_over: bool = false
var _filled: bool = false

signal port_pressed


func set_filled(filled: bool) -> void:
	_filled = filled


func is_filled() -> bool:
	return _filled


func _on_mouse_entered() -> void:
	_mouse_over = true


func _on_mouse_exited() -> void:
	_mouse_over = false


func _input(event: InputEvent) -> void:
	if _mouse_over and event.is_action_pressed("interact"):
		emit_signal("port_pressed", self)
