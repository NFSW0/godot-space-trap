@tool
extends Area2D

signal out_of_screen(room)
signal enter_screen(room)

var has_been_in_viewport = false
var connected_rooms := []

@export var minFloorWidth = 6
@export var minFloorHeight = 6
@export var maxFloorWidth = 15
@export var maxFloorHeight = 15
@export var maxOverlapFloors = 5
@export var fillGapSize = 4

@export_group("debug")
@export var refreshRoom := false:
	set(value):
		if Engine.is_editor_hint():
			_ready()
			
@onready var floor_layer: TileMapLayer = $FloorLayer
@onready var wall_layer: TileMapLayer = $WallLayer
@export var collision_polygon_2d: CollisionPolygon2D

var directions = {
	"right": Vector2i(1,0),
	"bottom": Vector2i(0,1),
	"left": Vector2i(-1,0),
	"top": Vector2i(0,-1),
}
var floorTiles = {
	"default": Vector2(0,0),
}
var wallTiles = {
	"left": Vector2(11,2),
	"right": Vector2(8,1),
	"bottom": Vector2(10,0),
	"topLeftCorner": Vector2(6,2),
	"topRightCorner": Vector2(5,2),
	"bottomLeftCorner": Vector2(6,1),
	"bottomRightCorner": Vector2(5,1),
	"top": Vector2(0,0),
	"top2": Vector2(0,0),
	"top3": Vector2(0,0),
	"top4": Vector2(9,3),
	"topLeftCornerReverse": Vector2(11,3),
	"topRightCornerReverse": Vector2(8,3),
	"bottomLeftCornerReverse": Vector2(11,0),
	"bottomRightCornerReverse": Vector2(8,0),
}

func _ready() -> void:
	floor_layer.clear()
	wall_layer.clear()

	_create_room()

func _create_room():
	var floorCount = randi_range(1, maxOverlapFloors)
	var floors = []
	
	for floor in floorCount:
		floors.append(_create_floor_rect())
		
	_draw_floor(floors)
	_fill_gaps()
	_create_walls()
	_create_collision_shape()
		
func _create_floor_rect():
	var startPointRange = 5
	var starPoint = Vector2(
		randi_range(-startPointRange, startPointRange), 
		randi_range(-startPointRange, startPointRange))
	var width = randi_range(minFloorWidth, maxFloorWidth)
	var height = randi_range(minFloorHeight, maxFloorHeight)
			
	return Rect2(starPoint, Vector2(width, height))

func _draw_floor(floors):
	for floor:Rect2 in floors:
		for x in floor.size.x:
			for y in floor.size.y:
				floor_layer.set_cell(Vector2(floor.position.x + x , floor.position.y + y), 1, floorTiles["default"])

func _fill_gaps():
	var changeList = []
	
	var rect: Rect2 = floor_layer.get_used_rect()

	for x in rect.size.x:
		for y in rect.size.y:
			var position = Vector2(x + rect.position.x,y + rect.position.y)
			
			if floor_layer.get_cell_source_id(position) >= 0: continue
			
			changeList += _get_fill_points(position)
	
	for point in changeList:
		floor_layer.set_cell(point, 1, floorTiles["default"])

func _get_fill_points(position):
	var list = []
	var surrounding = floor_layer.get_surrounding_cells(position)
	
	for i in surrounding.size():
		var counterSide = wrap(i + 2, 0, 4)
		var buffersurrounding = surrounding
		
		if _has_floor(surrounding[i]): 

			if _has_floor(surrounding[counterSide]):
				list.append(position)
			else:
				var bufferList = [position]
				
				for ii in fillGapSize:
					bufferList.append(buffersurrounding[counterSide])
					buffersurrounding = floor_layer.get_surrounding_cells(buffersurrounding[counterSide])
					
					if _has_floor(buffersurrounding[counterSide]):
						list += bufferList
						break

	return list

func _has_floor(position):
	return floor_layer.get_cell_source_id(position) > -1
	
