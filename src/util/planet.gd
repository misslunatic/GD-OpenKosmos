extends Node3D

# TODO: This needs to be tossed out and rewritten

var mesh: Mesh = Mesh.new()
@export var material: StandardMaterial3D;

@export var worldgen: WorldGenerator
@export var planet_mesh_group: Node3D

func get_fov_angle() -> float:
	return 90

func get_view_rotation() -> Vector3:
	return Vector3.FORWARD
	
func get_view_dist() -> float:
	return 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reprocess()
	
var long = 1
var lat = 1

var _detail: float = 30

@export var quadtree_noise: Noise

@export var detail: float:
	set(value):
		_detail = value
	get:
		return _detail

class PlanetQuad:
	var instance: RID
	var is_split: bool = false
	var dirty: bool = true
	var size: float = 1
	var true_pos: Vector3
	var map_pos: Vector2 = Vector2.ZERO
	var children: Array[PlanetQuad]
	var mesh: Mesh
	
	func _init(_size: float, _map_pos: Vector2, _origin: Vector3) -> void:
		size = _size
		map_pos = _map_pos
				
		var normalized = (Vector3(_map_pos.x, _map_pos.y, 0) - _origin).normalized()
		
		# Convert spherical coordinates to Cartesian coordinates
		true_pos.x = PI * cos(normalized.y) * cos(normalized.x)
		true_pos.z = PI * cos(normalized.y) * sin(normalized.x)
		true_pos.y = PI * sin(normalized.y)
	
	func split(_origin: Vector3) -> void:
		if is_split:
			return
		var new_size: float = size / 2
		var child_pos = [
			Vector2(map_pos.x, map_pos.y),
			Vector2(map_pos.x + new_size, map_pos.y),
			Vector2(map_pos.x, map_pos.y + new_size),
			Vector2(map_pos.x + new_size, map_pos.y + new_size)
		]
		
		for i in range(4):
			var child = PlanetQuad.new(new_size, child_pos[i], _origin)
			children.append(child)
		is_split = true
		
	func rejoin() -> void:
		children.clear()
		dirty = true
		is_split = false
		
	class Iterator:
		var planet: PlanetQuad
		var stack: Array[PlanetQuad]
		var i_stack: Array[int]

		func _init(_planet: PlanetQuad):
			planet = _planet
			stack = []
			i_stack = []

		func _iter_init(_arg):
			stack.append(planet)
			i_stack.append(0)
			return should_continue()

		func _iter_next(_arg):
			while stack.size() > 0:
				var current = stack[-1]
				var i_current = i_stack[-1]
				
				if current.is_split and i_current < 4:
					stack.append(current.children[i_current])
					i_stack.append(0)
					i_stack[-2] += 1
					return should_continue()
				else:
					stack.pop_back()
					i_stack.pop_back()
					
			return should_continue()

		func _iter_get(_arg) -> PlanetQuad:
			if stack.size() > 0:
				return stack[-1]
			return null

		func should_continue() -> bool:
			return stack.size() > 0

	func iter() -> Iterator:
		var _iter = Iterator.new(self)
		_iter.planet = self
		return _iter
	
var planetquad: PlanetQuad
@export var linemat: StandardMaterial3D

@export var minsize: float = 0.005
@export var detail_curve: Curve
@export var max_distance: float

func update_tree(planet: PlanetQuad) -> void:
	var count: int = 0;
	var half_original_size = planet.size / 2
	var origin = position + Vector3(half_original_size, half_original_size, half_original_size)
	for quadtree in planet.iter():
		count += 1
		var size = quadtree.size
		var pos = quadtree.map_pos
		var dist = (get_viewport().get_camera_3d().position.distance_to(quadtree.true_pos)-planet.size)
		var should_split: bool = detail_curve.sample(dist/max_distance) < size && size > minsize
		var half_size: float = size / 2
		
		if should_split and quadtree.is_split:
			continue
		elif should_split and not quadtree.is_split:
			quadtree.dirty
			var node = Node.new()
			if quadtree.instance.is_valid():
				RenderingServer.free_rid(quadtree.instance)
			quadtree.split(position)
		elif quadtree.is_split and not should_split:
			quadtree.rejoin()
		if quadtree.dirty && quadtree.is_split:
			var array = []
			array.resize(Mesh.ARRAY_MAX)
			quadtree.dirty = false
				
			var color_surface: PackedColorArray
			
			var pos_surface: PackedVector3Array = [
				# Quincunx pattern
				Vector3(0, 0, 0), 
				Vector3(0 + size, 0, 0),
				Vector3(0 + half_size, 0 + half_size, 0),
				
				Vector3(0, 0, 0), 
				Vector3(0 + half_size, 0 + half_size, 0),
				Vector3(0, 0 + size, 0),
				
				Vector3(0, 0 + size, 0), 
				Vector3(0 + half_size, 0 + half_size, 0),
				Vector3(0 + size, 0 + size, 0),
				
				Vector3(0 + size, 0 + size, 0),
				Vector3(0 + half_size, 0 + half_size, 0),
				Vector3(0 + size, 0, 0),
			]
			for i in range(pos_surface.size()):
				color_surface.append(worldgen.sample_color(
					Vector2(pos_surface[i].x, pos_surface[i].y)))
				var radius = PI
				#worldgen.sample_position(
					#Vector2(pos_surface[i].x, pos_surface[i].y)) + 1
				pos_surface[i].x += pos.x
				pos_surface[i].y += pos.y
				
				var normalized = (pos_surface[i] - origin).normalized()
				
				# Convert spherical coordinates to Cartesian coordinates
				pos_surface[i].x = radius * cos(normalized.y) * cos(normalized.x)
				pos_surface[i].z = radius * cos(normalized.y) * sin(normalized.x)
				pos_surface[i].y = radius * sin(normalized.y)
			array[Mesh.ARRAY_COLOR] = color_surface
			array[Mesh.ARRAY_VERTEX] = pos_surface
			var a_mesh = ArrayMesh.new()
			a_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)
			a_mesh.surface_set_material(0, material)
			
			quadtree.mesh = a_mesh
			quadtree.instance = RenderingServer.instance_create()
			RenderingServer.instance_set_base(quadtree.instance, quadtree.mesh.get_rid())
			RenderingServer.instance_set_scenario(quadtree.instance, get_world_3d().scenario)
			

func reprocess() -> void:
	planetquad = PlanetQuad.new(1, Vector2.ZERO, position)
	update_tree(planetquad)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	update_tree(planetquad)
	pass
	

