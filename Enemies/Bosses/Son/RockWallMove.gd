extends Move

func calculate_new_target_position():
	return owner.room.get_node("RoomCenter").global_position
