extends Control

signal on_play_dialog
signal on_finish_dialog

const OPEN_DOOR_DIALOG_NAME = "OPEN_DOOR"
const DEBUG_DIALOG = "DEBUG_DIALOG"
const DEBUG_STORY = preload("res://Dialog/Stories/DialogsBaked.tres")
const StoryReaderClass = preload("res://addons/EXP-System-Dialog/Reference_StoryReader/EXP_StoryReader.gd")

const SPEAKER_COLOR_LOOKUP = {
	"Son": Color.white
}

onready var bodyAnimationPlayer = $MarginContainer/MarginContainer/BodyLabel/AnimationPlayer
onready var bodyLabel = $MarginContainer/MarginContainer/BodyLabel

var _did = 0
var _nid = 0
var _final_nid = 0
var story_reader
var is_waiting = false

var debug = false

func _ready():
	story_reader = StoryReaderClass.new()
	set_story(DEBUG_STORY)
	
	assert_lengths()
	
	if debug:
		visible = false
		play_dialog(DEBUG_DIALOG)


func set_story(story: Resource):
	story_reader.read(story)

# TODO: input
func _input(event):
	if event is InputEventKey:
		if event.pressed == true and Input.is_action_just_pressed("attack") && visible:
			_on_Dialog_Player_advanced()
			Input.action_release("attack")

func _on_Dialog_Player_advanced():
	if _is_waiting():
		is_waiting = false
		_get_next_node()
		if _is_playing():
			_play_node()
	else:
		bodyAnimationPlayer.playback_speed = 3.0

# Public Methods

func play_dialog(record_name : String):
	_did = story_reader.get_did_via_record_name(record_name)
	_nid = story_reader.get_nid_via_exact_text(_did, "<start>")
	_final_nid = story_reader.get_nid_via_exact_text(_did, "<end>")
	_get_next_node()
	_play_node()
	get_tree().paused = true
	visible = true
	emit_signal("on_play_dialog")

# Private Methods

func _is_playing():
	return visible

func _is_waiting():
	return is_waiting

func assert_lengths():
	for did in story_reader.get_dids():
		for nid in story_reader.get_nids(did):
			var text = story_reader.get_text(did, nid)
			var speaker = _get_tagged_text("speaker", text)
			var dialog = _get_tagged_text("dialog", text)
			# nice
			assert (dialog.length() < 69)

func _get_next_node():
	_nid = story_reader.get_nid_from_slot(_did, _nid, 0)
	
	if _nid == _final_nid:
		visible = false
		get_tree().paused = false
		emit_signal("on_finish_dialog")

func _get_tagged_text(tag : String, text : String):
	var start_tag = "<" + tag + ">"
	var end_tag = "</" + tag + ">"
	var start_index = text.find(start_tag) + start_tag.length()
	var end_index = text.find(end_tag)
	var substr_length = end_index - start_index
	return text.substr(start_index, substr_length)


func _play_node():
	var text = story_reader.get_text(_did, _nid)
	var speaker = _get_tagged_text("speaker", text)
	var dialog = _get_tagged_text("dialog", text)
	
	var textColor = Color.white
	if SPEAKER_COLOR_LOOKUP.has(speaker):
		textColor = SPEAKER_COLOR_LOOKUP[speaker]
	
	bodyLabel.text = dialog
	bodyLabel.set("custom_colors/font_color", textColor)
	bodyAnimationPlayer.play("ShowText")


func on_Events_event_triggered(dialogName: String):
	assert(!_is_playing())
	
	# This way, we can display specific door open text if we want, falling back to regular open door text
	if story_reader.has_record_name(dialogName):
		play_dialog(dialogName)
	elif dialogName.find(OPEN_DOOR_DIALOG_NAME) != -1:
		play_dialog(OPEN_DOOR_DIALOG_NAME)

func _on_AnimationPlayer_animation_finished(anim_name):
	is_waiting = true
	bodyAnimationPlayer.playback_speed = 1.0
