## 实体管理器
## 用于实现多人同步创建实体
## 为避免场景切换实体销毁问题，统一为场内实体
## 因此场景切换后设置多人同步节点为场景节点
extends MultiplayerSpawner
class_name _EntityManager
# 多人生成器 用于同步生成节点
# data应包含entity_id
# 目标应继承自Entity，否则数据很可能不会被应用到目标
# data应避免包含sender_id，否则sender_id的内容会被覆盖


const ENTITY_LIBRARY_PATH = "res://entity/entity_library/"
var entity_library = {} # 策划实体数据(id, packed_scene)
var entity_normal_data = {} # 默认实体数据(id, data)
var entity_final_data = {} # 最终实体数据(游戏中产生的长期影响实体生成的数据)(id, data)
var unique_id: int = 0 # 用于产生唯一名称
var data_queue: Array = [] # 记录队列长度


## 生成实体
func generate_entity(data:Dictionary):
	if multiplayer.has_multiplayer_peer():
		rpc_id(1,"_rpc_generate_entity",data)
	else:
		_rpc_generate_entity(data)


## 生成实体(立刻)
func generate_entity_immediately(data:Dictionary):
	if multiplayer.has_multiplayer_peer():
		rpc_id(1,"_rpc_generate_entity_immediately",data)
	else:
		_rpc_generate_entity_immediately(data)


## 重设承载实体的节点, 通常在场景切换后调用, 默认情况下会设置为当前场景的根节点
func update_spawn_path(node_path:NodePath = get_tree().current_scene.get_path()):
	set_spawn_path(node_path)


@rpc("any_peer","call_local","reliable")
func _rpc_generate_entity(data:Dictionary):
	if multiplayer.has_multiplayer_peer():
		if not multiplayer.is_server():
			return
	var sender_id = multiplayer.get_remote_sender_id() # 获取请求端ID
	data["sender_id"] = sender_id # 补充生成数据
	data_queue.append(data)


@rpc("any_peer","call_local","reliable")
func _rpc_generate_entity_immediately(data:Dictionary):
	if multiplayer.has_multiplayer_peer():
		if not multiplayer.is_server():
			return
	var sender_id = multiplayer.get_remote_sender_id() # 获取请求端ID
	data["sender_id"] = sender_id # 补充生成数据
	spawn(data)


## 初始化
func _ready() -> void:
	_load_entity_library(ENTITY_LIBRARY_PATH)
	spawn_function = _generate_entity
	update_spawn_path()


## 在物理帧更新时生成实体
func _physics_process(_delta):
	if data_queue.is_empty():
		return
	var data = data_queue.pop_front()
	if data != null:
		if multiplayer.has_multiplayer_peer():
			spawn(data)
		else:
			var node = _generate_entity(data)
			get_node(spawn_path).add_child(node)


## 加载实体库
func _load_entity_library(_directory_path:String):
	var dir = DirAccess.open(_directory_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				_load_entity_library(_directory_path.path_join(file_name)) # 递归查找子文件夹
			else:
				if file_name.ends_with(".tscn"):
					var _resource = ResourceLoader.load(_directory_path.path_join(file_name)) as PackedScene
					var _scene_state = _resource.get_state()
					for prop_idx in _scene_state.get_node_property_count(0):
						if _scene_state.get_node_property_name(0,prop_idx) == "entity_id":
							var entity_id = _scene_state.get_node_property_value(0,prop_idx)
							entity_library[entity_id] = _resource
							break
			file_name = dir.get_next()
	else:
		push_warning("尝试访问场景预制体资源库时出错, 请确认该路径存在:", _directory_path)


## 获取唯一名称
func _get_unique_name(data) -> String:
	unique_id += 1
	return str(data["sender_id"]) + "_" + str(unique_id)


## 生成实体
func _generate_entity(data:Dictionary) -> Node:
	# 修正数据
	var entity_id = data["entity_id"]
	data = data.merged(entity_normal_data).merged(entity_final_data)
	
	# 实例化节点
	var packed_scene = entity_library.get(entity_id)
	if packed_scene == null:
		return EntityZero.new()
	if not packed_scene is PackedScene:
		return EntityZero.new()
	if not packed_scene.can_instantiate():
		return EntityZero.new()
	var node_instance = (packed_scene as PackedScene).instantiate()
	
	# 设置节点名称 确保节点路径相同 用于属性同步
	node_instance.name = _get_unique_name(data)
	
	# 设置多人控制权限
	(node_instance as Node).set_multiplayer_authority(data["sender_id"])
	data.erase("sender_id")
	
	# 设置节点初始化数据
	if node_instance.has_method("update_data"):
		node_instance.update_data(data)
	
	return node_instance
