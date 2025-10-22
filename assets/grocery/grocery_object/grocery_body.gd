class_name GroceryObject extends RigidBody3D

@export_category("Controls")
@export var orbit_speed: float = 0.25
@export var drag_speed: float = 0.005

@export_category("Internal")
@export var visibility_notifier: VisibleOnScreenNotifier3D

var _is_orbitting: bool = false
var _is_dragging: bool = false

@onready var _start_g_pos = global_position
@onready var _start_g_rot = global_rotation

func _ready():
	connect("input_event", _on_input_event)
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)
	visibility_notifier.connect("screen_exited", _on_screen_exited)

func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CursorShape.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CursorShape.CURSOR_ARROW)

func _on_screen_exited():
	global_position = _start_g_pos
	global_rotation = _start_g_rot
	
	if self is RigidBody3D:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO

func _on_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			event.pressed = false
			_is_orbitting = true
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			event.pressed = false
			_is_dragging = true

func _process(delta: float) -> void:
	if _is_dragging:
		if Input.is_action_just_released("left_mouse"):
			_is_dragging = false
			return
		
		var mouse_delta = Input.get_last_mouse_velocity()
		global_position += drag_speed * delta * Vector3(mouse_delta.x, -mouse_delta.y, 0)
	
	if _is_orbitting:
		if Input.is_action_just_released("right_mouse"):
			_is_orbitting = false
			return
		
		var mouse_delta = Input.get_last_mouse_velocity()
		
		# Update the angle based on orbit speed and delta time
		global_rotate(Vector3.UP, deg_to_rad(orbit_speed * delta * mouse_delta.x))
		global_rotate(Vector3.RIGHT, deg_to_rad(orbit_speed * delta * mouse_delta.y))
