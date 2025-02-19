## 四叉树资源
extends Resource
class_name Quadtree

# 四叉树节点类  存储的对象需要存在get_global_rect2方法
class QuadtreeNode:
	var bounds: Rect2    # 节点边界
	var capacity: int    # 节点容量
	var max_depth: int   # 最大深度
	var depth: int       # 当前深度
	
	var objects: Array   # 存储的对象
	var children: Array  # 子节点数组 [nw, ne, sw, se]
	var has_children: bool = false

	func _init(_bounds: Rect2, _capacity: int, _max_depth: int, _depth: int):
		bounds = _bounds
		capacity = _capacity
		max_depth = _max_depth
		depth = _depth
		objects = []
		children = []

	# 判断对象是否完全在节点边界内
	func contains(obj) -> bool:
		return bounds.encloses(obj.get_global_rect2())

	# 分裂节点为四个子节点
	func subdivide():
		var half_size = bounds.size / 2
		var child_depth = depth + 1
		
		children = [
			QuadtreeNode.new(Rect2(bounds.position, half_size), capacity, max_depth, child_depth),
			QuadtreeNode.new(Rect2(bounds.position + Vector2(half_size.x, 0), half_size),
				capacity, max_depth, child_depth),
			QuadtreeNode.new(Rect2(bounds.position + Vector2(0, half_size.y), half_size),
				capacity, max_depth, child_depth),
			QuadtreeNode.new(Rect2(bounds.position + half_size, half_size),
				capacity, max_depth, child_depth)
		]
		has_children = true

	# 插入对象到节点
	func insert(obj) -> bool:
		if not bounds.intersects(obj.get_global_rect2()):
			return false

		# 如果有子节点，尝试插入到子节点
		if has_children:
			for child in children:
				if child.insert(obj):
					return true
			return false
		
		# 添加到当前节点
		objects.append(obj)
		
		# 超过容量且未达最大深度时分裂
		if objects.size() > capacity and depth < max_depth:
			if not has_children:
				subdivide()
			
			# 将对象重新分配到子节点
			for _obj in objects:
				for child in children:
					if child.insert(_obj):
						break
			objects.clear()
		
		return true

	# 查询区域内的对象
	func query(range: Rect2, result: Array) -> Array:
		if not bounds.intersects(range):
			return result
			
		if has_children:
			for child in children:
				child.query(range, result)
		else:
			for obj in objects:
				if range.intersects(obj.get_global_rect2()):
					result.append(obj)
		return result

	# 移除对象
	func remove(obj) -> bool:
		if not bounds.intersects(obj.get_global_rect2()):
			return false
			
		if has_children:
			var removed = false
			for child in children:
				removed = child.remove(obj) or removed
			return removed
			
		var index = objects.find(obj)
		if index != -1:
			objects.remove_at(index)
			return true
		return false

# 四叉树主类
@export var bounds: Rect2 = Rect2(0, 0, 1024, 1024):
	set(value):
		bounds = value
		reset()
@export var capacity: int = 4: ## 节点容量(推荐4-8)
	set(value):
		capacity = max(1, value)
		reset()
@export var max_depth: int = 8: ## 最大深度(推荐6-8)
	set(value):
		max_depth = max(1, value)
		reset()


var root: QuadtreeNode


func _init(init_bounds: Rect2 = Rect2(0, 0, 1024, 1024), init_capacity: int = 4, init_max_depth: int = 8):
	bounds = init_bounds
	capacity = init_capacity
	max_depth = init_max_depth
	reset()

# 重置四叉树
func reset():
	root = QuadtreeNode.new(bounds, capacity, max_depth, 0)

# 插入对象
func insert(obj) -> void:
	root.insert(obj)

# 查询区域内的对象
func query(range: Rect2) -> Array:
	return root.query(range, [])

# 更新对象位置（先移除再重新插入）
func update(obj) -> void:
	if root.remove(obj):
		insert(obj)

# 移除对象
func remove(obj) -> bool:
	return root.remove(obj)
