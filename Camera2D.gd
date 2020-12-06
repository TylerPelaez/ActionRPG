extends Camera2D

func set_limits(topLeft, bottomRight):
	limit_top = topLeft.y
	limit_left = topLeft.x
	limit_bottom = bottomRight.y
	limit_right = bottomRight.x
