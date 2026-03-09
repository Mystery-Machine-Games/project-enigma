extends PathFollow3D

## Multiplier to convert mouse motion to proper mouse look scale and direction
const LOOK_MULTIPLIER: float = -0.001
## (min pitch, min yaw) radians
const MIN_LOOK_ROTATION: Vector2 = Vector2(-PI / 2, -PI / 4)
## (max pitch, max yaw) radians
const MAX_LOOK_ROTATION: Vector2 = Vector2(PI / 4, PI / 4)
## Rotation offset relative to path's curve's orientation
const LOOK_ROTATION_OFFSET: Vector3 = Vector3(0, PI / 2, 0)

## Sensitivity of mouse look rotation
@export_range(1.0, 10.0) var look_sensitivity: float = 5.0

## Horizontal max move speed in m/s
@export_range(0.0, 25.0, 0.01, "suffix:m/s", "or_greater")
var move_speed: float = 5.0

## (pitch, yaw) in radians
var _look_rotation: Vector3 = Vector3.ZERO
## [-1, 1] sum of movement input
var _move_direction: int = 0
## Selected focus item, can be focused with focus input
var _hovered_item: FocusItem = null
## If in focus mode, the focused item
var _focused_item: FocusItem = null
## Tween transition to focus mode
var _focus_tween: Tween = null
## Player head reference
@onready var _head: Node3D = %Head
## Player camera reference
@onready var _camera: Camera3D = %Head/Camera3D
## Cleanup callback in case a tween is canceled; (one-time use, consumed on next reset_tween call)
var _tween_cleanup: Variant = null


func _process(delta: float) -> void:
	if not _focused_item and not (_focus_tween and _focus_tween.is_running()):
		_head.rotation = _look_rotation + LOOK_ROTATION_OFFSET
		_move_direction = 0
		if Input.is_action_pressed("move_left"):
			_move_direction -= 1
		if Input.is_action_pressed("move_right"):
			_move_direction += 1

		progress += move_speed * _move_direction * delta


func _unhandled_input(event: InputEvent) -> void:
	if not _focused_item:
		if event.is_action_pressed("focus_item") and _hovered_item:
			_reset_tween()
			_focused_item = _hovered_item
			_tween_cleanup = (func () -> void:
				# Lift FocusItem's focus flag once tween has completed (cleanup callback).
				# This helps when used to detect when to enable focus mode-specific input.
				_focused_item.is_focused = true
			)
			_start_focus_tween()
	else:
		if event.is_action_pressed("unfocus_item"):
			_reset_tween()
			# Conversely to lifting, lower a FocusItems's focus flag before unfocus animation starts
			_focused_item.is_focused = false
			_start_unfocus_tween()
			_focused_item = null
		elif event.is_action_pressed("cycle_focus_view") and _focused_item.focusPointArr.size() > 1:
			_reset_tween()
			# TODO: Refactor multi-FocusPoint FocusItem's to be less coupled -Brian
			# Increments and sets multi-FocusPoint FocusItem's current focus point
			_focused_item.focus_index += 1;
			if _focused_item.focus_index >= _focused_item.focusPointArr.size():
				_focused_item.focus_index = 0;
			_focused_item.set_pos_and_rot();
			_start_focus_tween()


func get_camera() -> Camera3D:
	return _camera


func _on_focus_item_hovered(focus_item: FocusItem) -> void:
	_hovered_item = focus_item


## Cancel and null any existing tween
func _reset_tween() -> void:
	if _tween_cleanup is Callable:
		@warning_ignore("unsafe_cast")
		(_tween_cleanup as Callable).call()
		# one-time use cleanup
		_tween_cleanup = null
	if _focus_tween:
		_focus_tween.kill()
		_focus_tween = null


## Clear any current focus state
func _clear_focus() -> void:
	if _focused_item:
		_focused_item.is_focused = false
		_focused_item = null


## Starts focus tween on currently focused item
func _start_focus_tween() -> void:
	_focus_tween = create_tween().set_parallel()
	var tween_distance: float = (
		_head.global_position
		- _focused_item.focus_position
	).length()
	var tween_time: float = tween_distance / _focused_item.focus_speed
	_focus_tween.tween_property(
		_head,
		"global_rotation",
		_focused_item.focus_rotation,
		tween_time,
	)
	_focus_tween.tween_property(
		_head,
		"global_position",
		_focused_item.focus_position,
		tween_time,
	)
	_focus_tween.chain().tween_callback(_reset_tween)


## Starts unfocus tween from current focus
func _start_unfocus_tween() -> void:
	_focus_tween = create_tween().set_parallel()
	var tween_time: float = _head.position.length() / _focused_item.focus_speed
	_focus_tween.tween_property(
		_head,
		"rotation",
		LOOK_ROTATION_OFFSET,
		tween_time,
	)
	_focus_tween.tween_property(
		_head,
		"position",
		Vector3.ZERO,
		tween_time,
	)
	_focus_tween.chain().tween_callback(_reset_tween)
