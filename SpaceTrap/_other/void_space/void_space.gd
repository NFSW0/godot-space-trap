extends Node2D

@onready var skeleton: CharacterBody2D = $Node2D/Skeleton
@onready var dummy: CharacterBody2D = $Node2D/Dummy
@onready var entity_manager:_EntityManager = get_node_or_null("/root/EntityManager")

func _ready() -> void:
	skeleton.set("velocity", Vector2(50, 0))
	dummy.set("velocity", Vector2(100, 0))
	if entity_manager:
		entity_manager.update_spawn_path($Node2D.get_path())
