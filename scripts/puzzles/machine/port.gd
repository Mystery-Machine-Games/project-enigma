class_name MachinePort
extends StaticBody3D

@export var code: String

@onready var _wire_module: WireModule = $"../../../WireModule"
@onready var _outline_mesh: MeshInstance3D = $OutlineMesh
@onready var _port_mesh: MeshInstance3D = $PortMesh
@onready var _interactable_color: Material = load("res://assets/materials/white.tres")
@onready var _uninteractable_color: Material = load("res://assets/materials/red.tres")
@onready var _port_shape_sprite: Sprite3D = $PortShapeSprite

var _mouse_over: bool = false
var _filled: bool = false
var _interactable: bool = true

signal port_hovered
signal port_pressed


func _ready() -> void:
	_outline_mesh.visible = false
	_port_shape_sprite.visible = false


func set_interactable(interactable: bool) -> void:
	_interactable = interactable
	if not _interactable:
		_outline_mesh.material_override = _uninteractable_color
	else:
		_outline_mesh.material_override = _interactable_color


func is_interactable() -> bool:
	return _interactable


func set_filled(filled: bool) -> void:
	_filled = filled


func is_filled() -> bool:
	return _filled


func set_sprite_color() -> void:
	var port_material: Material = _port_mesh.material_override
	_port_shape_sprite.modulate = port_material.albedo_color


func _on_mouse_entered() -> void:
	if not _filled and _wire_module.is_in_focus():
		_mouse_over = true
		emit_signal("port_hovered", self, false)
		_outline_mesh.visible = true
		_port_shape_sprite.visible = true
		if _interactable:
			AudioManager.play_sound("hover")
		else:
			AudioManager.play_sound("error")


func _on_mouse_exited() -> void:
	_mouse_over = false
	_outline_mesh.visible = false
	_port_shape_sprite.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if _mouse_over and ControllerSupport.event_is_action_pressed(event, "interact_grab") and _wire_module.is_in_focus():
		emit_signal("port_pressed", self, true)
		if _interactable: 
			AudioManager.play_sound("click")
		else:
			AudioManager.play_sound("error")
	if _mouse_over and event.is_action_released("interact_grab") and _wire_module.is_in_focus():
		emit_signal("port_pressed", self, true)
		if _interactable:
			AudioManager.play_sound("click")
		else:
			AudioManager.play_sound("error")


func get_color() -> StandardMaterial3D:
	return get_node("PortMesh").material_override
