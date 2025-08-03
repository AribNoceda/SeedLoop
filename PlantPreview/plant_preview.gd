extends Node2D

@export var tilemap: TileMapLayer
@export var player : Node2D
@export var textures : Array[Texture2D]
@export var selected_plant_index := 0

@onready var sprite := $Sprite2D

func _process(delta: float) -> void:
	if not player or not tilemap:
		return
	
	
	var mouse_pos = get_global_mouse_position()
	var local_pos = tilemap.to_local(mouse_pos)
	var cell = tilemap.local_to_map((local_pos))
	var world = tilemap.map_to_local(cell)
	var tile_size = tilemap.tile_set.tile_size
	var player_cell = tilemap.local_to_map(tilemap.to_local(player.global_position))
	
	if abs(cell.x - player_cell.x) <= 1 and abs(cell.y - player_cell.y) <= 1:
		position = world
		
		var tile_data := tilemap.get_cell_tile_data(cell)
		var can_plant := false
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
