## 用户交互界面管理器
## 第一层：全屏幕独占，会阻止输入传递到后续层(包括游戏世界)，注册在第一层的UI相互排斥(同一时间不能存在两个第一层的UI)，如果开启新的第一层的UI会暂时关闭旧的第一层的UI，新的第一层的UI关闭后会恢复旧的第一层的UI(实现类似返回的功能)。使用案例：标题主菜单、游戏退出菜单、功能较多较复杂的背包界面、移动端的触屏输入界面……
## 第二层：占据部分屏幕，会阻止输入传递到后续层(包括游戏世界)，注册在第二层的UI可以同时存在，但是存在相对的覆盖关系，最新被互动的第二层的UI或者最新打开的第二层的UI要显示在最上层。使用案例：聊天界面、功能相对简单的互动界面、其他UI的开关按钮……
## 第三层：占据部分屏幕，不会阻止输入到后续层(也就是游戏世界)，注册在第三层的UI可以同时存在，无需处理覆盖关系，通常用于显示信息。使用案例：血条显示、名称显示……
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
