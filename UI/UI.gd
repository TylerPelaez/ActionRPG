extends CanvasLayer

signal black_fade_complete
signal faded_black

var fading_to_black = false
var show_ui_on_fade_end = false

func _ready():
# warning-ignore:return_value_discarded
	PlayerStats.connect("shards_changed", self, "update_shard_label")
	update_shard_label(PlayerStats.shards)

func update_shard_label(shardCount: int):
	$HBoxContainer/Label.text = "x" + str(shardCount)

func hide_ui():
	$HealthUI.visible = false
	$HBoxContainer.visible = false
	
func show_ui():
	$HealthUI.visible = true
	$HBoxContainer.visible = true

func fade_to_black(show_ui: bool = false):
	$ColorRect.visible = true
	$ColorRectTweener.interpolate_property($ColorRect, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$ColorRectTweener.start()
	fading_to_black = true
	show_ui_on_fade_end = show_ui
	
func fade_from_black():
	$ColorRectTweener.interpolate_property($ColorRect, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$ColorRectTweener.start()
	fading_to_black = false
	

# warning-ignore:unused_argument
func _on_ColorRectTweener_tween_completed(object, key):
	if fading_to_black:
		emit_signal("faded_black")
		if show_ui_on_fade_end:
			show_ui()
		else:
			hide_ui()
		fade_from_black()
	else:
		$ColorRect.visible = false
		emit_signal("black_fade_complete")
