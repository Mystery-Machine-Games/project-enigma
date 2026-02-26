extends Node

@onready var _test_world_camera: Camera3D = $TestWorld/Path3D/PlayerCharacter/Head/Camera3D
@onready var _troubleshooter_camera: Camera3D = $Troubleshooter/Camera3D

var _use_test_world: bool = true

func _ready() -> void:
	_swap_scenes(_use_test_world)

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("swap_playtest_scene")
		or event.is_action_pressed("unfocus_item") and not _use_test_world):
		_use_test_world = not _use_test_world
		_swap_scenes(_use_test_world)

func _swap_scenes(use_test_world: bool) -> void:
	print("Swapping scenes")
	if use_test_world:
		$TestWorld.show()
		$Troubleshooter.hide()
		$Troubleshooter/UI.hide()
		_test_world_camera.make_current()
	else:
		$Troubleshooter.show()
		$Troubleshooter/UI.show()
		$TestWorld.hide()
		_troubleshooter_camera.make_current()
