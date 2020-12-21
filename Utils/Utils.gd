extends Node
#Singleton!

const draw_debug = true
const should_randomize = true

const MAX_INT = 9223372036854775807
const MIN_INT = -9223372036854775808

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

func construct_query_params(shape: Shape2D, transform: Transform2D, mask: int) -> Physics2DShapeQueryParameters:
	var query = Physics2DShapeQueryParameters.new()
	query.collide_with_areas = true
	query.set_shape(shape)
	query.set_transform(transform)
	query.collision_layer = mask
	query.margin = 1.0
	return query

func shape_cast(shape: Shape2D, transform: Transform2D, mask: int = 1):
	var shape_result = shape_cast_get_result(shape, transform, mask)
	if shape_result == null || shape_result.size() == 0:
		return true
	else:
		return false		

func shape_cast_get_result(shape: Shape2D, transform: Transform2D, mask: int = 1):
	var space_state = get_tree().current_scene.get_world_2d().direct_space_state
	var query = construct_query_params(shape, transform, mask)
	var shape_result = space_state.intersect_shape(query)
	return shape_result

func shape_cast_collision_data(shape: Shape2D, transform: Transform2D, mask: int = 1):
	var space_state = get_tree().current_scene.get_world_2d().direct_space_state
	var query = construct_query_params(shape, transform, mask)
	var shape_result = space_state.collide_shape(query)
	return shape_result
