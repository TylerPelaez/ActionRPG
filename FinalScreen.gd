extends Node2D

func _ready():
	var stats = PlayerStats
	$VBoxContainer/HBoxContainer/Letters.text = "Letters: " + str(stats.letters_found) + "/5"
	$VBoxContainer/HBoxContainer/GemShards.text = "Gemshards: " + str(stats.shards)
	$VBoxContainer/HBoxContainer/GemShards.text = "Deaths: " + str(stats.death_count)

func _on_Button_pressed():
	get_tree().quit()
