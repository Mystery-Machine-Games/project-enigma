class_name Character
extends Sprite3D

@onready var _machine: Machine = $"../../LyleFocusBox/FocusHandle/Machine"


func _ready() -> void:
	_machine.machine_fixed.connect(_smile)


func _smile() -> void:
	texture = load("res://scripts/ui/character.gd")
