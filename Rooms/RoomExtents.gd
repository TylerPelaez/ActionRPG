extends Area2D

const TOP_LEFT_OFFSET = Vector2(-16, -32)
const TOP_BUFFER = Vector2(0, -8)
const BOTTOM_RIGHT_OFFSET = Vector2(16, 8)

onready var polygon = $CollisionPolygon2D
onready var nav = $Navigation2D
onready var topLeft = $Limits/TopLeft
onready var bottomRight = $Limits/BottomRight

func _ready():
	nav.initialize(polygon.polygon)	
	
	if topLeft.position == Vector2.ZERO && bottomRight.position == Vector2.ZERO:
		var min_x = Utils.MAX_INT
		var min_y = Utils.MAX_INT
		var max_x = Utils.MIN_INT
		var max_y = Utils.MIN_INT
	
		for point in polygon.polygon:
			min_x = min(min_x, point.x)
			min_y = min(min_y, point.y)
			max_x = max(max_x, point.x)
			max_y = max(max_y, point.y)
		
		topLeft.global_position = global_position + Vector2(min_x, min_y) + TOP_LEFT_OFFSET
		if fmod(topLeft.global_position.y, 32.0) == 0:
			topLeft.global_position += TOP_BUFFER
		bottomRight.global_position = global_position + Vector2(max_x, max_y) + BOTTOM_RIGHT_OFFSET

func topLeft():
	return topLeft.global_position
	
func bottomRight():
	return bottomRight.global_position
