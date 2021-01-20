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


func _ready():
	pass

func initBoid(window_width, window_height, movement_depth):
	x = rand_range(-window_width, window_width)
	y = rand_range(-window_height, window_height)
	z = rand_range(-movement_depth, movement_depth)
	dx = rand_range(0, d) - offset
	dy = rand_range(0, d) - offset
	dz = rand_range(0, d) - offset
	history = []
	return self
