extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Levels.player:
		Levels.load_entrypoint("intro_start")
