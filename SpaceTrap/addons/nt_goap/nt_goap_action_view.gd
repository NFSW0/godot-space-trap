@tool
extends ItemList


signal add_action(action:NT_GOAP_Action)
signal remove_action(action:NT_GOAP_Action)


func add_action_item(action:NT_GOAP_Action):
	var index = add_item(action.name)
	set_item_metadata(index, action)


func _get_drag_data(at_position: Vector2) -> Variant:
	
	var item_index = get_item_at_position(at_position)
	
	if item_index == -1:
		return
	
	var action:NT_GOAP_Action = get_item_metadata(item_index)
	
	if not action:
		return
	
	var preview_text = Label.new()
	preview_text.text = action.name
	var preview = Control.new()
	preview.add_child(preview_text)
	set_drag_preview(preview)
	
	if not Input.is_key_pressed(KEY_ALT):
		remove_item(item_index)
		remove_action.emit(action)
	
	return action


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is NT_GOAP_Action


func _drop_data(at_position: Vector2, data: Variant) -> void:
	add_action.emit(data)
