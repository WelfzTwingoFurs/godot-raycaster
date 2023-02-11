extends KinematicBody2D

export var positionZ = 0
var dontCollideWall = false
var dontCollideSprite = false
var averages = 0
var head_height = 100

var motion = Vector2()

func _ready():
	Worldconfig.playeraim = self
	#add_collision_exception_with($model)
	add_collision_exception_with($wheel0)
	add_collision_exception_with($wheel1)
	add_collision_exception_with($wheel2)
	add_collision_exception_with($wheel3)
	for n in $model.get_children():
		#if n.is_in_group("render"):
		add_collision_exception_with(n)

















export var wheel_base = 70  # Distance from front to rear wheel
export var steer_multi = 15  # Amount that front wheel turns, in degrees
export(float) var steer_max = 1.5
export(float) var steer_rate = 0.075

export var engine_power = 8  
export var break_power = 16

var steer_angle
var turn = 0
var traction = 0.1

func move_and_steer(delta):
	
	if abs(turn) > steer_max:
		turn = steer_max*sign(turn)
	
	if Input.is_action_pressed("ui_right"):
		turn += steer_rate
	elif Input.is_action_pressed("ui_left"):
		turn -= steer_rate
	else:
		turn = lerp(turn, 0, 1)
	steer_angle = turn * deg2rad(steer_multi)
	
	#motion = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		motion += transform.x*engine_power
	elif Input.is_action_pressed("ui_down"):
		motion -= transform.x*break_power
		if abs(motion.x) < 10:
			motion.x = 0
		if abs(motion.y) < 10:
			motion.y = 0
	
	#print(transform)
	
	
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	
	if ($wheel0.on_floor == true) or ($wheel1.on_floor == true):
		rear_wheel += motion * delta
	if ($wheel2.on_floor == true) or ($wheel3.on_floor == true):
		front_wheel += motion.rotated(steer_angle) * delta
	
	
	var new_heading = (front_wheel - rear_wheel).normalized()
	#motion = new_heading * motion.length()
	motion = motion.linear_interpolate(new_heading * motion.length(), traction)
	#velocity.linear_interpolate(new_heading * velocity.length(), traction)
	rotation = new_heading.angle()


export var cameraon = true
export var camdist = 500
export var camheight = 500
export var camZdivide = 2

func _process(_delta):
	if Worldconfig.player.camera:
		Worldconfig.player.position = position - Vector2(camdist,0).rotated(deg2rad(rotation_degrees))
		Worldconfig.player.rotation_angle = rad_overflow(deg2rad(rotation_degrees)-PI/2)+0.0001
		#Worldconfig.player.rotation_angle = lerp_angle(Worldconfig.player.rotation_angle, rad_overflow(deg2rad(rotation_degrees)), 0.1)
		Worldconfig.player.positionZ = ($wheel0.positionZ + $wheel1.positionZ + $wheel2.positionZ + $wheel3.positionZ)/4 + camheight
		#Worldconfig.player.positionZ = lerp(Worldconfig.player.positionZ, (($wheel0.positionZ + $wheel1.positionZ + $wheel2.positionZ + $wheel3.positionZ)/4 + camheight + abs([$wheel0.positionZ, $wheel1.positionZ, $wheel2.positionZ, $wheel3.positionZ].min() - [$wheel0.positionZ, $wheel1.positionZ, $wheel2.positionZ, $wheel3.positionZ].max())/camZdivide), 0.1)
		
		if motion != Vector2(0,0):
			Worldconfig.player.vbob += Worldconfig.player.vbob_speed
			

func _physics_process(delta):
	motion = move_and_slide(motion, Vector2(0,-1))
	if Worldconfig.player.camera:
		move_and_steer(delta)
	
	#Worldconfig.player.vroll = (($wheel0.positionZ + $wheel1.positionZ)/2 - ($wheel2.positionZ + $wheel3.positionZ)/2)*0.1
	
	
	
	
	
	
	
