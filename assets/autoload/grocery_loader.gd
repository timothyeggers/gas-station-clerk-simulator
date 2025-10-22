# GroceryLoader builds a random grocery list.  The available grocery list options point to resources of each GroceryData.
extends Node

const GROCERY_DATA_DIR = "res://assets/grocery/grocery_data/"

## All the available grocery options. And should be de-duped, but isn't unless manually done.
var groceries: Array[GroceryData] = []

## Builds a random grocery list of size count, selecting randomly from the self->groceries array.
func get_random_grocery_list(count: int) -> Array[GroceryData]:
	var list: Array[GroceryData] = []
	var previous_item: GroceryData
	for i in count:
		var randi = randi_range(0, groceries.size()-1)
		var grocery = groceries[randi]
		# Re-roll, as to not get duplicates right next to each other?
		#if grocery == previous_item:
		#	i -= 1
		#	continue
		list.append(grocery)
	return list

# Set this array to all the paths of GroceryData resources.  Use _debug_print_grocery_resources_array to get this declaration, then just paste over this declaration.
var _grocery_resource_paths: Array[String] = [
"res://assets/grocery/grocery_data/milk.tres",
"res://assets/grocery/grocery_data/water.tres",
]

func _ready():
	_debug_print_grocery_resources_array()
	_load_all()

# This is retarded, but basically print out a string declaring each grocery_data, so that I can copy it and paste it in this file as variable declarations.
func _debug_print_grocery_resources_array():
	if !OS.has_feature('debug'): return
	
	var declaration_string = "var _grocery_resource_paths: Array[String] = [\n"
	for file_name in DirAccess.get_files_at("res://assets/grocery/grocery_data"):
		var extension = "tres"
		var extension_replace = ".tres"
		if (file_name.get_extension() == extension):
			file_name = file_name.replace('.%s' % extension, '%s' % extension_replace)
			var full_path = "%s%s" % [GROCERY_DATA_DIR, file_name]
			declaration_string += "\"%s\"" % full_path + ",\n"
	declaration_string += "]"
	print(declaration_string)

# Ready call loads all the grocery resources into the self->groceries array.
func _load_all():
	for resource_path in _grocery_resource_paths:
		groceries.append(load(resource_path))
