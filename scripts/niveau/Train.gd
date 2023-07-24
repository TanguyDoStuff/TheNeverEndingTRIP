extends Node2D


func _ready():
	$BlackScreen.hide()
	$Cans.texture = load("res://assets/char/Cans/cans0000.png")
	$Cage.texture = load("res://assets/char/Frog/cage0000.png")
	$PiggyBack.hide()
	$Frog.hide()

func _process(_delta):
	if $Frog.frame >= 97:
		$Frog.hide()
