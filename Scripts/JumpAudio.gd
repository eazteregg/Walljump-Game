extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var positions = [0.0, 0.89, 1.78, 2.7, 3.5, 4.5, 5.3, 6.7, 7.9, 8.9]
onready var voice_sounds = get_node("VoiceSounds")
onready var foot_sounds = get_node("FootSounds")
onready var pull_up_sound = get_node("PullUpSound")
onready var timer = get_node("VoiceSounds/Timer")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	
func play_random_sound_for_x_seconds():
	voice_sounds.play(positions[rand_range(0, len(positions)-1)])
	foot_sounds.play(5.763)
	
	timer.start(0.2)

func play_pull_up_sound():
	pull_up_sound.play()

func reset_foot_sounds_position() -> void:
	foot_sounds.translation = Vector3.ZERO

func adjust_foot_sounds_position(new_global_position: Vector3) -> void:
	foot_sounds.global_translation = new_global_position

func _on_Timer_timeout():
	voice_sounds.stop()
