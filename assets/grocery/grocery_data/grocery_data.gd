class_name GroceryData extends Resource

enum ReceiptUnit {
	GALLON,
	PINT,
	QUART,
	BOTTLE,
	LOAF,
	NONE,
}

static var receipt_unit_table: Dictionary =  {
	ReceiptUnit.GALLON: "GAL",
	ReceiptUnit.PINT: "PNT",
	ReceiptUnit.QUART: "QT",
	ReceiptUnit.BOTTLE: "BTL",
	ReceiptUnit.LOAF: "LOAF",
	ReceiptUnit.NONE: ""
}

## Leads with 3 zeroes
enum BrandUID {
	MILLS = 928
}

enum ProductUID {
	MILK = 301,
	WATER = 839,
	BREAD = 201,
	NONE = 000
}

## This is the grocery_body for the object to be instantiated.
@export var scene: PackedScene
@export var friendly_name: String = "Milk"
@export var receipt_item_name: String = "MILK"
@export var receipt_item_unit: ReceiptUnit = ReceiptUnit.PINT
@export var brand_id: BrandUID = BrandUID.MILLS
@export var product_id: ProductUID = ProductUID.MILK
@export var price: float = 1.34

## String formatted with bbcode, for richtextlabel.  price_override is helpful if you want to display the 'wrong' price.
func get_receipt_rich_text(price_override: float = price) -> String:
	return "{brand_id}{product_id} {receipt_item_unit} {receipt_item_name} {price}".format(
			[ 
				["brand_id", "000%s" % brand_id], 
				["product_id", product_id], 
				["receipt_item_unit", receipt_unit_table[receipt_item_unit]], 
				["receipt_item_name", receipt_item_name], 
				["price", format_currency(price_override)] 
			])

## Format the price text to be a currency (0.00).  Pass in raw string, not a float converted to string, otherwise it'll be bad.
static func format_currency_string(text: String) -> String:
	var price_string: String = ""
	if text.length() > 0 && text.length() < 3:
		if text.length() == 1:
			price_string = text.insert(0, "0.0")
		else:
			price_string = text.insert(0, "0.")
	elif text.length() > 0:
		price_string = text.insert(text.length()-2,".")
	else:
		price_string = "0.00"
	return price_string

static func format_currency(value: float) -> String:
	return "%0.2f" % value
