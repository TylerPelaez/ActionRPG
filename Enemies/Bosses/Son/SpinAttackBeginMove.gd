extends Move

export (float) var travel_distance = 50.0

func calculate_new_target_position():
	return owner.global_position + ((owner.target.global_position - owner.global_position).normalized() * travel_distance)
