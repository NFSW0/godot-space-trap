extends Node2D


@onready var skeleton: CharacterBody2D = $Skeleton
@onready var dummy: CharacterBody2D = $Dummy


func _ready() -> void:
	skeleton.set("velocity", Vector2(50, 0))
	dummy.set("velocity", Vector2(100, 0))
