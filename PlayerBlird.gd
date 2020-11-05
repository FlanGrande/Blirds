extends KinematicBody


# Signals
signal rotation_update

# Editor variables.
export var speed := 10.0
export var vertical_speed := 24.0
export var spin_speed := 24.0
export var rotation_acceleration := 0.01
export var rotation_mouse_threshold := Vector2(0.0, 0.0)

# Movement variables.
var moving := false
var current_speed := Vector3(0.0, 0.0, 0.0)
var current_vertical_speed := 0.0
var vertical_acceleration := 0.01
var min_vertical_speed = -16.0
var max_vertical_speed = 16.0
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
	
	#mouse_position = Vector2()

func _input(event):
	if event is InputEventMouseMotion:
		mouse_position += event.relative
	
	#print(mouse_position)

func handle_input():
	if Input.is_action_pressed("move_forward"):
		moving = true
	else:
		moving = false

func handle_movement(delta):
	if mouse_position.x < -50 || mouse_position.x > 50:
		#rotate_y(mouse_position.x*-1 / 10000.0)
		rotate_object_local(Vector3(0.0, 1.0, 0.0), mouse_position.x*-1 * delta / 1000.0)
	
	if mouse_position.y < -50 || mouse_position.y > 50:
		#rotate_x(mouse_position.y*-1 / 10000.0)
		rotate_object_local(Vector3(1.0, 0.0, 0.0), mouse_position.y*-1 * delta / 1000.0)
	
	if Input.is_action_pressed("spin_left"):
		rotate_object_local(Vector3(0.0, 0.0, 1.0), spin_speed * delta)
	
	if Input.is_action_pressed("spin_right"):
		rotate_object_local(Vector3(0.0, 0.0, 1.0), -spin_speed * delta)

func apply_movement(delta : float, force := false):
	if moving or force:
		translate_object_local(Vector3(0.0, 0.0, -speed * delta))
		#var direction := Vector3(0.0, 0.0, -1.0).rotated(Vector3(0.0, 1.0, 0.0), rotation.y)
		#current_speed = Vector3(0.0, current_vertical_speed, 0.0) + speed * direction
		#var direction = $Sprite3D.translation
		#direction.z = -speed
		#translate_object_local()
		#current_speed = speed * direction
		#print($Sprite3D.translation)
		#print(current_speed)
		#move_and_slide(current_speed, Vector3(0.0, 1.0, 0.0))

func update_green_and_red_style():
	var animation_player = get_parent().get_node("AnimationPlayer")
	var green_direction = Vector3(0.0, 0.0, -1.0)
	var normalized_rotation = current_speed.angle_to(green_direction)
	normalized_rotation = rad2deg(normalized_rotation) / 360
	#print(normalized_rotation)
	emit_signal("rotation_update", normalized_rotation)

func apply_movement_feedback(delta):
	#current_sprite_position = Vector3(lerp(min_horizontal_position, max_horizontal_position, mouse_position.normalized().x) * horizontal_factor, lerp(min_vertical_position, max_vertical_position, current_vertical_speed * vertical_factor), 0.0)
	current_sprite_position = Vector3(mouse_position.x, -mouse_position.y, 0.0)/200.0
	#print(mouse_position)
	#print(current_sprite_position)
	#current_sprite_position = Vector3(clamp(min_horizontal_position, max_horizontal_position, current_sprite_position.x), clamp(min_vertical_position, max_vertical_position, current_sprite_position.y), 0.0)
	#current_sprite_position = Vector3(0.0, 0.0, 0.0)
	$Sprite3D.translation = current_sprite_position
