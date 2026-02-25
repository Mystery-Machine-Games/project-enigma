class_name Machine
extends Node3D

@onready var _button_module: ButtonModule = $ButtonModule
@onready var _wire_module: WireModule = $WireModule

var _wires_correct: bool = false


func _ready() -> void:
	_button_module.buttons_correct.connect(_check_solution)
	_wire_module.wires_correct.connect(_set_wires_correct)
	# TODO:
	# - connect wire_module wire_added signal to function that hides corresponding button
	# - connect wire_module wire_removed signal to function that shows corresponding button


func _set_wires_correct() -> void:
	_wires_correct = true


func _check_solution() -> void:
	if _wires_correct:
		print("[MACHINE][CHECK_SOLUTION] Machine fixed!")


func get_wire_module() -> WireModule:
	return _wire_module


func get_button_module() -> ButtonModule:
	return _button_module
