extends Object
class_name SphereCoord2D

var _lat: float = 0
var _long: float = 0
const PI_2: float = PI/2

func _sawtooth(value, v_min, v_max) -> float:
	var range_size = v_max - v_min
	var mod_value = fmod(value - v_min, range_size * 2)
	if mod_value > range_size:
		return v_max - (mod_value - range_size)
	else:
		return v_min + mod_value

var lat:
	get:
		return _lat
	set(value):
		_lat = value
		if _lat < -PI_2 or _lat > PI_2:
			long -= PI
			_lat = _sawtooth(_lat, -PI_2, PI_2)
			print("truncated lat to %s" % str(_lat))
			
var long:
	get:
		return _long
	set(value):
		_long = value
		if _long < -PI:
			_long = fmod(_long, PI)
		if _long > PI:
			_long = -fmod(_long, PI)
		
static var FORWARDS = new(0, 0)
static var BACKWARDS = new(PI, 0)
static var LEFT = new(-PI_2, 0)
static var RIGHT = new(PI_2, 0)
static var NORTH_POLE = new(0, PI_2)
static var SOUTH_POLE = new(0, -PI_2)
static var PRIME:
	get:
		return FORWARDS
		
func _init(lo, la):
	long = lo
	lat = la

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

	return "%° %' %\" %, %° %' %\" %" % [lat_d, lat_m, lat_s, lat_dir, 
	long_d, long_m, long_s, long_dir]

	
func to_direction() -> Vector3:
	var x: float = cos(_lat) * cos(_long)
	var z: float = cos(_lat) * sin(_long)
	var y: float = sin(_lat)
	return Vector3(x, y, z)
		
func direction() -> Vector3:
	# Convert latitude and longitude to spherical coordinates
	var x = cos(_lat) * cos(_long)
	var y = cos(_lat) * sin(_long)
	var z = sin(_lat)
	
	# Convert spherical coordinates to Cartesian coordinates
	var dir = Vector3(x, y, z)
	
	return dir
	
func add(coord: SphereCoord2D):
	# Update latitude and longitude
	lat += coord._lat
	long += coord._lat

func subtract(coord: SphereCoord2D):
	# Update latitude and longitude
	lat -= coord._lat
	long -= coord._lat
