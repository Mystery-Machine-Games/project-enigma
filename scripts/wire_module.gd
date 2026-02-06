class_name WireModule
extends Node3D

enum Axis {X, Y, Z}

@export var start_port_positions: Array[Vector3]
@export var end_port_distance: float
@export var port_axis: Axis

const NUM_WIRES: int = 3

@onready var _difficulty: int = randi_range(1, 3)
@onready var _start_ports: Array[MachinePort]

signal wires_correct


func _ready() -> void:
	pass


func _log_interaction() -> void:
	pass


func _check_solution() -> void:
	pass


func _generate_clues() -> void:
	pass
