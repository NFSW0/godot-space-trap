@tool
extends Control


@onready var action_view: ItemList = %ActionView
var nt_goap_manager = NT_GOAP_Manager


func update_view(actions : Array = nt_goap_manager.action_library):
	action_view.clear()
	for action in actions:
		action_view.add_action_item(action)


func _on_load_pressed() -> void:
	var load_dialog = EditorFileDialog.new()
	load_dialog.file_mode = 0
	#load_dialog.access = 2 # FileDialog可用 EditorFileDialog不可用
	#load_dialog.use_native_dialog = true # FileDialog可用 EditorFileDialog不可用
	load_dialog.set_filters(PackedStringArray(["*.json ; JSON Files"]))
	load_dialog.connect("file_selected", func(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var parsed_data = JSON.parse_string(content)
			if parsed_data is Array:
				nt_goap_manager.action_library = parsed_data.map(func(element): return NT_GOAP_Action.instantiate(element))
				update_view()
			else:
				print("Error: Invalid JSON format")
		else:
			print("Error: Unable to open file")
	)
	add_child(load_dialog)
	load_dialog.popup_centered()


func _on_export_pressed() -> void:
	var save_dialog = EditorFileDialog.new()
	#save_dialog.access = 2 # FileDialog可用 EditorFileDialog不可用
	#save_dialog.use_native_dialog = true # FileDialog可用 EditorFileDialog不可用
	save_dialog.set_filters(PackedStringArray(["*.json ; JSON Files"]))
	save_dialog.connect("file_selected", func(path):
		var file_path = path # 文件路径
		var file_directory = file_path.get_base_dir() # 获取目录路径
		var data = (nt_goap_manager.action_library as Array).map(func(element): return element.serialize())
		
		if not DirAccess.dir_exists_absolute(file_directory): # 如果目录不存在
			DirAccess.make_dir_recursive_absolute(file_directory) # 创建完整目录
		var file = FileAccess.open(file_path,FileAccess.WRITE) # 创建文件并打开, 关闭是自动的
		file.store_string(JSON.stringify(data)) # 写入字符化的数据
		)
	add_child(save_dialog)
	save_dialog.popup_centered()


func _on_action_view_remove_action(action: NT_GOAP_Action) -> void:
	nt_goap_manager.action_library.erase(action)
