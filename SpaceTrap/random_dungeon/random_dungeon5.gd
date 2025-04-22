extends Node2D

@export var maxRoomCount = 10
@export var viewport_size: Vector2 = Vector2(960, 540)  # 视口大小

@onready var rooms: Node2D = $rooms

const RANDOM_ROOM = preload("res://random_dungeon/randomRoom.tscn")

# 用于存储所有房间的引用
var room_references := []

func _ready() -> void:
	_initialize_rooms()

func _initialize_rooms():
	while room_references.size() < maxRoomCount and _count_out_of_viewport_rooms() < 2:
		await _create_room()

func _create_room():
	var existingRooms = rooms.get_children()
	
	var newRoom = RANDOM_ROOM.instantiate()
	newRoom.owner = get_tree().current_scene
	# 添加额外的状态标志：是否进入过视野
	newRoom.has_been_in_viewport = false
	# 监听房间的 out_of_screen 信号
	newRoom.connect("out_of_screen", Callable(self, "_on_room_out_of_screen"))
	newRoom.connect("enter_screen", Callable(self, "_on_room_enter_screen"))
	room_references.append(newRoom)  # 将房间添加到引用列表中
	
	var isFirstRoom = existingRooms.is_empty()
	if isFirstRoom: return
	
	var possibleRooms = []
	for room in existingRooms:
		if room == newRoom: continue
		possibleRooms.append(room)
	
	var selectedRoom = possibleRooms.pick_random()
	var success = await newRoom.connect_with(selectedRoom)
	
	var tries = 10
	while not success and tries > 0:
		selectedRoom = possibleRooms.pick_random()
		success = await newRoom.connect_with(selectedRoom)
		tries -= 1
	rooms.add_child(newRoom)
	if not success:
		newRoom.queue_free()

func _on_room_enter_screen(room):
	print("房间进入视野")

func _on_room_out_of_screen(room):
	# 当房间离开视野时触发
	print("房间离开视野：", room.name)
	
	# 确保房间在视野外且曾经进入过视野才处理
	if _is_in_viewport(room):
		print("视野内不重构")
		return
	
	if not room.has_been_in_viewport:
		print("新房间不重构")
		return
	
	print("重构房间")
	
	# 从引用列表中移除该房间
	room_references.erase(room)
	
	for old_room in room_references:
		if old_room == room: continue
		old_room.disconnect_from(room)
	
	# 销毁该房间
	room.queue_free()
	
	# 重新生成一个新的房间（在视野外）
	await _create_room()

func _process(delta):
	# 动态检测房间是否离开视野
	for room in rooms.get_children():
		if is_instance_valid(room):
			# 更新房间是否进入过视野的状态
			if _is_in_viewport(room) and not room.has_been_in_viewport:
				room.has_been_in_viewport = true
				print("房间 %s 进入视野" % room.name)
			# 如果房间离开视野且曾经进入过视野，则处理
			if not _is_in_viewport(room) and room.has_been_in_viewport:
				_on_room_out_of_screen(room)

func _is_in_viewport(room) -> bool:
	# 判断房间是否在视口内
	var viewport_rect = Rect2(get_viewport().get_visible_rect().position, viewport_size)
	var room_rect = room.get_global_rect()
	return viewport_rect.intersects(room_rect)

func _count_out_of_viewport_rooms() -> int:
	# 统计不在视口内的房间数量
	var count = 0
	for room in rooms.get_children():
		if not _is_in_viewport(room):
			count += 1
	return count
