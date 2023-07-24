extends Node2D

#################################### ACTION ####################################

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused == false:
			$Button/Resume.grab_focus()
			pauseShow()
		else:
			pauseHide()
	
	if Input.is_action_just_pressed("cancel"):
		pauseHide()

################################### FUNCTIONS ##################################

func pauseShow():
	get_tree().paused = true
	show()
	Global.isPauseMenuOn = true
	
func pauseHide():
	get_tree().paused = false
	hide()
	Global.isPauseMenuOn = false

func _on_resume_pressed():
	pauseHide()

func _on_quit_pressed():
	get_tree().paused = false
	Global.isPauseMenuOn = false
	Global.loadingScene = "res://scenes/niveau/MenuPrincipal.tscn" #Load main menu
	get_tree().change_scene_to_file("res://scenes/niveau/Loading.tscn") #Switch to the loading screen
