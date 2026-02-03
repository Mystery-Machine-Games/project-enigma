class_name Wire
extends Node3D

@export var movement_force: float
@export var handle: AnimatableBody3D

var _mouse_over: bool = false
var _mouse_down: bool = false
var _mouse_dir: Vector2


func _physics_process(_delta: float) -> void:
	if _mouse_down:
		var direction: Vector3
		direction = Vector3(_mouse_dir.y, 0, -_mouse_dir.x)
		handle.position += direction * movement_force
		#print(handle.position)
		#handle.position = handle.position.clamp(Vector3(5, 0, -2), Vector3(10, 0, 2))
		print(handle.position)

func _on_target_mouse_entered() -> void:
	_mouse_over = true
	#print("mouse over wire handle")


func _on_target_mouse_exited() -> void:
	_mouse_over = false
	#print("mouse exit wire handle")


func snap() -> void:
	_mouse_down = false


func _input(event: InputEvent) -> void:
	if _mouse_over and event.is_action_pressed("interact"):
		_mouse_down = true
		#print("mouse holding wire handle")
	if event.is_action_released("interact"):
		_mouse_down = false
	if event is InputEventMouseMotion:
		var mouse_motion: InputEventMouseMotion = event
		if mouse_motion.relative.is_zero_approx() == false:
			_mouse_dir = -mouse_motion.relative
