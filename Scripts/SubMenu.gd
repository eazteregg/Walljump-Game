extends Control

onready var buttons = get_node("Buttons")
var active = false
# Called when the node enters the scene tree for the first time.
func _ready():
	buttons.visible = false
	for child in buttons.get_children():
		if child is BaseButton:
			child.disabled = true

func _unhandled_input(event):
	
	if active and event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		go_back()
		
		

func go_back():
	disable()
	if get_parent().has_method("enable"):
			get_parent().enable()
	elif get_parent().has_method("close_menus"):
		get_parent().close_menus()
			
			
func enable():
	active = true
	buttons.visible = true
	for child in buttons.get_children():
		if child is BaseButton:
			child.disabled = false
		elif child.has_method("enable"):
			child.enable()
		
		
func disable():
	active = false
	buttons.visible = false
	for child in buttons.get_children():
		if child is BaseButton:
			child.disabled = true
		elif child.has_method("disable"):
			child.disable()


func _on_BackButton_button_up():
	go_back()
		
