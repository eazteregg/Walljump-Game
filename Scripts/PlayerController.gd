extends KinematicBody

signal speed_changed(velocity, delta, acceleration)

export var max_movement_speed = 13
export var min_movement_speed = 9
export var acceleration = 50
export var air_acceleration = 20
export var jump_impulse = 28
export var w_jump_impulse = 26
export var fall_acceleration = 75
export var mouse_sensitivity = 1

#export var air_influence = 7
export var max_air_speed = 20
export var min_air_speed = 20
export var wall_bounce = 20
export var jump_bounce = 5
export var max_walljumps = 3
export var deceleration = 4
export var max_incline = 0.4
export var walljump_distance = 1.04 # Determines how far one can be away from a wall to jump


var velocity = Vector3.ZERO
var wall_neighbours = []
var speed = min_movement_speed
var air_speed = min_air_speed
var walljumps = 0
var air_trajectory = Vector3.ZERO
var incline_move_offset # stores the distance by which the character checks for inclines 
var incline_detector_radius
var on_chain = false
var wall_ban_list = []
var backup_velocity = Vector3.ZERO
var moved_without_loss
var crouch_modifier
var respawn_point
var on_floor_custom

onready var ledge_detector = get_node("LedgeDetector")
onready var debug_ray = get_node("DebugRay")
onready var pull_up_tween = get_node("PullUpTween")
onready var pull_up_checker = get_node("PullUpChecker")
onready var incline_detector = get_node("InclineDetector")
onready var incline_detector_ray = incline_detector.get_child(0)
onready var collider = get_node("NormalCollider")
onready var collider_radius = collider.shape.radius
onready var vault_tween = get_node("VaultTween")
onready var window_smasher = get_node("WindowSmasher")
onready var walljump_ray_container = get_node("WallDetectorRays")
onready var walljump_rays = walljump_ray_container.get_children()
onready var onFloor_checker = get_node("onFloorChecker")
onready var jump_audio = get_node("JumpSounds")
onready var anim_player = get_node("Pivot/CharacterModel")
# Called when the node enters the scene tree for the first time.


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Make mouse invis and lock to center
	walljump_ray_container.adjust_rays_length(walljump_distance)
	


func _input(event):
	
	if event is InputEventMouseMotion: 
		rotation_degrees.y -= event.relative.x * mouse_sensitivity / 10 # rotate player horizontally
		#rotate only camera vertically
		$Camera.rotation_degrees.x = clamp($Camera.rotation_degrees.x - event.relative.y * mouse_sensitivity / 10, -90, 90)
	elif event.is_action_pressed("reset"):
		respawn()
		
		
