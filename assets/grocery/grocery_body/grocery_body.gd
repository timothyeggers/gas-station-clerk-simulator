class_name GroceryBody extends RigidBody3D

# The time off screen allowed until this is reset to initial position.
const TIME_OFF_SCREEN_RESET = 2.0
const MIN_Y_RESET = -5

@export_category("Controls")
@export var orbit_speed: float = 0.25
@export var drag_speed: float = 0.1

@export_category("Internal")
@export var visibility_notifier: VisibleOnScreenNotifier3D

var _is_orbitting: bool = false
var _is_dragging: bool = false

var _time_off_screen: float = 0

@onready var _start_g_pos = global_position
@onready var _start_g_rot = global_rotation

func _ready():
	connect("input_event", _on_input_event)
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)

func _on_mouse_entered():
	if !_is_orbitting:
		Input.set_default_cursor_shape(Input.CursorShape.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	if !_is_dragging && !_is_orbitting:
		Input.set_default_cursor_shape(Input.CursorShape.CURSOR_ARROW)

func _reset():
	_stop_drag()
	_stop_orbit()
	
	_time_off_screen = 0
	
	global_position = _start_g_pos
	global_rotation = _start_g_rot

func _on_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_start_orbit()
			event.pressed = false
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed and !_is_orbitting:
			_start_drag()
			event.pressed = false

func _start_orbit():
	_stop_drag()
	_is_orbitting = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	gravity_scale = 0
	if global_position.y < _start_g_pos.y:
		global_position.y = _start_g_pos.y
	Input.set_default_cursor_shape(Input.CURSOR_MOVE)

func _start_drag():
	_is_dragging = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	gravity_scale = 0
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _stop_orbit():
	_is_orbitting = false
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	gravity_scale = 1
	Input.set_default_cursor_shape(Input.CursorShape.CURSOR_ARROW)

func _stop_drag():
	_is_dragging = false
	gravity_scale = 1

var _was_off_screen = false
func _process(delta: float) -> void:
	if !visibility_notifier.is_on_screen():
		_was_off_screen = true
		_time_off_screen += delta
		if _time_off_screen > TIME_OFF_SCREEN_RESET:
			_reset()
	elif _was_off_screen:
		_was_off_screen = false
		_time_off_screen = 0
	
	if global_position.y < _start_g_pos.y + MIN_Y_RESET:
		_reset()
	
	if Input.is_action_just_released("left_mouse"):
		_stop_drag()
	
	if Input.is_action_just_released("right_mouse"):
		_stop_orbit()
	
	if Input.is_action_just_pressed("right_mouse") && _is_dragging:
		_start_orbit()
	
	if _is_orbitting:
		var mouse_delta = Input.get_last_mouse_velocity()
		# Update the angle based on orbit speed and delta time
		global_rotate(Vector3.UP, deg_to_rad(orbit_speed * delta * mouse_delta.x))
		global_rotate(Vector3.RIGHT, deg_to_rad(orbit_speed * delta * mouse_delta.y))

func _physics_process(delta: float) -> void:
	if _is_dragging:
		var mouse_delta = Input.get_last_mouse_velocity()
		linear_velocity = delta * Vector3(mouse_delta.x, -mouse_delta.y, 0) * drag_speed
