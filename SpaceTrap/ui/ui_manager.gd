## 用户交互界面管理器(CanvasLayer):分三层管理UI节点
## 上层:大小占据全部屏幕，叶子节点会阻止输入传递到后续层(包括游戏世界)，注册在本层的UI相互排斥(同一时间不能存在两个本层的UI)，如果开启新的本层的UI会暂时关闭旧的本层的UI，新的本层的UI关闭后会恢复旧的本层的UI(实现类似返回的功能)。使用案例：标题主菜单、游戏退出菜单、功能较多较复杂的背包界面、移动端的触屏输入界面……
## 中层:大小占据部分屏幕，叶子节点会阻止输入传递到后续层(包括游戏世界)，注册在本层的UI可以同时存在，但是存在相对的覆盖关系，最新被互动的本层的UI或者最新打开的本层的UI显示在最上层。使用案例：聊天界面、功能相对简单的互动界面、其他UI的开关按钮……
## 下层:大小占据部分屏幕，叶子节点不会阻止输入到后续层(也就是游戏世界)，注册在本层的UI可以同时存在，无需处理覆盖关系，通常用于显示信息。使用案例：血条显示、名称显示、提示信息显示……
## 中层与下层联合注册在上层(中下层与上层其他UI相互排斥)
class_name _UIManager
extends CanvasLayer

enum UILayer {TopLayer, MiddleLayer, BottomLayer}

const UI_LIBRARY_PATH = "res://ui/ui_library/" # UI存放路径
const UI_LIBRARY_JSON_NAME = "ui_library.json" # JSON文件名

var _ui_registry := {} # UI注册表 {ui_name: scene}
var _top_stack := []
var _middle_uis := []
var _bottom_uis := []
var _layer_containers := {}

func _ready() -> void:
	_init_layer(UILayer.BottomLayer, "BottomLayer")
	_init_layer(UILayer.MiddleLayer, "MiddleLayer")
	_init_layer(UILayer.TopLayer, "TopLayer")
	_load_ui_library(UI_LIBRARY_PATH)

## 注册UI场景
func register_ui(ui_name: String, scene: PackedScene):
	_ui_registry[ui_name] = scene

## 接管UI: 接管已经实例化的UI 相对屏幕静止 同时与请求者绑定存在关系(一起销毁)
func take_over_ui(ui_instance: Control, requester: Node):
	requester.connect("tree_exited", func():close_ui(ui_instance))
	var ui_layer = ui_instance.get("ui_layer")
	match ui_layer:
		UILayer.TopLayer:
			_open_top_ui(ui_instance)
		UILayer.MiddleLayer:
			_open_middle_ui(ui_instance)
		UILayer.BottomLayer:
			_open_bottom_ui(ui_instance)
		_:
			_open_top_ui(ui_instance)

## 打开UI: 从UI库中搜寻同名UI进行实例化并返回实例化结果
func open_ui(ui_name: String, requester: Node) -> Control:
	if not ui_name in _ui_registry:
		push_error("UI not registered: " + ui_name)
		return null
	
	var ui_instance = _ui_registry[ui_name].instantiate()
	var ui_layer = ui_instance.get("ui_layer")
	
	match ui_layer:
		UILayer.TopLayer:
			_open_top_ui(ui_instance)
		UILayer.MiddleLayer:
			_open_middle_ui(ui_instance)
		UILayer.BottomLayer:
			_open_bottom_ui(ui_instance)
		_:
			_open_top_ui(ui_instance)
	
	if ui_instance.has_method("on_ui_loaded"):
		ui_instance.on_ui_loaded(requester)
	
	return ui_instance

## 关闭UI: 关闭指定UI
func close_ui(ui_instance: Control):
	if ui_instance in _top_stack:
		_close_top_ui(ui_instance)
	elif ui_instance in _middle_uis:
		_middle_uis.erase(ui_instance)
		ui_instance.queue_free()
	elif ui_instance in _bottom_uis:
		_bottom_uis.erase(ui_instance)
		ui_instance.queue_free()

#region 加载UI库
func _load_ui_library(_directory_path: String) -> Dictionary:
	if OS.has_feature("editor"):
		# 编辑器环境下：遍历文件加载并更新JSON
		var ui_library := _load_ui_library_by_scan(_directory_path)
		_save_ui_library_json(_directory_path, ui_library)
		return ui_library
	else:
		# 导出环境下：仅通过JSON文件加载
		var ui_library := _load_ui_library_by_json(_directory_path)
		if ui_library.is_empty():
			push_error("Failed to load UI library, aborting...")
			return {}
		return ui_library