func _physics_process(delta):
	
	var direction = Vector3.ZERO
	var forward = transform.basis.z
	var right = transform.basis.x
	var down = transform.basis.y * -1.0
	var dir_modifier : float

	if velocity.length() < 0.1:
		velocity = Vector3.ZERO
	# emit signal to HUD
	
	
	# process inputs
	if Input.is_action_pressed("move_right"):
		direction += right
	if Input.is_action_pressed("move_left"):
		direction -= right
	if Input.is_action_pressed("move_backward"):
		direction += forward
	if Input.is_action_pressed("move_forward"):
		direction -= forward
	if Input.is_action_pressed("crouch"):
		crouch_modifier = 0.5
		scale = Vector3(1.0, 0.7, 1.0)
	else:
		if not test_move(transform, Vector3.UP):
			crouch_modifier = 1.0
			scale = Vector3(1.0, 1.0, 1.0)
	if Input.is_action_just_released("jump"):
		Input.action_release("jump_in_air")
	
		
	direction = direction.normalized()
	var hori_velocity = Vector2(velocity.x, velocity.z)
	
	if is_on_floor():
		
		
		# reset walljumps
		walljumps = 0
		if Input.is_action_pressed("jump_in_air"):
			Input.action_release("jump_in_air")
			
		# if directional buttons are being pressed, check their directionality, and depending on it, execute different behavior				
		var dir_dot = hori_velocity.normalized().dot(get_horizontal_velocity(direction))
			
		# -----------------------moving on the ground --------------------------------------
		
		# if speed is above max_movement speed, let it peter out in different ways-- can only be achieved by jumping
			
		if round(hori_velocity.length()) > max_movement_speed * crouch_modifier:
			#print("is over max movement speed")
			if crouch_modifier == 0.5:
				
				var exponent = lerp(1, 2.5, smoothstep(1.7* max_movement_speed * crouch_modifier, 3 * max_movement_speed, hori_velocity.length()))				
				var speed_kept = lerp(hori_velocity.length(), max_movement_speed * crouch_modifier, delta * deceleration * (pow(crouch_modifier, exponent)))
				var new_vel = (hori_velocity + get_horizontal_velocity(direction)).normalized() * speed_kept
				velocity.x = new_vel.x if abs(new_vel.x) < abs(new_vel.x + direction.x * acceleration * delta) else new_vel.x + direction.x * acceleration * delta
				velocity.z = new_vel.y if abs(new_vel.y) < abs(new_vel.y + direction.z * acceleration * delta) else new_vel.y + direction.z * acceleration * delta
				
			elif direction.length() == 0:
				
				var speed_kept = lerp(hori_velocity.length(), 0, (delta * deceleration * 2))
				velocity.x = hori_velocity.normalized().x * speed_kept
				velocity.z = hori_velocity.normalized().y * speed_kept
			else:	
				if dir_dot >= 0:
					dir_modifier = 1
				else:
					dir_modifier = 3
				
				var speed_kept = lerp(hori_velocity.length(), 0, (delta * deceleration * dir_modifier))
				velocity.x = hori_velocity.normalized().x * speed_kept +  direction.x * acceleration * delta * crouch_modifier * dir_modifier
				velocity.z = hori_velocity.normalized().y * speed_kept +  direction.z * acceleration * delta * crouch_modifier * dir_modifier

			# if speed is below max_movement_speed, check various other things again
		else:
			
			# if the player isn't pressing any directional buttons, let the speed peter out
			if direction.length() == 0:
		
				var speed_kept = lerp(hori_velocity.length(), 0, (delta * deceleration * 2))
				var new_vel = hori_velocity.normalized()
				velocity.x = new_vel.x * speed_kept
				velocity.z = new_vel.y * speed_kept
			

			else:
				# first set the directional modifier, since if the player wants to move backwards, no momentum will be conserved
				if dir_dot >= 0:
					dir_modifier = 1.0
				else:
					dir_modifier = 3.0
				
				# then check whether accelerating in their newly chosen direction would put the player above max movement speed
				var new_vel = Vector2(velocity.x + direction.x * acceleration * delta * crouch_modifier * dir_modifier, velocity.z + direction.z * acceleration * delta * crouch_modifier)
				if new_vel.length() >= max_movement_speed * crouch_modifier:
					
					# if so, move them along with max movement speed instead
					
					velocity.x = direction.x * max_movement_speed * crouch_modifier
					velocity.z = direction.z * max_movement_speed * crouch_modifier
					
				else:
					# else accelerate them depending on their directional modifier (dir_modifier)
					
					velocity.x += direction.x * acceleration * delta * crouch_modifier * dir_modifier
					velocity.z += direction.z * acceleration * delta * crouch_modifier * dir_modifier
					
				
		emit_signal("speed_changed",velocity, delta, acceleration)
		
		# jumping on the ground
		if Input.is_action_pressed("jump") and not vault_tween.is_active():
			jump_audio.reset_foot_sounds_position()
			jump_audio.play_random_sound_for_x_seconds()
			anim_player.switch_jump_anim()
			
			var cross_prod = abs(Vector2(forward.x, forward.z).cross(get_horizontal_velocity(velocity).normalized()))
			
			var lerped_cross_prod = lerp(1, 1, cross_prod)
			var vel_normalized = velocity.normalized()
			velocity.y += jump_impulse
			velocity.x += vel_normalized.x * jump_bounce * lerped_cross_prod
			velocity.z += vel_normalized.z * jump_bounce * lerped_cross_prod
			Input.action_release("crouch")
		
		
		# check for small bumps in the ground and move over them
		elif test_move(transform, Vector3(velocity.x, 0, velocity.z) * 1.3 * delta, true):
			incline_detector.force_update_rays()
			if incline_detector.should_relocate():
				print_debug("Relocating ", "Velocity: %s" % Vector3(velocity.x, 0, velocity.z))
				var pseudo_collision = move_and_collide(Vector3(velocity.x, 0, velocity.z) * 1.3 * delta, true, true,true)
				if pseudo_collision.get_angle() >= 0.785398:

					while move_and_collide(Vector3(velocity.x, 0, velocity.z) * 1.3 * delta, true, true, true):
						translate_object_local(Vector3.UP * 0.1)
		
		if Input.is_action_pressed("jump"):
			Input.action_release("jump")
		
	#  if not jumping 
	# ---------------------------------- detecting a ledge and pulling up ----------------------------------
	elif ledge_detector.detect_ledge() and not pull_up_checker.get_overlapping_bodies() and (not pull_up_tween.is_active()) and not on_floor_custom:
		if Input.is_action_pressed("move_forward"):
			pull_up_tween.interpolate_property(self, "translation", global_translation, global_translation + Vector3.UP *3 - transform.basis.z * 2, 1.0)
			pull_up_tween.start()
		
	#  -------------------------------- movement in the air --------------------------------------
	elif not pull_up_tween.is_active():
		# needs a new action to force players to press jump again in the air to wall jump
		if Input.is_action_just_pressed("jump"):
			Input.action_press("jump_in_air")
			print("Hit jump again...")
			
		#----------------------- walljumping -----------------------------
		var collisions = get_collisions_from_walljump_rays()
		if Input.is_action_pressed("jump_in_air") and collisions and walljumps < max_walljumps and not on_floor_custom:
			var closest_coll = collisions[0] if len(collisions) == 1 else get_closest_collision(collisions, direction)
			
			if moved_without_loss:
				
				velocity = backup_velocity
			elif backup_velocity != Vector3.ZERO:
				pass
				
			print_debug("Wall jumping")
			
			velocity.y = w_jump_impulse
			walljumps +=1
			Input.action_release("jump_in_air")
			print("Jump in air released")
			jump_audio.adjust_foot_sounds_position(closest_coll[0])
			jump_audio.play_random_sound_for_x_seconds()
			anim_player.switch_jump_anim()
			
			var bounce = velocity.bounce(closest_coll[1])
			var new_normal = get_horizontal_velocity(closest_coll[1]).normalized()
			var directional_influence = (new_normal + 1/3 * Vector2(forward.x, forward.z)).normalized()
			velocity.x = bounce.x + directional_influence.x * wall_bounce
			velocity.z = bounce.z + directional_influence.y * wall_bounce 
			emit_signal("speed_changed", velocity, delta, wall_bounce)
			
		# influencing trajectory in the air
		else:
			#when the player pushes in the direction opposite to the travelling direction, slowdown should be faster
			var modifier : float
			
			if hori_velocity.normalized().dot(get_horizontal_velocity(direction)) <= 0:
				modifier = 2.0
			else:
				var cross_prod = abs(Vector2(direction.x, direction.z).cross(get_horizontal_velocity(velocity).normalized()))
				modifier = lerp(0.5, 1.0, cross_prod)
			
				
			velocity.x = velocity.x + direction.x * air_acceleration * delta * modifier
			velocity.z = velocity.z + direction.z * air_acceleration * delta * modifier
			emit_signal("speed_changed", velocity, delta, air_speed)
			
	# applying gravity
	velocity.y -= fall_acceleration * delta
	
	# move if one is not pulling oneself up a ledge or vaulting
	if not pull_up_tween.is_active() and not vault_tween.is_active():
		var test_coll = move_and_collide(velocity * delta, true, true, true)
		moved_without_loss = false
		if test_coll and test_coll.collider.is_in_group("windows") and window_smasher != null:
			window_smasher.smash(test_coll.collider, get_horizontal_velocity(velocity))
			
		
		#if not pull_up_checker.get_overlapping_bodies() and velocity.y > 2.0 and test_coll:
		# check if vaulting, gotta run through the whole tree to find absolut scale of object vaulted over			
				
		elif velocity.y > 3.0 and get_horizontal_velocity(velocity).length() > 30.0 and test_coll and walljumps == 0:
		# if the player is above the top-most point of the colliding object, only then vault over it
			var global_height = get_abs_height_of_obj(test_coll.collider)
			
			
			if (global_height - global_translation.y < velocity.y) and not pull_up_checker.get_overlapping_bodies():
				
				backup_velocity = move_and_slide(velocity, Vector3.UP, 15)
				moved_without_loss = true
		
		if not moved_without_loss:
			backup_velocity = velocity
			velocity = move_and_slide(velocity, Vector3.UP, false, 4)
			
	on_floor_custom = on_floor()
	if pull_up_tween.is_active():
		velocity = Vector3.ZERO


