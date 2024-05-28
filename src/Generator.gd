extends Node

@export var generator: WorldGenerator

class Part:
	var positions: PackedVector3Array
	var colors: PackedColorArray
	var from_x: float
	var from_y: float
	var detail: float = 0

func create_part(detail: float, from_x: float, from_y: float, size_x: float, size_y: float) -> Part:
	var part: Part = Part.new()
	part.from_x = from_x
	part.from_y = from_y
	part.detail = detail
	var steps_long = int(abs(size_y) * detail)
	var steps_lat = int(abs(size_x) * detail)
	
	var step_long = size_y / steps_long
	var step_lat = size_x / steps_lat
	#var step_x = abs(from.x - to.x) / detail
	#var step_y = abs(from.y - to.y) / detail
	#var current: SphereCoord2D = SphereCoord2D.new(from.long, from.lat)
	#for x in Vector3(0.0, abs(size_long), 1.0/detail):
	#	current.long = from._long + x if size_long > 0 else -x
	#	for y in Vector3(0.0, abs(size_lat), 1.0/detail):
	#		current.lat = from._lat + y if size_lat > 0 else -y
	#		add_part_point(part, current);
	
	# Create the grid of triangles
	for i in range(steps_long):
		for j in range(steps_lat):
			var top_left = Vector2(from_x + i * step_long, from_y + j * step_lat)
			var top_right = Vector2(from_x + (i + 1) * step_long, from_y + j * step_lat)
			var bottom_left = Vector2(from_x + i * step_long, from_y + (j + 1)  * step_lat)
			var bottom_right = Vector2(from_x + (i + 1) * step_long, from_y + (j + 1) * step_lat)
			
			# Add two triangles for each grid square
			add_part_point(part, top_left)
			add_part_point(part, top_right)
			add_part_point(part, bottom_left)
			
			add_part_point(part, bottom_left)
			add_part_point(part, top_right)
			add_part_point(part, bottom_right)
	return part

var tristate: int = 0

func add_part_point(part: Part, coord: Vector2) -> void:
	tristate += 1
	var x: float = cos(coord.x) * cos(coord.y)
	var z: float = cos(coord.x) * sin(coord.y)
	var y: float = sin(coord.x)
	var vec2 = Vector2(x, z)
	var magnitude = generator.sample_position(vec2)
	var from_center = Vector3(x, y, z) * magnitude
	
	part.positions.push_back(from_center)
	part.colors.push_back(generator.sample_color(vec2))
	
	if tristate >= 3:
		tristate = 0
