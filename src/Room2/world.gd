extends Node2D

signal level_complete

var world_started: bool = false #Signals to start level
var keys_collected: Array = [false, false] #Stores keys collected. [Gold, Silver]
var fade_queue: Array = [] #Queue of objects to fade
var redkey: bool = false #Has the red key been collected

onready var chest: StaticBody2D = $chest #Chest object
onready var keys: Array = [$Keys/keyGold, $Keys/keySilver, $Keys/keyRed] 

func _ready():
	
	#Set all keys to hidden at begining
	for key in keys:
		keyStatus(key, false) 

func _physics_process(delta):
	
	#Update fading of keys
	update_fade()

#Updates the fade of keys
func update_fade():
	"""Updates modulation of keys based off their queue"""
	
	#Check for duplicates
	for key in fade_queue:
		if keys_collected[keys.find(key)]:
			print("Removing duplicate ", key)
			fade_queue.remove(fade_queue.find(key))
			keyStatus(key, false)
		
	#Each item queued
	for item in fade_queue:
			
		#If item done fading
		if item.modulate.a >= 1:
			print("item done") #Log status
			item.modulate.a = 1 #Set to 1 in case over
			fade_queue.erase(item) #Remove from queue
		
		#Increase fade
		item.modulate.a += 0.02
	
#Changes status of given key
func keyStatus(key, on: bool):
	"""keyStatus(key: Node2D, on: bool) -> void
	
	Updates the status of the given key
	key:		Node2D	-	The key in which to target
	on:		Bool		- 	The status in which to set the key to
	"""
	
	if on:
		fade_queue.append(key) #Fade in 
		key.get_node("keyCollision").disabled = false #Trun on collision
		
	if not on:
		key.get_node("keyCollision").disabled = true #Turn off collision
		key.modulate.a = 0 #Invisible
		
#Displays the red key
func display_red_key():
	keyStatus(keys[2], true)
	keys_collected.append(false) #Add to keys_collected list

##########SIGNALS##########

#When skeleton 1 dies
func _on_Skeleton1_die(location: Vector2):
	keyStatus(keys[0], true) #Show gold key
	keys[0].global_position = location #Set position to skeleton

#When skeleton 2 dies
func _on_Skeleton2_die(location: Vector2):
	keyStatus(keys[1], true) #Show silver key
	keys[1].global_position = location #Set position to skeleton

#When the player picks up a key
func _on_Player_key_collect(key: String):
	#Check key type
	if key == "gold":
		keyStatus(keys[0], false)
		keys_collected[0] = true
	if key == "silver":
		keyStatus(keys[1], false)
		keys_collected[1] = true
	if key == "red":
		keyStatus(keys[2], false)
		redkey = true
		keys_collected[2] = true
	
#Handler for miscellaneous interactions
func _on_Player_generic_collide(item):
	#If colliding with chest
	if item == "chest":
		#Only play if all keys are collected
		if not false in keys_collected:
			chest.get_node("AnimatedSprite").play()
	#If colliding with door
	if item == "door":
		#Only work when red key is collected
		if redkey:
			emit_signal("level_complete")

#When chest is finished opening
func _on_AnimatedSprite_animation_finished():
	#Display the red key
	display_red_key()
	
#On level finished
func _on_Intro_And_Exit_nextLevel():
	#Change scene
	get_tree().change_scene("res://scenes/Starting.tscn")

#On level start
func _on_Intro_And_Exit_startLevel():
	#Change scene
	world_started = true

#On level fail
func _on_Intro_And_Exit_restartLevel():
	#Restart scene
	get_tree().change_scene("res://scenes/Room 2.tscn")
