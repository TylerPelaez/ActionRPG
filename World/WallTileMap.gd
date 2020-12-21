extends TileMap

func _ready():
	for cell in get_used_cells():
		var auto_cell = get_cell_autotile_coord(cell.x, cell.y)
		var autotile_occluder = tile_set.autotile_get_light_occluder(0, auto_cell)
		var polygon = OccluderPolygon2D.new()
		
		var light_occluder = LightOccluder2D.new()
		add_child(light_occluder)
		light_occluder.light_mask = 1
		light_occluder.occluder = autotile_occluder
		light_occluder.occluder.cull_mode = OccluderPolygon2D.CULL_COUNTER_CLOCKWISE
		light_occluder.position = map_to_world(cell)
		light_occluder.show_behind_parent = true
		light_occluder.z_index = -1
		
	var region_size = tile_set.tile_get_region(0).size 
	var subtile_size = tile_set.autotile_get_size(0)
	var dimensions = region_size / subtile_size
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			tile_set.autotile_set_light_occluder(0, null, Vector2(x,y))
