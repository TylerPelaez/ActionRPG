extends Boss

const SpawnShader = preload("res://Enemies/Bosses/Son/SpawnSon.shader")
const WhiteColorShader = preload("res://WhiteColor.shader")

onready var sprite = $Sprite

func set_spawn_shader():
	sprite.material.shader = SpawnShader

func set_white_color_shader():
	sprite.material.shader = WhiteColorShader
