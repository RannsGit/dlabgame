extends KinematicBody2D

signal newGame

var progression = 0;
var downMovement = 0.1;
var started = false;

func _physics_process(delta):
	#Move side to side in sine wave, progression acting as angle
	progression = progression + 0.01;
	move_and_slide(Vector2(10 * sin(progression), 0));
	
	#On game start:
	if started:
		#Exponetially move down
		downMovement = downMovement*1.1
		move_and_slide(Vector2(0, -downMovement))
	#Once off screen, start first level
	if get_position().y < -2000:
		emit_signal("newGame")

func _on_NewGame_pressed():
	started = true;
