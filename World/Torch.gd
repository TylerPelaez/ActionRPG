extends AnimatedSprite

export var special = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if !special:
		frame = randi() % frames.get_frame_count("default")
		if randi() % 2 == 0:
			offset = Vector2(-1, 0)
			flip_h = true
	else:
		offset = Vector2(0, -6)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
