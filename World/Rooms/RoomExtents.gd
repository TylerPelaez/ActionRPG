extends Area2D

const TOP_LEFT_OFFSET = Vector2(-16, -32)
const TOP_BUFFER = Vector2(0, -8)
const BOTTOM_RIGHT_OFFSET = Vector2(16, 8)

onready var polygon = $CollisionPolygon2D
onready var nav = $Navigation2D
onready var top_left = $Limits/TopLeft
onready var bottom_right = $Limits/BottomRight

func _ready():
	if top_left.position == Vector2.ZERO && bottom_right.position == Vector2.ZERO:
		var min_x = Utils.MAX_INT
		var min_y = Utils.MAX_INT
		var max_x = Utils.MIN_INT
		var max_y = Utils.MIN_INT
	
		for point in polygon.polygon:
			min_x = min(min_x, point.x)
			min_y = min(min_y, point.y)
			max_x = max(max_x, point.x)
			max_y = max(max_y, point.y)
		
		top_left.global_position = global_position + Vector2(min_x, min_y) + TOP_LEFT_OFFSET
		if fmod(top_left.global_position.y, 32.0) == 0:
			top_left.global_position += TOP_BUFFER
		bottom_right.global_position = global_position + Vector2(max_x, max_y) + BOTTOM_RIGHT_OFFSET

func getRandomPointInRoom():
	# https://observablehq.com/@scarysize/finding-random-points-in-a-polygon
	# First triangulate the polygon
	var triangles = Geometry.triangulate_polygon(polygon.polygon)
	# Select a random triangle using a cumulative distribution
	var triangle = selectRandomTriangle(triangles)
	
	# Select a random point within that triangle
	return global_transform.xform(calculateRandomPoint(triangle))
	

func getTriangle(triangles, index):
	return [polygon.polygon[triangles[index * 3]], 
			polygon.polygon[triangles[(index * 3) + 1]], 
			polygon.polygon[triangles[(index * 3) + 2]]]

func getTriangleArea(triangle):
	var a = triangle[0]
	var b = triangle[1]
	var c = triangle[2]
	
	return 0.5 * (
		(b.x - a.x) * (c.y - a.y) -
		(c.x - a.x) * (b.y - a.y)
	)

func generateDistribution(triangles):
	var totalArea = 0.0
	for i in range(triangles.size() / 3):
		var triangle = getTriangle(triangles, i)
		totalArea += getTriangleArea(triangle)
	
	# This basically tells us triangles 0 - N-1 covers X % of the total area
	var cumulativeDistribution = []
	
	for i in range(triangles.size() / 3):
		var lastValue
		if cumulativeDistribution.empty():
			lastValue = 0
		else:
			lastValue = cumulativeDistribution[i - 1]
		
		var triangle = getTriangle(triangles, i)
		var nextValue = lastValue +  (float(getTriangleArea(triangle)) / float(totalArea))
		cumulativeDistribution.push_back(nextValue)
	
	# [area1 / totalarea, area1 + area2 / totalarea, area1 + area2 + area3 / totalarea, ...]
	return cumulativeDistribution

func selectRandomTriangle(triangles):
	var cumulativeDistribution = generateDistribution(triangles)
	var rnd = randf()
	for i in range(cumulativeDistribution.size()):
		if cumulativeDistribution[i] > rnd:
			return getTriangle(triangles, i)

func calculateRandomPoint(triangle):
	var wb = randf()
	var wc = randf()
	
	# Points will be outside of the triangle, inver weights
	if wb + wc > 1:
		wb = 1 - wb
		wc = 1 - wc
		
	var a = triangle[0]
	var b = triangle[1]
	var c = triangle[2]
	
	var rb_x = wb * (b.x - a.x)
	var rb_y = wb * (b.y - a.y)
	var rc_x = wc * (c.x - a.x)
	var rc_y = wc * (c.y - a.y)
	var r_x = rb_x + rc_x + a.x
	var r_y = rb_y + rc_y + a.y
	
	return Vector2(r_x, r_y)

func topLeft():
	return top_left.global_position
	
func bottomRight():
	return bottom_right.global_position

func initialize(static_bodies):
	nav.initialize(polygon.polygon, static_bodies)
