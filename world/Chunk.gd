extends Spatial

class_name Chunk

var mesh_instance
var noise
var lod # 0 highest detail. 0, 1, 2, ..., n
var x
var z
var chunk_size
var should_remove = true

var data_tool

func _init(init_noise, init_x, init_z, init_chunk_size, init_lod):
	self.noise = init_noise
	self.x = init_x * init_chunk_size
	self.z = init_z * init_chunk_size
	self.chunk_size = init_chunk_size
	self.lod = init_lod

func _ready():
	generate_chunk()

func _process(delta):
	pass
	#edit_mesh()

func generate_chunk():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
	plane_mesh.subdivide_depth = chunk_size * 0.5
	plane_mesh.subdivide_width = chunk_size * 0.5
	
	plane_mesh.material = load("res://world/terrain_material.tres")
	
	var surface_tool = SurfaceTool.new()
	data_tool = MeshDataTool.new()
	surface_tool.create_from(plane_mesh, 0)
	var array_plane = surface_tool.commit()
	var error = data_tool.create_from_surface(array_plane, 0)
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		
		vertex.y = noise.get_noise_3d(vertex.x + x, vertex.y, vertex.z + z) * 160
		
		data_tool.set_vertex(i, vertex)
	
	for s in range(array_plane.get_surface_count()):
		array_plane.surface_remove(s)
	
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	mesh_instance = MeshInstance.new()
	mesh_instance.mesh = surface_tool.commit()
	#mesh_instance.create_trimesh_collision()
	mesh_instance.cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_instance)

func edit_mesh():
	for i in range(0, data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		
		vertex.y = 0
		print(data_tool)
		data_tool.set_vertex(i, vertex)
	data_tool.commit_to_surface(mesh_instance)
