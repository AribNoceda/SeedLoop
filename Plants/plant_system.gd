extends Node2D

enum PlantStage {SEED, SPROUT, GROWN}

@export var stage_textures: Array[Texture2D] # [stages]
@export var growth_time := 5.0
@export var can_be_watered := true

var stage: PlantStage = PlantStage.SEED
var is_grown := false
var last_watered_time := -10.0

@onready var sprite := $Sprite2D
@onready var growth_timer := $GrowthTimer



func _ready() -> void:
	add_to_group("Plants")
	update_appearance()
	growth_timer.wait_time = growth_time
	growth_timer.one_shot = true
	update_appearance()
	
func water():
	if !can_be_watered or is_grown:
		return
	if growth_timer.is_stopped():
		advance_grow()
		growth_timer.start()
	else:
		print("still cooling down...")

func force_rain_grow():
	if is_grown:
		advance_grow()
		growth_timer.start()
		
		
func advance_grow():
	if stage == PlantStage.SEED:
		stage = PlantStage.SPROUT
	elif stage == PlantStage.SPROUT:
		stage = PlantStage.GROWN
		is_grown = true
	else:
		return
		
	update_appearance()
	
	
func update_appearance():
	if stage_textures.size() > int(stage):
		sprite.texture[int(stage)]
