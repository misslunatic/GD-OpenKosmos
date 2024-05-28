extends Node
class_name WorldGenerator

@export var colors: Gradient

@export var noise: Noise

@export var size: float

func get_material() -> Material:
	return StandardMaterial3D.new()

func sample_position(coord: Vector2) -> float:
	var x = sin(coord.x)
	var y = sin(coord.y)
	return 1 + noise.get_noise_2dv(coord)

var last = 0;

func sample_color(coord: Vector2) -> Color:
	var pos = sample_position(coord)
	last = pos
	return colors.sample(abs(noise.get_noise_2dv(coord) + 1))
