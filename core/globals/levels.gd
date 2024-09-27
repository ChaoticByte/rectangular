extends Node

class Entrypoint extends Object:
	var scene_name: String
	var player_position: Vector2
	var reset_physics: bool
	func _init(
		scene_name_: String,
		player_position_: Vector2,
		reset_physics: bool
	) -> void:
		self.scene_name = scene_name_
		self.player_position = player_position_
		self.reset_physics = reset_physics

const SCENES = {
	"intro": "uid://c6w7lrydi43ts"
}

var ENTRYPOINTS = {
	"intro_start": Entrypoint.new("intro", Vector2(0, 0), true)
}

# load that stuff

var level_root: Node
var player: Node2D

func load_scene(scn_name: String) -> bool:  # returns true on success
	if level_root == null:
		push_error("Can't load level, level_root is not registered yet.")
		return false
	if not scn_name in SCENES:
		push_error("Level " + scn_name + " doesn't exist.")
		return false
	unload_scene()
	var scn = load(SCENES[scn_name])
	level_root.add_child(scn.instantiate())
	return true

func unload_scene():
	for c in level_root.get_children():
		c.queue_free()

func load_entrypoint(ep_name: String) -> bool: # returns true on success
	if not ep_name in ENTRYPOINTS:
		push_error("Entrypoint " + ep_name + " doesn't exist.")
		return false
	if player == null:
		push_error("Can't load entrypoint, player is not registered yet.")
		return false
	var e: Entrypoint = ENTRYPOINTS[ep_name]
	if load_scene(e.scene_name):
		player.position = e.player_position
		return true
	else:
		return false
