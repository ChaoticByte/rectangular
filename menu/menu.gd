extends Node2D

func _physics_process(_delta: float) -> void:
	if NodeRegistry.player.position.y > 1000:
		NodeRegistry.player.position = Vector2(0, 0)