func _create_walls():
	var allFloorTiles = floor_layer.get_used_cells()
	allFloorTiles.sort_custom(func(a, b): return a.y > b.y)

	for floorPosition in allFloorTiles:
		var topEnd = not _has_floor(floorPosition + directions["top"])
		var leftEnd = not _has_floor(floorPosition + directions["left"])
		var bottomEnd = not _has_floor(floorPosition + directions["bottom"])
		var rightEnd = not _has_floor(floorPosition + directions["right"])
		
		if topEnd and leftEnd: _create_top_left_corner(floorPosition)
		elif topEnd and rightEnd: _create_top_right_corner(floorPosition)
		elif bottomEnd and leftEnd: _create_bottom_left_corner(floorPosition)
		elif bottomEnd and rightEnd: _create_bottom_right_corner(floorPosition)
		elif topEnd: _create_top_wall(floorPosition)
		elif leftEnd: _create_left_wall(floorPosition)
		elif bottomEnd: _create_bottom_wall(floorPosition)
		elif rightEnd: _create_right_wall(floorPosition)

func _create_top_left_corner(position):
	_create_top_wall(position)
	
	if _has_floor(position + directions["left"] + directions["bottom"]):
		wall_layer.set_cell(position + directions["top"] * 4 + directions["left"], 5, wallTiles["topLeftCorner"])
		wall_layer.set_cell(position + directions["top"] * 3 + directions["left"], 5, wallTiles["topLeftCornerReverse"])	
	elif _has_floor(position + directions["left"] + directions["bottom"] * 2):
		wall_layer.set_cell(position + directions["top"] * 4 + directions["left"], 5, wallTiles["topLeftCorner"])
		wall_layer.set_cell(position + directions["top"] * 3 + directions["left"], 5, wallTiles["left"])
		wall_layer.set_cell(position + directions["top"] * 2 + directions["left"], 5, wallTiles["topLeftCornerReverse"])
	elif _has_floor(position + directions["left"] + directions["bottom"] * 3):
		wall_layer.set_cell(position + directions["top"] * 4 + directions["left"], 5, wallTiles["topLeftCorner"])
		wall_layer.set_cell(position + directions["top"] * 3 + directions["left"], 5, wallTiles["left"])	
		wall_layer.set_cell(position + directions["top"] * 2 + directions["left"], 5, wallTiles["left"])
	else:
		wall_layer.set_cell(position + directions["top"] * 4 + directions["left"], 5, wallTiles["topLeftCorner"])
		wall_layer.set_cell(position + directions["top"] * 3 + directions["left"], 5, wallTiles["left"])	
		wall_layer.set_cell(position + directions["top"] * 2 + directions["left"], 5, wallTiles["left"])
		wall_layer.set_cell(position + directions["top"] + directions["left"], 5, wallTiles["left"])
		
	_create_left_wall(position)
	
func _create_top_right_corner(position):
	_create_top_wall(position)
	
	if _has_floor(position + directions["right"] + directions["bottom"]):
		wall_layer.set_cell(position + directions["top"] * 4 + directions["right"], 5, wallTiles["topRightCorner"])
		wall_layer.set_cell(position + directions["top"] * 3 + directions["right"], 5, wallTiles["topRightCornerReverse"])	
	elif _has_floor(position + directions["right"] + directions["bottom"] * 2):
		wall_layer.set_cell(position + directions["top"] * 4 + directions["right"], 5, wallTiles["topRightCorner"])
		wall_layer.set_cell(position + directions["top"] * 3 + directions["right"], 5, wallTiles["right"])
		wall_layer.set_cell(position + directions["top"] * 2 + directions["right"], 5, wallTiles["topRightCornerReverse"])
	elif _has_floor(position + directions["right"] + directions["bottom"] * 3):
		wall_layer.set_cell(position + directions["top"] * 4 + directions["right"], 5, wallTiles["topRightCorner"])
		wall_layer.set_cell(position + directions["top"] * 3 + directions["right"], 5, wallTiles["right"])	
		wall_layer.set_cell(position + directions["top"] * 2 + directions["right"], 5, wallTiles["right"])
	else:
		wall_layer.set_cell(position + directions["top"] * 4 + directions["right"], 5, wallTiles["topRightCorner"])
		wall_layer.set_cell(position + directions["top"] + directions["right"], 5, wallTiles["right"])
		wall_layer.set_cell(position + directions["top"] * 2 + directions["right"], 5, wallTiles["right"])
		wall_layer.set_cell(position + directions["top"] * 3 + directions["right"], 5, wallTiles["right"])
	
	_create_right_wall(position)
	
