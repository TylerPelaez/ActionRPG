extends Control

const HeartIcon = preload("res://UI/HeartIcon.tscn")

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var icons = $Icons

func set_hearts(value):
	hearts = clamp((float(value) / 2.0), 0, max_hearts)
	reset_icons()
	
func set_max_hearts(value):
	max_hearts = max(int(value / 2), 1)
	self.hearts = min(hearts, max_hearts) * 2
	reset_icons()
	
func delete_icons():
	for child in icons.get_children():
		icons.remove_child(child)
		child.queue_free()

# max_hearts = 4
# hearts = 2

func reset_icons():
	delete_icons()
	
	for i in range(0, max_hearts):
		if i <= (hearts - 1.0):
			var icon = HeartIcon.instance()
			icon.set_full()
			icons.add_child(icon)
		elif (hearts - 0.5) == i:
			var icon = HeartIcon.instance()
			icon.set_half()
			icons.add_child(icon)
		else:
			var icon = HeartIcon.instance()
			icon.set_empty()
			icons.add_child(icon)

func _ready():
	self.max_hearts = PlayerStats.max_health 
	self.hearts = PlayerStats.health
	reset_icons()
# warning-ignore:return_value_discarded
	PlayerStats.connect("health_changed", self, "set_hearts")
# warning-ignore:return_value_discarded
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
