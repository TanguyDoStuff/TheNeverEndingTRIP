extends Area2D

################################## PARAMETERS ##################################

@export var NPC_id = "placeholder"

const textSpeedSlow = 0.3	#The speed of the text appearing
const textSpeedFast = 1	#The speed of the text appearing while pressing A

const timeVictimEat = 60 #At what time does the victim eat its sandwich?

################################## VARIABLES ###################################

var isDialogueOn = false #Is someone talking?
var hasAnswer = false #Does the current dialogue need an answer?
var hasFollowing = false #Does the text have a following message?
var followingDialogue = "" #What dialogue does it follow?
var isAnswerOn = false #Can you answer something?
var currentAnswers = ["", ""]
var displayedDialogue = "" #What dialogue is currently displayed?
var isTextAppearing = false
var visibleCharacters = 0.0
var frogloverJumped = false #Has froglover finished the jumping animation?
var victimButtonPressed = false
var victimChoke = false
var isRestartTimerOn = false 
var victimStartled = false

@onready var PlayerArea = get_parent().get_parent().get_node("Player/PlayerModel/InteractZone")
@onready var DialogueBox = get_parent().get_parent().get_node("Player/UI/Camera2D/dialogueBox")
@onready var DialogueText = get_parent().get_parent().get_node("Player/UI/Camera2D/dialogueBox/Text")
@onready var DialogueAnimation = get_parent().get_parent().get_node("Player/UI/Camera2D/dialogueBox/AnimationPlayer")
@onready var DialoguePortraitSprite = get_parent().get_parent().get_node("Player/UI/Camera2D/dialogueBox/Portrait")
@onready var music = get_parent().get_parent().get_node("Sounds/BackgroundMusic")
@onready var CountdownTimer = get_parent().get_parent().get_node("Player/UI/Camera2D/Countdown/Label/Timer")

@onready var Answers = get_parent().get_parent().get_node("Player/UI/Camera2D/dialogueBox/Answers")
@onready var AnswerAnimation = get_parent().get_parent().get_node("Player/UI/Camera2D/dialogueBox/Answers/AnimationPlayer")
@onready var AnswerText1 = get_parent().get_parent().get_node("Player/UI/Camera2D/dialogueBox/Answers/VBoxContainer/Option1")
@onready var AnswerText2 = get_parent().get_parent().get_node("Player/UI/Camera2D/dialogueBox/Answers/VBoxContainer/Option2")
@onready var soundeffectSelect = get_parent().get_parent().get_node("Player/UI/Camera2D/dialogueBox/Answers/Select")
@onready var soundeffectNext = get_parent().get_parent().get_node("Player/UI/Camera2D/dialogueBox/Next")
@onready var soundeffectBodyFall = get_parent().get_parent().get_node("Sounds/BodyFall")
@onready var soundeffectBottleOpen = get_parent().get_parent().get_node("Sounds/BottleOpen")
@onready var soundeffectCanFall = get_parent().get_parent().get_node("Sounds/CanFall")
@onready var soundeffectElectricity = get_parent().get_parent().get_node("Sounds/Electricity")
@onready var soundeffectTrain = get_parent().get_parent().get_node("Sounds/TrainSoundEffect")
@onready var startledTimer = get_parent().get_node("FrogLover/StartledTimer")
@onready var frogloverSprite = get_parent().get_parent().get_node("Froglover")
@onready var victimSprite = get_parent().get_parent().get_node("Victim")
@onready var sandwichStealTimer = get_parent().get_node("FrogLover/SandwichTimer")
@onready var ElecTimer = get_parent().get_node("Victim/ElecTimer")
@onready var ChokeTimer = get_parent().get_node("Victim/ChokeTimer")
@onready var RestartTimer = get_parent().get_node("Victim/RestartTimer")

