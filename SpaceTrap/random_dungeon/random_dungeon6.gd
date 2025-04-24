extends Node2D

@export var max_room_count: int = 10
@export var viewport_size: Vector2 = Vector2(960, 540)

@onready var rooms: Node2D = $rooms

const RANDOM_ROOM = preload("res://random_dungeon/randomRoom.tscn")
var room_references := []

func _ready() -> void:
	_generate_initial_rooms()

func _generate_initial_rooms() -> void:
	while room_references.size() < max_room_count:
		var success = await _create_room()
		if not success:
			break

func _create_room() -> bool:
	var new_room = RANDOM_ROOM.instantiate()
	#new_room.owner = get_tree().current_scene
	new_room.has_been_in_viewport = false

	new_room.connect("enter_screen", Callable(self, "_on_room_enter_screen"))
	new_room.connect("out_of_screen", Callable(self, "_on_room_out_of_screen"))
	new_room.visible = false
	rooms.add_child(new_room)
	room_references.append(new_room)
	
	
	# 第一个房间无需连接
	if room_references.size() == 1:
		new_room.visible = true
		return true
	
	var possible_rooms = rooms.get_children().filter(func(r): return r != new_room)
	var tries = 10
	var connected = false
	while tries > 0 and not connected:
		var target = possible_rooms.pick_random()
		connected = await new_room.connect_with(target)
		tries -= 1

	if not connected:
		room_references.erase(new_room)
		new_room.queue_free()
	
	new_room.visible = true
	return connected

func _on_room_enter_screen(room: Node2D) -> void:
	room.has_been_in_viewport = true
	print("房间进入视野：%s" % room.name)

func _on_room_out_of_screen(room: Node2D) -> void:
	#if not room.has_been_in_viewport:
		#print("房间 %s 从未进入过视野，不重构" % room.name)
		#return

	#if _is_in_viewport(room):
		#print("房间 %s 仍在视野中，不重构" % room.name)
		#return

	print("房间 %s 离开视野，开始重构链" % room.name)

	# 执行链式清除
	await _rebuild_room_chain([room])


func _rebuild_room_chain(start_rooms: Array) -> void:
	var to_rebuild := []
	var visited := {}

	# 广度优先收集所有应清理的房间
	var queue := start_rooms.duplicate()
	while not queue.is_empty():
		var current = queue.pop_front()
		if not is_instance_valid(current): continue
		if visited.has(current): continue
		visited[current] = true

		if not room_references.has(current): continue
		if current.is_in_viewport(): continue
		#if _is_in_viewport(current): continue

		to_rebuild.append(current)

		# 搜索它连接的房间
		if current.has_method("get_connected_rooms"):
			for neighbor in current.get_connected_rooms():
				queue.append(neighbor)

	# 执行清理与断开
	for room in to_rebuild:
		room_references.erase(room)
		for other_room in room_references:
			if other_room.has_method("disconnect_from"):
				other_room.disconnect_from(room)
		room.queue_free()

	# 重建等量房间
	var rebuild_count = to_rebuild.size()
	for i in rebuild_count:
		await _create_room()


#func _is_in_viewport(room: Node2D) -> bool:
	#var viewport_rect = Rect2(get_viewport().get_visible_rect().position, viewport_size)
	#var room_rect = room.get_global_rect()
	#return viewport_rect.intersects(room_rect)
