extends Node
#Singleton!

const draw_debug = true
const should_randomize = false

const MAX_INT = 9223372036854775807
const MIN_INT = -9223372036854775808

func _ready():
	if should_randomize:
		randomize()

func instance_scene_on_main(scene, position):
	var main = get_tree().current_scene
	var instance = scene.instance()
	main.add_child(instance)
	instance.global_position = position
	return instance


func circle_cast(shape: Shape2D, transform: Transform2D, mask: int = 1):
	var space_state = get_tree().current_scene.get_world_2d().direct_space_state
	var query = Physics2DShapeQueryParameters.new()
	query.collide_with_areas = true
	query.set_shape(shape)
	query.set_transform(transform)
	query.collision_layer = mask
	var shape_result = space_state.intersect_shape(query)
	if shape_result == null || shape_result.size() == 0:
		return true
	else:
		return false
