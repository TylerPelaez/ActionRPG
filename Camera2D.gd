extends Camera2D

func set_limits(topLeft, bottomRight):
	limit_top = topLeft.y
	limit_left = topLeft.x
	limit_bottom = bottomRight.y
	limit_right = bottomRight.x

func limit_top_left():
	return Vector2(limit_left, limit_top)
	
func limit_bottom_right():
	return Vector2(limit_right, limit_bottom)
