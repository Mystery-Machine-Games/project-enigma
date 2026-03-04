extends Node3D

var jigsawPiece : PackedScene = preload("res://scenes/puzzles/jigsaw/JigsawPiece.tscn");
var jigsawDataPath : String = "res://assets/jerryMisc/data.txt";
var puzzleArr : Array[Array] = []
var puzzleTriangleArr : Array = []
var flatShapeArr : Array[Array]= [];
var debug : bool = false;
var width : int = 5;
var mult : float = 100;
var seed : int = randi();
var hintColors : Dictionary = {};
var offset : Vector3 = Vector3(0,0,0);
var currentSelected : JigsawPiece = null;
var selectedPos : Vector3 = Vector3(0,0,0)
var hintList : Array = [];

@export var areaLayer : int;
@export var bodyLayer: int;
@export var pieces : Node3D;
@export var camera : Camera3D;

func _ready() -> void:
	camera = $"../Path3D/PlayerCharacter".get_camera();
	$plane.collision_layer = bodyLayer
	await initialize_shape_arr();
	generate_shapes()

func get_hint_colors() -> Dictionary:
	var buttoncolors : Array = $"../LyleFocusBox/FocusHandle/Machine".get_button_module()._possible_button_colors
	var wirecolors : Array = $"../LyleFocusBox/FocusHandle/Machine".get_wire_module()._possible_port_colors
	var colorDict : Dictionary = {
		"circle_button": buttoncolors[0].albedo_color,
		"square_button": buttoncolors[1].albedo_color,
		"triangle_button": buttoncolors[2].albedo_color,
		"circle_port": wirecolors[0].albedo_color,
		"square_port": wirecolors[1].albedo_color,
		"triangle_port": wirecolors[2].albedo_color,
	}
	return colorDict;

func add_clueset(clueset : Clueset) -> void:
	var temparr : Array = [];
	for clue in clueset.get_clues():
		var arr : Array = [];
		arr.append(clue._item1.get_codes());
		arr.append([str(clue.is_positive())]);
		arr.append(clue._item2.get_codes());
		temparr.append(arr);
	hintList.append(temparr);

func generate_shapes() -> void:
	for n : Clueset in $"../LyleFocusBox/FocusHandle/Machine".cluesetArr:
		add_clueset(n);
	#for n : Array in hintList:
		#print(n)
	hintColors = get_hint_colors()
	draw_shapes_from_puzzle(randi_range(0,puzzleArr.size() - 1),Vector2(-3,0))
	draw_shapes_from_puzzle(randi_range(0,puzzleArr.size() - 1),Vector2(0,0))
	
	pieces.rotation = Vector3(-PI/2,PI,0) #when this is rotated a different direction the mesh is fully black for some reason

func draw_shapes_from_puzzle(puzzleIndex : int, vec : Vector2) -> void:
	
	var newList : Array = hintList.pop_front();
	#print(puzzleIndex)
	var node : puzzlePieceOrganizer = puzzlePieceOrganizer.new();
	node.puzzleCompleteSignal.connect(puzzle_complete)
	pieces.add_child(node);
	for shapeIndex : int in puzzleArr[puzzleIndex].size():
		var st : SurfaceTool = SurfaceTool.new()
		var m : JigsawPiece = jigsawPiece.instantiate();
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		#st.set_color(Color(randf(), randf(), randf()))
		#st.set_uv(Vector2(0, 0))
		
		for index : int in puzzleTriangleArr[puzzleIndex][shapeIndex]:
			var vec3 : Vector3 = puzzleArr[puzzleIndex][shapeIndex][index];
			st.add_vertex(vec3/mult);
		
		m.poly = flatShapeArr[puzzleIndex][shapeIndex];
		#print(m.poly)
		m.m = st.commit();
		m.width = width/(mult - 25)
		m.spriteScale = 300.0/mult
		m.seed = seed;
		m.layer = areaLayer;
		m.hintColors = hintColors;
		m.hint = newList.duplicate();
		
			
		
		
		node.add_child(m);
		randomize();
		m.position.x += vec[0] + randf_range(-2,2);
		m.position.y += vec[1] + randf_range(-1,1);
	node.initialize_pieces()
	for firstnode : JigsawPiece in node.get_children():
		for secondnode in node.get_children():
			if secondnode == firstnode:
				continue;
			var num : int = 0;
			for vertex : Vector2 in firstnode.poly:
				if vertex in secondnode.poly:
					num += 1;
			if num >= 2:
				firstnode.adjacentPieces.append(secondnode)
		#print(firstnode.adjacentPieces)
			#find all shapes that share 2 vertices with this shape

