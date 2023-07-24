extends CharacterBody2D

################################## PARAMETERS ##################################

const cameraSpeed = 10	#The speed of the camera
const cameraY = -100.0 #The Y axis of the camera

################################## VARIABLES ###################################

@onready var CountdownTimer = $Camera2D/Countdown/Label/Timer
@onready var victim = get_parent().get_parent().get_node("Victim").global_transform.origin

#################################### ACTION ####################################

func _physics_process(_delta):
	var from = global_transform.origin #Get the current position of the camera
	var to = get_parent().get_child(0).global_transform.origin #Get the position of the player
	var y = transform.y + Vector2(0,cameraY)
	
	if CountdownTimer.is_stopped():
		set_velocity((victim - from + y) * cameraSpeed)
	else:
		set_velocity((to - from + y) * cameraSpeed) #Calculate and set the velocity of the camera
	
	move_and_slide() #Move the camera
