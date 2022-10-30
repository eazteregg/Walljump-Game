extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var rays = get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func force_update_rays() -> void:
	for ray in rays:
		ray.force_raycast_update()

func update_ray_cast_tos(distance: float) -> void:
	for ray in rays:
		ray.cast_to = Vector3(0,0, -1) * distance

func get_rays() -> Array:
	return rays

func is_colliding() -> bool:
	for ray in rays:
		if ray.is_colliding():
			return true
	return false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
