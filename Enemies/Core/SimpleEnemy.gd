extends Enemy
class_name Bat

onready var sprite = $AnimatedSprite
onready var animationPlayer = $InvincibilityAnimationPlayer

func _ready():
	sprite.frame = randi() % sprite.frames.get_frame_count("default")

func update_animation():
	sprite.flip_h = velocity.x < 0

func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("Stop")

func _on_Hurtbox_invincibility_started():
	animationPlayer.play("Start")

