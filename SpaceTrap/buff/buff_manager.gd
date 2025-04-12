## 附益管理器
## 统一处理附益
## 处理逻辑:
## 无效判定:附益不存在 或 目标不存在
## 新建判定:无叠加目标
## 叠加判定:同附益、同目标、同来源时叠加层数和剩余持续时间，但无法超过最大值
## 无限叠加:无来源的附益可以忽略叠加上限
extends Node
class_name _BuffManager


const BUFF_LIBRARY_PATH = "res://buff/buff_library/"
var buff_library = {} ## 附益库{id, buff}
var active_buff_array:Array[Buff] = [] ## 生效的附益, 用于附益结算(间歇)
var inactive_buff_array = [] ## 失效的附益, 用于附益结算(消除)
var target_indexs = {} ## 存储目标附益, 方便查询


## 添加附益(编号, 目标)
func append_buff(buff_id:int, buff_target_node_path:NodePath, config_data:Dictionary = {}):
	if multiplayer.has_multiplayer_peer() and not multiplayer.is_server():
		print("多人游戏客户端忽略附益添加事件")
		return
	if not buff_library.has(buff_id):
		print("忽略附益，未知附益:", buff_id)
		return
	var buff_target:Node = get_node_or_null(buff_target_node_path)
	if buff_target == null:
		print("忽略附益，未知附益目标:", buff_target_node_path)
		return
	var new_buff:Buff = (buff_library[buff_id] as Buff).new(buff_target, config_data)
	if new_buff.stackable(active_buff_array):
		return
	new_buff.start()
	active_buff_array.append(new_buff)


## 初始化附益管理器
func _ready() -> void:
	_load_buff_library(BUFF_LIBRARY_PATH)


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
		var buff:Buff = active_buff_array[index]
		if buff.current_duration_remain > 0:
			buff._physics_process(delta)
		else:
			active_buff_array.remove_at(index)
			buff.end(active_buff_array)
		index -= 1


## 加载附益库
func _load_buff_library(_directory_path:String):
	var dir = DirAccess.open(_directory_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				_load_buff_library(_directory_path.path_join(file_name)) # 递归查找子文件夹
			else:
				if file_name.ends_with(".tres"):
					var _resource = ResourceLoader.load(_directory_path.path_join(file_name)) as Buff
					buff_library[_resource.buff_id] = _resource
			file_name = dir.get_next()
	else:
		push_warning("尝试访问场景预制体资源库时出错, 请确认该路径存在:", _directory_path)