#-----------------------------------------------------------------------------------
#-------------------------------------- Utils --------------------------------------
#-----------------------------------------------------------------------------------


func get_objs_on_path(path: String) -> Array:
	var objs = []
	var obj_names = Array(path.split("/"))
	for i in range(1, obj_names.size()):
		var curr_path = "/".join(obj_names.slice(0,i))
		objs.append(get_node(curr_path))
	
	return objs
	
	
func _check_if_collider_in_collisions(ray: RayCast):
		for i in range(get_slide_count()):
			if ray.get_collider() == get_slide_collision(i).collider:
				return true
		return false
	
	
func get_collisions_from_walljump_rays() -> Array:
	var hori_veloc = get_horizontal_velocity(velocity).length()
	var collisions = []
	for ray in walljump_rays:
		if ray.is_colliding():
			if ray.get_collider().get_parent().is_in_group("no_walljump"):
				continue
			# check whether the player's speed is below a certain threshold or alternatively, whether the wall has been touched thus ensuring clamped bounce velocity 
			if hori_veloc < max_movement_speed / 5 or get_slide_count() > 0 :
				collisions.append([ray.get_collision_point(), ray.get_collision_normal()])
				
				
	return collisions
	
	
func get_closest_collision(collisions: Array, direction : Vector3) -> Array:
	var nearest_coll = null
	var distance_to_nearest = 0
	var angle_to_nearest = 0
	for coll in collisions:
		
		if not nearest_coll:
			if PI/4  < coll[1].angle_to(Vector3.UP) and coll[1].angle_to(Vector3.UP) < (3*PI/4):
				nearest_coll = coll
				distance_to_nearest = get_global_translation().distance_to(coll[0])
				angle_to_nearest = (coll[0] - global_translation).dot(direction)
			else:
				print("Wall has wrong angle")
		else:
			
			if PI/4  < coll[1].angle_to(Vector3.UP) and coll[1].angle_to(Vector3.UP) < (3*PI/4):
				if direction == Vector3.ZERO:
					var distance_to_next = global_translation.distance_to(coll[0])
					if distance_to_nearest > distance_to_next:
						nearest_coll = coll
						distance_to_nearest = distance_to_next
				else:
					var angle_to_next = (coll[0] - global_translation).dot(direction)
					if angle_to_nearest < angle_to_next:
						nearest_coll = coll
						angle_to_nearest = angle_to_next
	return nearest_coll
		
	
