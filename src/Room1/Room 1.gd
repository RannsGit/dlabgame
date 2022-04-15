extends Node2D

signal chestOpen
signal keyRed
signal level_complete

onready var player: KinematicBody2D = $Player

var allKeys = false
var world_started = false
var chestOpened = false
var keyAppeared = false
	
func _physics_process(delta:float) -> void:
	keys_process()

#Handle Keys
func keys_process():
	"""Handle key collection and animations"""
	#Check if gold and silver key collected when accessing chest
	if(player.keysCollected[0] == true and player.keysCollected[1] == true and player.chestCollide):
		chestOpened = true
		$chest/AnimatedSprite.play("open")
	
	#Only show red key once chest animation is finished
	if ($chest/AnimatedSprite.frame >= 7 and !keyAppeared):
		emit_signal("keyRed")
	
	#Simplifies list of [true, true, ture] to single bool
	if (!player.keysCollected.has(false)):
		allKeys = true
		
	#If character has all keys, complete level
	if(allKeys and player.doorCollide):
		emit_signal("level_complete")

#Sets variable for child reference
func _on_Intro_And_Exit_startLevel():
	world_started = true

#Change to next level
func _on_Intro_And_Exit_nextLevel():
	get_tree().change_scene("res://scenes/Room 2.tscn")

#Restart current level
func _on_Intro_And_Exit_restartLevel():
	get_tree().change_scene("res://scenes/Room 1.tscn")
