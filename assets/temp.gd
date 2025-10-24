extends Node3D

@export var checkout_game: CheckoutGame

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("undo"):
		var arr: Array[GroceryData] = []
		for i in 10:
			arr.append(load("res://assets/grocery/grocery_data/milk.tres"))
		checkout_game.start_game(arr)
		set_process(false)
