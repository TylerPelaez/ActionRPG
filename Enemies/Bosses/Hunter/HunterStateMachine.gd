extends BossStateMachine

func _decide_on_next_state():
	# Battle start
	if current_state == null:
		return $Spawn
	if current_state == $Spawn:
		return $Idle
	if current_state == $Idle:
		return $SimpleAttackSequence
	if current_state == $SimpleAttackSequence:
		return $AreaAttackSequence
	if current_state == $AreaAttackSequence:
		return $SimpleAttackSequence
