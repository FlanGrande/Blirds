extends KinematicBody


# Signals
signal rotation_update

# Editor variables.
export var speed := 60.0
export var vertical_speed := 2.0
export var rotation_speed := 0.04
export var rotation_mouse_threshold := Vector2(1.0, 1.0)

# Movement variables.
var moving := false
var current_speed := Vector3(0.0, 0.0, 0.0)
var current_vertical_speed := 0.0

# Rotation variables.
var mouse_position := Vector2(0.0, 0.0)


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_input()
	handle_movement()
	handle_rotation()
	apply_movement(true)
	update_green_and_red_style()
	
	mouse_position = Vector2()

func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.relative
	
	#print(mouse_position)

func handle_input():
	if Input.is_action_pressed("move_forward"):
		moving = true
	else:
		moving = false

func handle_movement():
	if moving:
		current_speed = Vector3(0.0, 0.0, speed)
	else:
		current_speed = Vector3(0.0, 0.0, 0.0)
	
	if mouse_position.y > rotation_mouse_threshold.y:
		current_vertical_speed = -vertical_speed
	elif mouse_position.y < -rotation_mouse_threshold.y:
		current_vertical_speed = vertical_speed
	else:
		current_vertical_speed = 0.0

func handle_rotation():
	var rotation_direction := 0.0
	
	if mouse_position.x > rotation_mouse_threshold.x:
		rotate_y(-rotation_speed)
	
	if mouse_position.x < -rotation_mouse_threshold.x:
		rotate_y(rotation_speed)

func apply_movement(force := false):
	if moving or force:
		var direction := Vector3(0.0, 0.0, -1.0).rotated(Vector3(0.0, 1.0, 0.0), rotation.y)
		current_speed = Vector3(0.0, current_vertical_speed, 0.0) + speed * direction
		move_and_slide(current_speed, Vector3(0.0, 1.0, 0.0))

func update_green_and_red_style():
	var animation_player = get_parent().get_node("AnimationPlayer")
	var green_direction = Vector3(0.0, 0.0, -1.0)
	var normalized_rotation = current_speed.angle_to(green_direction)
	normalized_rotation = rad2deg(normalized_rotation) / 360
	print(normalized_rotation)
	emit_signal("rotation_update", normalized_rotation)
