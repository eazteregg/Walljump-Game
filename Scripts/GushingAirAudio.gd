extends AudioStreamPlayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var max_veloc = max(-1 * player.velocity.y, player.get_horizontal_velocity(player.velocity).length())
	if max_veloc > 30.0:
		volume_db = lerp(-18.0, -6.0, smoothstep(30.0, 60.0, max_veloc))
		if not playing:
			play()
	else:
		stop()
	
