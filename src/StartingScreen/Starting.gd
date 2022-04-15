extends Control

signal fadeIn

var count = 0
	
func _physics_process(delta):
	#Wait 1 second to trigger scene fade
	count = count + 1
	if count == 60:
		emit_signal("fadeIn")

func _on_background_newGame():
	get_tree().change_scene("res://scenes/IntroLevel.tscn")
