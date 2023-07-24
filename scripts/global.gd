extends Node

################################## VARIABLES ###################################

var isPauseMenuOn = false #Is the pause menu on?
var isPlayerStopMove = false #Should the player be able to move?
var loadingScene = "" #Check which scene to load in a loading screen

#GAME FLAGS
var sidekickTalked = false #Has the player talked to the sidekick once?
var sidekickFriendship = false #Have you befriended the sidekick?
var sidekickFollowPlayer = false #Should the sidekick follow the player?
var cansKnockedOver = false #Are the cans knocked over?
var screwdriverGet = false #Does the player have the screwdriver?
var electricityCut = false #Has the electricity been cut?
var frogFreed = false #Has the frog been freed?
var frogloverStartled = false #Is the froglover startled?
var victimSandwichEaten = false #Has the vicim eaten the sandwich
var isSandwichStolen = false #Has the frog stole the sandwich?
var killed = false #Is victim killed?

func reset():
	isPauseMenuOn = false #Is the pause menu on?
	isPlayerStopMove = false #Should the player be able to move?
	loadingScene = "" #Check which scene to load in a loading screen
	sidekickTalked = false #Has the player talked to the sidekick once?
	sidekickFriendship = false #Have you befriended the sidekick?
	sidekickFollowPlayer = false #Should the sidekick follow the player?
	cansKnockedOver = false #Are the cans knocked over?
	screwdriverGet = false #Does the player have the screwdriver?
	electricityCut = false #Has the electricity been cut?
	frogFreed = false #Has the frog been freed?
	frogloverStartled = false #Is the froglover startled?
	victimSandwichEaten = false #Has the vicim eaten the sandwich
	isSandwichStolen = false #Has the frog stole the sandwich?
	killed = false #Is victim killed?
