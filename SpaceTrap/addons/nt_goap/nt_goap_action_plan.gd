@tool
extends Control


@onready var action_view: ItemList = %ActionView


func update_view(actions : Array):
	action_view.clear()
	for action in actions:
		action_view.add_action_item(action)
