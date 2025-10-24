extends Camera3D

@export var max_rotation_y = 15
@export var rotation_speed = 30

func _process(delta: float) -> void:
	if Input.is_action_pressed("left"):
		rotation_degrees.y += rotation_speed * delta
	if Input.is_action_pressed("right"):
		rotation_degrees.y -= rotation_speed * delta
	rotation_degrees.y = clamp(rotation_degrees.y, -max_rotation_y, max_rotation_y)