var startingPos : Vector3 = Vector3.ZERO;
func _physics_process(_delta : float) -> void:
	if currentSelected:
		var group : Array = currentSelected.get_parent().get_group_for_piece(currentSelected)
		if group.size() == 0:
			#something has gone terribly wrong:
			pass
		else:
			for node : Node3D in group:
				node.global_position.x = (shoot_ray() + selectedPos).x;
				node.global_position.z = (shoot_ray() + selectedPos).z;
	
	if Input.is_action_just_pressed("leftclick"):
		#print("pressed")
		var temp : Dictionary = detect_piece();
		#if temp:
			#print(temp.collider.is_in_group("puzzlepieces"))
		if temp && temp.collider.is_in_group("puzzlepieces"):
			currentSelected = temp.collider.get_parent();
			#currentSelected.get_parent().float_up(true);
			selectedPos = temp.collider.global_position - temp.position;
			#currentSelected.global_position.y = 0.1
		
	if Input.is_action_just_released("leftclick"):
		var arr : Array = [];
		#if currentSelected:
			#currentSelected.get_parent().float_up(false);
		if currentSelected:
			currentSelected.try_organize();
		currentSelected = null;

func shoot_ray() -> Vector3: #used for mouse tracking
	#var camera : Camera3D = $pivot/Camera3D
	var raylength : int = 1000;
	var from : Vector3 = camera.project_ray_origin(camera.get_viewport().get_mouse_position());
	var to : Vector3 = from + camera.project_ray_normal(camera.get_viewport().get_mouse_position()) * raylength;
	var space : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state;
	var ray : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new();
	ray.collide_with_areas = false;
	ray.from = from;
	ray.to = to;
	ray.collision_mask = bodyLayer;
	var result : Dictionary = space.intersect_ray(ray);
	if !result.is_empty():
		#print(result)
		return result.position;
	return Vector3(0,0,0);
	
func detect_piece() -> Dictionary: #used for jigsaw piece
	var raylength : int = 1000;
	var from : Vector3 = camera.project_ray_origin(camera.get_viewport().get_mouse_position());
	var to : Vector3 = from + camera.project_ray_normal(camera.get_viewport().get_mouse_position()) * raylength;
	var space : PhysicsDirectSpaceState3D = get_world_3d().direct_space_state;
	var ray : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new();
	ray.collide_with_bodies = false;
	ray.collide_with_areas = true;
	ray.from = from;
	ray.to = to;
	ray.collision_mask = areaLayer;
	var result : Dictionary = space.intersect_ray(ray);
	if !result.is_empty():
		#print(result)
		return result;
	return {};

func initialize_shape_arr() -> void:
	var file : FileAccess = FileAccess.open(jigsawDataPath, FileAccess.READ)		#print(JSON.parse_string(file.get_as_text()))
	for p : Array in JSON.parse_string(file.get_as_text()):
		var tempshape : Array = []
		for s : Array in p:
			var tempVList : Array = [];
			for v : Array in s:
				var x : float = v[0]/2.34;
				var y : float = v[1]/2.34;
				tempVList.append(Vector2(x,y))
			#tempVList.reverse();
			tempshape.append(tempVList);
		flatShapeArr.append(tempshape);
	var num : int = 0;
	for puzzle : Array in JSON.parse_string(file.get_as_text()):
		
		var shapeArr : Array = [];
		var shapeTriangleArr : Array = [];
		var count : int = 0;
		for shape : Array in puzzle:
			
			#create front and back
			var currentShape : Array = [];
			var currentTriangles : Array = [];
			for n : int in 2:
				var temp : Array = shape.duplicate();
				if n == 1: 
					temp.reverse();
					pass
				#if num == 2 && count == 1:
					#print(temp)
				var vertexArr : Array[Vector3] = []
				for vertex : Array in temp:
					var x : float = vertex[0];
					var y : float = vertex[1];
					vertexArr.append(Vector3(x,y,n * width))
				var tempTRI : PackedInt32Array = Geometry2D.triangulate_polygon(temp);
				#if num == 2 && count == 1:
					#print(tempTRI)
				for index : int in tempTRI.size():
					tempTRI[index] += currentShape.size();
				#if num == 2 && count == 1:
					#print(tempTRI)
				#if num == 2:
					#tempTRI.reverse();
				currentShape.append_array(vertexArr)
				currentTriangles.append_array(tempTRI);
				#turn into big shape array, so next loop can access
			var arr1 : Array = currentShape.slice(0,shape.size());
			var arr2 : Array = currentShape.slice(shape.size());
			arr2.reverse();
			
			for vertexIndex : int in shape.size():
				var tempEdge : Array = []
				tempEdge = [
					arr1[vertexIndex-1], # this is a problem becasue ur getting the second shape's last item
					arr1[vertexIndex],
					arr2[vertexIndex],
					arr2[vertexIndex - 1]
				]
				tempEdge.reverse();
				var tempTRI : PackedInt32Array = Geometry2D.triangulate_polygon(tempEdge);
				for index : int in tempTRI.size():
					tempTRI[index] += currentShape.size();
				currentShape.append_array(tempEdge);
				currentTriangles.append_array(tempTRI);
				
			shapeArr.append(currentShape);
			shapeTriangleArr.append(currentTriangles)
			count += 1;
		num += 1;
		puzzleTriangleArr.append(shapeTriangleArr)
		puzzleArr.append(shapeArr)

func puzzle_complete(hints : Array) -> void:
	var temp : PuzzleHint = load("res://scenes/puzzles/jigsaw/hint_sprite.tscn").instantiate()
	$"../Interface/Control".add_child(temp)
	temp.clues = hints
	temp.hintColors = hintColors;
	temp.construct([],0,false);
	
