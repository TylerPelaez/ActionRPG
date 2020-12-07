extends VBoxContainer

#TODO
func _ready():
	pass

func initialize(stats):
	stats.connect("health_changed", self, "_on_Stats_health_changed")

func _on_Stats_health_changed(value):
	pass

func appear():
	show()

func disappear():
	hide()

