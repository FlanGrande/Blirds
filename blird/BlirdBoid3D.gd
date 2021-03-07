extends Spatial

class_name Boid3D

# Boid's x, y origin
var x = 0
var y = 0
var z = 0
# Boid's direction vector
var dx = 0
var dy = 0
var dz = 0
var d = 20
var offset = 10
# Boid history of positions
var history = []
var historyLength = 20

var trailEnabled = false
var trailColor = Color(1.0, 0.0, 0.0, 1.0)
var trailWidth = 1.0
var trailLineIG : ImmediateGeometry
var trailMaterial : Material
var trailParticles : Particles


func _ready():
	pass

func initBoid(window_width, window_height, movement_depth, trail_enabled, trail_color, trail_width, trail_material, history_length):
	x = rand_range(-window_width, window_width)
	y = rand_range(-window_height, window_height)
	z = rand_range(-movement_depth, movement_depth)
	dx = rand_range(0, d) - offset
	dy = rand_range(0, d) - offset
	dz = rand_range(0, d) - offset
	history = []
	trailEnabled = trail_enabled
	trailColor = trail_color
	trailWidth = trail_width
	trailMaterial = trail_material
	historyLength = history_length
	
	if(trailEnabled):
		trailLineIG = ImmediateGeometry.new()
		trailLineIG.material_override = trailMaterial
		get_parent().add_child(trailLineIG) # This is better than set_as_toplevel(true)
	
	return self

func _process(delta):
	var translation_vector = Vector3(x, y, z)
	
	if(trailEnabled):
		trailLineIG.translation = Vector3()
		trailLineIG.rotation = Vector3()
		trailLineIG.clear()
		trailLineIG.begin(Mesh.PRIMITIVE_LINES)
		trailLineIG.set_color(trailColor)
		trailLineIG.set_normal(Vector3(1, 1, 1))
		
		var previous_point = history[0]
		for point in history:
			if(previous_point != point):
				trailLineIG.add_vertex(Vector3(previous_point[0], previous_point[1], previous_point[2]))
				trailLineIG.add_vertex(Vector3(point[0], point[1], point[2]))
				previous_point = point
		
		trailLineIG.end()

func addToHistory(var point : Vector3, var index : int):
	history.push_back(point)
	
	if(history.size() > historyLength): # This will probably give me some issues.
		history.pop_front() # This will probably give me some issues.
