extends Node


@export var tax: float = 0.05


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

static func format_decimal(value: float) -> String:
	return "%0.2f" % value
