extends VBoxContainer

export var width = 250
export var height = 12

onready var TotalHealth = $HealthBar/Totalhealthbar
onready var Health = $HealthBar/Healthbar

var _stats
var _name

func _ready():
	if debug():
		visible = true
		PlayerStats.max_health = 16
		PlayerStats.health = 16 
		initialize(PlayerStats, "The Hunter")
	
func _process(delta):
	if debug() and Input.is_action_just_pressed("attack"):
		_stats.health -= 1

func reset():
	_stats.disconnect("health_changed", self, "_on_Stats_health_changed")

func initialize(stats, boss_name):
	_stats = stats
	stats.connect("health_changed", self, "_on_Stats_health_changed")
	TotalHealth.rect_size = Vector2(width, height)
	Health.rect_size = Vector2(width, height)
	
	$Nametag.text = boss_name

func _on_Stats_health_changed(value):
	Health.rect_size = Vector2((width / _stats.max_health) * value, height)

func appear():
	visible = true

func disappear():
	visible = false

func debug():
	return get_parent() == get_tree().root