func _create_bottom_left_corner(position):
	wall_layer.set_cell(position + directions["bottom"] + directions["left"], 5, wallTiles["bottomLeftCorner"])
	
	_create_left_wall(position)
	_create_bottom_wall(position)

func _create_bottom_right_corner(position):
	wall_layer.set_cell(position + directions["bottom"] + directions["right"], 5, wallTiles["bottomRightCorner"])
	
	_create_right_wall(position)
	_create_bottom_wall(position)
	
func _create_left_wall(position):
	if _has_floor(position + directions["left"] + directions["bottom"] * 4): return
	
	elif _has_floor(position + directions["left"] + directions["top"]):
		wall_layer.set_cell(position + directions["left"], 5, wallTiles["bottomLeftCornerReverse"])
	else:
		wall_layer.set_cell(position + directions["left"], 5, wallTiles["left"])

func _create_bottom_wall(position):
	if _has_floor(position + directions["bottom"] + directions["left"]):
		wall_layer.set_cell(position + directions["bottom"], 5, wallTiles["bottomRightCornerReverse"])
	elif _has_floor(position + directions["bottom"] + directions["right"]):
		wall_layer.set_cell(position + directions["bottom"], 5, wallTiles["bottomLeftCornerReverse"])
	else:
		wall_layer.set_cell(position + directions["bottom"], 5, wallTiles["bottom"])

func _create_right_wall(position):	
	if _has_floor(position + directions["right"] + directions["bottom"] * 4): return
	
	elif _has_floor(position + directions["right"] + directions["top"]):
		wall_layer.set_cell(position + directions["right"], 5, wallTiles["bottomRightCornerReverse"])
	else:
		wall_layer.set_cell(position + directions["right"], 5, wallTiles["right"])

func _create_top_wall(position):
	wall_layer.set_cell(position +  directions["top"], 1, wallTiles["top"])
	wall_layer.set_cell(position + directions["top"] * 2, 1, wallTiles["top2"])
	wall_layer.set_cell(position + directions["top"] * 3, 1, wallTiles["top3"])
	
	if _has_floor(position +  directions["top"] + directions["left"]):
		wall_layer.set_cell(position +  directions["top"] * 4, 5, wallTiles["topRightCornerReverse"])
	elif _has_floor(position +  directions["top"] + directions["right"]):
		wall_layer.set_cell(position +  directions["top"] * 4, 5, wallTiles["topLeftCornerReverse"])
	else:
		wall_layer.set_cell(position +  directions["top"] * 4, 5, wallTiles["top4"])

func _create_collision_shape():
	var collisionPoints = []
	
	var usedWalls = wall_layer.get_used_cells()
	
	for wallPosition in usedWalls:
		var atlasCords = wall_layer.get_cell_atlas_coords(wallPosition)
		
		if atlasCords == Vector2i(wallTiles["bottomRightCornerReverse"]) or atlasCords == Vector2i(wallTiles["bottomLeftCornerReverse"]) or atlasCords == Vector2i(wallTiles["topRightCornerReverse"]) \
		or atlasCords == Vector2i(wallTiles["topLeftCornerReverse"]) or atlasCords == Vector2i(wallTiles["topLeftCorner"]) or atlasCords == Vector2i(wallTiles["topRightCorner"]) \
		or atlasCords == Vector2i(wallTiles["bottomLeftCorner"]) or atlasCords == Vector2i(wallTiles["bottomRightCorner"]):
			collisionPoints.append(wall_layer.map_to_local(wallPosition))
	
	var sortedPoints = get_sorted_points(collisionPoints)
	collision_polygon_2d.set_polygon(sortedPoints)
	
	update_visiable_area(collisionPoints)

