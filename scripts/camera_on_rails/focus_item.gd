class_name FocusItem
extends Node

@export var focusPointArr : Array[Marker3D];
var focusIndex : int = 0;
## Camera position to tween to for focus mode in world space
var focus_position: Vector3;
## Camera rotation to tween to for focus mode in world space
var focus_rotation: Vector3;

## Speed of focus transition tween in m/s
@export var focus_speed: float = 1.0
## Item rotation angle per input
@export var item_rotation_angle: float = 90.0
## Duration of item rotation tween
@export var item_rotation_time: float = 0.5

## Flag to set when this item is focused on
var is_focused: bool = false

## Node3D handle to move object while focused
@export var _focus_handle: Node3D;

## Tween for rotating item in focus mode
var _item_rotation_tween: Tween

## Machine interface, focusing on the item shows/hides it
@onready var interface : Control = $"../Interface";

func _ready() -> void:
	set_pos_and_rot();

func set_pos_and_rot() -> void:
	focus_position = focusPointArr[focusIndex].global_position
	focus_rotation = focusPointArr[focusIndex].global_rotation

func _unhandled_input(event: InputEvent) -> void:
	if not is_focused:
		if interface.visible == true:
			interface.visible = false;
		return
	if is_focused && interface.visible == false:
		interface.visible = true;
	if event.is_action_pressed("item_yaw_left") and _try_initialize_rotation():
		_item_rotation_tween.tween_property(
			_focus_handle,
			"rotation:y",
			deg_to_rad(item_rotation_angle),
			item_rotation_time,
		).as_relative()
	if event.is_action_pressed("item_yaw_right") and _try_initialize_rotation():
		_item_rotation_tween.tween_property(
			_focus_handle,
			"rotation:y",
			deg_to_rad(-item_rotation_angle),
			item_rotation_time,
		).as_relative()
	if event.is_action_pressed("item_pitch_up") and _try_initialize_rotation():
		_item_rotation_tween.tween_property(
			_focus_handle,
			"global_rotation:x",
			deg_to_rad(item_rotation_angle),
			item_rotation_time,
		).as_relative()
	if event.is_action_pressed("item_pitch_down") and _try_initialize_rotation():
		_item_rotation_tween.tween_property(
			_focus_handle,
			"global_rotation:x",
			deg_to_rad(-item_rotation_angle),
			item_rotation_time,
		).as_relative()

	if _item_rotation_tween and not _item_rotation_tween.is_running():
		_item_rotation_tween.tween_callback(_reset_rotation_tween)
		_item_rotation_tween.play()


func _try_initialize_rotation() -> bool:
	if _item_rotation_tween:
		return false

	_item_rotation_tween = create_tween()
	_item_rotation_tween.stop()
	return true


func _reset_rotation_tween() -> void:
	if _item_rotation_tween:
		_item_rotation_tween.kill()
		_item_rotation_tween = null
