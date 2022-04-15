extends Actor

#Signals
signal key_collect #When key is collected
signal game_over #When character dies
signal mob_hit #When mob is attacked

#Variables retaining to character movement that can be changed in inspector
export(int) var CHAR_SPEED: int = 10
export(int) var MAX_CHAR_SPEED: int= 280
export(float) var ACCEL_RATE: float = 0.1
export(int) var START_SPEED: int = 20

#Inherit
onready var animation: AnimatedSprite = $AnimatedSprite
onready var healthbar: AnimatedSprite = get_parent().get_node("HealthBarContainer").get_node("Health bar")
onready var skeleton: KinematicBody2D = get_parent().get_node("Skeleton")

#Live variables
var realMaxSpeed:int = MAX_CHAR_SPEED #Used to interpolate constant MAX_CHAR_SPEED
var keyspressed:Array = [false, false, false, false] #Up, Down, Left, Right
var velocity:float = 0
var previousAngle:float = 0
var keysCollected: Array = [false, false, false]
var chestCollide: bool = false
var doorCollide: bool = false
var health: int = 5
var attacking: bool = false

#Process each frame
func _physics_process(delta: float) -> void:
	#Update variables
	chestCollide = false
	doorCollide = false
	
	#Interpret keystrokes
	keyspressed[0] = true if (Input.get_action_strength("move_up") == 1.0) else false
	keyspressed[1] = true if (Input.get_action_strength("move_down") == 1.0) else false
	keyspressed[2] = true if (Input.get_action_strength("move_left") == 1.0) else false
	keyspressed[3] = true if (Input.get_action_strength("move_right") == 1.0) else false
	
	#Adds sprinting function (shift)
	if (Input.get_action_strength("sprint") == 1.0):
		realMaxSpeed = MAX_CHAR_SPEED * 2
	else:
		realMaxSpeed = MAX_CHAR_SPEED
	
	#Find angle for travel
	var travelAngle = getAngle(keyspressed, previousAngle)
	previousAngle = travelAngle
	
	#If a key is pressed
	var keypressed = false
	for key in keyspressed:
		if key:
			keypressed = true
	
	#Move character
	updateVelocity(keypressed, ACCEL_RATE, realMaxSpeed, START_SPEED)
	var targetPos = calc2DMovement(travelAngle, velocity)
	move_and_slide(targetPos, Vector2(0,0), false, 4, 0.785, false)
	
	#Flip character
	if(travelAngle >= 135 and travelAngle <= 225):
		$AnimatedSprite.set_flip_h(true)
	if(travelAngle >= 315 or travelAngle <= 45):
		$AnimatedSprite.set_flip_h(false)
	
	#Variable for attack
	var collider_ids: Array = []
	
	#Detect and interpret collisions
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		collider_ids.append(collision.collider_id)
		if collision.collider.name.begins_with("chest"):
			chestCollide = true
		if collision.collider.name.begins_with("door"):
			doorCollide = true
		if collision.collider.name.begins_with("key"):
			var keytype = "silver"
			if "Gold" in str(collision.collider.name):
				emit_signal("key_collect", "gold")
				keysCollected[0] = true
			if "Silver" in str(collision.collider.name):
				emit_signal("key_collect", "silver")
				keysCollected[1] = true
			if "Red" in str(collision.collider.name):
				emit_signal("key_collect", "red")
	
	if Input.is_action_just_pressed("attack"):
		attack(collider_ids)
	
	#Update player health
	update_health()

#Find angle based on inputs
func getAngle(inputs, pang: int) -> int:
	"""getAngle(inputs: arry) -> int
	
	Determines angle from given keypresses
	Arguments:
		inputs:	array	-     4 length boolean array of w, a, s, & d accordingly
		pang:	int		-     Angle in which to return if no keypress
	"""
	#Discard any conflicting/opposite keystrokes
	if (inputs[0] && inputs[1]):
		inputs[0] = false
		inputs[1] = false
	if (inputs[2] && inputs[3]):
		inputs[2] = false
		inputs[3] = false
	#Assign angle measures to keys
	var angles = []
	for input in inputs:
		if inputs[0]: angles.append(270)
		if inputs[1]: angles.append(90)
		if inputs[2]: angles.append(180)
		if inputs[3]: angles.append(0)
	#Find average angle and return
	var total = 0
	if ((angles.find(270) != -1) && (angles.size()) > 1):
		if(angles.find(0) != -1):
			return 315    
	for angle in angles:
		total += angle 
	if (angles.size() > 0):
		return total / angles.size()
	return pang
		
func calc2DMovement(angle: float, speed: float) -> Vector2:
	"""calc2DMovement(angle: float, speed: float, pos: Vector2) -> Vector2
	
	Does required trigonometry to find delta movement from current location
	Arguments:
		angle:     float -         angle of desired movement
		speed:     float -         distance to move per update
		pos:     Vector2 -         position of character to move from last position """
	
	var returnVec: Vector2 = Vector2(0, 0)
	
	returnVec.x = (speed * cos(angle * (PI/180)))
	returnVec.y = (speed * sin(angle * (PI/180)))
	
	return returnVec

#Updates real character velocity
func updateVelocity(keypressed: bool, accel: float, maxspd: float, startspd: float = 1.0) -> void:
	"""updateVelocity(keypressed: bool, accel: float, maxspd: float) -> void
	
	Updates character velocities.
	Arguments:
		keypressed:		bool  -    if character is actively being moved
		accel:			float -    rate at which to accelerate and to decelerate (exponetial)
		maxspd:     		float -    maximum speed at which to cut acceleration
		startspd:    	float -    speed in which to start acceleration at. (Default 1)
		"""
	#Accelerate or decelerate depending on current velocity
	if (keypressed && (velocity < maxspd)):
		if (velocity == 0): velocity = startspd
		velocity += (maxspd * accel)
	if (!keypressed && (velocity > 0)):
		
		velocity -= (maxspd * accel)
	#Limits to limits
	if (velocity < 0):
		velocity = 0
	if (velocity > maxspd):
		velocity = maxspd

#Updates healthbar
func update_health():
	"""update_health() -> None
	
	Updates health bar depending on global variable: healthbar
	"""
	if self.modulate.g < 1:
		self.modulate.g += 0.01
	if self.modulate.b < 1:
		self.modulate.b += 0.01
	healthbar.frame = health
	if health <= 0:
		emit_signal("game_over")
	
#Attack mob
func attack(collider: Array):
	"""attack(collider_ids: Array) -> None
	
	signals mob hit """
	if not attacking:
		print("Character: Attack")
		emit_signal("mob_hit", collider)
		attacking = true
		animation.animation = "Attack"

#Set animation to idle 
func _on_AnimatedSprite_animation_finished():
	"""Return animation to idle if not attacking"""
	if animation.animation == "Attack":
		animation.animation = "default"
		#Timeout for attack
		yield(get_tree().create_timer(0.1), "timeout")
		attacking = false

#On mob attack
func _on_Skeleton_playerHit():
	"""Reduce health and flash red when hit"""
	if not attacking:
		health -= 1
		#Flash red
		self.modulate.g = 0.5
		self.modulate.b = 0.5
