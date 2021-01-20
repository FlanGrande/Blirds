extends Spatial

# Based on: https://github.com/beneater/boids/blob/master/boids.js

onready var boid_scene = preload("res://blird/BlirdBoid3D.tscn")

var window_width = 24.0
var window_height = 24.0
var forward_depth = 16.0

const numBoids = 20
const visualRange = 20

var boids = []


func _ready():
	for i in range(numBoids):
		var new_boid = boid_scene.instance()
		boids.push_back(new_boid.initBoid(window_width, window_height, forward_depth))
		add_child(new_boid)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for boid in boids:
		# Update the velocities according to each rule
		flyTowardsCenter(boid)
		avoidOthers(boid)
		matchVelocity(boid)
		limitSpeed(boid)
		keepWithinBounds(boid)
		
		#Update the position based on the current velocity
		boid.x += boid.dx;
		boid.y += boid.dy;
		boid.z += boid.dz;
		boid.history.push_back([boid.x, boid.y, boid.z])
		if(boid.history.size() > 50): # This will probably give me some issues.
			boid.history.pop_front() # This will probably give me some issues.
		
		drawBoid(boid)


# Constrain a boid to within the window. If it gets too close to an edge,
# nudge it back in and reverse its direction.
func keepWithinBounds(boid : Boid3D):
	var margin = 40.0 # CONST?
	var turnFactor = 0.1 # CONST?
	
	if (boid.x < margin):
		boid.dx += turnFactor
	
	if (boid.x > window_width - margin):
		boid.dx -= turnFactor
	
	if (boid.y < margin):
		boid.dy += turnFactor
	
	if (boid.y > window_height - margin):
		boid.dy -= turnFactor
	
	if (boid.z < margin):
		boid.dz += turnFactor
	
	if (boid.z > forward_depth - margin):
		boid.dz -= turnFactor


# Find the center of mass of the other boids and adjust velocity slightly to
# point towards the center of mass.
func flyTowardsCenter(boid : Boid3D):
	var boidPosition = Vector3(boid.x, boid.y, boid.z)
	var centeringFactor = 0.005; # adjust velocity by this % # CONST?
	
	var centerX = 0;
	var centerY = 0;
	var centerZ = 0;
	var numNeighbors = 0;
	
	for otherBoid in boids:
		var otherBoidPosition = Vector3(otherBoid.x, otherBoid.y, otherBoid.z)
		if(boidPosition.distance_to(otherBoidPosition) < visualRange):
			centerX += otherBoid.x
			centerY += otherBoid.y
			centerZ += otherBoid.z
			numNeighbors += 1
	
	if(numNeighbors >= 0):
		centerX = centerX / numNeighbors
		centerY = centerY / numNeighbors
		centerZ = centerZ / numNeighbors
		boid.dx += (centerX - boid.x) * centeringFactor
		boid.dy += (centerY - boid.y) * centeringFactor
		boid.dz += (centerZ - boid.z) * centeringFactor


# Move away from other boids that are too close to avoid colliding
func avoidOthers(boid : Boid3D):
	var boidPosition = Vector3(boid.x, boid.y, boid.z)
	var minDistance = 4.0 # The distance to stay away from other boids # CONST?
	var avoidFactor = 0.05 # Adjust velocity by this % # CONST?
	var moveX = 0
	var moveY = 0
	var moveZ = 0
	
	for otherBoid in boids:
		var otherBoidPosition = Vector3(otherBoid.x, otherBoid.y, otherBoid.z)
		if(otherBoid != boid): # Is it really different as in javascript?
			if(boidPosition.distance_to(otherBoidPosition) < minDistance):
				moveX += boid.x - otherBoid.x;
				moveY += boid.y - otherBoid.y;
				moveZ += boid.z - otherBoid.z;
	
	boid.dx += moveX * avoidFactor
	boid.dy += moveY * avoidFactor
	boid.dz += moveZ * avoidFactor

# Find the average velocity (speed and direction) of the other boids and
# adjust velocity slightly to match.
func matchVelocity(boid : Boid3D):
	var boidPosition = Vector3(boid.x, boid.y, boid.z)
	var matchingFactor = 0.05 # Adjust by this % of average velocity # CONST?
	
	var avgDX = 0
	var avgDY = 0
	var avgDZ = 0
	var numNeighbors = 0
	
	for otherBoid in boids:
		var otherBoidPosition = Vector3(otherBoid.x, otherBoid.y, otherBoid.z)
		if(boidPosition.distance_to(otherBoidPosition) < visualRange):
			avgDX += otherBoid.dx
			avgDY += otherBoid.dy
			avgDZ += otherBoid.dz
			numNeighbors += 1
	
	if(numNeighbors >= 0):
		avgDX = avgDX / numNeighbors
		avgDY = avgDY / numNeighbors
		avgDZ = avgDZ / numNeighbors
		
		boid.dx += (avgDX - boid.dx) * matchingFactor
		boid.dy += (avgDY - boid.dy) * matchingFactor
		boid.dz += (avgDZ - boid.dz) * matchingFactor

# Speed will naturally vary in flocking behavior, but real animals can't go
# arbitrarily fast.
func limitSpeed(boid : Boid3D):
	var speedLimit = 1.0# CONST?
	var speed = pow(boid.dx * boid.dx + boid.dy * boid.dy + boid.dz * boid.dz, 1.0/3.0) # CONST?
	
	if(speed > speedLimit):
		boid.dx = (boid.dx / speed) * speedLimit
		boid.dy = (boid.dy / speed) * speedLimit
		boid.dz = (boid.dz / speed) * speedLimit

func drawBoid(boid : Boid3D):
	boid.translation = Vector3(boid.x, boid.y, boid.z)
	var target = Vector3(-boid.dx, -boid.dy, -boid.dz)*100.0 # This needs to take into account the player's speed.
	boid.look_at(target, Vector3.UP)
