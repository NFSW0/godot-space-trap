extends State
class_name GhostStateMove

var state_name = "move"


func enter_state():
	super.enter_state()


func _process(_delta: float) -> void:
	if _entity.speed == 0:
		_entity.transform_state("idle")


func exit_state():
	super.exit_state()
