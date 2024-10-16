extends Node

func _ready() -> void:
	NodeRegistry.player = %Player
	NodeRegistry.level_root_container = %LevelRootContainer
	LevelsCore.load_menu()
