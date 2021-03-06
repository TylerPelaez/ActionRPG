extends Control

signal on_play_dialog
signal on_finish_dialog(dialogName)
signal choide_made


export (float) var per_character_length = .03

const OPEN_DOOR_DIALOG_NAME = "OPEN_DOOR"
const DEBUG_DIALOG = "DEBUG_DIALOG"
const DEBUG_STORY = preload("res://Dialog/Stories/DialogsBaked.tres")
const StoryReaderClass = preload("res://addons/EXP-System-Dialog/Reference_StoryReader/EXP_StoryReader.gd")
const CHOICE_DIALOG = "THE_BLADE"


const SPEAKER_COLOR_LOOKUP = {
	"Tutorial": Color.gray,
	"Self": Color.darkgreen,
	"Narrate": Color.white,
	"Hunter": Color("#4d2b25"),
	"Letter": Color.gold,
	"Tablet": Color.crimson,
	"Father": Color.crimson,
	"Son": Color.gold
}

onready var bodyTweener = $MarginContainer/MarginContainer/BodyLabel/Tween
onready var bodyLabel = $MarginContainer/MarginContainer/BodyLabel
onready var choices = [$Choice1, $Choice2, $Choice3]

var _did = 0
var _nid = 0
var _final_nid = 0
var story_reader
var current_name
var is_waiting = false
var choices_displayed = false
var final_choice

var current_focus
var debug = false

func _ready():
	story_reader = StoryReaderClass.new()
	set_story(DEBUG_STORY)
	
	assert_lengths()
	
	for choice in choices:
		choice.connect("focus_entered", self, "_on_focus_changed", [choice])

	if debug:
		visible = false
		play_dialog(DEBUG_DIALOG)
		show_choices()

func set_story(story: Resource):
	story_reader.read(story)

# TODO: input
func _input(event):
	if event is InputEventKey:
		if choices_displayed && event.pressed == true and _is_waiting() and Input.is_action_just_pressed("attack"):
			final_choice = current_focus
			hide_choices()
			_on_Dialog_Player_advanced()
			Input.action_release("attack")
		elif event.pressed == true and Input.is_action_just_pressed("attack") && visible:
			_on_Dialog_Player_advanced()
			Input.action_release("attack")
		


func _on_Dialog_Player_advanced():
	if _is_waiting():
		$AdvanceAudioPlayer.play()
		is_waiting = false
		_get_next_node()
		if _is_playing():
			_play_node()
	else:
		bodyTweener.playback_speed = 3.0

# Public Methods

func play_dialog(record_name : String):
	_did = story_reader.get_did_via_record_name(record_name)
	_nid = story_reader.get_nid_via_exact_text(_did, "<start>")
	_final_nid = story_reader.get_nid_via_exact_text(_did, "<end>")
	current_name = record_name
	if record_name.begins_with("PRELUDE"):
		PlayerStats.letters_found += 1
	
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
			var dialog = _get_tagged_text("dialog", text)
			# nice
			var length = dialog.length()
			assert(text == "<end>" || story_reader.has_slot(did, nid, 0))

func _get_next_node():
	var slot = 0
	if _nid == 4:
		if final_choice == $Choice1:
			slot = 2
		elif final_choice == $Choice2:
			slot = 1
		
	_nid = story_reader.get_nid_from_slot(_did, _nid, slot)
	
	if current_name == CHOICE_DIALOG && _nid == 4:
		show_choices()
	elif _nid == _final_nid:
		visible = false
		get_tree().paused = false
		emit_signal("on_finish_dialog", current_name)

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
	
	if speaker != "Tutorial" && speaker != "Narrate":
		dialog = '"' + dialog + '"'
	
	bodyLabel.text = dialog
	bodyLabel.set("custom_colors/font_color", textColor)
	bodyTweener.interpolate_property(bodyLabel, "percent_visible", 0, 1, dialog.length() * per_character_length, Tween.TRANS_LINEAR)
	bodyTweener.start()

func on_Events_event_triggered(dialogName: String):
	assert(!_is_playing())
	if !Utils.play_dialog:
		return
	
	# This way, we can display specific door open text if we want, falling back to regular open door text
	if story_reader.has_record_name(dialogName):
		play_dialog(dialogName)
	elif dialogName.find(OPEN_DOOR_DIALOG_NAME) != -1:
		play_dialog(OPEN_DOOR_DIALOG_NAME)

func _on_Tween_tween_completed(object, key):
	is_waiting = true
	bodyTweener.playback_speed = 1.0

func _on_focus_changed(node):
	for choice in choices:
		if choice == node:
			choice.modulate.a = 1
			current_focus = choice
		else:
			choice.modulate.a = .5

func show_choices():
	for choice in choices:
		choice.visible = true
		choice.focus_mode = FOCUS_ALL
	
	choices_displayed = true
	current_focus = $Choice2
	$Choice2.grab_focus()

func hide_choices():
	for choice in choices:
		choice.visible = false
		choice.focus_mode = FOCUS_NONE
	
	choices_displayed = false
	current_focus = null
