extends Node
#Singleton!

const draw_debug = true
const MAX_INT = 9223372036854775807
const MIN_INT = -9223372036854775808

func instance_scene_on_main(scene, position):
	var main = get_tree().current_scene
	var instance = scene.instance()
	main.add_child(instance)
	instance.global_position = position
	return instance
