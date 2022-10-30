extends RayCast


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	cast_to = get_node("/root/TestChamber/Skyscraper/StaticBody").global_translation - translation
	print(cast_to)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
