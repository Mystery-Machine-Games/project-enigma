class_name Machine
extends Node3D

enum Difficulty {EASY = 1, MEDIUM, HARD}

var difficulty: Difficulty:
	get:
		return Config.current["General"]["difficulty"]
	set(value):
		Config.set_config_value("General", "difficulty", value)
@export var colors_shared: bool # TODO: Whether or not ports, wires, and buttons can share the same colors
@export var port_colors: Array[Material]
@export var wire_colors: Array[Material]
@export var button_colors: Array[Material]

@onready var _button_module: ButtonModule = $ButtonModule
@onready var _wire_module: WireModule = $WireModule
@onready var _outline_mesh: MeshInstance3D = $OutlineMesh

var _wires_correct: bool = false
var _machine_initialized: bool = false
signal machine_initialized
signal machineFixed;

var cluesetArr : Array[Clueset] = [];


func _ready() -> void:
	_outline_mesh.material_override = load("res://assets/materials/red.tres")
	_button_module.buttons_correct.connect(_check_solution)
	_button_module.buttons_reset.connect(_error)
	_wire_module.wires_correct.connect(_set_wires_correct)
	set_difficulty(difficulty)
	_button_module.set_colors(button_colors)
	_wire_module.set_colors(port_colors, wire_colors)
	_button_module.initialize_puzzle()
	_wire_module.initialize_puzzle()
	#$"../../../3DJigsaw".generate_shapes();


func _process(_delta: float) -> void:
	if not _machine_initialized:
		_machine_initialized = true
		emit_signal("machine_initialized")


func _set_wires_correct() -> void:
	_wires_correct = true


func _check_solution() -> void:
	if _wires_correct:
		print("[MACHINE][CHECK_SOLUTION] Machine fixed!")
		machineFixed.emit();
	else:
		_error()


func set_difficulty(difficulty: Difficulty) -> void:
	_wire_module.set_difficulty(difficulty)
	_button_module.set_difficulty(difficulty)


func get_wire_module() -> WireModule:
	return _wire_module


func get_button_module() -> ButtonModule:
	return _button_module


func add_clueset(clueset : Clueset) -> void:
	cluesetArr.append(clueset);


func _error() -> void:
	_outline_mesh.visible = true
	AudioManager.play_sound("error")
	await get_tree().create_timer(0.25).timeout
	#await(get_tree().create_timer(1.0), "timeout")
	_outline_mesh.visible = false
