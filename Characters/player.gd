extends CharacterBody2D

@onready var anim = $AnimationTree
@onready var statemachine = anim.get("parameters/playback")

@export var start_direction : Vector2 = Vector2(0,1)
@export var PLAYER_SPEED : float = 100

func _ready():
	update_animation(start_direction)


func _physics_process(delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up"))
	
	
	update_animation(input_direction)
		#  define velocity for the move_and_slide function
	velocity = input_direction * PLAYER_SPEED
		# move character
	move_and_slide()
	pick_state()
		
func update_animation(move_input : Vector2):
	if(move_input != Vector2.ZERO):
		anim.set("parameters/Walk/blend_position", move_input)
		anim.set("parameters/Idle/blend_position", move_input)
		
func pick_state():
	if(velocity != Vector2.ZERO):
		statemachine.travel("Walk")
	else:
		statemachine.travel("Idle")
