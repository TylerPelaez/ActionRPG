extends Node2D
class_name CutsceneSpawner

export (String) var triggering_event
export (PackedScene) var Cutscene

var ui
var main_camera
var player

func _ready():
	assert(triggering_event != null)
	
	Events.subscribe(triggering_event, funcref(self, "spawn_cutscene"))
	
func initialize(_ui, camera, _player):
	ui = _ui
	main_camera = camera
	player = _player

func spawn_cutscene():
	assert(ui != null && main_camera != null)
	
	call_deferred("do_cutscene")
	
func do_cutscene():
	ui.connect("faded_black", self, "toggle_main_camera")
	var cutscene = Utils.instance_scene_on_main(Cutscene, global_position)
	cutscene.initialize(ui)
	cutscene.connect("cutscene_ended", self, "unpause_player")
	player.is_paused = true
	
	ui.fade_to_black(false)

func toggle_main_camera():
	main_camera.current = !main_camera.current

func unpause_player():
	player.is_paused = false
