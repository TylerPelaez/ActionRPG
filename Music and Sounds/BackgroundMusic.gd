extends AudioStreamPlayer

const track_1 = preload("res://Music and Sounds/magical_theme.ogg")
const track_2 = preload("res://Music and Sounds/spoopyzanpo.ogg")
const hunter_fight = preload("res://Music and Sounds/hunter.ogg")
const final_boss = preload("res://Music and Sounds/boss-theme.ogg")

func silence():
	stop()
	if !$Ambience.is_playing():
		$Ambience.play()

func track1():
	stream = track_1
	play()
	volume_db = -21.102
	
	if !$Ambience.playing:
		$Ambience.play()
	
func track2():
	stream = track_2
	volume_db = -18.864
	play()
	if !$Ambience.playing:
		$Ambience.play()
	
func final_boss():
	if stream != final_boss:
		volume_db = -21.102
		$Ambience.stop()
		stream = final_boss
		play()

func hunter():
	if stream != hunter_fight:
		volume_db = -27.362
		$Ambience.stop()
		stream = hunter_fight
		play()
