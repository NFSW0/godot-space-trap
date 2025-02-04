@tool
extends Control


signal add_environment(environment:NT_GOAP_Environment)
signal remove_environment(environment:NT_GOAP_Environment)


@onready var library_view: ItemList = %LibraryView
@onready var nt_goap_manager = get_node_or_null("/root/NT_GOAP_Manager")


func update_view(environments:Array = nt_goap_manager.environment_library):
	library_view.clear()
	for environment in environments:
		library_view.add_environment_item(environment)


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
				nt_goap_manager.environment_library = parsed_data.map(func(element): return NT_GOAP_Environment.instantiate(element))
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
		var data = (nt_goap_manager.environment_library as Array).map(func(element): return element.serialize())
		
		if not DirAccess.dir_exists_absolute(file_directory): # 如果目录不存在
			DirAccess.make_dir_recursive_absolute(file_directory) # 创建完整目录
		var file = FileAccess.open(file_path,FileAccess.WRITE) # 创建文件并打开, 关闭是自动的
		file.store_string(JSON.stringify(data)) # 写入字符化的数据
		)
	add_child(save_dialog)
	save_dialog.popup_centered()


func _on_library_view_add_environment(environment: NT_GOAP_Environment) -> void:
	add_environment.emit(environment)


func _on_library_view_remove_environment(environment: NT_GOAP_Environment) -> void:
	remove_environment.emit(environment)
