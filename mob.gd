extends KinematicBody2D

#Properties
export(String) var LEVEL: String = ""
export(bool) var PASSIVE: bool = false
export(int) var SPEED: int = 300 #Character speed
export(float) var ATTACK_COOLDOWN: float = 0.25	#Seconds until next attack
export(float) var OFFENSE_TIMEOUT: float = 0.25	#Seconds to allow character to attack
export(float) var HIT_TINT_DURATION_PERCENT: float = 1.0 #Percentage of duration
export(float) var DIE_SPEED: float = 1 #Speed to die
export(int) var STARTING_HEALTH: int = 3
export(bool) var SMART: bool 

####INHERIT####
#Always inherit
onready var animation: AnimatedSprite = $AnimatedSprite
onready var hitsound: AudioStreamPlayer2D = $Hitsound
#Specific to level
var world
var parent
var timer
var Nav2D
var Player
var Line


#Active variables
var active: bool = true #if game isn't over
var attacking: bool = false
var touching_character: bool = false
var health: int = STARTING_HEALTH
var die: bool = false
var path: PoolVector2Array 


signal playerHit #Signal when sucessful hit on character
signal die #Signal when skeleton dies

func _ready():
	#Load variables specific to level
	if LEVEL == "Room2":
		parent = get_parent()
		timer = $Timer
		Nav2D = parent.get_node("Navigation2D")
		Player = parent.get_parent().get_node("Player")
		Line = parent.get_node("Line2D")
		Line.points = generate_path()
		
	if LEVEL == "Room1":
		 parent = get_parent()
		 timer = $Timer
		 Nav2D = parent.get_node("LevelNavagation")
		 Player = parent.get_node("Player")
		 Line = parent.get_node("Line2D")
		 Line.points = generate_path()
	world = get_tree().root.get_child(0)
	#Set modulate to normal for begining
	modulate.r = 1
	modulate.g = 1
	modulate.b = 1


func _physics_process(delta):	
	
	#Don't do anything until the intro animation has finished playing
	if not world.world_started:
		return
	
	#Attack mechanics
	update_health()
		
	#Stop if deactivated
	if not active:
		return
	#Pathfind
	if not PASSIVE:
		Line.points = generate_path()
		navagate()

#Generate simple path
func generate_path():
	"""generate_path() -> Array
	
	Get array of points of path to player """
	
	return Nav2D.get_simple_path(self.global_position, Player.global_position, SMART)

#Navagete allong path to character
func navagate():
	"""Navagate allong generate_path() at given export speed"""
	
	#Get velocity
	path = generate_path()
	var velocity = self.global_position.direction_to(path[1]) * SPEED
	
	
	#Move allong path
	if self.global_position == path[1]:
			path.remove(0)
	velocity = move_and_slide(velocity)
	
	#Check if reached player
	touching_character = false
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if "Player" in collision.collider.name:
			touching_character = true
			attack() 
			
	#Flip character
	$AnimatedSprite.set_flip_h(((Player.global_position.x - global_position.x) < 0) if abs(velocity.x) < SPEED * 0.2 else (velocity.x < 0))
			
#Sends player hits
func attack():
	"""Wait certan ammount of time to allow character to hit, then hit if no action taken"""
	
	#Give Player time to attack before dealing damage
	yield(get_tree().create_timer(OFFENSE_TIMEOUT), "timeout")
	
	#Double check that attack is still valid after offense timeout
	if not Player.attacking and not attacking and touching_character:
		#Attack
		animation.animation = "attack"
		attacking = true

#When to allow next attack
func _on_AnimatedSprite_animation_finished():
	"""Marks the end of an attack mood, in addition to a timeout"""
	
	#Return animation to default state
	animation.animation = "default"
	
	#Add cooldown for next attack
	yield(get_tree().create_timer(ATTACK_COOLDOWN), "timeout")
	
	#Only signal player attack once animation and timeout complete
	if attacking:
		emit_signal("playerHit")
		attacking = false

#Stop movement if game over
func _on_Player_game_over():
	"""Pauses movement once game is over"""
	
	active = false

#Update mob health and add death mechanic
func update_health():
	"""Update health according to global variable and reset to normal modulate"""
	
	#Return modulate back to 1
	if self.modulate.g < 1:
		self.modulate.g += (0.01 * HIT_TINT_DURATION_PERCENT)
	if self.modulate.b < 1:
		self.modulate.b += (0.01 * HIT_TINT_DURATION_PERCENT)
	
	#Die when dead (lol)
	if health <= 0:
		die()

#Small animation for death		
func die():
	"""Adds a bit of an animation for death"""
	
	#Acknowlage death
	die = true
	
	#Fade out
	modulate.a -= 0.02 * DIE_SPEED
	modulate.g -= 0.02 * DIE_SPEED
	modulate.b -= 0.02 * DIE_SPEED
	modulate.r -= 0.01 * DIE_SPEED
	
	#Delete when gone
	if modulate.a <= 0:
		emit_signal("die", global_position)
		print("Emmiting die signal")
		queue_free()

#Receives player hits
func _on_Player_mob_hit(collisions):
	"""Updates health and flashes red on player hit"""
	for id in collisions:
		#Only trigger if mob id matches player hit
		if get_instance_id() == id:
			
			#Print to debugger
			print(self.name, " hit by player. Id: ", id)
			
			#Set red tint
			self.modulate.g = 0.5
			self.modulate.b = 0.5
			
			#Reduce health
			health -= 1
			
			#Make sound
			hitsound.play()
			
			#Return to prevent duplicates
			return
