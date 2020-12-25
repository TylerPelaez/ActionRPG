extends Level

func _ready():
	Events.subscribe("NEW_PATH_OPEN_DOOR", funcref(BackgroundMusic, "track2"))
