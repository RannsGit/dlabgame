extends Node

signal startLevel #When intro is done playing
signal nextLevel #When exit is done playing
signal restartLevel #When game over is done playing

export(float) var STEP: float = 0.01 #Step in which to fade
export(bool) var DISABLE_STARTING_SCREEN: bool = false

var peaked = false #Has the text faded all the way in yet
var modulate = 0 #Variable holding alpha value
var animation: String #Which animation to play
onready var intro_text = $Opening/introText
onready var exit_text = $Opening/exitText
onready var lose = $Opening/gameover
onready var normpan = $Opening/Panel
	
func _ready():
	#Sets alpha to 0 so there is no flash when loading
	intro_text.modulate.a = 0
	exit_text.modulate.a = 0
	normpan.modulate.a = 1
	
	#Disable starting screen if requested
	if DISABLE_STARTING_SCREEN:
		STEP = 0.5
	
	animation = "start"

func _physics_process(delta):
	
	#Play at begining of level
	if animation == "start":fade("startLevel", normpan, intro_text, true)
#
	#Play at end of level
	if animation == "level complete":fade("nextLevel", normpan, exit_text, false)
			
	#Play game over
	if animation == "game over":fade("restartLevel", normpan, lose, false)

#Fade in and out
func fade(sig: String, panel: Control, text: Control, reveal: bool):
	"""fade(sig: String, panel: Control, text: Contrl, reveal: bool) -> void
	
	Fades in and out control pannels to display level information. Specifically
	for level transitions. 
	
	Arguments:
		sig:		String		-	The signal in which to emit apoun finish
		panel:	Control		-	The back pannel; it sits behind the text
		text:	Control		-	The node containing the text to fade
		reveal:	Bool			-	If panel should be faded out at the end
	"""
	
	#Fade in panel
	if not peaked and panel.modulate.a < 1:
		panel.modulate.a += STEP
	
	if panel.modulate.a >= 1:
			#Fade in text
			if !peaked:
				text.modulate.a = text.modulate.a + STEP
				
			#Recognize if text has reached full opacity
			if text.modulate.a >= 1.1:
				peaked = true
				
			#Fade out text once peaked
			if peaked and text.modulate.a >= 0:
				text.modulate.a -= STEP
				
			#Recognize text completion
			if peaked and text.modulate.a <= 0:
				if not reveal:
					#Complete if no reveal
					emit_signal(sig) #Signal next event
					peaked = false #reset peaked variable
					animation = "" #reset animation to prevent loop
					return
	#Fade out back panel
	if reveal:
		
		#Wait until text is done
		if peaked and text.modulate.a <= 0:
			
			#Fade out pannel
			if panel.modulate.a > 0:
				panel.modulate.a -= STEP
				
			#Recognize when complete
			else:
				emit_signal(sig) #Signal next event
				peaked = false #reset peaked variable
				animation = "" #reset animation to prevent loop
				return 
	
#Accept level completion
func _on_World_level_complete():
	animation = "level complete"

#Accept character death
func _on_Player_game_over():
	animation = "game over"
