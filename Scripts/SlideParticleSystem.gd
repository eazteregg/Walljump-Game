extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var player = get_parent()
onready var ground_particles = get_node("SlideParticleSystemGround")
onready var air_particles = get_node("SlideParticleSystemAir")
var gradient = Gradient.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	
	gradient.add_point(0, Color(255,255,255,255))
	gradient.add_point(100,  Color(255,0,0,255))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var hori_veloc = player.get_horizontal_velocity(player.velocity).length()
	var crouched = player.crouch_modifier == 0.5
	var on_floor = player.on_floor_custom
	if hori_veloc > 10.0 and crouched:
		if on_floor:
			ground_particles.initial_velocity = lerp(0.2, 5.0, smoothstep(10.0, 60.0, hori_veloc))
			ground_particles.emitting = true
			air_particles.emitting = false
		else:
			air_particles.scale_amount = lerp(0.2, 3, smoothstep(30.0, 80.0,hori_veloc))
			air_particles.color = gradient.interpolate(lerp(0, 100, smoothstep(30.0, 80, hori_veloc)))
			air_particles.emitting = true
			ground_particles.emitting = false
	else:
		ground_particles.emitting = false
		air_particles.emitting = false
		
	
