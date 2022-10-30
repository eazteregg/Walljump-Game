extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func smash(collider: StaticBody, velocity: Vector2) -> void:
	collider.destroy(velocity)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	for i in range(parent.get_slide_count()):
		#print_debug("Window Smasher process")
		var collider = parent.get_slide_collision(i).collider
		
		if collider != null and collider.is_inside_tree() and collider.is_in_group("windows"):
			smash(collider, parent.get_horizontal_velocity(parent.backup_velocity))
			parent.velocity = parent.backup_velocity
			break
