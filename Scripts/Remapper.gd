extends Control

tool

export var button_text: String setget set_button_text

onready var button = get_node("ControlsButton")
onready var label = get_node("Label")



var action : String
var curr_event : InputEvent
var awaiting_input = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _ready():
	action = button_text
	curr_event = InputMap.get_action_list(action)[0]
	set_label_text(curr_event.scancode)
	
func _input(event):
	
	if awaiting_input:
		var code = null
		
		if event is InputEventKey:
			code = event.scancode
			
		elif event.is_action_pressed("ui_cancel"):
			awaiting_input = false 
			set_button_text(action)
			
		if code != null:
			
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)
			set_label_text(code)
			awaiting_input = false
			set_button_text(action)

func set_button_text(new_text: String) -> void:
	
	if Engine.editor_hint:
		print(new_text)
		print(ProjectSettings.has_setting("input/" + new_text))
		if ProjectSettings.has_setting("input/" + new_text):
			button_text = new_text
			get_node("ControlsButton").text = button_text
			print(ProjectSettings.get_setting("input/" + new_text))
			curr_event = ProjectSettings.get_setting("input/" + new_text)["events"][0]
			set_label_text(curr_event.scancode)
			action = button_text
		else:
		
			print("Sorry, the action you've selected is not defined.")
	else:
		button_text = new_text
		get_node("ControlsButton").text = button_text

func set_label_text(new_scancode: int) -> void:
	label.text = OS.get_scancode_string(new_scancode)

func enable():
	for child in get_children():
		if child is BaseButton:
			child.disabled = false

func disable():

	for child in get_children():
		if child is BaseButton:
			child.disabled = true
		


func _on_ControlsButton_button_up():
	set_button_text("Press any key/ press Esc to cancel")
	awaiting_input = true
