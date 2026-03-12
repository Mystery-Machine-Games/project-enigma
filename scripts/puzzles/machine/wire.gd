class_name MachineWire
extends Node3D

@onready var type_sprite: Sprite3D = $WireTypeSprite
@onready var wire_mesh: MeshInstance3D = $Armature/Skeleton3D/Wire
@onready var skeleton: Skeleton3D = $Armature/Skeleton3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var _data: MachineWireData
var _mouse_over: bool

signal wire_clicked


func set_type_sprite() -> void:
	type_sprite.texture = load(TypeSpriteDictionary.type_to_sprite(_data.get_type()).get_path())


func set_color(color: Material) -> void:
	wire_mesh.set_surface_override_material(0, color)


func get_data() -> MachineWireData:
	return _data


func get_skeleton() -> Skeleton3D:
	return skeleton


func get_anim_player() -> AnimationPlayer:
	return anim_player


func set_data(data: MachineWireData) -> void:
	_data = data


func _on_interaction_area_mouse_entered() -> void:
	_mouse_over = true


func _on_interaction_area_mouse_exited() -> void:
	_mouse_over = false


func _unhandledd_input(event: InputEvent) -> void:
	if _mouse_over and event.is_action_pressed("interact_grab"):
		emit_signal("wire_clicked", _data.get_type())
		AudioManager.play_sound("cut")
