extends Node2D

#################################### ACTION ####################################

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.reset()
	$Buttons/Start.grab_focus()

func _on_start_pressed():
	Global.loadingScene = "res://scenes/niveau/Intro.tscn" #Load train
	get_tree().change_scene_to_file("res://scenes/niveau/Loading.tscn") #Switch to the loading screen
