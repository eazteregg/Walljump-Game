extends Spatial

tool
export var ray_size = 1.0 setget adjust_rays_length
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var rays = get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func adjust_rays_length(length: float) -> void:
	print("this")
	ray_size = length
	var rays = get_children()
	for ray in rays:
		ray.cast_to = Vector3(0,0,1) * length

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
