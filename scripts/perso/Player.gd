extends CharacterBody2D

################################## PARAMETERS ##################################

const walkSPEED = 600.0
const runSPEED = 1000.0

################################## VARIABLES ###################################

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#################################### ACTION ####################################

func _physics_process(delta):	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("movementLeft", "movementRight")
	if Input.is_action_pressed("cancel"):
		if direction:
			velocity.x = direction * runSPEED
			if Global.isPlayerStopMove == false:
				turnAround()
				$Sprite.play("Walk")
		else:
			velocity.x = move_toward(velocity.x, 0, runSPEED)
			$Sprite.play("Idle")
	else:
		if direction:
			velocity.x = direction * walkSPEED
			if Global.isPlayerStopMove == false:
				turnAround()
				$Sprite.play("Walk")
		else:
			velocity.x = move_toward(velocity.x, 0, walkSPEED)
			$Sprite.play("Idle")

	if Global.isPlayerStopMove == false:
		move_and_slide()
		
		
	if Input.is_action_just_pressed("movementRight") and Global.isPlayerStopMove == false:
		$Sprite.flip_h = false

func turnAround():
	if velocity.x > 0:
		$Sprite.flip_h = false
		$InteractZone.position.x = 102
	elif velocity.x < 0:
		$Sprite.flip_h = true
		$InteractZone.position.x = -60
