class_name Graph
extends Object

var _vertices: Array[Vertex]
var _edges: Array[Edge]


func add_vertex(data: Variant, name: String = "") -> Vertex:
	var new_vertex: Vertex = Vertex.new(name, data)
	_vertices.append(new_vertex)
	return new_vertex


func remove_vertex() -> void:
	pass # TODO


func add_edge(vertex1: Vertex, vertex2: Vertex, weight: float = 0.0) -> Edge:
	var new_edge: Edge = Edge.new(vertex1, vertex2, weight)
	_edges.append(new_edge)
	return new_edge


func remove_edge() -> void:
	pass # TODO


func find_vertex(name: String) -> Vertex:
	for vertex: Vertex in _vertices:
		if vertex.get_name() == name:
			return vertex
	return null


func _to_string() -> String:
	var output: String = ""
	for edge in _edges:
		var vertices: Array[Vertex] = edge.get_vertices()
		output += vertices[0].get_name() + " --> " + vertices[1].get_name() + "\n"
	return output


func free() -> void:
	for edge: Edge in _edges:
		edge.free()
	for vertex: Vertex in _vertices:
		vertex.free()
