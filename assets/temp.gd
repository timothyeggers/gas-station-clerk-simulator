extends Node3D

@export var checkout_game: CheckoutGame

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("undo"):
		checkout_game.start_game(GroceryLoader.get_random_grocery_list(2))
		set_process(false)
