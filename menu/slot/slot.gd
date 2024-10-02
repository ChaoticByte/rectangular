extends Node2D

const COLOR_NORMAL = Color.DARK_SLATE_GRAY
const COLOR_USED = Color.WHITE

@export var slot_idx: int
@export var slot_label: String = ""

func update_color():
	if Gamestate.is_slot_used(slot_idx):
		$StaticBody2D/platform.color = COLOR_USED
	else:
		$StaticBody2D/platform.color = COLOR_NORMAL

func _ready() -> void:
	$Label.text = str(slot_label)
	update_color()

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
		update_color()
		NodeRegistry.player.position = self.global_position - Vector2(0, 32)
