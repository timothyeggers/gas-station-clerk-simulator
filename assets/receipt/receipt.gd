class_name Receipt extends Control

signal receipt_selected
signal receipt_deselected

const SCENE_PATH: NodePath = "res://assets/receipt/receipt.tscn"

@export_category("Internal")
@export var receipt_list_label: RichTextLabel
@export var button: TextureButton
@export var receipt_footer_label: RichTextLabel
@export var receipt_footer_texture: TextureRect

@onready var _pos_before: Vector2 = position

var _is_collapsed: bool = false
var _is_dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _subtotal: float = 0.0

var _submit_text: String = """
	SUBTOTAL: %s
	TAX: %s
	
	[u]TOTAL: %s[/u]
"""

static func create(attach_to: Node) -> Receipt:
	if !attach_to || !is_instance_valid(attach_to) || attach_to.is_queued_for_deletion():
		return
	
	var s = load(SCENE_PATH)
	var control: Receipt = s.instantiate()
	
	attach_to.add_child(control)
	
	return control

func _ready():
	receipt_list_label.clear()
	receipt_list_label.append_text("[fill]")
	receipt_footer_label.clear()
	receipt_footer_label.append_text(_submit_text % ["0.00", str(100 * Game.tax) + "%", "0.00"])

	button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	if _is_dragging: return
	
	_is_dragging = true
	_drag_offset = global_position - get_global_mouse_position()
	_pos_before = position
	expand()
	
	receipt_footer_label.show()
	receipt_footer_texture.show()
	
	receipt_selected.emit()

func _process(delta: float) -> void:
	if !_is_dragging: return
	
	global_position = _drag_offset + get_global_mouse_position()
	
	if Input.is_action_just_pressed("right_mouse"):
		receipt_deselected.emit()
		dock()

func dock():
	_is_dragging = false
	receipt_footer_label.hide()
	receipt_footer_texture.hide()
	reset_size()
	position = _pos_before

func enter(grocery: GroceryData, price_entered: float):
	if price_entered != grocery.price:
		var item: String = grocery.get_receipt_rich_text(price_entered)
		receipt_list_label.append_text("[s]%s[/s]" % item)
		receipt_list_label.newline()
	receipt_list_label.append_text(grocery.get_receipt_rich_text())
	receipt_list_label.newline()
	
	_subtotal += grocery.price
	receipt_footer_label.text = _submit_text % [Game.format_decimal(_subtotal), str(Game.tax * 100) + "%", Game.format_decimal(_subtotal + _subtotal * Game.tax)]

func toggle_collapse():
	if _is_collapsed:
		expand()
	else:
		collapse()
	
	_is_collapsed = !_is_collapsed

func collapse():
	receipt_list_label.hide()

func expand():
	receipt_list_label.show()
