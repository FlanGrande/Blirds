extends KinematicBody


# Signals
signal rotation_update

# Editor variables.
export var speed := 10.0
export var acceleration := 1.2
export var deceleration := 0.1
export var min_speed := 10.0
export var max_speed := 800.0
export var spin_speed := 24.0
export var rotation_acceleration := 0.01
export var rotation_mouse_threshold := Vector2(0.0, 0.0)

# Movement variables.
var moving := false
var current_speed := Vector3(0.0, 0.0, 0.0)
var rotation_speed := 0.0
var min_rotation_speed := -0.2
var max_rotation_speed := 0.2

# Movement feedback variables.
var current_sprite_position := Vector3(0.0, 0.0, 0.0)
var horizontal_factor := 10.4
var vertical_factor := 10.0
var min_vertical_position = -0.1
var max_vertical_position = 0.1
var min_horizontal_position = -0.1
var max_horizontal_position = 0.2

var target_position : Vector3

# Rotation variables.
var mouse_position := Vector2(0.0, 0.0)


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_input()
	handle_movement(delta)
	apply_movement(delta, true)
	update_green_and_red_style()
	apply_movement_feedback(delta)


func _input(event):
	if event is InputEventMouseMotion:
		mouse_position += event.relative

func handle_input():
	if Input.is_action_pressed("move_forward"):
		moving = true
	else:
		moving = false

func handle_movement(delta):
	if mouse_position.x < -50 || mouse_position.x > 50:
		rotate_object_local(Vector3(0.0, 1.0, 0.0), mouse_position.x*-1 * delta / 1000.0)
	
	if mouse_position.y < -50 || mouse_position.y > 50:
		rotate_object_local(Vector3(1.0, 0.0, 0.0), mouse_position.y*-1 * delta / 1000.0)
	
	if Input.is_action_pressed("spin_left"):
		rotate_object_local(Vector3(0.0, 0.0, 1.0), spin_speed * delta)
	
	if Input.is_action_pressed("spin_right"):
		rotate_object_local(Vector3(0.0, 0.0, 1.0), -spin_speed * delta)
	
	
	var forward = transform.basis.z
	
	#print(forward)
	#print(Vector3.DOWN.dot(forward))
	if(Vector3.DOWN.dot(forward) < 0.0):
		speed += acceleration
	else:
		speed -= deceleration
	
	speed = clamp(speed, min_speed, max_speed)
	#print("SPEED")
	#print(speed)
	
	#if direction.dot(enemy.transform.basis.z) > 0:
	#	enemy.im_watching_you(player)
	
	#print(rotation_degrees.y)
	#if(rotation_degrees.y < 0):
	#	speed += acceleration

func apply_movement(delta : float, force := false):
	#transform = transform.orthonormalized()
	if moving or force:
		translate_object_local(Vector3(0.0, 0.0, -speed * delta))

func update_green_and_red_style():
	var animation_player = get_parent().get_node("AnimationPlayer")
	var green_direction = Vector3(0.0, 0.0, -1.0) # green mood
	var normalized_rotation = current_speed.angle_to(green_direction)
	normalized_rotation = rad2deg(normalized_rotation) / 360
	emit_signal("rotation_update", normalized_rotation)

func apply_movement_feedback(delta):
	current_sprite_position = Vector3(mouse_position.x, -mouse_position.y, 10.0)/200.0
	$Sprite3D.translation = current_sprite_position
