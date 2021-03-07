extends Spatial

export var debug = false
var timer

# Called when the node enters the scene tree for the first time.
func _ready():
	if(debug):
		timer = Timer.new()
		timer.connect("timeout", $BoidNode3D, "OnDebugTimerTimeout")
		add_child(timer)
		timer.start(1.0)
