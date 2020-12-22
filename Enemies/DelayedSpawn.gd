extends Node2D
class_name DelayedSpawn

const SpawnEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export (Utils.ENEMY) var enemyToSpawn
export (int) var wave =1

func spawnEnemy():
	var instance = Utils.enemyLookup[enemyToSpawn].instance()
	get_parent().call_deferred("add_child",instance)
	instance.set_deferred("global_position", global_position)
	instance.call_deferred("activate")
	var effect  = Utils.instance_scene_on_main(SpawnEffect, global_position)
	effect.no_sound()
	
	return instance
