extends Navigation2D


func _ready():
	pass
#	var polygon = navPolygon.get_navigation_polygon()

#       var trees = get_node("../YSort/Trees")
#       var bushes = get_node("../YSort/Bushes")
#       add_all_children_to_navPolygon(trees)
#       add_all_children_to_navPolygon(bushes)

#	polygon.make_polygons_from_outlines()
#
#	navPolygon.set_navigation_polygon(polygon)
#	navPolygon.enabled = false
#	navPolygon.enabled = true

func initialize(points: PoolVector2Array):
	var navPoly = NavigationPolygon.new()
	navPoly.add_outline(points)
	navPoly.make_polygons_from_outlines()
	navpoly_add(navPoly, global_transform)

func add_all_children_to_navPolygon(parent):
	pass
#	var polygon = navPolygon.get_navigation_polygon()
#	for child in parent.get_children():
#		var newpolygon = PoolVector2Array()
#
#		var polygon_transform = child.get_node("CollisionPolygon2D").get_global_transform()
#		var polygon_bp = child.get_node("CollisionPolygon2D").get_polygon()
#		for vertex in polygon_bp:
#			newpolygon.append(polygon_transform.xform(vertex))
#
#		polygon.add_outline(newpolygon)
