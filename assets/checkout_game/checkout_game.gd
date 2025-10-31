class_name CheckoutGame extends Node

@export var grocery_name_label: Label
@export var grocery_price_label: Label
@export var grocery_spawn: Node3D

@export_category("Internal")
@export var price_entry_label: Label
@export var receipt_anchor: Control
@export var collapse_receipt_button: TextureButton
@export var submit_button: TextureButton

var _game_in_progress: bool = false

# The full grocery list the customer submitted.
var _grocery_list: Array[GroceryData] = []
#var _remaining_list: Array[GroceryData] = []
var _submitted_list: Array[GroceryData] = []

# The index of the current grocery in the _grocery_list
var _index: int = -1
# The _grocery_body is instantiated from grocery_data.scene, and is free'd when submitted.
var _grocery_body: Node3D

# This is the friendly name displayed on the cash register.
var _price_string = "0.00"

# This is for tracking raw input text, which isn't formatted at all. _price_string is formatted from this value.
var _input_string = ""
var _prev_input_string = ""

var _current_receipt: Receipt = null
var _current_receipt_selected: bool = false

func start_game(grocery_list: Array[GroceryData]):
	if _current_receipt:
		_current_receipt.queue_free()
	if _grocery_body:
		_grocery_body.queue_free()
	_current_receipt_selected = false
	_current_receipt = Receipt.create(receipt_anchor)
	_current_receipt.receipt_selected.connect(_on_receipt_selected)
	_current_receipt.receipt_deselected.connect(_on_receipt_deselected)
	_submitted_list = []
	_index= -1
	_grocery_body = null
	_price_string = "0.00"
	_input_string = ""
	_prev_input_string = ""
	_grocery_list = grocery_list
	_submitted_list = []
	
	_start_next_grocery()
	
	_game_in_progress = true

func end_game():
	_game_in_progress = false
	start_game(_grocery_list)

func get_remaining_groceries_list():
	pass
	#_grocery_list.reduce()

## Submit the current grocery, with the inputted price. Start the next grocery for the checkout mini-game.
func submit():
	if !get_current_grocery(): return
	
	_current_receipt.dock()
	
	var price_entered = float(_price_string)
	_price_string = "0.00"
	_input_string = ""
	_prev_input_string = ""
	
	#_remaining_list.remove_at(_index)
	var grocery = get_current_grocery()
	_submitted_list.append(grocery)
	
	#for grocery in _remaining_list:
	#	print("Name: %s, Price: %s" % [grocery.friendly_name, grocery.price])
	
	for g in _submitted_list:
		print("Name: %s, Price: %s" % [g.friendly_name, g.price])
	
	# Update UI
	_current_receipt.enter(grocery, price_entered)
	
	# Do move animation to bag
	if _grocery_body && is_instance_valid(_grocery_body):
		_grocery_body.queue_free()
	
	_start_next_grocery()

## Returns the current grocery being checked out in the mini-game.  Or null, if out of bounds.
func get_current_grocery() -> GroceryData:
	if _index >= _grocery_list.size():
		return null
	return _grocery_list[_index]

## Starts the mini-game for the next grocery item in the list, otherwise ends mini-game.
func _start_next_grocery() -> GroceryData:
	var grocery = null
	_index += 1
	
	if _index >= _grocery_list.size():
		return
	
	grocery =  _grocery_list[_index]
	
	grocery_name_label.text = grocery.friendly_name
	grocery_price_label.text = Game.format_decimal(grocery.price)
	
	if grocery.scene:
		_grocery_body = grocery.scene.instantiate()
		grocery_spawn.add_child(_grocery_body)
	
	return grocery

func _on_receipt_selected():
	_current_receipt_selected = true

func _on_receipt_deselected():
	_current_receipt_selected = false

func _on_collapse_button_pressed():
	_current_receipt.toggle_collapse()

func _on_submit_pressed():
	if !_current_receipt_selected: return
	end_game()

func _grocery_body_entered_bag(body):
	submit()

func _ready():
	collapse_receipt_button.button_down.connect(_on_collapse_button_pressed)
	submit_button.button_down.connect(_on_submit_pressed)
	Signals.grocery_entered_bag.connect(_grocery_body_entered_bag)

func _process(delta: float) -> void:
	if !_game_in_progress: return
	
	if Input.is_action_just_pressed("backspace"):
		if _input_string.length() > 0:
			_input_string = _input_string.substr(0, _input_string.length() - 1)
	
	#region Number Inputs
	# I know, what the fuck, but just hear me out.  It was necessary. And fuck textedit.
	if Input.is_action_just_pressed("num_0"):
		_input_string += "0"
	if Input.is_action_just_pressed("num_1"):
		_input_string += "1"
	if Input.is_action_just_pressed("num_2"):
		_input_string += "2"
	if Input.is_action_just_pressed("num_3"):
		_input_string += "3"
	if Input.is_action_just_pressed("num_4"):
		_input_string += "4"
	if Input.is_action_just_pressed("num_5"):
		_input_string += "5"
	if Input.is_action_just_pressed("num_6"):
		_input_string += "6"
	if Input.is_action_just_pressed("num_7"):
		_input_string += "7"
	if Input.is_action_just_pressed("num_8"):
		_input_string += "8"
	if Input.is_action_just_pressed("num_9"):
		_input_string += "9"
	#endregion
	
	# Insert padded 0's to get a nice price label.
	if _prev_input_string != _input_string:
		_price_string = Game.format_currency_string(_input_string)
		_prev_input_string = _input_string
	
	if Input.is_action_just_pressed("submit"):
		submit()
	
	price_entry_label.text = _price_string
