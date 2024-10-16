extends Node2D

func _physics_process(_delta: float) -> void:
	if NodeRegistry.player.position.y > 1000:
		LevelsCore.call_deferred("load_menu")