func update_visiable_area(polygon_points):
	# 初始化边界框的最小和最大值
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF
	
	# 遍历顶点，计算边界框
	for point in polygon_points:
		min_x = min(min_x, point.x)
		min_y = min(min_y, point.y)
		max_x = max(max_x, point.x)
		max_y = max(max_y, point.y)
	
	# 构建局部坐标系下的 AABB
	var local_aabb = Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))
	
	# 设置 VisibleOnScreenNotifier2D 的矩形区域
	$VisibleOnScreenNotifier2D.set_rect(local_aabb)


func get_sorted_points(list):
	var newList = []
	var lastPoint
	var lastDirection = "y"
	var duplicateList = list.duplicate()

	for i in list.size():
		if not lastPoint: 
			lastPoint = list[i]
			newList.append(lastPoint)
			duplicateList.erase(lastPoint)
			continue
		
		var options = []
		for point in duplicateList:
			if point == lastPoint: continue
			
			if lastDirection == "y" and lastPoint.x == point.x: options.append(point)
			elif lastDirection == "x" and lastPoint.y == point.y: options.append(point)
		
		if lastDirection == "y": lastDirection = "x"
		else: lastDirection = "y"

		var selectedPoint
		var distance = 0
		for option in options:
			if not selectedPoint:
				selectedPoint = option
				distance = lastPoint.distance_to(option)
			elif lastPoint.distance_to(option) < distance:
				selectedPoint = option
				distance = lastPoint.distance_to(option)

		lastPoint = selectedPoint
		newList.append(lastPoint)
		duplicateList.erase(lastPoint)

	return newList

func connect_with(room):
	if not room:
		return
	var openDirections = directions.values()
	var selectedDirection = openDirections.pick_random()
	
	var ownConnectionPointDict = get_connection_point(-1 * selectedDirection)
	var roomConnectionPointDict = room.get_connection_point(selectedDirection)
	
	var oldPosition = global_position
	global_position -= Vector2(ownConnectionPointDict["globalPosition"] - roomConnectionPointDict["globalPosition"])

	await get_tree().create_timer(0.05).timeout

	if not room:
		return
	if not get_overlapping_areas().is_empty():
		return false
	
	create_door(ownConnectionPointDict["mapPoint"], -1 * selectedDirection)
	room.create_door(roomConnectionPointDict["mapPoint"], selectedDirection)
	
	if connected_rooms.has(room): return true
	connected_rooms.append(room)
	if room.has_method("add_connection"):
		room.add_connection(self)
	return true
	
	return true

func add_connection(room: Node2D) -> void:
	if not connected_rooms.has(room):
		connected_rooms.append(room)

func get_connection_point(direction) -> Dictionary:
	var rect = floor_layer.get_used_rect()
	var allCells = floor_layer.get_used_cells()
	
	if direction == directions["right"]:
		var x = rect.position.x + rect.size.x -1
		allCells = allCells.filter(func(element): return element.x == x)
		direction *= 2
	elif direction == directions["left"]:
		var x = rect.position.x
		allCells = allCells.filter(func(element): return element.x == x)
	elif direction == directions["bottom"]:
		var y = rect.position.y + rect.size.y -1
		allCells = allCells.filter(func(element): return element.y == y)
	elif direction == directions["top"]:
		var y = rect.position.y
		allCells = allCells.filter(func(element): return element.y == y)
		direction *= 5
	
	var selectedPoint: Vector2i = allCells.pick_random()
	
	return {
		"mapPoint": selectedPoint,
		"globalPosition": floor_layer.map_to_local(selectedPoint  + direction) + global_position
	}

func create_door(doorPoint, direction):
	if direction == directions["right"]:
		_create_right_door(doorPoint, direction)
	elif direction == directions["left"]:
		_create_left_door(doorPoint, direction)
	elif direction == directions["bottom"]:
		_create_bottom_door(doorPoint, direction)
	elif direction == directions["top"]:
		_create_top_door(doorPoint, direction)
		
	wall_layer.set_cell(doorPoint + direction, 0, Vector2(-1,-1))
	floor_layer.set_cell(doorPoint + direction, 1, floorTiles["default"])

