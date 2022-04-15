extends StaticBody2D

#Hide when signlaed
func _on_Player_key_collect(type):
	if type == "silver":
		$keyCollision.disabled = true;
		$keySprite.visible = false;
