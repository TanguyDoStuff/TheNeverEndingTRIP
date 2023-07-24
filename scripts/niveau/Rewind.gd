extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.reset()
	$Hourglass.play_backwards()
	$AnimationPlayer.play("Rewind")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if $Hourglass.frame == 0:
		Global.loadingScene = "res://scenes/niveau/Train.tscn" #Load train
		get_tree().change_scene_to_file("res://scenes/niveau/Loading.tscn") #Switch to the loading screen
