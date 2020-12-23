extends HitBox
class_name SwordHitBox

var knockback_vector := Vector2.ZERO

func _ready():
	damage = PlayerStats.player_damage
