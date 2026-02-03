extends Area3D

@export var snap_point: Node3D

var filled: bool = false


func _on_body_entered(body: Node3D) -> void:
	if body.get_parent() is Wire and not filled:
		print("PORT FILLED")
		filled = true
		body.global_position = snap_point.global_position
		var wire: Wire = body.get_parent()
		wire.snap()


func _on_body_exited(body: Node3D) -> void:
	if body.get_parent() is Wire and get_overlapping_bodies().size() == 0:
		print("PORT EMPTIED")
		filled = false
