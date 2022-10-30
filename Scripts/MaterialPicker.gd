extends Spatial
tool

export (Material) var new_material : Resource setget set_material_in_children




# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func set_material_in_children(material):
	new_material = material
	for child in get_children():
		if child is MeshInstance and child.mesh.resource_local_to_scene:
				child.set_surface_material(0, material)
		elif child.has_method("set_material_in_children"):
				child.set_material_in_children(material)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
