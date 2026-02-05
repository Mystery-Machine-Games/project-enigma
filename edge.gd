class_name Edge
extends Object

var _vertex1: Vertex
var _vertex2: Vertex
var _weight: float


func _init(vertex1: Vertex, vertex2: Vertex, weight: float) -> void:
	_vertex1 = vertex1
	_vertex2 = vertex2
	_weight = weight


func get_vertices() -> Array[Vertex]:
	return [_vertex1, _vertex2]


func set_vertices(vertex1: Vertex, vertex2: Vertex) -> void:
	_vertex1 = vertex1
	_vertex2 = vertex2


func get_weight() -> float:
	return _weight


func set_weight(weight: float) -> void:
	_weight = weight
