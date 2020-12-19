extends Boss

const TrapScene = preload("res://Enemies/Bosses/Hunter/BearTrap.tscn")

const MAX_TRAPS = 2
const directionLookup = {
	Vector2.RIGHT: "Right",
	Vector2.UP: "Up",
	Vector2.DOWN: "Down",
	Vector2.LEFT: "Left"
}

var traps_laid = []
var last_direction = Vector2.DOWN

onready var animationPlayer = $AnimationPlayer

func get_direction(input_direction):
	var max_dot = -100
	var best_direction = Vector2.DOWN
	
	for direction in directionLookup.keys():
		var dot: float = float(input_direction.dot(direction))
		if dot > max_dot:
			max_dot = dot
			best_direction = direction
			
	return best_direction


func play_animation(animationName, direction):
	var end_direction = directionLookup[get_direction(direction.normalized())] 
	if animationPlayer.is_playing() && animationPlayer.current_animation.begins_with(animationName):
		var start_time = animationPlayer.current_animation_position
		animationPlayer.play(animationName + end_direction)
		animationPlayer.seek(start_time)
	else:
		animationPlayer.play(animationName + end_direction)
	
	last_direction = end_direction

func _on_beartrap_death(instance):
	traps_laid.erase(instance)

func lay_trap():
	if traps_laid.size() >= MAX_TRAPS:
		traps_laid.pop_front().die()
	
	var instance = Utils.instance_scene_on_main(TrapScene, global_position)
	instance.connect("on_death", self, "_on_beartrap_death")
	traps_laid.push_back(instance)
