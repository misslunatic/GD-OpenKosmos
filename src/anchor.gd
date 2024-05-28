class_name Anchor3D
extends RigidBody3D

@export var world: Node3D

func _process(_delta: float) -> void:
	if position != Vector3.ZERO:
		world.position = -position
		position = Vector3.ZERO
	
#func _set(property: StringName, value: Variant) -> bool:
	#if property == "position":
		#print("shifting pos")
		#world.position = -value
	#
	#return true
