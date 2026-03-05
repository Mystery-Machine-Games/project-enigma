extends PathFollow3D

## Multiplier to convert mouse motion to proper mouse look scale and direction
const LOOK_MULTIPLIER: float = -0.001
## (min pitch, min yaw) radians
const MIN_LOOK_ROTATION: Vector2 = Vector2(-PI / 2, -PI / 4)
## (max pitch, max yaw) radians
const MAX_LOOK_ROTATION: Vector2 = Vector2(PI / 4, PI / 4)
## Rotation offset relative to path's curve's orientation
const LOOK_ROTATION_OFFSET: Vector3 = Vector3(0, PI / 2, 0)
## Length of mouse cursor raycast for focusing objects
const FOCUS_RAY_LENGTH: float = 2.0

## Sensitivity of mouse look rotation
@export_range(1.0, 10.0) var look_sensitivity: float = 5.0

## Horizontal max move speed in m/s
@export_range(0.0, 25.0, 0.01, "suffix:m/s", "or_greater")
var move_speed: float = 5.0

## (pitch, yaw) in radians
var _look_rotation: Vector3 = Vector3.ZERO
## [-1, 1] sum of movement input
var _move_direction: int = 0
## If in focus mode, the focused item
var _focused_item: FocusItem = null
## [from, to] raycast for mouse cursor
var _focus_ray: Array[Vector3] = [Vector3.ZERO, Vector3.ZERO]
## Tween transition to focus mode
var _focus_tween: Tween = null
## Player camera reference
@onready var _camera: Camera3D = %Head/Camera3D


func _process(delta: float) -> void:
	if not _focused_item and not (_focus_tween and _focus_tween.is_running()):
		%Head.rotation = _look_rotation + LOOK_ROTATION_OFFSET
		_move_direction = 0
		if Input.is_action_pressed("move_left"):
			_move_direction -= 1
		if Input.is_action_pressed("move_right"):
			_move_direction += 1

		progress += move_speed * _move_direction * delta


func _physics_process(_delta: float) -> void:
	# Handle focus action
	if Input.is_action_just_pressed("focus_item") and not _focused_item:
		# Cancel any running focus animation
		if _focus_tween:
			_focus_tween.kill()
		# Raycast to see if cursor is pointing to a focus item
		var raycast_params: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
			_focus_ray[0],
			_focus_ray[1],
		)
		raycast_params.collide_with_areas = true
		var raycast_result: Dictionary = get_world_3d().direct_space_state.intersect_ray(
			raycast_params,
		)
		var collider: Object = raycast_result.get("collider")
		
		if collider and collider is FocusItem:
			_focus_on(collider)
			_focus_tween = create_tween().set_parallel()
			var tween_distance: float = (
				%Head.global_position
				- _focused_item.focus_position
			).length()
			var tween_time: float = tween_distance / _focused_item.focus_speed
			_focus_tween.tween_property(
				%Head,
				"global_rotation",
				_focused_item.focus_rotation,
				tween_time,
			)
			_focus_tween.tween_property(
				%Head,
				"global_position",
				_focused_item.focus_position,
				tween_time,
			)
			_focus_tween.chain().tween_callback(_reset_tween)
	
	if Input.is_action_just_pressed("ui_accept") and _focused_item && _focused_item.focusPointArr.size() > 1:
		# Cancel any running focus animation
		#hardcoding something here for time
		$"../../Interface".get_wire_buttons().visible = _focused_item.focusIndex == 0;
		if _focus_tween:
			_focus_tween.kill()
		_focused_item.focusIndex += 1;
		if _focused_item.focusIndex >= _focused_item.focusPointArr.size():
			_focused_item.focusIndex = 0;
		_focused_item.set_pos_and_rot();
		_focus_tween = create_tween().set_parallel()
		var tween_distance: float = (
			%Head.global_position
			- _focused_item.focus_position
		).length()
		var tween_time: float = tween_distance / _focused_item.focus_speed
		_focus_tween.tween_property(
			%Head,
			"global_rotation",
			_focused_item.focus_rotation,
			tween_time,
		)
		_focus_tween.tween_property(
			%Head,
			"global_position",
			_focused_item.focus_position,
			tween_time,
		)
		_focus_tween.chain().tween_callback(_reset_tween)

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed ):
		_focus_ray[0] = _camera.project_ray_origin(event.position)
		_focus_ray[1] = (
			_focus_ray[0]
			+ _camera.project_ray_normal(event.position)
			* FOCUS_RAY_LENGTH
		)
	elif event.is_action_pressed("unfocus_item") and _focused_item:
		if _focus_tween:
			_focus_tween.kill()
		_focus_tween = create_tween().set_parallel()
		var tween_time: float = %Head.position.length() / _focused_item.focus_speed
		_focus_tween.tween_property(
			%Head,
			"rotation",
			LOOK_ROTATION_OFFSET,
			tween_time,
		)
		_focus_tween.tween_property(
			%Head,
			"position",
			Vector3.ZERO,
			tween_time,
		)
		_focus_tween.chain().tween_callback(_reset_tween)
		_focus_on(null)


## Sets focus on focus_item. If focus_item is null, unfocuses.
func _focus_on(focus_item: FocusItem) -> void:
	if focus_item and focus_item.is_focused:
		push_warning("[player_controller] focus_item is already being focused on")
		return

	if _focused_item:
		_focused_item.is_focused = false
	if focus_item:
		_focused_item = focus_item
		_focused_item.is_focused = true
	else:
		_focused_item = null


func _reset_tween() -> void:
	if _focus_tween:
		_focus_tween.kill()
		_focus_tween = null

func get_camera() -> Camera3D:
	return $Head/Camera3D;
