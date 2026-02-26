class_name puzzlePieceOrganizer
extends Node3D

func try_organize_pieces() -> void:
	#check pieces are near
	var DISTANCE : float = 1;
	var meanPos : Vector2 = Vector2(0,0);
	for c : Node3D in get_children():
		meanPos += Vector2(c.position[0],c.position[1]);
	meanPos /= get_children().size();
	
	for c : Node3D in get_children():
		var vec : Vector2 = meanPos - Vector2(c.position[0],c.position[1]);
		if vec.length() > DISTANCE:
			return;
	var tween : Tween = get_tree().create_tween();
	tween.set_parallel()
	for c : Node3D in get_children():
		tween.tween_property(c, "position",Vector3(meanPos[0],meanPos[1],c.position.z),0.5);
	
