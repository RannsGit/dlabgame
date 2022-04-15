extends Panel

#Speed in which to fade
export var STEP = 0.01;

var fadeIn = false;
var fadeOut = false

func _physics_process(delta):
	#Change alpha layer by STEP when activated
	if fadeIn:
		if self.modulate.a > 0:
			self.modulate.a = self.modulate.a - STEP;
		else:
			fadeIn = false
	if fadeOut:
		if self.modulate.a < 1:
			self.modulate.a = self.modulate.a + STEP;
		else:
				get_tree().change_scene("res://scenes/About Page.tscn")

func _on_Control_fadeIn():
	fadeIn = true;
	
func _on_About_pressed():
	fadeOut = true;

