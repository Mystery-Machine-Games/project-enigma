extends Node3D
class_name JigsawPiece
var m : ArrayMesh = null;
var width : float = 0;
var layer : int = 0;
var poly : PackedVector2Array = [];
var spriteScale : float = 1;
var seed : int = 0;
var hint : Array = [];
var hintColors : Dictionary = {};
var group : Array = [self];
var adjacentPieces : Array = [];
var header : Array =  [];
@export var mesh : MeshInstance3D;
@export var previewMesh : MeshInstance3D;
@export var collider : CollisionShape3D;
@export var polygon : PuzzleHint;
@export var viewport : Sprite3D;
@export var area : Area3D;

func _ready() -> void:
	$Area3D/SubViewport.size *= spriteScale;
	polygon.scale *= spriteScale;
	viewport.offset *= spriteScale;
	$previewMesh/Sprite3D.offset *= spriteScale;
	
	area.collision_layer = layer;
	
	mesh.mesh = m;
	#var shaderMat : StandardMaterial3D = mesh.material_override
	#shaderMat.set_shader_parameter("color",Color(randf(),randf(),randf()))
	
	previewMesh.mesh = mesh.mesh;
	#previewMesh.material_override = mesh.material_override;
	
	collider.shape = m.create_trimesh_shape()
	
	$previewMesh/Sprite3D.position.z = width;
	#$previewMesh/SubViewport/Polygon2D.polygon = poly;
	viewport.position.z = width;
	
	if hint.size() > 0:
		polygon.clues = hint;
	if header.size() > 0:
		polygon.header = header;
	polygon.hintColors = hintColors;
	polygon.construct(poly,seed);

func float_up(boolean : bool) -> void:
	if boolean: # ???
		AudioManager.play_sound("pickup")
		previewMesh.visible = true;
		pass
	var tween : Tween = get_tree().create_tween();
	if boolean:
		tween.tween_property(mesh,"position",Vector3(0,0,0.2),0.3).set_ease(Tween.EASE_OUT);
		tween.parallel().tween_property(viewport,"position",Vector3(0,0,0.2 + width),0.3).set_ease(Tween.EASE_OUT);
	else:
		tween.tween_property(mesh,"position",Vector3(0,0,0),0.3).set_ease(Tween.EASE_IN);
		tween.parallel().tween_property(viewport,"position",Vector3(0,0,0 + width),0.3).set_ease(Tween.EASE_IN);
	if !boolean:
		#going down
		tween.finished.connect(get_parent().try_organize_pieces.bind(self));
		await tween.finished;
		previewMesh.visible = false;

func try_organize() -> void:
	get_parent().try_organize_pieces(self);

func return_selected() -> Array:
	return group;

func get_hints() -> Array:
	return hint;
