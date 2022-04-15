extends Control

var fadeOut = false;

func _physics_process(delta):
	if fadeOut:
		self.modulate.a = self.modulate.a - 0.01

func _on_NewGame_pressed():
	fadeOut = true;
