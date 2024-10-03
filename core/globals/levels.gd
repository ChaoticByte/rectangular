extends Node

const mainmenu_player_pos: Vector2 = Vector2(0, 128 + 32)

class Entrypoint extends Object:
	var scene_name: String
	var player_position: Vector2
	var keep_velocity: bool
	var initial_velocity: Vector2
	func _init(
		scene_name_: String,
		player_position_: Vector2,
		# keep player velocity
		# if player velocity is zero, use initial_velocity
		keep_velocity_: bool = true,
		# initial player velocity
		initial_velocity_: Vector2 = Vector2.ZERO
	) -> void:
		self.scene_name = scene_name_
		self.player_position = player_position_
		self.keep_velocity = keep_velocity_
		self.initial_velocity = initial_velocity_

const SCENES = {
	"menu": "uid://bqmpoix37kutp",
	"intro": "uid://c6w7lrydi43ts",
	"test": "uid://dqf665b540tfg",
}
var MENU_SCENE: PackedScene = preload("res://menu/menu.tscn")

var ENTRYPOINTS = {
	"intro_start": Entrypoint.new("intro", Vector2(0, 0)),
	"test": Entrypoint.new("test", Vector2(1680, 200), false, Vector2(0, -500)),
}

# load that stuff

var current_scene_name: String = ""

func _pre_load_checks() -> bool:
	if NodeRegistry.level_root_container == null:
		push_error("Can't load level, level_root_container is not registered yet.")
		return false
	if NodeRegistry.player == null:
		push_error("Can't load entrypoint, player is not registered yet.")
		return false
	return true

func load_scene(scn_name: String, force_reload: bool = false) -> bool:
	# returns true on success
	if current_scene_name == scn_name and not force_reload:
		return true # nothing to do :)
	if not _pre_load_checks():
		return false
	if not scn_name in SCENES:
		push_error("Level " + scn_name + " doesn't exist.")
		return false
	unload_scene()
	var scn: Node2D = load(SCENES[scn_name]).instantiate()
	NodeRegistry.level_root_container.add_child(scn)
	return true

func unload_scene():
	if NodeRegistry.level_root_container != null:
		for c in NodeRegistry.level_root_container.get_children():
			c.queue_free()

func load_entrypoint(ep_name: String) -> bool: # returns true on success
	if not ep_name in ENTRYPOINTS:
		push_error("Entrypoint " + ep_name + " doesn't exist.")
		return false
	if not _pre_load_checks():
		return false
	var e: Entrypoint = ENTRYPOINTS[ep_name]
	if load_scene(e.scene_name):
		NodeRegistry.player.position = e.player_position
		NodeRegistry.player.camera.call_deferred("reset_smoothing")
		if not e.keep_velocity or NodeRegistry.player.velocity == Vector2.ZERO:
			NodeRegistry.player.velocity = e.initial_velocity
		Gamestate.last_entrypoint = ep_name
		Gamestate.save_slot() # save game
		return true
	else:
		return false

func load_menu():
	if not _pre_load_checks():
		return false
	unload_scene()
	NodeRegistry.player.position = mainmenu_player_pos
	return load_scene("menu", true)
