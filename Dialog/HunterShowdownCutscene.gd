extends Node2D

export (String) var CUTSCENE_DIALOG_START = "HUNTER_CUTSCENE_1"
export (String) var CUTSCENE_TABLET = "HUNTER_TABLET_0"

signal cutscene_ended
signal cutscene_ended_and_fade_over
const UIScene = preload("res://UI/UI.tscn")
onready var animator = $CutsceneAnimator
onready var fake_player = $Player
onready var fake_hunter = $Hunter

var ui_ref


func _ready():
	if get_parent() == get_tree().root:
		# Just for debug, These lines are happening by default in game
		var instance = UIScene.instance()
		add_child(instance)
		Events.connect("event_triggered", instance.get_node("DialogueBox"), "on_Events_event_triggered" )
		
		# The cutscene animator needs to know when dialog ended to play the ending of cutscene
		initialize(instance)
		fake_player.true_pause = true
		fake_player.animationTree.active = false
		instance.fade_to_black(false)
	
	fake_player.true_pause = true
	fake_player.animationTree.active = false
	fake_hunter.visible = true
	$Hunter/Sprite.frame = 44
	$Hunter/AnimationPlayer.stop()
	Events.add_event(CUTSCENE_DIALOG_START)
	Events.add_event(CUTSCENE_TABLET)

func initialize(ui):
	# The cutscene animator needs to know when dialog ended to play the ending of cutscene
	ui.get_node("DialogueBox").connect("on_finish_dialog", self, "_on_dialog_finished")
	connect("cutscene_ended", ui, "fade_to_black", [true])
	ui.connect("black_fade_complete", self, "_on_black_fade_complete")
	ui.connect("faded_black", self, "take_camera")
	ui_ref = ui
	

func take_camera():
	fake_player.visible = !fake_player.visible
	$Camera2D.current = !$Camera2D.current

func _on_black_fade_complete():
	if $Camera2D.current:
		animator.play("CutsceneStart")
		ui_ref.disconnect("faded_black", self, "take_camera")
	else:
		emit_signal("cutscene_ended_and_fade_over")
		queue_free()

func _on_CutsceneStart_finished():
	Events.trigger(CUTSCENE_DIALOG_START)
	
func _on_WalkToTablet_finished():
	Events.trigger(CUTSCENE_TABLET)

# Player walks up, then first dialog occurs. 
# Once dialog ends, player walks closer to the tablet, tablet dialog occurs.
# Then Player talks to the hunter one last time, befor fight

func _on_dialog_finished(dialogName):
	if dialogName == CUTSCENE_DIALOG_START:
		animator.play("WalkToTablet")
	elif dialogName == CUTSCENE_TABLET:
		animator.play("CutsceneEnd")

# Tell game to continue + start boss fight
func _on_CutsceneEnd_finished():
	emit_signal("cutscene_ended")
