extends Move
class_name SimpleAttackMove

func calculate_new_target_position():
	var roomExtents = owner.room.roomExtents
	var point = Vector2.ZERO

	while (true):
		point = roomExtents.getRandomPointInRoom()
		
		if (start_position.distance_to(point) > 25 && 
			owner.target.global_position.distance_to(point) > 25 && 
			Utils.shape_cast(HunterCollisionShape, owner.global_transform.translated(point))):
			break
	
	return point