#	if Input.is_action_pressed("ply2_up"):
#		motion += Vector2(0,10).rotated(deg2rad(rotation_degrees))
#
#	elif Input.is_action_pressed("ply2_down"):
#		motion -= Vector2(0,10).rotated(deg2rad(rotation_degrees))
#
#	else:
#		motion = lerp(motion,Vector2(0,0),0.1)
#
#	if Input.is_action_pressed("ply2_left"):
#		if Input.is_action_pressed("ui_select"):
#			position += Vector2(5,0).rotated(deg2rad(rotation_degrees))
#		else:
#			rotation_degrees -= 5
#
#	elif Input.is_action_pressed("ply2_right"):
#		if Input.is_action_pressed("ui_select"):
#			position -= Vector2(5,0).rotated(deg2rad(rotation_degrees))
#		else:
#			rotation_degrees += 5
	
	
	
	
	
	
	$model/base.extraZ[0] = $wheel0.positionZ
	$model/base.extraZ[1] = $wheel1.positionZ
	$model/base.extraZ[2] = $wheel2.positionZ
	$model/base.extraZ[3] = $wheel3.positionZ
	
	
	
	
	positionZ = ($wheel0.positionZ + $wheel1.positionZ + $wheel2.positionZ + $wheel3.positionZ)/4
	#positionZ = [$wheel0.positionZ, $wheel1.positionZ, $wheel2.positionZ, $wheel3.positionZ].min()
	
	#head_height = [$wheel0.positionZ, $wheel1.positionZ, $wheel2.positionZ, $wheel3.positionZ].min() - [$wheel0.positionZ, $wheel1.positionZ, $wheel2.positionZ, $wheel3.positionZ].max()




func collide():
	for n in col_sprites.size():
		if (dontCollideSprite) or (col_sprites[n].dontCollideSprite):
			add_collision_exception_with(col_sprites[n])
			
		
		else:
			var heightsBT = Vector2(-1,1)
			
			heightsBT.x = col_sprites[n].positionZ
			heightsBT.y = col_sprites[n].positionZ+col_sprites[n].head_height
			
			
			
			#pé < baixo, cabeça > baixo
			#pé > baixo, cabeça < topo
			#pé < topo, cabeça > topo
			if (positionZ <= heightsBT.x && positionZ+head_height >= heightsBT.x) or (positionZ >= heightsBT.x && positionZ+head_height <= heightsBT.y) or (positionZ < heightsBT.y && positionZ+head_height >= heightsBT.y): 
				# pé < topo, cabeça > topo, pé - topo = <head_height
				if (positionZ < heightsBT.y && positionZ+head_height > heightsBT.y) && (positionZ - heightsBT.y < head_height/2):
					positionZ = heightsBT.y
					#on_floor = true
					on_body = true
					body_on = col_sprites[n]
				
				elif (positionZ < heightsBT.x && positionZ+head_height > heightsBT.x) && ((positionZ+head_height) - heightsBT.x < head_height/2):
					positionZ = heightsBT.x - head_height -1
					on_body = false
				
				else:
					remove_collision_exception_with(col_sprites[n])
			
			else:
				add_collision_exception_with(col_sprites[n])
	
	
	
	
	
	
	for n in col_walls.size():
		if dontCollideWall:
			add_collision_exception_with(col_walls[n])
			
		
		else:
			if col_walls[n].flag_2height:
				var heightsBT = Vector2(-1,1)
				
				if col_walls[n].heights[1] < col_walls[n].heights[2]:
					heightsBT.x = col_walls[n].heights[1]
					heightsBT.y = col_walls[n].heights[2]
				else:
					heightsBT.x = col_walls[n].heights[2]
					heightsBT.y = col_walls[n].heights[1]
				
				#pé < baixo, cabeça > baixo
				#pé > baixo, cabeça < topo
				#pé < topo, cabeça > topo
				if (positionZ <= heightsBT.x && positionZ+head_height >= heightsBT.x) or (positionZ >= heightsBT.x && positionZ+head_height <= heightsBT.y) or (positionZ < heightsBT.y && positionZ+head_height >= heightsBT.y): 
					# pé < topo, cabeça > topo, pé - topo = <head_height
					if col_walls[n].jumpover && (positionZ < heightsBT.y && positionZ+head_height > heightsBT.y) && (positionZ - heightsBT.y < head_height/2):
						positionZ = heightsBT.y
					
					elif col_walls[n].jumpover && (positionZ < heightsBT.x && positionZ+head_height > heightsBT.x) && ((positionZ+head_height) - heightsBT.x < head_height/2):
						positionZ = heightsBT.x - head_height -1
					
					else:
						remove_collision_exception_with(col_walls[n])
				
				else:
					add_collision_exception_with(col_walls[n])
	
	
	
	
	
	
	for n in col_floors.size():
		
		if dontCollideWall:
			add_collision_exception_with(col_floors[n])
		
		else:
		#if col_floors != null:
			if col_floors[n].flag_1height:
				
				#if col_floors[n].heights[0] < positionZ: #shadow position#
				if col_floors[n].heights[0] - positionZ < compareZ:
					compareZ = col_floors[n].heights[0] - positionZ
				
				
				
				if col_floors[n].absolute == -1:
					if positionZ > col_floors[n].heights[0]-1:
						positionZ = col_floors[n].heights[0] - head_height
						on_floor = false
				elif col_floors[n].absolute == 1:
					if positionZ < col_floors[n].heights[0]-head_height:
						positionZ = col_floors[n].heights[0]
						on_floor = true
				
				#if on_floor == false:
				if move_dir.z == -1:
					if (positionZ < col_floors[n].heights[0]) && (positionZ+head_height > col_floors[n].heights[0]):
						positionZ = col_floors[n].heights[0]# + head_height
						
						on_floor = true 
						if motionZ < 0:
							motionZ = 0
							positionZ = col_floors[n].heights[0]
				
				if move_dir.z == 1:
					if (positionZ < col_floors[n].heights[0]) && (positionZ+head_height > col_floors[n].heights[0]):
						positionZ = col_floors[n].heights[0] - head_height
						
						on_floor = false
						if motionZ > 0:
							motionZ = 0
			
			
			
			
			
			else:
				var new_height = slope(
					Vector3(position.x,position.y,0), 
					Vector3(col_floors[n].points[0].x, col_floors[n].points[0].y, col_floors[n].heights[0]), 
					Vector3(col_floors[n].points[1].x, col_floors[n].points[1].y, col_floors[n].heights[1]), 
					Vector3(col_floors[n].points[2].x, col_floors[n].points[2].y, col_floors[n].heights[2])) #+ margin
				
				
				if (col_floors[n].absolute == 1) && (positionZ < new_height):
					positionZ = new_height
					on_floor = true
				elif (col_floors[n].absolute == -1) && (positionZ + head_height > new_height):
					positionZ = new_height - head_height
					on_floor = false
					continue
				
				
				if move_dir:
					if new_height > positionZ + head_height:
						if new_height < positionZ + head_height + motionZ:
							motionZ = -motionZ
					
					elif new_height > positionZ:
						positionZ = new_height
						on_floor = true
					else:
						if on_floor:
							positionZ = new_height
						else:
							on_floor = false




