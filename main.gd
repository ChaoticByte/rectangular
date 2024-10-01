extends Node2D

func _ready() -> void:
	NodeRegistry.level_root_container = $LevelRoot
	NodeRegistry.player = $Player
	Levels.load_menu()
