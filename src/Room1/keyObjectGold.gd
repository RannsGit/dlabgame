extends StaticBody2D

#Hide when signaled
func _on_Player_key_collect(target):
	if target == "gold":
		$keyCollision.disabled = true
		$keySprite.visible = false
