extends Node2D

@export var slot_idx: int
@export var slot_label: String = ""


func _ready() -> void:
	$Label.text = str(slot_label)

func _on_area_2d_load_body_entered(body: Node2D) -> void:
	# load slot & start game
	if body == NodeRegistry.player:
		Gamestate.current_slot = slot_idx
		Gamestate.load_slot()
		Levels.load_entrypoint(Gamestate.last_entrypoint)

func _on_area_2d_delete_body_entered(body: Node2D) -> void:
	# reset slot on disk
	if body == NodeRegistry.player:
		Gamestate.reset_slot(slot_idx)
		NodeRegistry.player.position = Levels.mainmenu_player_pos
