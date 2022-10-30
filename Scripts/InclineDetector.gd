extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var distance
var collider_cyl
#var space_free # flag for whether the space above a small ledge is free to be "teleported" to
var rays_bottom
var rays_top
#var acceleration
# Called when the node enters the scene tree for the first time.
func _ready():
	distance = 1
	collider_cyl = get_node("Cylinder")
	rays_bottom = get_node("BottomRays")
	rays_top = get_node("Top Rays")

func update_ray_cast_tos(distance: float) -> void:
	for rays in [rays_bottom, rays_top]:
		rays.update_ray_cast_tos(distance)
	
func force_update_rays() -> void:
	print_debug("Updating Rays...")
	for rays in [rays_bottom, rays_top]:
		rays.force_update_rays()
#func _on_Player_speed_changed(velocity, delta, acceleration):
#	#var horizontal_vel = Vector3(velocity.x, 0, velocity.z) * acceleration * 1.3 * delta
#	var horizontal_vel = Vector3(velocity.x, 0, velocity.z)
#	if horizontal_vel.length() != 0:
#		ray.cast_to = horizontal_vel
#		print("Cast to: %s" % ray.cast_to)

func should_relocate() -> bool:
	return not rays_bottom.is_colliding() and not rays_top.is_colliding() and not get_overlapping_bodies()


func _on_Player_speed_changed(velocity, delta, acceleration):

	var horizontal_vel = Vector3(velocity.x, 0, velocity.z) * 1.3 * delta
	#print("Acceleration: %s" % acceleration)
	if horizontal_vel.length() != 0:
		look_at_from_position(global_translation, global_translation + horizontal_vel.normalized(), Vector3.UP)

	distance = 2*(horizontal_vel).length()
	#print("Distance: %s" %distance)
	#print("Forward: %s" % -transform.basis.z, " velocity: %s", horizontal_vel.normalized())
	#print("Detec position: %s" % global_translation, "Player position: %s" % get_parent().global_translation)
	#print(transform.basis.z)
	#print("Minimum: %s" % min(-1 * distance * abs(acceleration), -0.4))
	var dist = 1.4 + horizontal_vel.length()
	collider_cyl.translation.z = min(-1 * distance, -0.4)
	update_ray_cast_tos(dist)
	
	#print("Global translation of collider: %s" % collider_cyl.global_translation, "Global translation of detector: %s" % global_translation)
		
	
