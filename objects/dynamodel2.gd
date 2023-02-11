extends Node2D

export(float) var scaleZ = 2.8
export var offset = -27

func _ready():
	for n in get_children():
		if n.is_in_group("render"):
			for m in n.heights.size():
				n.heights[m] *= scaleZ


func _physics_process(_delta):
	var average_back = (to_global($base.points[0]) + to_global($base.points[1]))/2
	var average_left = (to_global($base.points[1]) + to_global($base.points[2]))/2
	var average_front = (to_global($base.points[2]) + to_global($base.points[3]))/2
	var average_right = (to_global($base.points[3]) + to_global($base.points[0]))/2

	
	
	for n in get_children():
		if n.is_in_group("render"):
			for m in n.points.size():
				n.extraZ[m] = theraot(
					Vector3(to_global(n.points[m]).x, to_global(n.points[m]).y, n.heights[m] + n.extraZ[m]),
		Vector3(average_right.x, average_right.y, $base.heights[0] + $base.extraZ[0] +offset),
		Vector3(average_left.x, average_left.y, $base.heights[1] + $base.extraZ[1] +offset), 
		Vector3(average_front.x, average_front.y, ((($base.heights[2] + $base.extraZ[2]) + ($base.heights[3] + $base.extraZ[3]))/2 +offset) ))#############



func theraot(v0,v1,v2,v3):
	var normal = (v2 - v1).cross(v3 - v1).normalized()
	var dir = Vector3(0.0, 0.0, 1.0)
	var r = v0 + dir * ((v1.dot(normal)) - v0.dot(normal)) / dir.dot(normal)
	
	return r.z

