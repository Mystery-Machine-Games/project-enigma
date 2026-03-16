class_name puzzlePieceOrganizer
extends Node3D

signal puzzleCompleteSignal;

var pieces : Array = [];

func initialize_pieces() -> void:
	for c : JigsawPiece in get_children():
		pieces.append([c]);

func get_group_for_piece(node : JigsawPiece) -> Array:
	for group : Array in pieces:
		if node in group:
			return group;
	return [];

func try_organize_pieces(node : JigsawPiece) -> void:
	if pieces.size() == 1:
		return;
	var DISTANCE : float = 0.2;
	var nodegroup : Array = [];
	
	for group : Array in pieces:
		if node in group:
			nodegroup = group.duplicate();
			#there should only be one group that a node is ever in
	
	for n : JigsawPiece in nodegroup:
		for piece : JigsawPiece in n.adjacentPieces:
			if piece in nodegroup:
				continue
			if (piece.position - n.position).length() < DISTANCE:
				#found a piece adjacent to the node!
				tween_group_to_position(nodegroup.duplicate(), piece.position);
				#merge the arrays
				
				for foundarr : Array in pieces:
					if piece in foundarr:
						pieces.erase(nodegroup);
						pieces.erase(foundarr);
						print(foundarr);
						nodegroup.append_array(foundarr);
						
						pieces.append(nodegroup);
	
						AudioManager.play_sound("click")
						
	if pieces.size() == 1:
		puzzleCompleteSignal.emit(get_children().front().get_hints(), get_children().front().header);
		AudioManager.play_sound("success")

	#print("trying to organize")
	#if b == true:
		#return;
	#check pieces are near
	#var meanPos : Vector2 = Vector2(0,0);
	#for c : Node3D in get_children():
		#meanPos += Vector2(c.position[0],c.position[1]);
	#meanPos /= get_children().size();
	#
	#for c : Node3D in get_children():
		#var vec : Vector2 = meanPos - Vector2(c.position[0],c.position[1]);
		#if vec.length() > DISTANCE:
			#return;
	#var tween : Tween = get_tree().create_tween();
	#tween.set_parallel()
	#for c : Node3D in get_children():
		#tween.tween_property(c, "position",Vector3(meanPos[0],meanPos[1],c.position.z),0.5);
	#for c : Node3D in get_children():
		#c.group = get_children();

func tween_group_to_position(group : Array, pos : Vector3) -> void:
	var tween : Tween = get_tree().create_tween();
	tween.set_parallel(true);
	for node : JigsawPiece in group:
		tween.tween_property(node, "position",pos,0.1);
	pass
