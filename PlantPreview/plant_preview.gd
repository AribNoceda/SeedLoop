extends Node2D

@export var tilemap: TileMapLayer
@export var player : Node2D
@export var textures : Array[Texture2D]
@export var selected_plant_index := 0

@onready var sprite := $Sprite2D
var can_plant := false
var hovered_cell := Vector2i.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if Input.is_action_just_pressed("VineClimber"):
			selected_plant_index = 0
		elif Input.is_action_just_pressed("FruitKeeper"):
			selected_plant_index = 1
		elif Input.is_action_just_pressed("BridgeLily"):
			selected_plant_index = 2
		elif Input.is_action_just_pressed("GlowShroom"):
			selected_plant_index = 3
		elif Input.is_action_just_pressed("WateringCan"):
			selected_plant_index = 4
			
		elif Input.is_action_just_pressed("interact") and can_plant:
			plant_at_cell(hovered_cell)

func _process(_delta: float) -> void:
	if not player or not tilemap:
		return
	
	
	var mouse_pos = get_global_mouse_position()
	var local_pos = tilemap.to_local(mouse_pos)
	var cell = tilemap.local_to_map((local_pos))
	var world = tilemap.map_to_local(cell)
	var _tile_size = tilemap.tile_set.tile_size
	var player_cell = tilemap.local_to_map(tilemap.to_local(player.global_position))
	
	
	can_plant = false
	hovered_cell = cell
	
	if abs(cell.x - player_cell.x) <= 1 and abs(cell.y - player_cell.y) <= 1:
		position = world
		
		var tile_data := tilemap.get_cell_tile_data(cell)
		var  terrain_type = null
		
		if tile_data != null:
			terrain_type = tile_data.get_custom_data("terrain")
			
			
			match selected_plant_index:
				0, 1, 3: #The rest
					can_plant = terrain_type == "empty"
					
				2: #Bridge Lily
					can_plant = terrain_type == "water"
		
		else:
			can_plant = false
		
		
		if can_plant:
			sprite.texture = textures[0]
		elif terrain_type == "water":
			sprite.texture = textures[2]
		else:
			sprite.texture = textures[1]
		
				# Check for planting input
		if Input.is_action_just_pressed("interact"):
			plant_at_cell(cell)


func plant_at_cell(cell: Vector2i) -> void:
	if not tilemap or not textures.has(selected_plant_index):
		return
		
	# AVOID double planting
	var existing = tilemap.get_cell_tile_data(cell)
	if existing and existing.get_custom_data("has_plant") == true:
		return

	# instance the plant
	var plant_scenes = {
		0: preload("res://Plants/VineClimber.tscn"),
		1: preload("res://Plants/FruitKeeper.tscn"),
		2: preload("res://Plants/BridgeLily.tscn"),
		3: preload("res://Plants/GlowShroom.tscn")
	}
	var plant_scene = plant_scenes.get(selected_plant_index)
	if not plant_scene:
		return
	
	var plant = plant_scene.instantiate()
	tilemap.get_parent().add_sibling(plant)
	plant.global_position = tilemap.map_to_local(cell) + Vector2(tilemap.tile_set.tile_size) / 2
	
	
	var tile_set = tilemap.tile_set
	var planted_atlas_coords : Vector2i = Vector2i(-1, -1)
	var found_source_id : int = -1

	
	for source_index in range(tile_set.get_source_count()):
		var source_id = tile_set.get_source_id(source_index)
		var source = tile_set.get_source(source_id)
		
		if source is TileSetAtlasSource:
			var count = source.get_tiles_count()
			for i in range(count):
				var coords = source.get_tile_id(i)
				if not source.has_tile(coords):
					continue
				var tile_data = source.get_tile_data(coords, 0)
				if tile_data.get_custom_data("has_plant") == true and tile_data.get_custom_data("plant_type") == selected_plant_index:
					planted_atlas_coords = coords
					found_source_id = source_id
					break
		if found_source_id != -1:
			break
	if found_source_id != -1 and planted_atlas_coords != Vector2i(-1,-1):
		tilemap.set_cell(hovered_cell, found_source_id, planted_atlas_coords)
