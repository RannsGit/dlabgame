extends KinematicBody2D

var fadingIn = false
var animation: Node2D
var activated = false

func _ready():
	animation = $AnimatedSprite
	animation.modulate.a = 0
	$CollisionShape2D.disabled = true;
	
func _physics_process(delta):
	if activated:
		if animation.modulate.a < 1:
			animation.modulate.a = animation.modulate.a + 0.01
	#Disable collisions once key collected
	if get_parent().allKeys:
		$CollisionShape2D.disabled = true;
func _on_World_keyRed():
	$CollisionShape2D.disabled = false;
	activated = true


func _on_Player_key_collect(target):
	if target == "red":
		if activated:
			#Set 3rd key value to obtained in Player object
			get_parent().get_node("Player").keysCollected[2] = true;
			$AnimatedSprite.visible = false;
			$CollisionShape2D.disabled = true;
