class_name Machine
extends Node3D

enum Difficulty {ONE, TWO}

@export var difficulty: Difficulty

@onready var _button_module: ButtonModule = $ButtonModule
@onready var _wire_module: WireModule = $WireModule

var _wires_correct: bool = false
signal machineFixed;

var cluesetArr : Array[Clueset] = [];

func _ready() -> void:
	_button_module.buttons_correct.connect(_check_solution)
	_wire_module.wires_correct.connect(_set_wires_correct)
	_button_module.set_difficulty(difficulty)
	_wire_module.set_difficulty(difficulty)
	#$"../../../3DJigsaw".generate_shapes();


func _set_wires_correct() -> void:
	_wires_correct = true


func _check_solution() -> void:
	if _wires_correct:
		print("[MACHINE][CHECK_SOLUTION] Machine fixed!")
		machineFixed.emit();


func get_wire_module() -> WireModule:
	return _wire_module


func get_button_module() -> ButtonModule:
	return _button_module

func add_clueset(clueset : Clueset) -> void:
	cluesetArr.append(clueset);
