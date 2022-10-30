extends Control

onready var speed_gauge = get_node("VBoxContainer/SpeedGauge")
onready var timer = get_node("VBoxContainer/Timer")
onready var player = get_parent()

var speed
var time_elapsed = 0.0
var timer_running = true

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("speed_changed", self, "_on_Player_speed_changed")
	
func _on_Player_speed_changed(velocity, _delta, _accel):
	speed_gauge.text = "Speed: %s" % (Vector2(velocity.x, velocity.z).length())
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timer_running:
		time_elapsed += delta
		timer.text = "Time: %s" % time_elapsed

func get_time() -> int:
	return time_elapsed
