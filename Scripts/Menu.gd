extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ChamberOne_button_up():
	get_tree().change_scene("res://TestChamber.tscn")


func _on_ChamberTwo_button_up():
	get_tree().change_scene("res://Level-Two.tscn")


func _on_TerrainScene_button_up():
	get_tree().change_scene("res://TerrainScene.tscn")


func _on_Tutorial_button_up():
	get_tree().change_scene("res://Tutorial.tscn")
