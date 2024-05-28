extends RigidBody3D

@export var label: Label

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		apply_impulse(Vector3.FORWARD * 1000)
	label.text = "Position: " + str(position)
