## 静默状态
extends State
class_name StateIdle


var state_name = "idle"


func enter_state():
	print(_entity.name,"-enter-",state_name)
	super.enter_state()


#func _process(_delta: float) -> void:
	#pass
#
#
#func _physics_process(_delta: float) -> void:
	#pass


func exit_state():
	print(_entity.name,"-exit-",state_name)
	super.exit_state()
