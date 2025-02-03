@tool
extends ItemList


signal add_environment(environment:NT_GOAP_Environment)
signal remove_environment(environment:NT_GOAP_Environment)


func add_environment_item(environment:NT_GOAP_Environment):
	var index = add_item(environment.name)
	set_item_metadata(index, environment)


func _get_drag_data(at_position: Vector2) -> Variant:
	
	var item_index = get_item_at_position(at_position)
	
	if item_index == -1:
		return
	
	var environment:NT_GOAP_Environment = get_item_metadata(item_index)
	
	if not environment:
		return
	
	var preview_text = Label.new()
	preview_text.text = environment.name
	var preview = Control.new()
	preview.add_child(preview_text)
	set_drag_preview(preview)
	
	if not Input.is_key_pressed(KEY_ALT):
		remove_item(item_index)
		remove_environment.emit(environment)
	
	return environment


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is NT_GOAP_Environment


func _drop_data(at_position: Vector2, data: Variant) -> void:
	add_environment.emit(data)
