## 数据管理器[自动加载]
## 统一处理数据文件读写
## 管理玩家偏好数据(本体数据作为场景预制体)
extends Node
class_name _DataManager


const PREFER_DATA_PATH = "user://data.json"
var prefer_data = {} # 偏好数据:保存玩家数据、保存空间数据、保存设置数据


func _ready() -> void:
	_read_prefer_data()


## 设置玩家偏好数据
func set_prefer_data(key, value):
	prefer_data[key] = value


## 保存玩家偏好数据
func save_prefer_data():
	var json_string = JSON.stringify(prefer_data)
	var file = FileAccess.open(PREFER_DATA_PATH, FileAccess.WRITE)
	file.store_string(json_string)


## 读取玩家偏好数据
func _read_prefer_data():
	if not FileAccess.file_exists(PREFER_DATA_PATH):
		return
	var file = FileAccess.open(PREFER_DATA_PATH, FileAccess.READ)
	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)
	if error == OK:
		prefer_data = json.data
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
