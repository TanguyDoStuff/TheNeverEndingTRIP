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
var outroFinish = false #Has the outro finished?

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
	
	if outroFinish == true and isDialogueOn == false:
		isDialogueOn = false
		DialogueAnimation.play("disappear")
		await DialogueAnimation.animation_finished
		DialogueBox.hide()
		
		Global.loadingScene = "res://scenes/niveau/MenuPrincipal.tscn" #Load train
		get_tree().change_scene_to_file("res://scenes/niveau/Loading.tscn") #Switch to the loading screen
	
func dialogueDetect():
	if $Timer.time_left == 0 and isDialogueOn == false and outroFinish == false:
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
		"outro":
			displayDialogues("outro1")

func displayDialogues(currentDialogue):
	displayedDialogue = currentDialogue
	match currentDialogue:
		"outro1":
			hasFollowing = true
			followingDialogue = "outro2"
			setPortrait("blank")
			DialogueText.text = "[i][color=Darkblue]I guess that's it."
		"outro2":
			followingDialogue = "outro3"
			DialogueText.text = "[i][color=Darkblue]Another life saved."
		"outro3":
			followingDialogue = "outro4"
			DialogueText.text = "[i][color=Darkblue]And I'm out of the timeloop once again...\nAm I ever going to get rid of this curse?"
		"outro4":
			followingDialogue = "outro5"
			DialogueText.text = "[i][color=Darkblue]Oh well, I guess this is life."
		"outro5":
			hasFollowing = false
			DialogueText.text = "[center]Thanks for playing!!"
			outroFinish = true
