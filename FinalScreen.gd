extends Control

func _ready():
	var stats = PlayerStats
	$VBoxContainer/HBoxContainer/Letters.text = "Letters: " + str(stats.letters_found) + "/5"
	$VBoxContainer/HBoxContainer/GemShards.text = "Gemshards: " + str(stats.shards)
	$VBoxContainer/HBoxContainer/Deaths.text = "Deaths: " + str(stats.death_count)
	get_tree().paused = true

func _on_Button_pressed():
	get_tree().quit()
