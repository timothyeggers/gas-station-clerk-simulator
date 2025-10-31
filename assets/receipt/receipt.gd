class_name Receipt extends Control

const SCENE_PATH: NodePath = "res://assets/receipt/receipt.tscn"

@export_category("Receipt")
@export var receipt_list_label: RichTextLabel

var _is_collapsed: bool = false

static func create(attach_to: Node) -> Receipt:
	if !attach_to || !is_instance_valid(attach_to) || attach_to.is_queued_for_deletion():
		return
	
	var s = load(SCENE_PATH)
	var control: Receipt = s.instantiate()
	
	control.receipt_list_label.clear()
	control.receipt_list_label.append_text("[fill]")
	
	attach_to.add_child(control)
	
	return control

func enter_wrong(rich_text: String):
	receipt_list_label.append_text("[s]%s[/s]" % rich_text)
	receipt_list_label.newline()

func enter(rich_text: String):
	receipt_list_label.append_text(rich_text)
	receipt_list_label.newline()

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
