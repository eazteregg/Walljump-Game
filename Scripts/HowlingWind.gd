extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var positions = []

onready var audio = get_node("HowlingWindAudio")
onready var switch_timer = get_node("SwitchTimer")
onready var fade_out_tween = get_node("FadeOutTween")


# Called when the node enters the scene tree for the first time.
func _ready():
	
	for child in get_children():
		if child is Spatial:
			positions.append(child)
			

	set_wait_time_to_random()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	print(audio.playing)

func set_wait_time_to_random():
	switch_timer.wait_time = rand_range(2.0, 7.0)

func _on_Area3D_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	print("body entered")
	if not audio.playing:
		audio.play()
		switch_timer.start()
	elif audio.stream_paused:
		audio.stream_paused = false
		switch_timer.start()
		


func _on_Area3D_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	print('body exited')
	audio.stream_paused = true
	switch_timer.stop()
	

func _on_SwitchTimer_timeout():
	if not audio.stream_paused and not fade_out_tween.is_active():
		print("Starting Fade Out")
		print(audio)
		print(audio.unit_db)
		fade_out_tween.interpolate_property(audio, "unit_db", 0.0, -24.0, 1.0)
		fade_out_tween.start()
		print(fade_out_tween.is_active())

func _on_FadeOutTween_tween_completed(object, key):
	print("Fade Out completed")
	audio.unit_db = 0.0
	audio.translation = positions[rand_range(0, len(positions))].translation
	set_wait_time_to_random()
	switch_timer.start()


func _on_FadeOutTween_tween_step(object, key, elapsed, value):
	print(value)
