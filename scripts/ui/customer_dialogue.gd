class_name CharacterDialogue
extends Label3D

@onready var _machine: Machine = $"../LyleFocusBox/FocusHandle/Machine"


func _ready() -> void:
	_machine.machine_fixed.connect(_thank)


func _thank() -> void:
	text = "Thank you for fixing my machine!"
