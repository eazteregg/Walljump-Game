extends Label

onready var speed_label = get_node("VBoxContainer/SpeedGauge")
onready var player = get_parent()
var speed


# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("speed_changed", self, "_on_Player_speed_changed")
	
func _on_Player_speed_changed(velocity, _delta, _accel):
	text = "Speed: %s" % (Vector2(velocity.x, velocity.z).length())
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
