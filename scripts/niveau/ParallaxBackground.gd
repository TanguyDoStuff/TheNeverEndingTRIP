extends ParallaxBackground

################################## PARAMETERS ##################################

const SPEED = 300

################################## VARIABLES ###################################

var offset_scroll = 0

#################################### ACTION ####################################

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	offset_scroll += SPEED * delta
	
	set_scroll_offset(Vector2(-offset_scroll, 0))
