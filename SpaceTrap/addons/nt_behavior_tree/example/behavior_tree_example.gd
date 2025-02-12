extends InfluenceableEntity2D


@export var behavior_tree: BehaviorBase


func _physics_process(delta: float) -> void:
	behavior_tree.execute(delta, self)
