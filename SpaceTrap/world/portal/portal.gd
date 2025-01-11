extends Node2D
class_name Portal

# 传递body、self、target_portal给处理器

@export var targe_portal:Portal
var teleporting_nodes = []


func _ready() -> void:
	if not targe_portal:
		# 获取ShaderMaterial的副本 - 因为Shader参数是全局的
		var shader_material = (self.material as ShaderMaterial).duplicate()
		self.material = shader_material
		# 设置Shader参数
		shader_material.set_shader_parameter("gray_enabled", true)


func _on_area_entered(area: Area2D) -> void:
	if not targe_portal:
		return
	var transport_request = TransportData.new(self.get_path(), targe_portal.get_path(), area.get_path())
	ProtalManager.append_transport_request(transport_request.serialize())
func _on_body_entered(body: Node2D) -> void:
	if not targe_portal:
		return
	var transport_request = TransportData.new(self.get_path(), targe_portal.get_path(), body.get_path())
	ProtalManager.append_transport_request(transport_request.serialize())


func _on_area_exited(area: Area2D) -> void:
	pass # Replace with function body.
func _on_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
