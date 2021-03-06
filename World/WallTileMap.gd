extends TileMap

export var do_init = true

func _ready():
	if do_init:
		for cell in get_used_cells():
			var auto_cell = get_cell_autotile_coord(cell.x, cell.y)
		
			var autotile_occluder = tile_set.autotile_get_light_occluder(1, auto_cell)
			
			var light_occluder = LightOccluder2D.new()
			add_child(light_occluder)
			light_occluder.light_mask = 1
			light_occluder.occluder = autotile_occluder
			light_occluder.position = map_to_world(cell)
			light_occluder.show_behind_parent = true
			light_occluder.z_index = -1
