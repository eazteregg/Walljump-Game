extends Spatial
tool

export var text: String setget set_text
onready var panel = get_node("PopupPanel")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
		

# Called when the node enters the scene tree for the first time.
func _ready():
	panel.text = text

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	
	panel.show()
	
func set_text(new_text: String) -> void:
	text = new_text
	


func _on_Area_body_exited(body):
	panel.hide()
