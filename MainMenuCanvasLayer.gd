extends CanvasLayer

func _ready():
	pass

func _on_Play_pressed():
	get_tree().change_scene("res://World/Level1.tscn")

func _on_About_pressed():
	$AboutScreen.visible = true
	$AboutScreen/Back.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_Back_pressed():
	$AboutScreen.visible = false
	$AboutScreen/Back.mouse_filter = Control.MOUSE_FILTER_PASS
