class_name CheckoutGame extends Node

@export var grocery_name_label: Label
@export var grocery_price_label: Label
@export var grocery_spawn: Node3D

@export_category("Register")
@export var price_entry_label: Label

var _game_in_progress: bool = false

# The full grocery list the customer submitted.
var _grocery_list: Array[GroceryData] = []
#var _remaining_list: Array[GroceryData] = []
var _submitted_list: Array[GroceryData] = []

# The index of the current grocery in the _grocery_list
var _index: int = -1
# The _node is instantiated from grocery_data.scene, and is free'd when submitted.
var _node: Node3D

# This is the friendly name displayed on the cash register.
var _price_string = "0.00"

# This is for tracking raw input text, which isn't formatted at all. _price_string is formatted from this value.
var _input_string = ""
var _prev_input_string = ""

var _is_receipt_collapsed: bool = false

func start_game(grocery_list: Array[GroceryData]):
	_grocery_list = grocery_list
	_submitted_list = []
	receipt_list_label.clear()
	receipt_list_label.append_text("[fill]")
	
	_start_next_grocery()
	
	_game_in_progress = true

func end_game():
	_game_in_progress = false

func get_remaining_groceries_list():
	pass
	#_grocery_list.reduce()

## Submit the current grocery, with the inputted price. Start the next grocery for the checkout mini-game.
func submit():
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
	if price_entered != grocery.price:
		receipt_list_label.append_text("[s]%s[/s]" % grocery.get_receipt_rich_text(price_entered))
		receipt_list_label.newline()
		receipt_list_label.append_text(grocery.get_receipt_rich_text())
		receipt_list_label.newline()
	else:
		receipt_list_label.append_text(grocery.get_receipt_rich_text())
		receipt_list_label.newline()
	
	# Do move animation to bag
	if _node && is_instance_valid(_node):
		_node.queue_free()
	
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
		end_game()
		return
	
	grocery =  _grocery_list[_index]
	
	grocery_name_label.text = grocery.friendly_name
	grocery_price_label.text = GroceryData.format_currency(grocery.price)
	
	if grocery.scene:
		_node = grocery.scene.instantiate()
		grocery_spawn.add_child(_node)
	
	return grocery

func _on_collapse_button_pressed():
	_is_receipt_collapsed = !_is_receipt_collapsed
	
	if _is_receipt_collapsed:
		receipt_list_label.hide()
	else:
		receipt_list_label.show()

func _grocery_body_entered_bag(body):
	submit()

func _ready():
	collapse_receipt_button.button_down.connect(_on_collapse_button_pressed)
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
		_price_string = GroceryData.format_currency_string(_input_string)
		_prev_input_string = _input_string
	
	if Input.is_action_just_pressed("submit"):
		submit()
	
	price_entry_label.text = _price_string
