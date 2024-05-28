extends SphereCoord2D
class_name SphereCoord3D
		
@export var altitude: float = 0
		
func _init(la, lo, al):
	lat = la
	long = lo
	altitude = al
	
static func from_vec3(v: Vector3) -> SphereCoord3D:
	return new(
		atan2(v.z, sqrt(v.x * v.x + v.y * v.y)),
		atan2(v.y, v.x),
		sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
	)

func _to_string() -> String:
	var lat_deg = rad_to_deg(_lat)
	var long_deg = rad_to_deg(_long)

	var lat_abs = abs(lat_deg)
	var long_abs = abs(long_deg)

	var lat_d = int(lat_abs)
	var lat_m = int((lat_abs - lat_d) * 60)
	var lat_s = int(((lat_abs - lat_d) * 60 - lat_m) * 60)

	var long_d = int(long_abs)
	var long_m = int((long_abs - long_d) * 60)
	var long_s = int(((long_abs - long_d) * 60 - long_m) * 60)

	var lat_dir = "S"
	if _lat >= 0:
		lat_dir = "N"
	var long_dir = "W"
	if _long >= 0: 
		long_dir = "E"

	return "%u, %° %' %\" %, %° %' %\" %" % [
		altitude, 
		lat_d, lat_m, lat_s, lat_dir, 
		long_d, long_m, long_s, long_dir
	]

func to_vector() -> Vector3:
	return to_direction() * altitude
	
func addv(pos: Vector3):
	add3d(from_vec3(pos))
	
func subtractv(pos: Vector3):
	subtract3d(from_vec3(pos))
		
func add3d(pos: SphereCoord3D):
	# Update latitude and longitude
	altitude += pos.altitude
	add(pos)

func subtract3d(pos: SphereCoord3D):
	# Update latitude and longitude
	altitude -= pos.altitude
	subtract(pos)
