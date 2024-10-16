extends Node2D

func _on_next_level_body_entered(body: Node2D) -> void:
	if body == NodeRegistry.player:
		LevelsCore.load_entrypoint("test")

func _on_unlock_player_body_entered(body: Node2D) -> void:
	if body == NodeRegistry.player:
		body.locked = false

func _on_delete_bodies_body_entered(body: Node2D) -> void:
	if body != NodeRegistry.player:
		body.call_deferred("queue_free")
