extends Room

signal boss_died

var player
var boss
export (NodePath) var lifebarPath
export (String) var ON_ENTER_TRIGGER = "BOSS_ROOM_ENTERED"
export (String) var SPAWN_BOSS_TRIGGER = "SPAWN_BOSS"
export (bool) var SPAWN_BOSS_IMMEDIATELY = false

var cutscene_triggered = false

func _ready():
	Events.subscribe(ON_ENTER_TRIGGER, funcref(self, "_on_cutscene_triggered"))
	Events.subscribe(SPAWN_BOSS_TRIGGER, funcref(self, "spawn_boss"))
	starting_room = false
	enemy_count += 1
	room_defeated = false
	for child in get_children():
		if child is Boss:
			boss = child
			boss.connect("died", self, "on_boss_death")
			break

func on_boss_death():
	room_defeated = true
	if item_drop != null:
		Utils.call_deferred("instance_scene_on_main", item_drop, roomExtents.get_midpoint_in_bounds())
	emit_signal("boss_died")
	open_doors()

func spawn_boss():
	boss.initialize(player, self, get_node(lifebarPath))
	boss.start()
	
func reset():
	open_doors()
	if !room_defeated:
		boss.reset()

func _on_cutscene_triggered():
	cutscene_triggered = true

func _on_RoomExtents_body_entered(body):
	player = body
	if !active:
		if !room_defeated && (cutscene_triggered || SPAWN_BOSS_IMMEDIATELY):
				spawn_boss()
	._on_RoomExtents_body_entered(body)


func _on_RoomExtents_body_exited(body):
	player = null
