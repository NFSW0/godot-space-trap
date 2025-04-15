# class_name HealthBar
extends Label

var standard_health: float = 100.0
var standard_health_bar_length: float = 100.0
var max_health_bar_length: float = 480.0

var old_health_bar_width: float = 0.0
var old_health: int = 0
var tweem_duration: float = 0.5

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
	var new_health = roundi(health)
	
	var tween: Tween = self.create_tween()
	tween.tween_method(set_custom_minimum_size_x, old_health_bar_width, health_bar_width, tweem_duration)
	tween.parallel().tween_method(set_size_x, old_health_bar_width, health_bar_width, tweem_duration)
	tween.parallel().tween_method(set_custom_text, old_health, new_health, tweem_duration)
	old_health_bar_width = health_bar_width
	old_health = new_health


func set_custom_minimum_size_x(health_bar_width):
	set_indexed("custom_minimum_size:x", health_bar_width)

func set_size_x(health_bar_width):
	set_indexed("size:x", health_bar_width)

func set_custom_text(new_health):
	set("text", "%s" % new_health)
