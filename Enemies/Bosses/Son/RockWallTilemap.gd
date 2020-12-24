extends TileMap
class_name RockWallTileMap

signal destroyed

export var damage = 1

const RockWallTileBoundingBox = preload("res://Enemies/Bosses/Son/RockWallTileBoundingBox.tres")
const TileMaterial = preload("res://Enemies/Bosses/Son/RockWallTilemapShaderMaterial.tres")
const ORIGIN = Vector2(0,0)
const TILE_COUNT = 20

var expansions = 0

func _ready():
	clear()
	expand(0)
#	for tile in tile_set.get_tiles_ids():
#		tile_set.tile_set_material(tile, TileMaterial)
#		tile_set.tile_get_material(tile).set_shader_param("global_transform", get_global_transform())

# warning-ignore:unused_argument
func _physics_process(delta):
	var time = $AnimationPlayer.current_animation_position / $AnimationPlayer.current_animation_length
	
	if (float(expansions) / TILE_COUNT < time):
		expand(expansions)
	
func clear():
	.clear()
	update_bitmask_region()
	expansions = 0

func _on_ClearTimer_timeout():
	clear()
	emit_signal("destroyed")
	queue_free()

func expand(index):
# warning-ignore:narrowing_conversion
	set_cell(ORIGIN.x + index, ORIGIN.y, 0)
# warning-ignore:narrowing_conversion
	set_cell(ORIGIN.x - index, ORIGIN.y, 0)
# warning-ignore:narrowing_conversion
	set_cell(ORIGIN.x, ORIGIN.y + index, 0)
# warning-ignore:narrowing_conversion
	set_cell(ORIGIN.x, ORIGIN.y - index, 0)
	expansions += 1

	update_bitmask_region()
	fix_invalid_tiles()

func delete_cell(cell_x, cell_y):
	set_cell(cell_x, cell_y, -1)
	update_bitmask_region()

func create_finished():
	collision_mask = 0
