extends Level 

const winscreen = preload("res://World/WinScreen.tscn")

func _ready():
	Events.add_event("FATHER_DEATH")
	Events.subscribe("FATHER_DEATH", funcref(self, "_on_father_death"))
	Events.subscribe("SPAWN_BOSS", funcref(BackgroundMusic, "final_boss"))
	BackgroundMusic.track2()

func _on_father_death():
	BackgroundMusic.silence()
	# set up ui for fade out after final dialogue
	$CanvasLayer/DialogueBox.connect("on_finish_dialog", self, "_on_dialog_finished")
	
func _on_dialog_finished(dialogName):
	if dialogName == "THE_BLADE":
		Events.clear()
		$CanvasLayer.connect("faded_black", self, "_on_faded_black")
		
		$CanvasLayer.fade_to_black()

func _on_faded_black():
	$CanvasLayer.add_child(winscreen.instance())
