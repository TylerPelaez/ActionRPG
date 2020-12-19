extends Room


var player
var boss

func _ready():
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
	open_doors()

func spawn_boss():
	boss.initialize(player, self)
	boss.start()
	
func _on_RoomExtents_body_entered(body):
	._on_RoomExtents_body_entered(body)
	player = body
	if !room_defeated:
		spawn_boss()

func _on_RoomExtents_body_exited(body):
	player = null
