extends State
class_name GhostStateIdle


var state_name = "idle"


func enter_state():
	super.enter_state()


func _process(_delta: float) -> void:
	if _entity.speed > 0:
		_entity.transform_state("move")


func exit_state():
	super.exit_state()
