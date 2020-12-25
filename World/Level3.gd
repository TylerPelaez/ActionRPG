extends Level

func _ready():
	Events.subscribe("SPAWN_BOSS", funcref(BackgroundMusic, "hunter"))

func _on_BossRoom_boss_died():
	BackgroundMusic.silence()
