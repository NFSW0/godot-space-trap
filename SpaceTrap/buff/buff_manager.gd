## 附益管理器
## 统一处理附益
## 处理逻辑:
## 无效判定:附益不存在 或 目标不存在
## 新建判定:无叠加目标
## 叠加判定:同附益、同目标、同来源时叠加层数和剩余持续时间，但无法超过最大值
## 无限叠加:无来源的附益可以忽略叠加上限
extends Node
class_name _BuffManager


signal buff_changed(active_buff_array:Array[Buff])
const BUFF_LIBRARY_PATH = "res://buff/buff_library/"
var buff_library = {} ## 附益库{id, buff}
var active_buff_array:Array[Buff] = [] ## 生效的附益, 用于附益结算(间歇)
var inactive_buff_array = [] ## 失效的附益, 用于附益结算(消除)
var target_indexs = {} ## 存储目标附益, 方便查询


## 添加附益(编号, 目标)
func append_buff(buff_id:int, buff_target_node_path:NodePath, config_data:Dictionary = {}):
	var new_id = "%s" % buff_id
	if multiplayer.has_multiplayer_peer() and not multiplayer.is_server():
		print("多人游戏客户端忽略附益添加事件")
		return
	if not buff_library.has(new_id):
		print("忽略附益，未知附益:", new_id)
		return
	var buff_target:Node = get_node_or_null(buff_target_node_path)
	if buff_target == null:
		print("忽略附益，未知附益目标:", buff_target_node_path)
		return
	var new_buff:Buff = (buff_library[new_id] as Buff).new(buff_target, config_data)
	if new_buff.stackable(active_buff_array):
		buff_changed.emit(active_buff_array)
		return
	new_buff.start()
	active_buff_array.append(new_buff)
	buff_changed.emit(active_buff_array)

func register_packed_resource(packed_resource_id: String, packed_scene: Buff):
	buff_library[packed_resource_id] = packed_scene
	return true

## 初始化附益管理器
func _ready() -> void:
	_load_packed_resource_library()


## 附益输入处理
func _input(event: InputEvent) -> void:
	if not multiplayer.is_server():
		return
	for buff:Buff in active_buff_array:
		buff._input(event)


## 附益更新处理
func _physics_process(delta: float):
	if multiplayer.has_multiplayer_peer():
		if not multiplayer.is_server():
			return
	var index:int = active_buff_array.size() - 1
	while index >= 0:
		if active_buff_array.size() < 1:
			return
		var buff:Buff = active_buff_array[index]
		if buff.current_duration_remain > 0:
			buff._physics_process(delta)
		else:
			active_buff_array.remove_at(index)
			buff.end(active_buff_array)
		index -= 1


#region 自动更新预制资源库


const _PACKED_RESOURCE_LIBRARY_PATH := "res://buff/buff_library/" # 用于调试时自动搜索预制资源，并完成记录
const _PACKED_RESOURCE_REGISTRY_PATH := "res://buff/buff_registry.json" # 此文件记录预制资源路径表，用于导出程序使用{"resource_id": packed_scene_path}
const _PROPERTY_NAME := "buff_id" # 扫描识别的属性名


# 加载预制资源库
func _load_packed_resource_library():
	if OS.has_feature("editor"):
		var packed_resource_map = _scan_and_load_packed_resource(_PACKED_RESOURCE_LIBRARY_PATH)
		var success = _save_packed_resource_registry(packed_resource_map, _PACKED_RESOURCE_REGISTRY_PATH)
		if not success:
			push_error("保存预制资源注册表失败，导出程序将无法使用预制资源")
	else:
		_read_registry_and_load_packed_resource(_PACKED_RESOURCE_REGISTRY_PATH)


# 读取注册表并加载预制资源
func _read_registry_and_load_packed_resource(json_path: String) -> void:
	var file := FileAccess.open(json_path, FileAccess.READ)
	if file:
		var data = file.get_as_text()
		var result = JSON.parse_string(data) as Dictionary
		if typeof(result) == TYPE_DICTIONARY:
			for packed_resource_id: String in result.keys():
				var scene_path: String = "%s" % result[packed_resource_id]
				var packed_scene: Buff = load(scene_path) as Buff
				if packed_scene:
					register_packed_resource(packed_resource_id, packed_scene)
				else:
					push_warning("预制资源载入失败：%s" % scene_path)
		else:
			push_warning("预制资源注册表格式不正确")
	else:
		push_warning("无法打开预制资源注册表：%s" % json_path)


# 保存预制资源注册表，返回执行结果
func _save_packed_resource_registry(packed_resource_map:Dictionary, file_path:String) -> bool:
	var json := JSON.stringify(packed_resource_map, "\t")
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(json)
		file.close()
		return true
	else:
		return false


# 递归扫描并加载可用预制资源，返回可用路径注册表{"packed_resource_id":file_path}
func _scan_and_load_packed_resource(_directory_path: String) -> Dictionary:
	var packed_resource_map = {}
	var dir = DirAccess.open(_directory_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.begins_with("."):
				file_name = dir.get_next()
				continue
			var full_path := _directory_path.path_join(file_name)
			if dir.current_is_dir():
				packed_resource_map.merge(_scan_and_load_packed_resource(full_path)) # 递归查找子文件夹
			else:
				if file_name.ends_with(".tres"):
					var packed_scene: Buff = ResourceLoader.load(full_path) as Buff
					var packed_resource_id = "%s" % packed_scene.get(_PROPERTY_NAME)
					var success = register_packed_resource(packed_resource_id, packed_scene)
					if success:
						packed_resource_map[packed_resource_id] = full_path
					else:
						push_warning("预制资源ID(%s)注册失败，请改变ID后重试" % packed_resource_id)
					break
					packed_resource_map[packed_resource_id] = full_path
			file_name = dir.get_next()
	else:
		push_warning("尝试访问场景预制资源库时出错, 请确认该路径存在:", _directory_path)
	return packed_resource_map


#endregion 自动更新预制资源库
