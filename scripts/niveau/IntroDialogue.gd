extends Node2D

################################## PARAMETERS ##################################

@export var NPC_id = "placeholder"

const textSpeedSlow = 0.3	#The speed of the text appearing
const textSpeedFast = 1	#The speed of the text appearing while pressing A

################################## VARIABLES ###################################

var isDialogueOn = false #Is someone talking?
var hasFollowing = false #Does the text have a following message?
var followingDialogue = "" #What dialogue does it follow?
var displayedDialogue = "" #What dialogue is currently displayed?
var isTextAppearing = false
var visibleCharacters = 0.0
var frogloverJumped = false #Has froglover finished the jumping animation?
var introFinish = false #Has the intro finished?

@onready var DialogueBox = $dialogueBox
@onready var DialogueText = $dialogueBox/Text
@onready var DialogueAnimation = $dialogueBox/AnimationPlayer
@onready var DialoguePortraitSprite = $dialogueBox/Portrait

@onready var soundeffectSelect = $dialogueBox/Answers/Select
@onready var soundeffectNext = $dialogueBox/Next

#################################### ACTION #########################

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	dialogueDetect()
	textSlowlyAppear()
	
	if introFinish == true and isDialogueOn == false:
		isDialogueOn = false
		DialogueAnimation.play("disappear")
		await DialogueAnimation.animation_finished
		DialogueBox.hide()
		
		Global.loadingScene = "res://scenes/niveau/Train.tscn" #Load train
		get_tree().change_scene_to_file("res://scenes/niveau/Loading.tscn") #Switch to the loading screen
	
func dialogueDetect():
	if $Timer.time_left == 0 and isDialogueOn == false and introFinish == false:
		DialogueText.visible_ratio = 0					
		setDialogues() #Set the dialogues
		DialogueAnimation.play("appear")
		DialogueBox.show()
		isDialogueOn = true
		return 0
	if isDialogueOn == true and isTextAppearing == false and (Input.is_action_just_pressed("accept") or Input.is_action_just_pressed("cancel")):
		if hasFollowing == true:
			soundeffectNext.play()
			DialogueText.visible_ratio = 0
			displayDialogues(followingDialogue)
		else:
			isDialogueOn = false
			soundeffectNext.play()
			DialogueAnimation.play("disappear")
			await DialogueAnimation.animation_finished
			DialogueBox.hide()

func textSlowlyAppear():
	if DialogueText.visible_ratio < 1:
		isTextAppearing = true
		if Input.is_action_just_pressed("cancel"):
			DialogueText.visible_ratio = 1
			isTextAppearing = false
		else:
			if Input.is_action_pressed("accept"):
				visibleCharacters = visibleCharacters + textSpeedFast
				if visibleCharacters >= 1:
					DialogueText.visible_characters = DialogueText.visible_characters + 1
					visibleCharacters = visibleCharacters - 1
			else:
				visibleCharacters = visibleCharacters + textSpeedSlow
				if visibleCharacters >= 1:
					DialogueText.visible_characters = DialogueText.visible_characters + 1
					visibleCharacters = visibleCharacters - 1
	else:
		isTextAppearing = false

func setPortrait(portrait):
	var DialoguePortrait = str("res://assets/portrait/", portrait, ".png") #Set the dialogue portrait
	if ResourceLoader.exists(DialoguePortrait): #If the portrait for the character exist
		DialoguePortraitSprite.show()
		DialoguePortraitSprite.texture = load(DialoguePortrait) #Apply it
	else:
		DialoguePortraitSprite.hide() #Hide the sprite

func setDialogues():
	match NPC_id:
		"intro":
			displayDialogues("intro1")

func displayDialogues(currentDialogue):
	displayedDialogue = currentDialogue
	match currentDialogue:
		"intro1":
			hasFollowing = true
			followingDialogue = "intro2"
			setPortrait("blank")
			DialogueText.text = "[i][color=Darkblue]I am cursed."
		"intro2":
			followingDialogue = "intro3"
			DialogueText.text = "[i][color=Darkblue]Whenever someone dies near me and there's\na way for me to prevent it, I get stuck in a\ntimeloop and go back 2 minutes before their\ndeath."
		"intro3":
			followingDialogue = "intro4"
			DialogueText.text = "[i][color=Darkblue]Here we are again..."
		"intro4":
			followingDialogue = "intro5"
			DialogueText.text = "[i][color=Darkblue]Someone in this train will die in 2 minutes."
		"intro5":
			hasFollowing = false
			DialogueText.text = "[i][color=Darkblue]Let's do it."
			introFinish = true
