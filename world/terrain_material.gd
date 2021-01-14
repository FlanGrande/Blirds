extends ShaderMaterial

var frequency_timer := Timer.new()

var color_offset = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	print("hola")
	frequency_timer.start(1)
	frequency_timer.connect("timeout", self, "OnFrequencyTimerTimeout")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("hola")
	color_offset = frequency_timer.wait_time
	set_shader_param("color_offset", color_offset)

func OnFrequencyTimerTimeout():
	frequency_timer.start(1)
