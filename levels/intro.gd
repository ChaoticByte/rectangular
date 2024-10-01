extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == NodeRegistry.player:
		NodeRegistry.player.die()

func _on_next_level_body_entered(body: Node2D) -> void:
	if body == NodeRegistry.player:
		Levels.load_entrypoint("test")
