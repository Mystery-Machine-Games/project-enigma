class_name MachineWire
extends Node3D

@onready var type_sprite: Sprite3D = $WireTypeSprite

var _data: MachineWireData
var _mouse_over: bool

signal wire_clicked


func set_type_sprite() -> void:
	type_sprite.texture = load(TypeSpriteDictionary.type_to_sprite(_data.get_type()).get_path())


func get_data() -> MachineWireData:
	return _data


func set_data(data: MachineWireData) -> void:
	_data = data


func _on_interaction_area_mouse_entered() -> void:
	_mouse_over = true


func _on_interaction_area_mouse_exited() -> void:
	_mouse_over = false


func _input(event: InputEvent) -> void:
	if _mouse_over and event.is_action_pressed("interact"):
		emit_signal("wire_clicked", _data.get_type())
