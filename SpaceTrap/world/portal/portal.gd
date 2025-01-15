extends Node2D
class_name Portal


@export var targe_portal: Portal
@onready var portal_manager = get_node("/root/PortalManager")  # 获取传送管理器


var teleporting_task = []


#region 传送自动触发点
func _on_area_entered(area: Area2D) -> void:
	var transport_request = _generate_transport_request(area)
	if is_instance_valid(portal_manager) and transport_request:
		portal_manager.append_transport_request(transport_request.serialize())

func _on_body_entered(body: Node2D) -> void:
	var transport_request = _generate_transport_request(body)
	if is_instance_valid(portal_manager) and transport_request:
		portal_manager.append_transport_request(transport_request.serialize())

func _on_area_exited(area: Area2D) -> void:
	var transport_request = _generate_transport_request(area)
	if is_instance_valid(portal_manager) and transport_request:
		portal_manager.end_transport_request(transport_request.serialize())

func _on_body_exited(body: Node2D) -> void:
	var transport_request = _generate_transport_request(body)
	if is_instance_valid(portal_manager) and transport_request:
		portal_manager.end_transport_request(transport_request.serialize())

func _generate_transport_request(node: Node) -> TransportData:
	if not targe_portal or not is_instance_valid(node):
		return null
	var final_portal = targe_portal
	while final_portal and is_instance_valid(final_portal) and final_portal.targe_portal != null:
		final_portal = final_portal.targe_portal
	if not is_instance_valid(final_portal):
		return null
	return TransportData.new(self.get_path(), final_portal.get_path(), node.get_path())
#endregion


## 传送开始 开启Shader裁剪
func add_task(node: Node, duplicate_node: Node):
	if not is_instance_valid(node) or not is_instance_valid(duplicate_node):
		return
	teleporting_task.append({"node": node, "duplicate_node": duplicate_node})
	
	var node_material = node.get("material")
	if node_material is ShaderMaterial:
		node_material.set_shader_parameter("cut_enabled", true)
	var duplicate_node_material = duplicate_node.get("material")
	if duplicate_node_material is ShaderMaterial:
		duplicate_node_material.set_shader_parameter("cut_enabled", true)


## 传送结束 关闭Shader裁剪
func erase_task(node: Node, duplicate_node: Node):
	if not is_instance_valid(node) or not is_instance_valid(duplicate_node):
		return
	teleporting_task.erase({"node": node, "duplicate_node": duplicate_node})
	
	var node_material = node.get("material")
	if node_material is ShaderMaterial:
		node_material.set_shader_parameter("cut_enabled", false)
	var duplicate_node_material = duplicate_node.get("material")
	if duplicate_node_material is ShaderMaterial:
		duplicate_node_material.set_shader_parameter("cut_enabled", false)
	
	_swap_transforms(node, duplicate_node)
	
	duplicate_node.call_deferred("queue_free")


## 调试绘制传送门的位置和法线
func _draw() -> void:
	if is_instance_valid(targe_portal):
		draw_line(Vector2(), targe_portal.global_position - position, Color(1,1,0))
	
	for task in teleporting_task:
		var node = task.get("node")
		var duplicate_node = task.get("duplicate_node")
		if not is_instance_valid(node) or not is_instance_valid(duplicate_node) or not is_instance_valid(targe_portal):
			continue
		
		draw_circle(Vector2(), 5, Color(1, 0, 0))
		var normal = (node.global_position - global_position).normalized()
		draw_line(Vector2(), Vector2() + normal * 50, Color(1, 0, 0))
		
		if is_instance_valid(targe_portal):
			var start_point = targe_portal.global_position - position
			draw_circle(start_point, 5, Color(0, 1, 0))
			var normal2 = (duplicate_node.global_position - targe_portal.global_position).normalized()
			draw_line(start_point, start_point + normal2 * 50, Color(0, 1, 0))


## 传送处理
func _process(_delta: float) -> void:
	queue_redraw()
	for task in teleporting_task:
		var node = task.get("node")
		var duplicate_node = task.get("duplicate_node")
		if not is_instance_valid(node) or not is_instance_valid(duplicate_node) or not is_instance_valid(targe_portal):
			continue
		
		_update_material(node, duplicate_node)
		_sync_transform(node, self, duplicate_node, targe_portal)


## 更新材质 用于更新裁剪
func _update_material(node, duplicate_node):
	if not is_instance_valid(node) or not is_instance_valid(duplicate_node):
		return
	
	var node_material = node.get("material")
	if node_material is ShaderMaterial:
		node_material.set_shader_parameter("cut_line_position", global_position)
		node_material.set_shader_parameter("cut_line_normal", node.global_position - global_position)
	
	var duplicate_node_material = duplicate_node.get("material")
	if duplicate_node_material is ShaderMaterial:
		duplicate_node_material.set_shader_parameter("cut_line_position", targe_portal.global_position)
		duplicate_node_material.set_shader_parameter("cut_line_normal", targe_portal.global_position - duplicate_node.global_position)


## 把 A 相对 B 的变换 同步到 C 相对 D 的变换
func _sync_transform(a: Node2D, b: Node2D, c: Node2D, d: Node2D) -> void:
	if not is_instance_valid(a) or not is_instance_valid(b) or not is_instance_valid(c) or not is_instance_valid(d):
		return
	
	var global_transform_a = a.global_transform
	var global_transform_b = b.global_transform
	var relative_transform = global_transform_b.affine_inverse() * global_transform_a
	var global_transform_d = d.global_transform
	var target_global_transform = global_transform_d * relative_transform
	c.global_transform = target_global_transform


## 交换物体 A 和物体 B 的全局变换
func _swap_transforms(a: Node2D, b: Node2D) -> void:
	if not is_instance_valid(a) or not is_instance_valid(b):
		return
	
	var temp_transform = a.global_transform
	a.global_transform = b.global_transform
	b.global_transform = temp_transform
