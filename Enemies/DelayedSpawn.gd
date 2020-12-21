extends Node2D
class_name DelayedSpawn

const SpawnEffect = preload("res://Effects/EnemyDeathEffect.tscn")

enum ENEMY {
	BAT,
	ACOLYTE,
	KNIGHT
}

const enemyLookup = {
	ENEMY.BAT: preload("res://Enemies/Bat/Bat.tscn"),
	ENEMY.ACOLYTE: preload("res://Enemies/Acolyte/Acolyte.tscn"),
	ENEMY.KNIGHT: preload("res://Enemies/StatueKnight/StatueKnight.tscn")
}

export (ENEMY) var enemyToSpawn
export (int) var wave =1

func spawnEnemy():
	var instance = enemyLookup[enemyToSpawn].instance()
	get_parent().call_deferred("add_child",instance)
	instance.set_deferred("global_position", global_position)
	instance.call_deferred("activate")
	Utils.instance_scene_on_main(SpawnEffect, global_position)
	
	return instance
