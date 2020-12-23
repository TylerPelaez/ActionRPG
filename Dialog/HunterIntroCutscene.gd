extends Node2D

export (String) var CUTSCENE_DIALOG_NAME = "HUNTER_CUSTCENE_0"
signal cutscene_ended
const UIScene = preload("res://UI/UI.tscn")
onready var animator = $CutsceneAnimator

var ui_ref

func _ready():
	if get_parent() == get_tree().root:
		# Just for debug, These lines are happening by default in game
		var instance = UIScene.instance()
		add_child(instance)
		Events.connect("event_triggered", instance.get_node("DialogueBox"), "on_Events_event_triggered" )
		
		
		
		# The cutscene animator needs to know when dialog ended to play the ending of cutscene
		initialize(instance)
		
		instance.fade_to_black(false)
	
	Events.add_event(CUTSCENE_DIALOG_NAME)

func initialize(ui):
	# The cutscene animator needs to know when dialog ended to play the ending of cutscene
	ui.get_node("DialogueBox").connect("on_finish_dialog", self, "_on_dialog_finished")
	connect("cutscene_ended", ui, "fade_to_black", [true])
	ui.connect("black_fade_complete", self, "_on_black_fade_complete")
	ui.connect("faded_black", self, "take_camera")
	ui_ref = ui
	

func take_camera():
	$Camera2D.current = !$Camera2D.current

func _on_black_fade_complete():
	if $Camera2D.current:
		animator.play("CutsceneStart")
		ui_ref.disconnect("faded_black", self, "take_camera")
	else:
		queue_free()

func _on_Stats_no_health():
	animator.play("HunterWalk")

func _on_HunterWalk_finished():
	Events.trigger(CUTSCENE_DIALOG_NAME)
	animator.play("Talking")

func _on_dialog_finished(dialogName):
	if dialogName == CUTSCENE_DIALOG_NAME:
		animator.play("CutsceneEnd")
	
func _on_CutsceneEnd_finished():
	emit_signal("cutscene_ended")