#################################### ACTION #########################
func _ready():
	victimSprite.play("Idle")
	frogloverSprite.play("Idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	dialogueDetect()
	textSlowlyAppear()
	
	#FrogLover
	if startledTimer.is_stopped() == false: #If FrogLover is startled...
		Global.frogloverStartled = true
		if frogloverJumped == true:
			frogloverSprite.play("Distracted")
		else:
			frogloverSprite.play("Jump")
			
		if frogloverSprite.frame >= 5:
			frogloverJumped = true
	else:
		Global.frogloverStartled = false
		if Global.frogFreed == false:
			frogloverSprite.play("Idle")
		else:
			frogloverSprite.play("IdleSad")
	
	#Victim
	if CountdownTimer.time_left <= timeVictimEat and Global.isSandwichStolen == false and Global.victimSandwichEaten == false and Global.isSandwichStolen == false:
		victimSprite.play("EatSandwich")
	if victimSprite.animation == "EatSandwich" and victimSprite.frame == 2 and Global.isSandwichStolen == false:
		victimSprite.play("IdleNoSandwich")
		Global.victimSandwichEaten = true
	if sandwichStealTimer.is_stopped() and Global.frogFreed == true and victimStartled == false:
		Global.isSandwichStolen = true
		victimSprite.play("Startled")
		victimStartled = true
	
	#VictimDeaths
	if CountdownTimer.is_stopped() and Global.killed == false:
		DialogueAnimation.play("disappear") #Hide the dialogue box
		DialogueBox.hide()
		Global.isPlayerStopMove = true
		
		if Global.electricityCut == false:
			if ElecTimer.is_stopped() and victimButtonPressed == true:
				music.stop()
				victimSprite.play("ElecDeath")
				soundeffectElectricity.play()
				Global.killed = true
			elif victimButtonPressed == false:
				ElecTimer.start()
				victimSprite.play("ElecPressButton")
				victimButtonPressed = true
		elif Global.victimSandwichEaten == true:
			if ChokeTimer.is_stopped() and victimChoke == true:
				music.stop()
				victimSprite.play("PoisonDeath")
				soundeffectBodyFall.play()
				Global.killed = true
			elif victimChoke == false:
				ChokeTimer.start()
				victimSprite.play("Choke")
				victimChoke = true
		else:
			Global.loadingScene = "res://scenes/niveau/Outro.tscn" #Load train
			get_tree().change_scene_to_file("res://scenes/niveau/Loading.tscn") #Switch to the loading screen
		
		#Restart after death
	if Global.killed == true:
		soundeffectTrain.volume_db = soundeffectTrain.volume_db - 0.05 #Slow down heart rate >v>
		if isRestartTimerOn == false:
			RestartTimer.start()
			isRestartTimerOn = true
		elif RestartTimer.is_stopped():
			Global.loadingScene = "res://scenes/niveau/Rewind.tscn" #Reload train
			get_tree().change_scene_to_file("res://scenes/niveau/Loading.tscn") #Switch to the loading screen
	
	if Global.isPlayerStopMove == false: #It's a bandaid for a bug that I couldn't fix, sry
		isDialogueOn = false #If the player spam a dialogue box with a single dialogue, it can menu-store the dialogue or smth, yeaaah....
	
func dialogueDetect():
	for i in len(get_overlapping_areas()):
		if get_overlapping_areas()[i] == PlayerArea and Input.is_action_just_pressed("accept"):
			if isDialogueOn == false:
				DialogueText.visible_ratio = 0					
				setDialogues() #Set the dialogues
				DialogueAnimation.play("appear")
				DialogueBox.show()
				isDialogueOn = true
				Global.isPlayerStopMove = true
				return 0
	if isDialogueOn == true and isTextAppearing == false and (Input.is_action_just_pressed("accept") or Input.is_action_just_pressed("cancel")):
		if hasFollowing == true:
			soundeffectNext.play()
			DialogueText.visible_ratio = 0
			displayDialogues(followingDialogue)
		elif isAnswerOn == true:
			soundeffectSelect.play()
			setAnswer()
		elif hasAnswer == true:
			soundeffectNext.play()
			AnswerAppear(currentAnswers[0], currentAnswers[1])
		else:
			isDialogueOn = false
			soundeffectNext.play()
			DialogueAnimation.play("disappear")
			await DialogueAnimation.animation_finished
			DialogueBox.hide()
			Global.isPlayerStopMove = false

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

func AnswerAppear(text1, text2):
	isAnswerOn = true
	AnswerText1.text = text1
	AnswerText2.text = text2
	AnswerText1.grab_focus()
	AnswerAnimation.play("appear")
	hasAnswer = false #To make things easier :3

func AnswerDisappear():
	if AnswerText1.has_focus():
		AnswerText1.release_focus()
	else:
		AnswerText2.release_focus()
	AnswerAnimation.play("disappear")
	isAnswerOn = false

func setDialogues():
	match NPC_id:
		"placeholder":
			setPortrait("placeholder")
			DialogueText.text = "This is a placeholder\nI shouldn't appear."
		"sidekick":
			if Global.sidekickTalked == false:
				Global.sidekickTalked = true
				displayDialogues("sidekick_introduction")
			else:
				if Global.sidekickFriendship == true:
					displayDialogues("sidekick_helping")
				else:
					displayDialogues("sidekick_ignore")
		"froglover":
			if Global.frogFreed == false:
				if Global.frogloverStartled == false:
					displayDialogues("froglover_interact")
				else:
					displayDialogues("froglover_interact_startled")
			else:
				displayDialogues("froglover_missing")
		"victim":
			if Global.isSandwichStolen == false:
				displayDialogues("victim_introduction")
			else:
				displayDialogues("victim_karen")
		"electricbox":
			if Global.electricityCut == true:
				displayDialogues("electricbox_noelectricity")
			else:
				if Global.screwdriverGet == false:
					if Global.sidekickTalked == false:
						displayDialogues("electricbox_nottalkedtoanyone")
					else:
						if Global.sidekickFollowPlayer == true:
							displayDialogues("electricbox_talkedtopeople_noscrewdriver_sidekickfollow")
						else:
							displayDialogues("electricbox_talkedtopeople_noscrewdriver_sidekickdonotfollow")
				else:
					if Global.sidekickTalked == false:
						displayDialogues("electricbox_nottalkedtoanyone_screwdriver")
					else:
						if Global.sidekickFollowPlayer == true:
							displayDialogues("electricbox_open")
						else:
							displayDialogues("electricbox_talkedtopeople_screwdriver_sidekickdonotfollow")
		"weirdbottle":
			displayDialogues("weirdbottle_interact")
		"cans":
			if Global.cansKnockedOver == false:
				displayDialogues("cans_interact")
			else:
				if Global.screwdriverGet == false:
					displayDialogues("getscrewdriver")
				else:
					displayDialogues("screwdriver_crimes")

func setAnswer():
	if Input.is_action_just_pressed("cancel"):
		AnswerText2.grab_focus()
	if AnswerText1.has_focus():
		match displayedDialogue:
			"sidekick_introduction":
				displayDialogues("sidekick_introduction_iliketrains1")
			"sidekick_helping":
				displayDialogues("sidekick_help_accept")
			"weirdbottle_interact":
				if Global.sidekickFollowPlayer == true:
					soundeffectBottleOpen.play()
					displayDialogues("weirdbottle_yes_sidekick")
				else:
					soundeffectBottleOpen.play()
					displayDialogues("weirdbottle_yes")
			"cans_interact":
				displayDialogues("cans_knockover")
			"getscrewdriver2":
				displayDialogues("screwdriver_received")
			"electricbox_open":
				displayDialogues("electricbox_open_yes")
			"froglover_interact":
				displayDialogues("froglover_opencage")
			"froglover_interact_startled":
				displayDialogues("froglover_opencage_distracted")
	elif AnswerText2.has_focus():
		match displayedDialogue:
			"sidekick_introduction":
				displayDialogues("sidekick_introduction_ihatetrains")
			"sidekick_helping":
				displayDialogues("sidekick_help_deny")
			"weirdbottle_interact":
				displayDialogues("weirdbottle_no")
			"cans_interact":
				displayDialogues("cans_notknockover")
			"getscrewdriver2":
				displayDialogues("screwdriver_ignore")
			"electricbox_open":
				displayDialogues("electricbox_open_no")
			"froglover_interact":
				displayDialogues("froglover_talk")
			"froglover_interact_startled":
				displayDialogues("froglover_donothing")
	DialogueText.visible_ratio = 0
	AnswerDisappear()

func displayDialogues(currentDialogue):
	displayedDialogue = currentDialogue
	match currentDialogue:
		"sidekick_introduction":
			setPortrait("sidekick")
			hasAnswer = true
			DialogueText.text = "Oh hey!\nAre you interested into trains too?"
			currentAnswers = ["Yeah!", "Nah not really."]
			Global.sidekickTalked = true
		"sidekick_introduction_iliketrains1":
			hasFollowing = true
			followingDialogue = "sidekick_introduction_iliketrains2"
			DialogueText.text = "Finally! Someone to talk to about my reason to\nlive!"
			Global.sidekickFriendship = true
		"sidekick_introduction_iliketrains2":
			followingDialogue = "sidekick_introduction_iliketrains3"
			DialogueText.text = "Did you know that the fastest passenger train\nin the world is the L0 Series?\nIt is a high-speed Japanese Maglev train.\nIts speed record is 603 km/h!"
		"sidekick_introduction_iliketrains3":
			followingDialogue = "sidekick_introduction_iliketrains4"
			DialogueText.text = "Of course, it is not the speed used while\noperational.\nIf it is carrying passengers, it stays at\n500 km/h..."
		"sidekick_introduction_iliketrains4":
			followingDialogue = "sidekick_introduction_iliketrains5"
			DialogueText.text = "Which is still fast!\nBy comparaison, the TGV POS operational\nspeed is 320 km/h!\nCrazy right?"
		"sidekick_introduction_iliketrains5":
			followingDialogue = "sidekick_introduction_iliketrains6"
			DialogueText.text = "Man...\nI wish I could be in Japan to ride the L0\nSeries."
		"sidekick_introduction_iliketrains6":
			followingDialogue = "sidekick_introduction_iliketrains7"
			DialogueText.text = "I'm kinda scared to go in countries where\nI don't know the language.\nBut hey! I'm learning Japanese quite fast!\nMaybe I'll have the courage to go there soon!"
		"sidekick_introduction_iliketrains7":
			followingDialogue = "sidekick_introduction_iliketrains8"
			DialogueText.text = "Learning Japanese is really hard, I mean...\nThere are three writing system! I feel like I'll\nnever be able to master the Kanji..."
		"sidekick_introduction_iliketrains8":
			followingDialogue = "sidekick_introduction_iliketrains9"
			DialogueText.text = "Honestly, learning any languages is difficult,\nmostly if it is vastly different from your native\nlanguage! I really admire polyglots, they can\ncommunicate with so many people."
		"sidekick_introduction_iliketrains9":
			followingDialogue = "sidekick_introduction_iliketrains10"
			DialogueText.text = "Now that I think about it, how do they learn so\nmany languages in such a short amount of time?\nThere might be magic involved..."
		"sidekick_introduction_iliketrains10":
			hasFollowing = false
			DialogueText.text = "Ah! You seem to be in a rush, I'll let you go.\nThanks a lot for listening to me!\nIf you ever needs help, don't hesitate asking!"
		"sidekick_introduction_ihatetrains":
			DialogueText.text = "Oh.... Too bad."
		"sidekick_helping":
			setPortrait("sidekick")
			hasAnswer = true
			DialogueText.text = "If you ever need help, don't hesitate asking!"
			currentAnswers = ["Follow me!", "I'm good."]
		"sidekick_help_deny":
			DialogueText.text = "Okay!"
		"sidekick_help_accept":
			DialogueText.text = "I'm coming!"
			Global.sidekickFollowPlayer = true
			get_parent().get_node("Sidekick/Collision").position.x = -99999 #Move away the collision
			get_parent().get_node("Sidekick/Collision").position.y = -99999
		"sidekick_ignore":
			setPortrait("sidekick")
			DialogueText.text = ". . . . ."
		"electricbox_nottalkedtoanyone":
			setPortrait("blank")
			DialogueText.text = "[i][color=Darkblue]This electric box is too high for me to open it.\n.... It is locked anyway."
		"electricbox_nottalkedtoanyone_screwdriver":
			setPortrait("blank")
			DialogueText.text = "[i][color=Darkblue]Alright, I got something to open it.\nNow I need a way to get up there."
		"electricbox_talkedtopeople_noscrewdriver_sidekickfollow":
			setPortrait("blank")
			DialogueText.text = "[i][color=Darkblue]This electric box is too high for me to open it.\nI could ask them to carry me, but I probably should find a way to open it first...."
		"electricbox_open":
			setPortrait("blank")
			hasAnswer = true
			DialogueText.text = "[i][color=Darkblue]Alright! If I want to access it, I would probably need them to carry me..."
			currentAnswers = ["Ask", "...I'm too shy"]
		"electricbox_open_yes":
			hasFollowing = true
			followingDialogue = "electricbox_open_yes2"
			setPortrait("sidekick")
			DialogueText.text = "......\nWAIT! Isn't that... Illegal??"
		"electricbox_open_yes2":
			followingDialogue = "electricbox_open_yes3"
			DialogueText.text = "You know what, I trust boys that wear\neyeliner.\nAnd you're also really into trains! Just like me!"
		"electricbox_open_yes3":
			followingDialogue = "electricbox_open_yes4"
			DialogueText.text = "That explains why you're so interested about\nhow they work and want to see the interior\nof the system!"
		"electricbox_open_yes4":
			followingDialogue = "electricbox_open_yes5"
			DialogueText.text = "Let's do it."
		"electricbox_open_yes5":
			followingDialogue = "electricbox_open_yes6"
			get_parent().get_parent().get_node("Player/PlayerModel").hide()
			get_parent().get_parent().get_node("Sidekick/SidekickModel").hide()
			get_parent().get_parent().get_node("PiggyBack").show()
			get_parent().get_parent().get_node("PiggyBack").play()
			setPortrait("blank")
			DialogueText.text = "[i][color=Darkblue]Time to turn off the electricity!"
			Global.electricityCut = true
		"electricbox_open_yes6":
			hasFollowing = false
			get_parent().get_parent().get_node("Player/PlayerModel").show()
			get_parent().get_parent().get_node("Sidekick/SidekickModel").show()
			get_parent().get_parent().get_node("PiggyBack").hide()
			DialogueText.text = "[i][color=Darkblue]All done!"
		"electricbox_open_no":
			DialogueText.text = "[i][color=Darkblue]...I want a piggyback ride..."
		"electricbox_talkedtopeople_noscrewdriver_sidekickdonotfollow":
			setPortrait("blank")
			DialogueText.text = "[i][color=Darkblue]This electric box is too high for me to open it.\nI could ask for help, but I probably should find a way to open it first...."
		"electricbox_talkedtopeople_screwdriver_sidekickdonotfollow":
			setPortrait("blank")
			DialogueText.text = "[i][color=Darkblue]This electric box is too high for me to open it.\nI probably should ask for help!"
		"electricbox_noelectricity":
			setPortrait("blank")
			DialogueText.text = "[i][color=Darkblue]No more electricity!"
		"weirdbottle_interact":
			setPortrait("blank")
			hasAnswer = true
			DialogueText.text = "[i][color=Darkblue]That's a weird bottle... I wonder what's in it."
			currentAnswers = ["Drink it", "Ignore it"]
		"weirdbottle_yes_sidekick":
			hasFollowing = true
			followingDialogue = "weirdbottle_yes"
			setPortrait("sidekick")
			DialogueText.text = "Wh-- What are you doing?"
		"weirdbottle_yes":
			hasFollowing = true
			followingDialogue = "weirdbottle_yes2"
			setPortrait("blank")
			DialogueText.text = "[i][color=Darkblue]Ew! That... Taste.... Horrible....."
		"weirdbottle_yes2":
			followingDialogue = "weirdbottle_yes3"
			get_parent().get_parent().get_node("BlackScreen").show()
			soundeffectBodyFall.play()
			DialogueText.text = "[i][color=Darkblue]You fainted."
			music.stop()
		"weirdbottle_yes3":
			Global.loadingScene = "res://scenes/niveau/Rewind.tscn" #Reload train
			get_tree().change_scene_to_file("res://scenes/niveau/Loading.tscn") #Switch to the loading screen
		"weirdbottle_no":
			DialogueText.text = "[i][color=Darkblue]Being in a timeloop doesn't justify doing that."
		"cans_interact":
			setPortrait("blank")
			hasAnswer = true
			DialogueText.text = "[i][color=Darkblue]Man, why do people just keep littering?"
			currentAnswers = ["Knock it over", "Ignore it"]
		"cans_knockover":
			Global.cansKnockedOver = true
			get_parent().get_parent().get_node("Cans").texture = load("res://assets/char/Cans/cans0001.png")
			soundeffectCanFall.play()
			DialogueText.text = "[i][color=Darkblue]Evilness."
			get_parent().get_node("FrogLover/StartledTimer").start()
		"cans_notknockover":
			DialogueText.text = "[i][color=Darkblue]Come on, I'm not THAT evil."
		"getscrewdriver":
			setPortrait("blank")
			hasFollowing = true
			followingDialogue = "getscrewdriver2"
			DialogueText.text = "[i][color=Darkblue]Wait! Something was behind the cans!"
		"getscrewdriver2":
			hasFollowing = false
			hasAnswer = true
			DialogueText.text = "[i][color=Darkblue]Is that... A screwdriver?"
			currentAnswers = ["Pick it up", "Ignore it"]
		"screwdriver_received":
			Global.screwdriverGet = true
			get_parent().get_parent().get_node("Cans").texture = load("res://assets/char/Cans/cans0002.png")
			DialogueText.text = "[i][color=Darkblue]Screwdriver: Received!!"
		"screwdriver_crimes":
			setPortrait("blank")
			DialogueText.text = "[i][color=Darkblue]Crimes."
		"screwdriver_ignore":
			DialogueText.text = "[i][color=Darkblue]Bah, who needs a screwdriver anyway?"
		"froglover_interact":
			setPortrait("froglover")
			hasAnswer = true
			DialogueText.text = "Hey, have you seen my beautiful frog?"
			currentAnswers = ["Open the cage", "Continue talking"]
		"froglover_opencage":
			setPortrait("blank")
			DialogueText.text = "[i][color=Darkblue]It's not a good idea to open the cage now.\nI should find a way to distract him."
		"froglover_opencage_distracted":
			setPortrait("blank")
			sandwichStealTimer.start()
			Global.frogFreed = true
			get_parent().get_parent().get_node("Cage").texture = load("res://assets/char/Frog/cage0001.png")
			get_parent().get_parent().get_node("Frog").show()
			get_parent().get_parent().get_node("Frog").play("frog")
			get_parent().get_parent().get_node("Frog").frame = 0
			DialogueText.text = "[i][color=Darkblue]Be free little frog!"
		"froglover_talk":
			hasFollowing = true
			followingDialogue = "froglover_talk2"
			DialogueText.text = "I am SO PROUD of Esteban, my frog.\nWe are traveling to a frog beauty show, and\nMAN, Esteban look so cool and is so cute!!"
		"froglover_talk2":
			followingDialogue = "froglover_talk3"
			DialogueText.text = "I would do ANYTHING for my little froggy\nfrog frog...\nI mean, that's why humans have hands."
		"froglover_talk3":
			followingDialogue = "froglover_talk4"
			DialogueText.text = "Pat the frog."
		"froglover_talk4":
			followingDialogue = "froglover_talk5"
			DialogueText.text = "Hold the frog."
		"froglover_talk5":
			followingDialogue = "froglover_talk6"
			DialogueText.text = "Cherish the frog."
		"froglover_talk6":
			hasFollowing = false
			DialogueText.text = "Forfeit all mortal possesions to the frog."
		"froglover_interact_startled":
			setPortrait("blank")
			hasAnswer = true
			DialogueText.text = "[i][color=Darkblue]He seems distracted..."
			currentAnswers = ["Open the cage", "Do nothing"]
		"froglover_donothing":
			DialogueText.text = "[i][color=Darkblue]I don't want to break his froggy heart..."
		"froglover_missing":
			setPortrait("froglover")
			DialogueText.text = "E-Esteban?\nESTEBAN??\nESTEBAAAAAAAAN!!!! NOOOOOOO!"
		"victim_introduction":
			hasFollowing = true
			followingDialogue = "victim_introduction2"
			setPortrait("victim")
			DialogueText.text = "Ugh. What do YOU want from me?"
		"victim_introduction2":
			followingDialogue = "victim_introduction3"
			DialogueText.text = "Seriously look at you, you inferior entity.\nHow can you even consider walking up to me?"
		"victim_introduction3":
			hasFollowing = false
			setPortrait("blank")
			DialogueText.text = "[i][color=Darkblue]...What."
		"victim_karen":
			hasFollowing = true
			followingDialogue = "victim_karen2"
			setPortrait("victim")
			DialogueText.text = "WHAT THE....\nA MONSTER JUST ATE MY SANDWICH??\nI NEED TO SPEAK TO THE MANAGER!!!"
		"victim_karen2":
			followingDialogue = "victim_karen3"
			DialogueText.text = "My husband works here!!\nI deserve to be treated like a queen!!\nHe's so perfect he even made this sandwich\nfor me!!"
		"victim_karen3":
			hasFollowing = false
			setPortrait("blank")
			DialogueText.text = "[i][color=Darkblue]Oh no."
