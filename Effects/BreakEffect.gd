extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var anim_player = $AnimationPlayer
onready var anim = anim_player.get_animation("ShatteringAnim")
onready var hori_forward = Vector2(get_parent().transform.basis.z.x, get_parent().transform.basis.z.z)
onready var audio_player = get_node("ShatterSound")
# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.connect("animation_finished", get_parent(), "on_break_animation_finished")
	pass # Replace with function body.

func start_animation(velocity: Vector2) -> void:
	
	audio_player.play(1.0)
	print(audio_player.playing)
	var dot = velocity.dot(hori_forward)
	
	for i in range(anim.get_track_count()):
		var path:String = anim.track_get_path(i)
		if path.split(':')[-1] == "translation":
			print(anim.track_get_key_value(i, 0))
			if dot <= 0:
				anim.track_set_key_value(i, 1, anim.track_get_key_value(i, 0) - transform.basis.z * 0.1 * velocity.length())
			else:
				anim.track_set_key_value(i, 1, anim.track_get_key_value(i, 0) + transform.basis.z * 0.1 * velocity.length())
				#anim.track_set_key_value(i, 1, transform.basis.z)
				
	anim_player.play("ShatteringAnim")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
