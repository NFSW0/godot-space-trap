extends Node


@onready var card_container: HFlowContainer = %CardContainer
@export var card_packed_scene: PackedScene
var current_continer = ""
var target_id = -1
var mouse_press_position = Vector2()
var mouse_release_position = Vector2()


@onready var entity_manager:_EntityManager = get_node_or_null("/root/EntityManager")
@onready var buff_manager:_BuffManager = get_node_or_null("/root/BuffManager")
@onready var data_manager:_DataManager = get_node_or_null("/root/DataManager")


func _ready() -> void:
	if entity_manager:
		# 设置多人实体承载节点
		entity_manager.update_spawn_path($Node2D.get_path())


func _input(event: InputEvent) -> void:
	# 检查鼠标左键是否按下
	if event.is_action_pressed("interact"):
		mouse_press_position = get_node(entity_manager.spawn_path).get_viewport().get_mouse_position()
	
	# 检查鼠标左键是否松开
	if event.is_action_released("interact"):
		mouse_release_position = get_node(entity_manager.spawn_path).get_viewport().get_mouse_position()
		match current_continer:
			"entity":
				entity_manager.generate_entity({"entity_id": target_id, "position": mouse_press_position, "velocity":mouse_release_position - mouse_press_position})
				return
			_:
				return

	if event.is_released():
		## entity
		if event.as_text() == "1":
			if entity_manager:
				var position = get_node(entity_manager.spawn_path).get_viewport().get_mouse_position()
				entity_manager.generate_entity({"entity_id": 1, "position": position, "velocity":Vector2(100,100)})
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
		if event.as_text() == "5":
			pass


## 点击建筑按钮
func _on_block_pressed() -> void:
	if _is_duplicate_click("block"):
		return
	
	card_container.show()
	current_continer = "block"

## 点击实体按钮
func _on_entity_pressed() -> void:
	if _is_duplicate_click("entity"):
		return
	
	if entity_manager:
		var entity_library:Dictionary = entity_manager.entity_library
		for entity_id in entity_library.keys():
			var new_card = card_packed_scene.instantiate()
			new_card.set_data(entity_library[entity_id], "%s" % entity_id, func():target_id = entity_id)
			card_container.add_child(new_card)
	
	card_container.show()
	current_continer = "entity"

## 点击附益按钮
func _on_buff_pressed() -> void:
	if _is_duplicate_click("buff"):
		return
	
	card_container.show()
	current_continer = "buff"

## 点击物品按钮
func _on_item_pressed() -> void:
	if _is_duplicate_click("item"):
		return
	
	card_container.show()
	current_continer = "item"

## 处理重复的按钮点击
func _is_duplicate_click(tag:String) -> bool:
	if current_continer == tag:
		card_container.hide()
		current_continer = ""
		target_id = -1
		return true
	else:
		for child in card_container.get_children():
			child.call_deferred("queue_free")
		return false
