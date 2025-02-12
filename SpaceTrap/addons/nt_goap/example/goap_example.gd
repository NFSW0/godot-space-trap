extends CharacterBody2D


@export var goap: GOAP


func _physics_process(delta: float) -> void:
	goap.execute(delta, self)
