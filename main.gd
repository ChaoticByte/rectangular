extends Node

func _ready() -> void:
	NodeRegistry.player = %Player
	NodeRegistry.level_root_container = %LevelRootContainer
	NodeRegistry.level_text_root_container = %LevelTextRootContainer
	Levels.load_menu()
