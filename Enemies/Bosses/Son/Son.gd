extends Boss

const SpawnShader = preload("res://Enemies/Bosses/Son/SpawnSon.shader")
const WhiteColorShader = preload("res://WhiteColor.shader")
const WallTilemapScene = preload("res://Enemies/Bosses/Son/RockWallTilemap.tscn")

const WALL_ORIGIN_OFFSET = Vector2(-8, -8) 


onready var sprite = $Sprite
onready var wall_origin = $WallOrigin

var wall 

func set_spawn_shader():
	sprite.material.shader = SpawnShader

func set_white_color_shader():
	sprite.material.shader = WhiteColorShader

func create_wall():
	wall = Utils.instance_scene_on_node(WallTilemapScene, wall_origin.global_position + WALL_ORIGIN_OFFSET, room)
	wall.connect("destroyed", self, "_on_wall_destroyed")

func _on_wall_destroyed():
	wall = null
