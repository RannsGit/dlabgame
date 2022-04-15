extends Node2D

signal level_complete #On level win

var world_started: bool = false #If world started

func _ready():
	#Signal world start
	world_started = true
	
#On level win
func _on_Player_level_win():
	emit_signal("level_complete")
	
#When animation finished
func _on_Intro_And_Exit_nextLevel():
	get_tree().change_scene("res://scenes/Room 1.tscn")
