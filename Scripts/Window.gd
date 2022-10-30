extends StaticBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var available: bool
onready var break_effect = $BreakEffect
var mesh : MeshInstance
# Called when the node enters the scene tree for the first time.
func _ready():
	available = true
	for child in get_children():
		if child is MeshInstance:
			mesh = child
	#print(mesh)

func destroy(velocity:Vector2) -> void:
	print_debug("Destroying window...")
	$CollisionShape.disabled = true
	mesh.visible = false
	break_effect.visible = true
	break_effect.start_animation(velocity)
	available = false

func on_break_animation_finished(anim_name):
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous fra
