extends Navigation2D

var nav_poly
onready var nav_instance = $NavigationPolygonInstance

func initialize(points: PoolVector2Array, static_bodies: Array):
	nav_poly = NavigationPolygon.new()
	
	# Adding outlines can handle the case where there is a cutout to be made squarely in the middle of the room, 
	# but the clip_polygons call handles the case where the cutout is agains the edge of the room
	
	var outlines = []
	for body in static_bodies:
		var newpolygon = PoolVector2Array()
		var polygon_bp = body.get_node("CollisionPolygon2D").get_polygon()
		for vertex in polygon_bp:
			newpolygon.append(body.transform.xform(vertex))

		var result = Geometry.clip_polygons_2d(points, newpolygon)
		if result.size() == 1:
			points = result[0]
		else:
			outlines.append(result[1])

	nav_poly.add_outline(points)
	for outline in outlines:
		nav_poly.add_outline(outline)
	
	nav_poly.make_polygons_from_outlines()

	nav_instance.set_navigation_polygon(nav_poly)

# warning-ignore:return_value_discarded
	navpoly_add(nav_poly, global_transform)
