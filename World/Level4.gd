extends Level 

func _ready():
	Events.add_event("FATHER_DEATH")
	Events.subscribe("FATHER_DEATH", funcref(self, "_on_father_death"))
	
	
func _on_father_death():
	# set up ui for fade out after final dialogue
	$CanvasLayer/DialogueBox.connect("on_finish_dialog", self, "_on_dialog_finished")
	
func _on_dialog_finished(dialogName):
	if dialogName == "THE_BLADE":
		Events.clear()
		$CanvasLayer.connect("faded_black", self, "_on_faded_black")
		
		$CanvasLayer.fade_to_black()

func _on_faded_black():
	var loaded = load("res://World/WinScreen.tscn")
	get_tree().change_scene_to(loaded)
