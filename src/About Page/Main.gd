extends Node2D

func _on_button_pressed():
	$"Intro And Exit".animation = "level complete"


func _on_Intro_And_Exit_nextLevel():
	get_tree().change_scene("res://scenes/Starting.tscn");
