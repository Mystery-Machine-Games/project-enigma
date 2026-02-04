extends Node

@onready var _button_module: Node = $ButtonModule
@onready var _wire_module: Node = $WireModule

var _wires_correct: bool = false


func _ready() -> void:
	_button_module.buttons_correct.connect(_check_solution)
	

func _check_solution() -> void:
	print("[MACHINE][CHECK_SOLUTION] Machine fixed!")
