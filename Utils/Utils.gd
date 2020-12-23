extends Node

enum ENEMY {
	BAT,
	ACOLYTE,
	KNIGHT,
	SMALLBAT
}


const enemyLookup = {
	ENEMY.BAT: preload("res://Enemies/Bat/Bat.tscn"),
	ENEMY.ACOLYTE: preload("res://Enemies/Acolyte/Acolyte.tscn"),
	ENEMY.KNIGHT: preload("res://Enemies/StatueKnight/StatueKnight.tscn"),
	ENEMY.SMALLBAT: preload("res://Enemies/Bat/SmallBat.tscn")
}

const draw_debug = false
const should_randomize = true
const play_dialog = true

# I know these arent actually max int, but godot was complaining about maxint being too high :(
const MAX_INT = 9223372036854775
const MIN_INT = -9223372036854775

var level = 1

func _ready():
	if should_randomize:
		randomize()

func instance_scene_on_main(scene, position):
	var main = get_tree().current_scene
	return instance_scene_on_node(scene, position, main)

func instance_scene_on_node(scene, position, node):
	var instance = scene.instance()
	node.add_child(instance)
	instance.global_position = position
	return instance


func construct_query_params(shape: Shape2D, transform: Transform2D, mask: int = 1, exclude: Array = []) -> Physics2DShapeQueryParameters:
	var query = Physics2DShapeQueryParameters.new()
	query.collide_with_areas = true
	query.set_shape(shape)
	query.set_transform(transform)
	query.exclude = exclude
	query.collision_layer = mask
	query.margin = 1.0
	return query

func shape_cast(shape: Shape2D, transform: Transform2D, mask: int = 1):
	var shape_result = shape_cast_get_result(shape, transform, mask)
	if shape_result == null || shape_result.size() == 0:
		return true
	else:
		return false		

func shape_cast_get_result(shape: Shape2D, transform: Transform2D, mask: int = 1, exclude: Array = []):
	var space_state = get_tree().current_scene.get_world_2d().direct_space_state
	var query = construct_query_params(shape, transform, mask, exclude)
	var shape_result = space_state.intersect_shape(query)
	return shape_result

func shape_cast_collision_data(shape: Shape2D, transform: Transform2D, mask: int = 1):
	var space_state = get_tree().current_scene.get_world_2d().direct_space_state
	var query = construct_query_params(shape, transform, mask)
	var shape_result = space_state.collide_shape(query)
	return shape_result

func shape_cast_motion_does_not_collide(shape: Shape2D, transform: Transform2D, origin: Vector2, endpoint: Vector2, mask: int = 1, exclude: Array = []):
	var space_state = get_tree().current_scene.get_world_2d().direct_space_state
	var query = construct_query_params(shape, transform, mask, exclude)
	query.motion = endpoint - origin
	var motion_result = space_state.cast_motion(query)
	if motion_result != null && !motion_result.empty() && motion_result[0] == 1.0 && motion_result[1] == 1.0:
		return true
	else:
		return false

func get_scene_from_enemy_object(enemy):
	assert (enemy is Enemy)
	if enemy is Smallbat:
		return enemyLookup[ENEMY.SMALLBAT] 
	if enemy is Bat:
		return enemyLookup[ENEMY.BAT]
	elif enemy is Acolyte:
		return enemyLookup[ENEMY.ACOLYTE]
	elif enemy is StatueKnight:
		return enemyLookup[ENEMY.KNIGHT]
	return null

func load_next_level():
	level += 1
# warning-ignore:return_value_discarded
	get_tree().change_scene(Utils.get_scene(Utils.level))	

func get_scene(sceneNumber):
	return "res://World/Level" + str(sceneNumber) + ".tscn"
