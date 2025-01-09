extends Node2D
class_name Portal

# 传递body、self、target_portal给处理器

@export var targe_portal:Portal
var teleporting_nodes = []


func _on_area_entered(area: Area2D) -> void:
	var transport_request = TransportData.new(self.get_path(), targe_portal.get_path(), area.get_path())
	ProtalManager.append_transport_request(transport_request)
func _on_body_entered(body: Node2D) -> void:
	var transport_request = TransportData.new(self.get_path(), targe_portal.get_path(), body.get_path())
	ProtalManager.append_transport_request(transport_request)
