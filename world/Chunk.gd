extends Spatial

class_name Chunk

var mesh_instances = []
var noise
var lod # 1 highest detail. 1, 2, 3, ..., n NOT ZERO
var x
var y
var z
var chunk_size
var should_remove = true
var material_shader

var LODSpatial = Spatial.new()

func _init(init_noise, init_x, offset_y, init_z, init_chunk_size, init_lod):
	self.noise = init_noise
	self.x = init_x * init_chunk_size
	self.y = offset_y
	self.z = init_z * init_chunk_size
	self.chunk_size = init_chunk_size
	self.lod = init_lod

func _ready():
	LODSpatial = Spatial.new()
	LODSpatial.set_script(load("res://addons/lod_spatial.gd"))
	LODSpatial.lod_0_max_distance = 2000
	LODSpatial.lod_1_max_distance = 3000
	LODSpatial.lod_2_max_distance = 4000
	add_child(LODSpatial)
	generate_chunk()

func _process(delta):
	pass

func generate_chunk():
	var lod_levels = 3
	
	for lod_i in range(lod_levels):
		var polygons = chunk_size * 0.5
		var plane_mesh = PlaneMesh.new()
		plane_mesh.size = Vector2(chunk_size, chunk_size)
		
		plane_mesh.subdivide_width = polygons / (lod_i + 3)
		plane_mesh.subdivide_depth = polygons / (lod_i + 3)
		
		#ShaderMaterial : material_shader2 = load("res://world/terrain_material.tres")
		
		
		#plane_mesh.material = load("res://world/terrain_material.tres")
		#plane_mesh.material.set_script(load("res://world/terrain_material.gd"))
		#TO DO: make water flat.
		#plane_mesh.material
		
		var surface_tool = SurfaceTool.new()
		var data_tool = MeshDataTool.new()
		surface_tool.create_from(plane_mesh, 0)
		var array_plane = surface_tool.commit()
		var error = data_tool.create_from_surface(array_plane, 0)
		
		for i in range(0, data_tool.get_vertex_count()):
			var vertex = data_tool.get_vertex(i)
			
			vertex.y = noise.get_noise_3d(vertex.x + x, vertex.y, vertex.z + z) * 60 + y
			
			data_tool.set_vertex(i, vertex)
	
		for s in range(array_plane.get_surface_count()):
			array_plane.surface_remove(s)
		
		var tmp_material = load("res://world/terrain_material.tres")
		#print(tmp_material.get_script())
		data_tool.set_material(tmp_material)
		data_tool.commit_to_surface(array_plane)
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		#surface_tool.add_smooth_group(true)
		#surface_tool.append_from(array_plane, 0, Transform.IDENTITY)
		surface_tool.create_from(array_plane, 0)
		surface_tool.generate_normals()
		
		mesh_instances.append(MeshInstance.new())
		mesh_instances[lod_i].mesh = surface_tool.commit()
		#print(mesh_instances[lod_i].mesh)
		#mesh_instance.create_trimesh_collision()
		mesh_instances[lod_i].cast_shadow = GeometryInstance.SHADOW_CASTING_SETTING_OFF
		mesh_instances[lod_i].name = "MeshInstance-lod" + str(lod_i)
		LODSpatial.add_child(mesh_instances[lod_i])
