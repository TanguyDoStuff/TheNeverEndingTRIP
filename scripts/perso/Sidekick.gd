extends CharacterBody2D

################################## PARAMETERS ##################################

const SPEED = 20.0

################################## VARIABLES ###################################

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var player = get_parent().get_parent().get_node("Player/PlayerModel")

#################################### ACTION ####################################

func _ready():
	$Sprite.play("idle_book")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if Global.sidekickFollowPlayer == true:
		position += (player.position - position) / SPEED
		
		if (player.position.x - position.x) > 5 or (player.position.x - position.x) < -5:
			turnAround()
			$Sprite.play("walk")
		else:
			$Sprite.play("idle_follow")
			
		if position.x <= -14: #Little fix so that they don't walk against the left wall lmao
			$Sprite.play("idle_follow")
	
	move_and_slide()

func turnAround():
	if (player.position.x - position.x) > 0:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true
