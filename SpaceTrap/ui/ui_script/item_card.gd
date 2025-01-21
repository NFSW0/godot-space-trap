extends PanelContainer


@export var sub_viewport: SubViewport
@export var item_name: Label
var on_click: Callable


func set_data(_packed_scene:PackedScene, _item_name:String, _on_click:Callable):
	for child in sub_viewport.get_children():
		child.call_deferred("queue_free")
	var instance_node = _packed_scene.instantiate()
	sub_viewport.add_child(instance_node)
	
	item_name.text = _item_name
	
	on_click = _on_click


func _on_click_button_pressed() -> void:
	on_click.call()
