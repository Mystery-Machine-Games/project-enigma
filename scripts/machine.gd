extends Node

@onready var _button_module: Node = $ButtonModule
@onready var _wire_module: Node = $WireModule

var _wires_correct: bool = false


func _ready() -> void:
	@warning_ignore("unsafe_property_access", "unsafe_method_access")
	_button_module.buttons_correct.connect(_check_solution)
	@warning_ignore("unsafe_property_access", "unsafe_method_access")
	_wire_module.wires_correct.connect(_set_wires_correct)


func _set_wires_correct() -> void:
	_wires_correct = true


func _check_solution() -> void:
	if _wires_correct:
		print("[MACHINE][CHECK_SOLUTION] Machine fixed!")
