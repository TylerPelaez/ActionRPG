extends Node

export(int) var max_health = 1 setget set_max_health
var health = max_health setget set_health

var shards = 0
var death_count = 0
var letters_found = 0
# FIXME
var player_damage = 2

signal no_health
signal health_changed(value)
signal max_health_changed(value)
signal shards_changed(value)


func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		death_count += 1
		emit_signal("no_health")

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed", max_health)

func _ready():
	Events.add_event("PLAYER_SHARD_OBTAINED")
	reset()

func _on_new_scene():
	Events.subscribe("FEEL_STRONGER", funcref(self,"increase_damage"))

func reset():
	self.health = max_health

func pickupShard():
	shards += 1
	if shards == 1:
		Events.trigger("PLAYER_SHARD_OBTAINED")
	emit_signal("shards_changed", shards)

func increase_damage():
	player_damage += 1
