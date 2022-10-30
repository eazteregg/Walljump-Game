extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var anim_player = get_node("AnimationPlayer")
onready var player = get_parent().get_parent()
onready var max_movement_speed = player.max_movement_speed
onready var pull_up_tween = player.get_node("PullUpTween")

var jump_animation = "JumpAnimRight"
# Called when the node enters the scene tree for the first time.

func _ready():
	pass
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	var hori_velocity = player.get_horizontal_velocity(player.velocity).length()
	var y_velocity = player.velocity.y
	var crouch = player.crouch_modifier == 0.5
	
	if player.is_on_floor() or player.on_floor_custom:
		
		if hori_velocity > 0.01:
			if not crouch:
				anim_player.play("WalkingAnim", -1, lerp(1.0, 2.0, smoothstep(0, max_movement_speed, hori_velocity)))
			else:
				anim_player.play("SlideAnim")
		else:
			anim_player.play("IdleAnim", 0.3)
		
	elif y_velocity < 0.0:
		if not crouch:
			anim_player.play("FallingAnim", -1)
		else:
			anim_player.play("SlideAnim")
			
	elif y_velocity > 0:
		if  not crouch:
			anim_player.play(jump_animation, 0.3)
		else:
			anim_player.play("SlideAnim")
			
	elif pull_up_tween.is_active():
		anim_player.play("PullUpAnim", -1, 1.0)
			
		

func switch_jump_anim():
	if jump_animation == "JumpAnimRight":
		jump_animation = "JumpAnimLeft"
	else:
		jump_animation = "JumpAnimRight"
