extends StaticBody2D

var fadeIn = false;

func _ready():
	$Sprite.modulate.a = 0;
	pass
	
func _physics_process(delta):
	if fadeIn:
		var sprite = $Sprite
		if sprite.modulate.a < 100:
			sprite.modulate.a = sprite.modulate.a + 0.01
			print("sprite alpha", sprite.modulate.a)


func _on_World_level_complete():
	print("level complete")
	fadeIn = true;