func get_abs_height_of_obj(obj: Spatial) -> float:
	var path_objs = get_objs_on_path(obj.get_path())
	var height = 1
			
	for i in range(path_objs.size()):
		var obj_in_path = path_objs[i]
		if obj_in_path is Spatial:
			height *= obj.scale.y
			
		# if it's the last object, also check its mesh
		# and multiply height by the mesh scale as well
		if i == path_objs.size()-1:
			for child in path_objs[i].get_children(): 
				if child is MeshInstance:
					height *= child.scale.y
	
	return obj.global_translation.y + height
	
	
func get_closest_wall(wallneighbours: Array, direction: Vector3) -> Vector3:
	var nearest_coll = null
	var distance_to_nearest = 0
	var angle_to_nearest = 0
	for i in range(len(wallneighbours)):
		if not nearest_coll:
			var possible_coll = move_and_collide(wall_neighbours[0].global_translation - translation, true, true, true)
			if PI/4  < possible_coll.normal.angle_to(Vector3.UP) and possible_coll.normal.angle_to(Vector3.UP) < (3*PI/4):
				nearest_coll = possible_coll
				distance_to_nearest = get_global_translation().distance_to(nearest_coll.position)
				angle_to_nearest = (nearest_coll.position - global_translation).dot(direction)
			else:
				print("Wall has wrong angle")
		else:
			
			var next_coll =  move_and_collide(wall_neighbours[i].global_translation - translation, true, true, true)
			if PI/4  < next_coll.normal.angle_to(Vector3.UP) and next_coll.normal.angle_to(Vector3.UP) < (3*PI/4):
				if direction == Vector3.ZERO:
					var distance_to_next = global_translation.distance_to(next_coll.position)
					if distance_to_nearest > distance_to_next:
						nearest_coll = next_coll
						distance_to_nearest = distance_to_next
				else:
					var angle_to_next = (next_coll.position - global_translation).dot(direction)
					
					if angle_to_nearest < angle_to_next:
						nearest_coll = next_coll
						angle_to_nearest = angle_to_next
				
	return nearest_coll
	
	
func get_horizontal_velocity(vec: Vector3) -> Vector2:
	return Vector2(vec[0], vec[2])


func pos_or_neg(i:int) -> int:
	return -1 if i<0 else 1
	
	
func get_colliders_on_body(body) -> Array:
	var colliders = []
	for child in body.get_children():
		if child is CollisionShape:
			colliders.append(child)
	return colliders


func respawn():
	velocity = Vector3.ZERO
	if respawn_point == null:
		get_tree().reload_current_scene()
	else:
		global_translation = respawn_point

func on_floor() -> bool:
	return onFloor_checker.is_colliding()

func _on_PullUpTween_tween_completed(object, key) -> void:
	Input.action_release("jump")


func _on_InclineDetector_body_entered(body):
	pass
	
	
func _on_InclineDetector_body_exited(body):
	pass


func _on_PullUpTween_tween_started(object, key):
	velocity = Vector3.ZERO
	jump_audio.play_pull_up_sound()

func _on_SpecialDetector_area_entered(area):
	print(area)
	if area.is_in_group("spawns"):
		print_debug("Spawn entered")
		respawn_point = area.global_translation
	elif area.get_collision_layer_bit(5):
		print("Death Zone entered")
		respawn()
	else:
		print_debug("Chain entered...")
		on_chain = true	


func _on_VelocityBufferTimer_timeout():
	backup_velocity = Vector3.ZERO
