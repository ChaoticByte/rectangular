extends Node2D

func _ready() -> void:
	Levels.level_root = $LevelRoot
	Levels.player = $Player
	Levels.load_entrypoint("intro_start")
