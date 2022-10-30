extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = get_parent()
onready var step_audio = get_node("StepAudio")
onready var slide_audio = get_node("SlideAudio")
onready var step_audio_metal = get_node("StepAudioMetal")
onready var on_floor_checker = player.get_node("onFloorChecker")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var hori_veloc = player.get_horizontal_velocity(player.velocity).length()
	if player.on_floor_custom and hori_veloc > 0.5:
		
		if player.crouch_modifier == 1.0:
			if on_floor_checker.get_collider().get_parent().is_in_group("metal"):
				if not step_audio_metal.playing:
					step_audio_metal.play()
				
			elif not step_audio.playing:
				step_audio.play()
				
		elif hori_veloc > 10.0:
			slide_audio.unit_db = lerp(-18.0, 0.0, smoothstep(10, 80, hori_veloc))
			if not slide_audio.playing:
				slide_audio.play()
		else:
			slide_audio.stop()
	else:
		step_audio.stop()
		slide_audio.stop()
		step_audio_metal.stop()
