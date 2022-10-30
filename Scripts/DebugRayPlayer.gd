extends RayCast


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var incline = get_parent().get_node("InclineDetector")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _physics_process(delta):
	cast_to = -incline.transform.basis.z


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
