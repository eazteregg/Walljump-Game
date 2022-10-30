extends Tween

onready var player = get_parent()
var curr_velocity = Vector3.ZERO
var curr_delta = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func vault_delay(velocity, distance, test_coll):
	print("Tween started")
	print("Distance: %s" % distance)
	curr_velocity =  velocity
	var target = test_coll.position + distance
	var time = distance.length()/(curr_velocity.length())
	interpolate_property(player, "translation", player.translation, target, time, 1, 0)
	start()

func _on_VaultTween_tween_completed(object, key):
	print("Tween completing...")
	print("Current velocity: %s" % curr_velocity)
	print(get_process_delta_time())
	#player.set_collision_mask_bit(1, true)
	#player.set_collision_mask_bit(2, true)
	#while player.move_and_collide(curr_velocity * get_process_delta_time(), true, true, true):
		#player.translate_object_local(Vector3.UP * 0.05)
	#player.move_and_collide(curr_velocity * get_process_delta_time(), true, true, false)
	#player.move_and_collide(Vector3.DOWN, true,true, false)
	player.velocity = curr_velocity
	


func _on_VaultTween_tween_started(object, key):
	print("starting vault")

