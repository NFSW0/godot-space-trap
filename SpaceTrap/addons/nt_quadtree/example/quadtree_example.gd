extends Node2D

@export var quad_tree: Quadtree
@export var example_entity: PackedScene
@export var debug_label: Label  # 用于显示查询结果的 Label

# 用于存储场景中的实体
var entities: Array = []

func _ready() -> void:
	# 获取项目设置中的窗口大小
	var window_width = ProjectSettings.get_setting("display/window/size/viewport_width")
	var window_height = ProjectSettings.get_setting("display/window/size/viewport_height")
	
	# 初始化四叉树
	quad_tree = Quadtree.new()
	quad_tree.bounds = Rect2(0, 0, window_width, window_height)  # 使用窗口大小作为四叉树边界
	quad_tree.capacity = 4  # 每个节点最多存储 4 个对象
	quad_tree.max_depth = 6  # 最大深度为 6

	# 生成一些示例实体
	for i in range(20):
		var entity = example_entity.instantiate()
		add_child(entity)
		entity.position = Vector2(randf_range(0, window_width), randf_range(0, window_height))  # 随机位置
		entities.append(entity)
		quad_tree.insert(entity)  # 将实体插入四叉树

func _physics_process(delta: float) -> void:
	# 更新四叉树中的动态实体
	for entity in entities:
		quad_tree.update(entity)

	# 示例：查询鼠标位置附近的实体
	var mouse_position = get_global_mouse_position()
	var query_range = Rect2(mouse_position - Vector2(50, 50), Vector2(100, 100))  # 查询范围
	var nearby_entities = quad_tree.query(query_range)

	# 更新 Label 的文本内容和位置
	if debug_label:
		debug_label.text = "Nearby entities: " + str(nearby_entities.size())
		debug_label.position = mouse_position + Vector2(20, 20)  # 让 Label 跟随鼠标，稍微偏移避免遮挡

	# 请求重新绘制（用于可视化）
	queue_redraw()

func _draw() -> void:
	# 绘制四叉树边界
	draw_quadtree(quad_tree.root)

	# 绘制查询范围
	var mouse_position = get_global_mouse_position()
	var query_range = Rect2(mouse_position - Vector2(50, 50), Vector2(100, 100))
	draw_rect(query_range, Color(1, 0, 0, 0.2), true)  # 红色半透明矩形

# 递归绘制四叉树
func draw_quadtree(node: Quadtree.QuadtreeNode) -> void:
	if node.has_children:
		for child in node.children:
			draw_quadtree(child)
	else:
		draw_rect(node.bounds, Color(0, 1, 0, 0.1), false)  # 绿色边框
