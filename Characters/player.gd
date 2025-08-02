extends CharacterBody2D

@onready var anim = $AnimationTree
@onready var statemachine = anim.get("parameters/playback")
@onready var water_anim = $AnimationTree2
@onready var water_statemachine = $AnimationPlayer2
@onready var walk_sprite = $MovingSprite
@onready var watering_sprite = $WateringSprite
@onready var water_ray = $WaterRay

@export var start_direction : Vector2 = Vector2(0,1)
@export var PLAYER_SPEED : float = 100

var is_watering := false
var last_direction : Vector2

func _ready():
	update_animation(start_direction)
	walk_sprite.visible = true
	watering_sprite.visible = false


func _physics_process(_delta):
	if is_watering:
		velocity = Vector2.ZERO
	else:
		var input_direction = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down") - Input.get_action_strength("up")).normalized()
			
		if input_direction != Vector2.ZERO:
			last_direction = input_direction
			
			#Change Ray direction
			water_ray.target_position = last_direction * 16
			

	
		update_animation(input_direction)
		#  define velocity for the move_and_slide function
		velocity = input_direction * PLAYER_SPEED
		
		if Input.is_action_just_pressed("interact"):
			start_watering()
			print(water_ray.get_collider())
			print("Ray target:", water_ray.target_position)

		# move character
	move_and_slide()
	pick_state()
		
func update_animation(move_input : Vector2):
	if(move_input != Vector2.ZERO):
		anim.set("parameters/Walk/blend_position", move_input)
		anim.set("parameters/Idle/blend_position", move_input)
		
func pick_state():
	if is_watering:
		return null
	if(velocity != Vector2.ZERO):
		statemachine.travel("Walk")
	else:
		statemachine.travel("Idle")


func start_watering():
	#Check For Plants
	if not water_ray.is_colliding():
		return
	var target = water_ray.get_collider()
	if not target.is_in_group("Plants"):
		return
	print("Hit object:", target)
	print("Is in 'Plants':", target.is_in_group("Plants"))
	print("Has 'water' method:", target.has_method("water"))

	
	
	
	is_watering = true
	velocity = Vector2.ZERO
	
	#WATERING Starts
	walk_sprite.visible = false
	watering_sprite.visible = true
	
	water_anim.set("parameters/Water/blend_position", last_direction)
	
	#Waiting for animation
	await  get_tree().create_timer(1.2).timeout
	
	#Watering Ends
	is_watering = false
	walk_sprite.visible = true
	watering_sprite.visible = false
	
	
	if target.has_method("water"):
		target.water()
