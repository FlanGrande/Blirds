extends Spatial

#export(Color) var sky_top_color_red : Color
#export(Color) var sky_horizon_color_red : Color
#export(Color) var ground_bottom_color_red : Color
#export(Color) var ground_horizon_color_red : Color
#export(Color) var sun_color_red : Color
#export(Color) var sky_top_color_green : Color
#export(Color) var sky_horizon_color_green : Color
#export(Color) var ground_bottom_color_green : Color
#export(Color) var ground_horizon_color_green : Color
#export(Color) var sun_color_green : Color

const chunk_size = 64
const chunks_amount = 16

var noise
var chunks = {}
var unready_chunks = {}
var thread

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 6
	noise.period = 80
	
	thread = Thread.new()

func add_chunk(x, z):
	var key = str(x) + "," + str(z)
	
	if chunks.has(key) or unready_chunks.has(key):
		return
	
	if not thread.is_active():
		thread.start(self, "load_chunk", [thread, x, z])
		unready_chunks[key] = 1

func load_chunk(args):
	var thread = args[0]
	var x = args[1]
	var z = args[2]
	
	var chunk = Chunk.new(noise, x, z, chunk_size)
	chunk.translation = Vector3(x * chunk_size, 0, z * chunk_size)
	
	call_deferred("load_done", chunk, thread)

func load_done(chunk : Chunk, thread: Thread):
	add_child(chunk)
	
	var key = str(chunk.x / chunk_size) + "," + str(chunk.z / chunk_size)
	chunks[key] = chunk
	unready_chunks.erase(key)
	thread.wait_to_finish()

func get_chunk(x, z):
	var key = str(x) + "," + str(z)
	
	if chunks.has(key):
		return chunks.get(key)
	
	return null

func _process(delta):
	update_chunks()
	clean_up_chunks()
	reset_chunks()
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()

func update_chunks():
	var player_translation = $KinematicBody.translation
	var p_x = int(player_translation.x) / chunk_size
	var p_z = int(player_translation.z) / chunk_size
	
	for x in range(p_x - chunks_amount * 0.5, p_x + chunks_amount * 0.5):
		for z in range(p_z - chunks_amount * 0.5, p_z + chunks_amount * 0.5):
			add_chunk(x, z)

func clean_up_chunks():
	pass

func reset_chunks():
	pass

func _on_KinematicBody_rotation_update(normalized_rotation):
	#update_sky_colors(normalized_rotation)
	$AnimationPlayer.play("green_to_red")
	$AnimationPlayer.seek(lerp(0.0, 2.0, normalized_rotation), true)
	$AnimationPlayer.stop()

#func update_sky_colors(interpolation_step):
#	var sky_top_color_lerp = lerp(sky_top_color_red, sky_top_color_green*2, interpolation_step)
#	var sky_horizon_color_lerp = lerp(sky_horizon_color_red, sky_horizon_color_green*2, interpolation_step)
#	var ground_bottom_color_lerp = lerp(ground_bottom_color_red, ground_bottom_color_green*2, interpolation_step)
#	var ground_horizon_color_lerp = lerp(ground_horizon_color_red, ground_horizon_color_green*2, interpolation_step)
#	var sun_color_lerp = lerp(sun_color_green, sun_color_red*2, interpolation_step)
#
#	$WorldEnvironment.environment.background_sky.set("sky_top_color", sky_top_color_lerp)
#	$WorldEnvironment.environment.background_sky.set("sky_horizon_color", sky_horizon_color_lerp)
#	$WorldEnvironment.environment.background_sky.set("ground_bottom_color", ground_bottom_color_lerp)
#	$WorldEnvironment.environment.background_sky.set("ground_horizon_color", ground_horizon_color_lerp)
#	$WorldEnvironment.environment.background_sky.set("sun_color", sun_color_lerp)