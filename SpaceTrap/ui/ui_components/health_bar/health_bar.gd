# class_name HealthBar
extends Label

var standard_health: float = 100.0
var standard_health_bar_length: float = 100.0
var max_health_bar_length: float = 480.0

func on_ui_loaded(requester: Node) -> void:
	if not requester:
		return
	requester.tree_exited.connect(func():call_deferred("queue_free"))
	if requester.has_signal("mass_changed"):
		requester.connect("mass_changed", Callable(self, "update_view"))
	else:
		printerr("尝试给无生命对象添加血量显示界面!")

func update_view(health: float):
	var saturation_calculator: SaturationCalculator = SaturationCalculator.new(standard_health, standard_health_bar_length, max_health_bar_length)
	var health_bar_width: float = saturation_calculator.calculate(health) if saturation_calculator else 100.0
	set_indexed("custom_minimum_size:x", health_bar_width)
	set_indexed("size:x", health_bar_width)
	set("text", "%s" % roundi(health))
