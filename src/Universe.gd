extends Node

# WIP

class UniverseObject:
	var semi_major_axis: float
	var eccentricity: float
	var inclination: float
	var altitude: float
	
	func get_mass() -> float:
		return 1
	func get_velocity() -> Vector3:
		return Vector3.FORWARD
	func get_position() -> Vector3:
		return Vector3.ONE

var gravitators: Array[UniverseObject]
var objects: Array[UniverseObject]

var G: float = 9.8

# Newton's equation of motion
#func step(time: float):
	#for obj in objects:
		#var force: Vector3
		#for grav in gravitators:
			#var qI = obj.get_position()
			#var qJ = grav.get_position()
			#var magnitude: Vector3 = abs(qJ - qI) ^ 3
			#
			#if is_equal_approx(magnitude.length(), 0):
				#continue
			#
			#force += G * obj.get_mass() * grav.get_mass() * (qJ - qI) / magnitude
		#apply_force_to_orbit(obj, force, time)
#
## Function to apply force to orbital parameters
#func apply_force_to_orbit(obj: UniverseObject, force: Vector3, time: float):
	## Compute the specific orbital energy
	#var mu = G * obj.get_mass()
	#var r = obj.get_position().length()
	#var v = obj.get_velocity().length()
	#var specific_energy = v * v / 2 - mu / r
#
	## Calculate the change in specific orbital energy due to the force
	#var delta_energy = force.dot(obj.get_velocity()) * time / obj.get_mass()
#
	## Update the semi-major axis
	#obj.semi_major_axis = -mu / (2 * (specific_energy + delta_energy))
#
	## Calculate the specific angular momentum
	#var h_vec = obj.get_position().cross(obj.get_velocity())
	#var h = h_vec.length()
#
	## Update the eccentricity
	#var p = h * h / mu
	#var new_eccentricity = sqrt(1 - p / obj.semi_major_axis)
	#obj.eccentricity = clamp(new_eccentricity, 0, 1)
#
	## Ensure the eccentricity is within bounds
	#if obj.eccentricity < 0:
		#obj.eccentricity = 0
	#elif obj.eccentricity > 1:
		#obj.eccentricity = 1
