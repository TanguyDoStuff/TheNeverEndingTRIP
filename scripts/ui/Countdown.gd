extends Label

################################## VARIABLES ###################################

var minutes = 0
var seconds = 0

#################################### ACTION ####################################

func _ready():
	get_parent().get_child(1).play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
		
	seconds = int($Timer.time_left)
	minutes = 0
	
	while seconds >= 60:
		minutes = minutes + 1
		seconds = seconds - 60
	
	if seconds < 10:
		set_text(str(minutes,":0",seconds))
	else:
		set_text(str(minutes,":",seconds))

func _on_timer_timeout():
	get_parent().get_child(1).pause()
	$Timer.stop()
