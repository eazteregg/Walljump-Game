extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var rays = get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
		

func detect_ledge() -> bool:
	
	for ray in rays:
		ray.force_raycast_update()
		if ray.is_colliding() and not ray.get_collider().get_parent().is_in_group("no_walljump"):
			return true
	
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
