extends Boss

export (float) var SPAWN_X_OFFSET = 32
export (float) var SPAWN_Y_OFFSET = 32
export (int) var MAX_SUMMONED_ENEMIES = 4

const SpawnEffect = preload("res://Effects/EnemyDeathEffect.tscn")
const AcolyteScene = preload("res://Enemies/Acolyte/Acolyte.tscn")
const KnightScene = preload("res://Enemies/StatueKnight/StatueKnight.tscn")

const SpawnShader = preload("res://Enemies/Bosses/Son/SpawnSon.shader")
const WhiteColorShader = preload("res://WhiteColor.shader")
const WallTilemapScene = preload("res://Enemies/Bosses/Son/RockWallTilemap.tscn")

const WALL_ORIGIN_OFFSET = Vector2(-8, -8) 


onready var sprite = $Sprite
onready var wall_origin = $WallOrigin

var wall 
var summoned_enemies = []


func set_spawn_shader():
	sprite.material.shader = SpawnShader

func set_white_color_shader():
	sprite.material.shader = WhiteColorShader

func create_wall():
	wall = Utils.instance_scene_on_node(WallTilemapScene, wall_origin.global_position + WALL_ORIGIN_OFFSET, room)
	wall.connect("destroyed", self, "_on_wall_destroyed")

func _on_wall_destroyed():
	wall = null

func can_spawn_enemy():
	return summoned_enemies.size() < MAX_SUMMONED_ENEMIES

func spawn_enemy(knight):
	assert(summoned_enemies.size() < MAX_SUMMONED_ENEMIES)
	var roomCenter = room.get_node("RoomCenter").global_position
	var offset = Vector2(-SPAWN_X_OFFSET, SPAWN_Y_OFFSET) if knight else Vector2(SPAWN_X_OFFSET, SPAWN_Y_OFFSET)
	var midpoint = ((roomCenter + global_position) / 2) + offset
	
	var scene = KnightScene if knight else AcolyteScene
	var instance = scene.instance()
	
	summoned_enemies.push_back(instance)
	
	room.call_deferred("add_child",instance)
	
	instance.set_deferred("global_position", midpoint)
	instance.call_deferred("activate")
	var effect  = Utils.instance_scene_on_main(SpawnEffect, midpoint)
	effect.no_sound()
	instance.connect("on_death", self, "_on_enemy_death", [instance])

func _on_enemy_death(enemy):
	summoned_enemies.erase(enemy)

func reset():
	clear_enemies()
	.reset()

func clear_enemies():
	for enemy in summoned_enemies:
		
		if enemy is Acolyte && enemy.spawning_projectile != null:
				enemy.spawning_projectile.queue_free()
	
		enemy.queue_free()
	
	if wall != null:
		wall.clear()
		wall.queue_free()
	summoned_enemies.clear()

func _on_Die_finished():
	clear_enemies()
	._on_Die_finished()
	Events.add_event("FATHER_DEATH")
	Events.trigger("FATHER_DEATH")