# 通过扫描文件系统加载UI库(仅编辑器环境使用)
func _load_ui_library_by_scan(_directory_path: String) -> Dictionary:
	var ui_library := {}
	var dir := DirAccess.open(_directory_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and not file_name.begins_with("."):
				# 递归处理子目录
				var subdir_library := _load_ui_library_by_scan(_directory_path.path_join(file_name))
				for key in subdir_library:
					ui_library[key] = subdir_library[key]
			elif file_name.ends_with(".tscn"):
				# 注册UI场景
				var scene_name := file_name.get_basename()
				var scene_path := _directory_path.path_join(file_name)
				ui_library[scene_name] = scene_path
				register_ui(scene_name, load(scene_path))
			file_name = dir.get_next()
	else:
		print("无法访问UI存放目录, 停止自动加载UI: ", _directory_path)
	
	return ui_library

# 通过JSON文件加载UI库
func _load_ui_library_by_json(_directory_path: String) -> Dictionary:
	var ui_library := {}
	var json_path := _directory_path.path_join(UI_LIBRARY_JSON_NAME)
	
	# 使用ResourceLoader检查JSON文件是否存在
	if not ResourceLoader.exists(json_path):
		push_error("UI记录文件缺失: ", json_path)
		return {}
	
	# 加载JSON文件内容
	var json: JSON = ResourceLoader.load(json_path)
	ui_library = json.data
	
	# 使用ResourceLoader加载所有UI场景
	for scene_name in ui_library:
		var scene_path: String = ui_library[scene_name]
		if ResourceLoader.exists(scene_path):
			var scene = ResourceLoader.load(scene_path)
			if scene:
				register_ui(scene_name, scene)
			else:
				push_error("加载UI场景失败: ", scene_path)
		else:
			push_error("UI场景资源不存在: ", scene_path)
	
	return ui_library

# 保存UI加载记录到JSON文件
func _save_ui_library_json(_directory_path: String, ui_library: Dictionary) -> void:
	var json_path := _directory_path.path_join(UI_LIBRARY_JSON_NAME)
	var file := FileAccess.open(json_path, FileAccess.WRITE)
	
	if file:
		file.store_string(JSON.stringify(ui_library, "\t"))
		file.close()
	else:
		push_error("无法创建UI记录文件, 请检查路径是否存在: ", UI_LIBRARY_PATH)
#endregion 加载UI库

#region 初始化层级容器
func _init_layer(ui_layer: UILayer, layer_name: String):
	var container = get_node_or_null(layer_name)
	if not container:
		container = Control.new()
		container.set("name", layer_name)
		container.set("mouse_filter", Control.MOUSE_FILTER_IGNORE)
		container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(container)
	_layer_containers[ui_layer] = container
#endregion 初始化层级容器

#region 上层UI处理
func _open_top_ui(new_ui: Control):
	_hide_current_top_ui()
	_add_ui_to_top_stack(new_ui)
	_on_top_layer_changed()

func _close_top_ui(ui_instance: Control):
	_remove_ui_from_top_stack(ui_instance)
	_show_current_top_ui()
	_on_top_layer_changed()

func _hide_current_top_ui():
	if not _top_stack.is_empty():
		var current_top_layer_ui = _top_stack.back()
		current_top_layer_ui.visible = false

func _add_ui_to_top_stack(new_ui: Control):
	_set_ui_to_layer(new_ui, _layer_containers[UILayer.TopLayer])
	_top_stack.append(new_ui)

func _remove_ui_from_top_stack(ui_instance: Control):
	_top_stack.erase(ui_instance)
	ui_instance.queue_free()

func _show_current_top_ui():
	if not _top_stack.is_empty():
		var current_top_layer_ui = _top_stack.back()
		current_top_layer_ui.visible = true

func _on_top_layer_changed():
	var is_top_stack_empty = _top_stack.is_empty()
	_layer_containers[UILayer.MiddleLayer].visible = is_top_stack_empty
	_layer_containers[UILayer.BottomLayer].visible = is_top_stack_empty
#endregion 上层UI处理

#region 中层UI处理
func _open_middle_ui(new_ui: Control):
	_set_ui_to_layer(new_ui, _layer_containers[UILayer.MiddleLayer])
	_middle_uis.append(new_ui)
	new_ui.gui_input.connect(_on_middle_ui_interacted.bind(new_ui))

# 中层UI交互后设置遮挡关系
func _on_middle_ui_interacted(event: InputEvent, popup: Control):
	if event is InputEventMouseButton:
		popup.move_to_front()
#endregion 中层UI处理

#region 下层UI处理
func _open_bottom_ui(new_ui: Control):
	_set_ui_to_layer(new_ui, _layer_containers[UILayer.BottomLayer])
	_bottom_uis.append(new_ui)
#endregion 下层UI处理


#region 辅助方法
func _set_ui_to_layer(ui_node: Control, layer_node: Control):
	if ui_node.get_parent():
		ui_node.reparent(layer_node)
	else:
		layer_node.add_child(ui_node)
#endregion 辅助方法
