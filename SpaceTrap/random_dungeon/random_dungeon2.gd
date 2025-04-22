extends Node2D

@export var maxRoomCount = 10

@onready var rooms: Node2D = $rooms
@export var button: Button

const RANDOM_ROOM = preload("res://random_dungeon/randomRoom.tscn")

func _ready() -> void:
	# 初始化时可以创建一些初始房间，或者留空
	button.connect("pressed", _on_button_pressed)

func _create_room():
	var existingRooms = rooms.get_children()
	
	var newRoom = RANDOM_ROOM.instantiate()
	rooms.add_child(newRoom)
	newRoom.owner = get_tree().current_scene
	
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

	if not success:
		newRoom.queue_free()

func _on_button_pressed() -> void:
	# 检查当前房间数量是否达到最大值
	if rooms.get_children().size() >= maxRoomCount:
		print("已达到最大房间数量！")
		return
	
	# 创建一个新房间
	await _create_room()
