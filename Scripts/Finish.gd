extends Spatial

onready var label = get_node("FinishScreen/Label")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	get_node("FinishScreen").visible = true
	var time = body.get_node("HUD").get_time()
	label.text = "Congratulations!! \n you've reached the end in %s s" % time
	get_tree().paused = true
	
	
