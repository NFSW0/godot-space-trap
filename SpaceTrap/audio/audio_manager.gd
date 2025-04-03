## 音频管理器[客户端]
## 管理和主持背景音乐的播放, 确保同一时间只有一首背景音乐并且不会因跨场景而终止
## 通过名称或ID返回音频播放节点, 播放时机、自动销毁、父对象、位置等由请求者自行处理
class_name _AudioManager
extends Node


const AUDIO_LIBRARY_PATH = "res://audio/audio_library/" # 音频库路径
const AUDIO_LIBRARY_JSON_NAME = "audio_library.json" # JSON文件名
var _audio_registry := {} # 音频注册表 {audio_name: scene}
var _current_bgm: AudioStreamPlayer = null # 当前正在播放的BGM节点


func _ready() -> void:
	_load_audio_library(AUDIO_LIBRARY_PATH)


## 注册音频场景
func register_audio(audio_name: String, scene: PackedScene):
	_audio_registry[audio_name] = scene


## 获取指定名称的音频
func get_audio(audio_name: String) -> Node:
	if not audio_name in _audio_registry:
		push_error("audio not registered: " + audio_name)
		return null
	return _audio_registry[audio_name].instantiate()


## 播放背景音乐
func play_bgm(bgm_name: String, fade_in_duration: float = 0.0):
	# 如果BGM已经存在且是同一首，直接返回
	if _current_bgm and _current_bgm.name == bgm_name:
		print("BGM already playing: " + bgm_name)
		return
	
	# 停止当前正在播放的BGM（如果有）
	stop_bgm(0.7)
	
	# 实例化新的BGM节点
	var new_bgm = get_audio(bgm_name)
	if not new_bgm:
		push_error("Failed to load BGM: " + bgm_name)
		return
	
	# 添加到场景树中（作为全局节点）
	add_child(new_bgm)
	
	# 淡入效果
	if fade_in_duration > 0:
		new_bgm.volume_db = -80 # 初始音量设为静音
		new_bgm.play()
		var tween = new_bgm.create_tween()
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(new_bgm, "volume_db", 0, fade_in_duration)
	else:
		new_bgm.play()
	
	# 更新当前BGM引用
	_current_bgm = new_bgm


## 停止背景音乐
func stop_bgm(fade_out_duration: float = 0.0):
	if not _current_bgm:
		print("当前没有正在播放的背景音乐……")
		return
	
	if not fade_out_duration > 0:
		_current_bgm.stop()
		_current_bgm.queue_free()
		_current_bgm = null
	else:
		var bgm_to_stop = _current_bgm # 记录需要停止的背景音乐节点 动画过程中_current_bgm可能变换
		var tween = bgm_to_stop.create_tween()
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(bgm_to_stop, "volume_db", -80, fade_out_duration)
		tween.tween_callback(_on_fade_out_finished.bind(bgm_to_stop))


#region 加载音频库
func _load_audio_library(_directory_path: String) -> Dictionary:
	if OS.has_feature("editor"):
		# 编辑器环境下：遍历文件加载音频并更新JSON文件
		var audio_library := _load_audio_library_by_scan(_directory_path)
		_save_audio_library_json(_directory_path, audio_library)
		return audio_library
	else:
		# 导出环境下：仅通过JSON文件加载
		var audio_library := _load_audio_library_by_json(_directory_path)
		if audio_library.is_empty():
			push_error("Failed to load Audio library, aborting...")
			return {}
		return audio_library

# 通过扫描文件系统加载音频库(仅编辑器环境使用)
func _load_audio_library_by_scan(_directory_path: String) -> Dictionary:
	var audio_library := {}
	var dir := DirAccess.open(_directory_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if dir.current_is_dir() and not file_name.begins_with("."):
				# 递归处理子目录
				var subdir_library := _load_audio_library_by_scan(_directory_path.path_join(file_name))
				for key in subdir_library:
					audio_library[key] = subdir_library[key]
			elif file_name.ends_with(".tscn"):
				# 注册音频场景
				var scene_name := file_name.get_basename()
				var scene_path := _directory_path.path_join(file_name)
				audio_library[scene_name] = scene_path
				register_audio(scene_name, load(scene_path))
			file_name = dir.get_next()
	else:
		print("无法访问音频存放目录, 停止自动加载音频: ", _directory_path)
	
	return audio_library

# 通过JSON文件加载音频库
func _load_audio_library_by_json(_directory_path: String) -> Dictionary:
	var audio_library := {}
	var json_path := _directory_path.path_join(AUDIO_LIBRARY_JSON_NAME)
	
	# 使用ResourceLoader检查JSON文件是否存在
	if not ResourceLoader.exists(json_path):
		push_error("音频记录文件缺失: ", json_path)
		return {}
	
	# 加载JSON文件内容
	var json: JSON = ResourceLoader.load(json_path)
	audio_library = json.data
	
	# 使用ResourceLoader加载所有音频场景
	for scene_name in audio_library:
		var scene_path: String = audio_library[scene_name]
		if ResourceLoader.exists(scene_path):
			var scene = ResourceLoader.load(scene_path)
			if scene:
				register_audio(scene_name, scene)
			else:
				push_error("音频加载失败: ", scene_path)
		else:
			push_error("音频资源不存在: ", scene_path)
	
	return audio_library

# 保存音频加载记录到JSON文件
func _save_audio_library_json(_directory_path: String, audio_library: Dictionary) -> void:
	var json_path := _directory_path.path_join(AUDIO_LIBRARY_JSON_NAME)
	var file := FileAccess.open(json_path, FileAccess.WRITE)
	
	if file:
		file.store_string(JSON.stringify(audio_library, "\t"))
		file.close()
	else:
		push_error("无法创建音频记录文件, 请检查路径是否存在: ", AUDIO_LIBRARY_PATH)
#endregion 加载音频库


#region 私有方法
## 淡出完成后的回调
func _on_fade_out_finished(audio_player: AudioStreamPlayer):
	audio_player.stop()
	audio_player.queue_free()
	# 只有当停止的bgm是当前bgm时才置空
	if _current_bgm == audio_player:
		_current_bgm = null
#endregion 私有方法
