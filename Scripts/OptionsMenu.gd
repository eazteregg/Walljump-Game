extends Node2D

onready var top_level_menu = get_node("TopLevelMenu")
onready var control_menu = get_node("TopLevelMenu/SubLevelMenu")
var menu_open = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _unhandled_input(event):
	
	if event.is_action_pressed("ui_cancel") and not menu_open:
		print("opening menu")
		menu_open = true
		top_level_menu.enable()
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED) # Make mouse invis and lock to center
		get_tree().paused = true

func close_menus():
	print("closing menu")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	menu_open = false
	get_tree().paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_ControlsButton_button_up():
	print("now")
	top_level_menu.disable()
	control_menu.enable()


func _on_QuitButton_button_up():
	get_tree().quit()


func _on_RestartButton_button_up():
	close_menus()
	get_tree().reload_current_scene()
