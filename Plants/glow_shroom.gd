extends "res://Plants/plant_system.gd"

@onready var light := $PointLight2D
var last_growth_time := 0.0

func _ready() -> void:
	add_to_group("Plants")
	update_appearance()
	last_growth_time = Time.get_ticks_msec() / 1000.0  # in seconds

func update_appearance():
	if stage_textures.size() > int(stage):
		sprite.texture = stage_textures[int(stage)]
	light.visible = (stage == PlantStage.GROWN)

func water():
	var current_time := Time.get_ticks_msec() / 1000.0
	if current_time - last_growth_time >= 5.0 and stage < PlantStage.GROWN:
		stage += 1
		last_growth_time = current_time
		update_appearance()
