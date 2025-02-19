##  感知管理器  处理感知节点
extends Node


## 阵营枚举(势力枚举)
enum Faction {NEUTRAL, PLAYER, ENEMY, NPC}


## 感知事件信号
signal perception_updated(subject, target, status)


var _registered_nodes := {}  ## 已注册节点{node_id: node}
var _faction_index := {}  ## 阵营索引{faction: [nodes]}
var _quadtree: Quadtree  ## 四叉树分割计算


func _ready() -> void:
	var window_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var window_height = ProjectSettings.get_setting("display/window/size/viewport_height")
	_quadtree = Quadtree.new(Rect2(0, 0, window_width, window_height), 4, 6)


## 注册节点
func register_node(node: PerceptionBase) -> void:
	var id = node.get_instance_id()
	if not _registered_nodes.has(id):
		_registered_nodes[id] = node
		if not _faction_index.has(node.faction):
			_faction_index[node.faction] = []
		_faction_index[node.faction].append(node)
		_quadtree.insert(node)  # 将感知节点插入四叉树
		print("Registered perception node: ", node.name)


## 注销节点
func unregister_node(node: PerceptionBase) -> void:
	var id = node.get_instance_id()
	if _registered_nodes.erase(id):
		_faction_index[node.faction].erase(node)
		_quadtree.remove(node)  # 从四叉树移除感知节点
		print("Unregistered perception node: ", node.name)


## 获取附近的感知节点
func get_nearby_nodes(node: PerceptionBase, range: float) -> Array:
	var query_range = Rect2(node.global_position - Vector2(range, range), Vector2(range * 2, range * 2))
	return _quadtree.query(query_range)


# 主更新循环
func _process(delta: float) -> void:
	for node in _registered_nodes.values():
		if node.is_active:
			# 只更新附近的感知节点
			var nearby_nodes = get_nearby_nodes(node, node.detection_range)
			node.update_perception(nearby_nodes)
