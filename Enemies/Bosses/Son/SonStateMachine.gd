extends BossStateMachine

func _decide_on_next_state():
	# Battle start
	if current_state == null:
		return $Spawn
	if current_state == $Spawn:
		return $RockWallSequence
	if current_state == $RockWallSequence:
		return $SpinAttackSequence
	if current_state == $SpinAttackSequence:
		return $RockWallSequence
	if current_state == $Idle:
		return $RockWallSequence