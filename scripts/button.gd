class_name MachineButton
extends Node

var mouse_over: bool = false
var mouse_down: bool = false
var time_down: float = 0

enum Shape {CIRCLE, SQUARE}

@export var button_shape: Shape


func _process(delta: float) -> void:
	if mouse_down:
		time_down += delta
	elif time_down > 0:
		print("The ", Shape.keys()[button_shape], " button was held down for ", time_down, " seconds")
		time_down = 0


func _on_mouse_entered() -> void:
	mouse_over = true
	$Hover.play()


func _on_mouse_exited() -> void:
	mouse_over = false
	if mouse_down:
		$AnimationPlayer.play("button_animations/button_release")
		mouse_down = false


func _input(event: InputEvent) -> void:
	if mouse_over and event.is_action_pressed("interact"):
		$AnimationPlayer.play("button_animations/button_press")
		mouse_down = true
	if mouse_over and event.is_action_released("interact"):
		$AnimationPlayer.play("button_animations/button_release")
		mouse_down = false