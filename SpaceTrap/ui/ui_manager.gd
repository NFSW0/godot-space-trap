## 界面管理器
## 主控层(游戏菜单)>输入层(聊天栏)>显示层(数据显示)
extends CanvasLayer
class_name _UIManager


const UI_LIBRARY_PATH = "res://ui/ui_library/"
var ui_library = {}


func _ready() -> void:
	_load_ui_library(UI_LIBRARY_PATH)


## 隐藏界面
func hide_ui(ui_file_name:String):
	for child in get_children():
		if child.name == ui_file_name:
			(child as CanvasItem).hide()
			return


## 显示界面
func show_ui(ui_file_name:String):
	for child in get_children():
		if child.name == ui_file_name:
			(child as CanvasItem).show()
			return
	
	if ui_library.has(ui_file_name):
		var new_ui = (ui_library[ui_file_name] as PackedScene).instantiate()
		new_ui.name = ui_file_name
		(new_ui as CanvasItem).show()
		self.add_child(new_ui)


## 加载所有UI界面
func _load_ui_library(_directory_path:String):
	var dir = DirAccess.open(_directory_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				_load_ui_library(_directory_path.path_join(file_name)) # 递归查找子文件夹
			else:
				if file_name.ends_with(".tscn"):
					ui_library[file_name.get_basename()] = ResourceLoader.load(_directory_path.path_join(file_name))
			file_name = dir.get_next()
	else:
		push_warning("尝试访问场景预制体资源库时出错, 请确认该路径存在:", _directory_path)
