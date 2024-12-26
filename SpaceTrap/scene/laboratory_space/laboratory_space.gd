extends Node


var entity_manager:_EntityManager = null
var buff_manager:_BuffManager = null


func _ready() -> void:
	entity_manager = get_node_or_null("/root/EntityManager")
	buff_manager = get_node_or_null("/root/BuffManager")
	if entity_manager:
		# 设置多人实体承载节点
		entity_manager.update_spawn_path($Node2D.get_path())


func _input(event: InputEvent) -> void:
	if event.is_released():
		## entity
		if event.as_text() == "1":
			if entity_manager:
				var position = get_node(entity_manager.spawn_path).get_viewport().get_mouse_position()
				entity_manager.generate_entity({"entity_id": 1, "position": position, "speed": Vector2(100,0)})
		if event.as_text() == "2":
			if entity_manager:
				var position = get_node(entity_manager.spawn_path).get_viewport().get_mouse_position()
				entity_manager.generate_entity({"entity_id": 2, "position": position, "test": true})
		## BUFF
		if event.as_text() == "3":
			if buff_manager:
				buff_manager.append_buff(1,get_path())
		if event.as_text() == "4":
			if buff_manager:
				buff_manager.append_buff(2,get_path())