func _create_right_door(doorPoint, direction):
	if _has_wall(doorPoint + direction + directions["top"] *2):
		wall_layer.set_cell(doorPoint + direction + directions["top"], 5, wallTiles["topRightCornerReverse"])

	if _has_wall(doorPoint + direction + directions["bottom"] *2):
		wall_layer.set_cell(doorPoint + direction + directions["bottom"], 5, wallTiles["bottomRightCornerReverse"])
	else:
		wall_layer.set_cell(doorPoint + direction + directions["bottom"], 5, wallTiles["bottom"])

func _create_left_door(doorPoint, direction):
	if _has_wall(doorPoint + direction + directions["top"] *2):
		wall_layer.set_cell(doorPoint + direction + directions["top"], 5, wallTiles["topLeftCornerReverse"])
	
	if _has_wall(doorPoint + direction + directions["bottom"] *2):
		wall_layer.set_cell(doorPoint + direction + directions["bottom"], 5, wallTiles["bottomLeftCornerReverse"])
	else:
		wall_layer.set_cell(doorPoint + direction + directions["bottom"], 5, wallTiles["bottom"])

func _create_bottom_door(doorPoint, direction):
	if _has_wall(doorPoint + direction + directions["left"] *2):
		wall_layer.set_cell(doorPoint + direction + directions["left"], 5, wallTiles["bottomLeftCornerReverse"])
	else:
		wall_layer.set_cell(doorPoint + direction + directions["left"], 5, wallTiles["left"])
		
	if _has_wall(doorPoint + direction + directions["right"] *2):
		wall_layer.set_cell(doorPoint + direction + directions["right"], 5, wallTiles["bottomRightCornerReverse"])
	else:
		wall_layer.set_cell(doorPoint + direction + directions["right"], 5, wallTiles["right"])

func _create_top_door(doorPoint, direction):
	wall_layer.set_cell(doorPoint + direction*2, 0, Vector2(-1,-1))
	wall_layer.set_cell(doorPoint + direction*3, 0, Vector2(-1,-1))
	wall_layer.set_cell(doorPoint + direction*4, 0, Vector2(-1,-1))
	
	floor_layer.set_cell(doorPoint + direction * 2, 1, floorTiles["default"])
	floor_layer.set_cell(doorPoint + direction * 3, 1, floorTiles["default"])
	floor_layer.set_cell(doorPoint + direction * 4, 1, floorTiles["default"])
	
	if _has_wall(doorPoint + direction * 4 + directions["left"] *2):
		wall_layer.set_cell(doorPoint + direction  * 4 + directions["left"], 5, wallTiles["topLeftCornerReverse"])
	else:
		wall_layer.set_cell(doorPoint + direction  * 4 + directions["left"], 5, wallTiles["left"])
		
	if _has_wall(doorPoint + direction * 4 + directions["right"] *2):
		wall_layer.set_cell(doorPoint + direction * 4 + directions["right"] , 5, wallTiles["topRightCornerReverse"])
	else:
		wall_layer.set_cell(doorPoint + direction  * 4 + directions["right"], 5, wallTiles["right"])


func disconnect_from(room):
	if not room:
		return false  # 如果房间为空，直接返回失败
	connected_rooms.erase(room)
	# 获取连接方向
	var connection_direction = get_connection_direction(room)
	if connection_direction == null:
		return false  # 如果没有找到连接方向，返回失败

	# 获取连接点信息
	var ownConnectionPointDict = get_connection_point(-1 * connection_direction)
	var roomConnectionPointDict = room.get_connection_point(connection_direction)

	# 移除门
	remove_door(ownConnectionPointDict["mapPoint"], -1 * connection_direction)
	room.remove_door(roomConnectionPointDict["mapPoint"], connection_direction)

	# 恢复连接点的墙壁和地板
	restore_connection_point(ownConnectionPointDict["mapPoint"], -1 * connection_direction)
	room.restore_connection_point(roomConnectionPointDict["mapPoint"], connection_direction)
	
	return true  # 断连成功

