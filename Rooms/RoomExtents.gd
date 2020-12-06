extends Area2D

const CAMERA_LIMIT_OFFSET = 32

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
		
		topLeft.global_position = Vector2(global_position.x + min_x, global_position.y + min_y)
		bottomRight.global_position = Vector2(global_position.x + max_x, global_position.y + max_y)

func topLeft():
	return topLeft.global_position
	
func bottomRight():
	return bottomRight.global_position
