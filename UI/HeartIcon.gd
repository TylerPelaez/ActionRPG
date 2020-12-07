extends TextureRect

const full = preload("res://UI/HeartFull.png")
const empty = preload("res://UI/HeartEmpty.png")
const half = preload("res://UI/HeartHalf.png")

func set_full():
	texture = full

func set_empty():
	texture = empty	
	
func set_half():
	texture = half
