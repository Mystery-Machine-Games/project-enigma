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
@export var areaLayer : int;
@export var bodyLayer: int;
@export var pieces : Node3D;
func _ready() -> void:
	$plane.collision_layer = bodyLayer
	initialize_shape_arr();
	draw_shapes_from_puzzle(0)
	pieces.rotation = Vector3(-PI/2,PI,0) #when this is rotated a different direction the mesh is fully black for some reason

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
				if num == 2 && count == 1:
					print(temp)
				var vertexArr : Array[Vector3] = []
				for vertex : Array in temp:
					var x : float = vertex[0];
					var y : float = vertex[1];
					vertexArr.append(Vector3(x,y,n * width))
				var tempTRI : PackedInt32Array = Geometry2D.triangulate_polygon(temp);
				if num == 2 && count == 1:
					print(tempTRI)
				for index : int in tempTRI.size():
					tempTRI[index] += currentShape.size();
				if num == 2 && count == 1:
					print(tempTRI)
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

func draw_shapes_from_puzzle(puzzleIndex : int) -> void:
	var initialsize : int = pieces.get_children().size()
	for shapeIndex : int in puzzleArr[puzzleIndex].size():
		#if shapeIndex != 1:
			#continue;
		var st : SurfaceTool = SurfaceTool.new()
		var m : JigsawPiece = jigsawPiece.instantiate();
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		st.set_color(Color(randf(), randf(), randf()))
		st.set_uv(Vector2(0, 0))
		
		for index : int in puzzleTriangleArr[puzzleIndex][shapeIndex]:
			var vec3 : Vector3 = puzzleArr[puzzleIndex][shapeIndex][index];
			#print(vec3/300)
			st.add_vertex(vec3/mult);
		
		#print(flatShapeArr[puzzleIndex][shapeIndex])
		m.poly = flatShapeArr[puzzleIndex][shapeIndex];
		m.m = st.commit();
		m.width = width/(mult - 25)
		m.spriteScale = 300.0/mult
		m.seed = seed;
		m.layer = areaLayer;
		initialsize += 1;
		
		pieces.add_child(m);
		#m.position.x += randf_range(-1,1);
		#return;
var speed : int = 10;
func shoot_ray() -> Vector3:
	var camera : Camera3D = $pivot/Camera3D
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
	
func detect_piece() -> Dictionary:
	var camera : Camera3D = $pivot/Camera3D
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
var offset : Vector3 = Vector3(0,0,0);
var currentSelected : Node3D =  null;
func _physics_process(_delta : float) -> void:
	#print($pivot/Camera3D.project_ray_normal($pivot/Camera3D.get_viewport().get_mouse_position()).slide(Vector3(0.5,0.5,0).normalized()))
	if currentSelected:
		#currentSelected.global_position.y = 0.1
		currentSelected.get_parent().global_position.x = (shoot_ray() + offset).x;
		currentSelected.get_parent().global_position.z = (shoot_ray() + offset).z;
	if Input.is_action_just_pressed("leftclick"):
		#print("pressed")
		var temp : Dictionary = detect_piece();
		
		if temp:
			currentSelected = temp.collider;
			currentSelected.get_parent().float_up(true);
			offset = currentSelected.global_position - temp.position;
			#currentSelected.global_position.y = 0.1
	if Input.is_action_just_released("leftclick"):
		#currentSelected.global_position.y = 0
		if currentSelected:
			currentSelected.get_parent().float_up(false);
		currentSelected = null;
		
	#if Input.is_action_pressed("ui_accept"):
		#$pivot.rotation_degrees += Vector3(0,speed,0);
	#if Input.is_action_pressed("q"):
		#if currentSelected:
			#currentSelected.rotation_degrees += Vector3(0,0,3);
	#if Input.is_action_pressed("e"):
		#if currentSelected:
			#currentSelected.rotation_degrees += Vector3(0,0,3);
