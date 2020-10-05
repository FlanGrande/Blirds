extends Spatial

export(Color) var sky_top_color_red : Color
export(Color) var sky_horizon_color_red : Color
export(Color) var ground_bottom_color_red : Color
export(Color) var ground_horizon_color_red : Color
export(Color) var sun_color_red : Color
export(Color) var sky_top_color_green : Color
export(Color) var sky_horizon_color_green : Color
export(Color) var ground_bottom_color_green : Color
export(Color) var ground_horizon_color_green : Color
export(Color) var sun_color_green : Color

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func _on_KinematicBody_rotation_update(normalized_rotation):
	#update_sky_colors(normalized_rotation)
	$AnimationPlayer.play("green_to_red")
	$AnimationPlayer.seek(lerp(0.0, 2.0, normalized_rotation), true)
	$AnimationPlayer.stop()

func update_sky_colors(interpolation_step):
	var sky_top_color_lerp = lerp(sky_top_color_red, sky_top_color_green*2, interpolation_step)
	var sky_horizon_color_lerp = lerp(sky_horizon_color_red, sky_horizon_color_green*2, interpolation_step)
	var ground_bottom_color_lerp = lerp(ground_bottom_color_red, ground_bottom_color_green*2, interpolation_step)
	var ground_horizon_color_lerp = lerp(ground_horizon_color_red, ground_horizon_color_green*2, interpolation_step)
	var sun_color_lerp = lerp(sun_color_green, sun_color_red*2, interpolation_step)
	
	$WorldEnvironment.environment.background_sky.set("sky_top_color", sky_top_color_lerp)
	$WorldEnvironment.environment.background_sky.set("sky_horizon_color", sky_horizon_color_lerp)
	$WorldEnvironment.environment.background_sky.set("ground_bottom_color", ground_bottom_color_lerp)
	$WorldEnvironment.environment.background_sky.set("ground_horizon_color", ground_horizon_color_lerp)
	$WorldEnvironment.environment.background_sky.set("sun_color", sun_color_lerp)