func get_connection_direction(room):
	# 遍历所有方向，检查是否有连接
	for direction in directions.values():
		var ownConnectionPointDict = get_connection_point(-1 * direction)
		var roomConnectionPointDict = room.get_connection_point(direction)
		if is_room_connected(ownConnectionPointDict, roomConnectionPointDict):
			return direction
	return null  # 如果没有找到连接方向，返回 null

func is_room_connected(ownConnectionPointDict, roomConnectionPointDict) -> bool:
	# 判断两个房间是否通过连接点相连
	return (ownConnectionPointDict["globalPosition"] == roomConnectionPointDict["globalPosition"])

func remove_door(doorPoint, direction):
	# 根据方向移除门
	wall_layer.set_cell(doorPoint + direction, 0, Vector2(-1, -1))  # 清除墙壁
	floor_layer.set_cell(doorPoint + direction, 1, Vector2(-1, -1))  # 恢复地板为默认值

	# 根据方向清理额外的装饰（如角落）
	if direction == directions["right"]:
		_remove_right_door(doorPoint, direction)
	elif direction == directions["left"]:
		_remove_left_door(doorPoint, direction)
	elif direction == directions["bottom"]:
		_remove_bottom_door(doorPoint, direction)
	elif direction == directions["top"]:
		_remove_top_door(doorPoint, direction)

func _remove_right_door(doorPoint, direction):
	wall_layer.set_cell(doorPoint + direction + directions["top"], 0, Vector2(-1, -1))
	wall_layer.set_cell(doorPoint + direction + directions["bottom"], 0, Vector2(-1, -1))

func _remove_left_door(doorPoint, direction):
	wall_layer.set_cell(doorPoint + direction + directions["top"], 0, Vector2(-1, -1))
	wall_layer.set_cell(doorPoint + direction + directions["bottom"], 0, Vector2(-1, -1))

func _remove_bottom_door(doorPoint, direction):
	wall_layer.set_cell(doorPoint + direction + directions["left"], 0, Vector2(-1, -1))
	wall_layer.set_cell(doorPoint + direction + directions["right"], 0, Vector2(-1, -1))

func _remove_top_door(doorPoint, direction):
	wall_layer.set_cell(doorPoint + direction * 2, 0, Vector2(-1, -1))
	wall_layer.set_cell(doorPoint + direction * 3, 0, Vector2(-1, -1))
	wall_layer.set_cell(doorPoint + direction * 4, 0, Vector2(-1, -1))

	wall_layer.set_cell(doorPoint + direction * 4 + directions["left"], 0, Vector2(-1, -1))
	wall_layer.set_cell(doorPoint + direction * 4 + directions["right"], 0, Vector2(-1, -1))

func restore_connection_point(point, direction):
	# 恢复连接点的墙壁和地板为默认值
	wall_layer.set_cell(point + direction, 0, wallTiles["left"])
	floor_layer.set_cell(point + direction, 1, floorTiles["default"])


func _has_wall(lookPosition):
	return wall_layer.get_cell_source_id(lookPosition) > -1


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	out_of_screen.emit(self)


func get_global_rect() -> Rect2:
	# 获取 VisibleOnScreenNotifier2D 的局部 rect
	var local_rect: Rect2 = $VisibleOnScreenNotifier2D.rect
	
	# 将局部 rect 的位置转换为全局坐标
	var global_position: Vector2 = $VisibleOnScreenNotifier2D.global_position
	
	# 计算全局 rect
	var global_rect: Rect2 = Rect2(
		global_position + local_rect.position,  # 全局左上角位置
		local_rect.size                         # 矩形大小保持不变
	)
	
	return global_rect


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	enter_screen.emit(self)


func get_connected_rooms() -> Array:
	return connected_rooms


func is_in_viewport():
	return $VisibleOnScreenNotifier2D.is_on_screen()