func slope(v0,v1,v2,v3):
	var normal = (v2 - v1).cross(v3 - v1).normalized()
	var dir = Vector3(0.0, 0.0, 1.0)
	var r = v0 + dir * ((v1.dot(normal)) - v0.dot(normal)) / dir.dot(normal)
	
	return r.z
	




var col_floors = []
var col_walls = []
var col_sprites = []
var on_floor = false
var on_body = false
var body_on = null
var compareZ = INF
var move_dir = Vector3(0,0,0)
var motionZ = 0

func _on_ColArea_body_shape_entered(_body_id, body, _body_shape, _local_shape):
	if body.is_in_group("floor"):
		if !col_floors.has(body):
			if (col_floors.size() == 0) && (body.flag_1height) && (on_floor == true) && (body.heights[0] < positionZ): on_floor = false
			
			col_floors.push_back(body)
			compareZ = INF
			
	elif body.is_in_group("wall"):
		if !col_walls.has(body):
			col_walls.push_back(body)
	
	elif body.is_in_group("sprite"):
		if !col_sprites.has(body):
			col_sprites.push_back(body)

func _on_ColArea_body_shape_exited(_body_id, body, _body_shape, _local_shape):
	if body.is_in_group("floor"):
		on_floor = false
		if col_floors.has(body):
			col_floors.erase(body)
			compareZ = INF
			
			if (col_floors.size() == 0) && (!dontCollideWall):
				if (positionZ <= Worldconfig.player.min_Z): positionZ = Worldconfig.player.min_Z
			
	
	if body.is_in_group("wall"):
		if col_walls.has(body):
			col_walls.erase(body)
	
	if body.is_in_group("sprite"):
		if col_sprites.has(body):
			col_sprites.erase(body)
			on_floor = false








func rad_overflow(N):
	if N > PI*2:
		N -= PI*2
	elif N < 0:
		N += PI*2
	
	return N

func deg_overflow(N):
	if N > 360:
		N -= 360
	elif N < 360:
		N += 360
	
	return N