extends Node2D

################################## VARIABLES ###################################

var scene: String = Global.loadingScene
var scene_load_status = 0 #The status of the scene (is it loaded or not?)

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("default")
	ResourceLoader.load_threaded_request(scene) #Start loading the scene

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	scene_load_status = ResourceLoader.load_threaded_get_status(scene) #Check if the scene finished loading
	
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED: #If the scene finished loading
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(scene)) #Load the scene
		queue_free() #Free the memory
