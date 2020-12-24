extends BossStateMachine

var last_choice_made

func _decide_on_next_state():
	if current_state == null:
		return $Spawn
		
	if current_state == $Spawn:
		return $SummonEnemies
		
	if current_state == $SummonEnemies:
		return $SpinAttackSequence
		
	if current_state == $RockWallSequence:
		return $SpinAttackSequence
		
	if current_state == $SpinAttackSequence: 
		return $Idle
	
	if current_state == $Idle:
		if last_choice_made == $RockWallSequence && owner.can_spawn_enemy():
			last_choice_made = $SummonEnemies
			return $SummonEnemies
		else:
			last_choice_made = $RockWallSequence
			return $RockWallSequence



