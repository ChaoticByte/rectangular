extends Node

# gamestate

var last_entrypoint: String

func reset_gamestate():
	# defaults
	last_entrypoint = "intro_start"

# save/load slot

const slot_min: int = 0
const slot_max: int = 3

var current_slot: int = -1
var current_slot_locked: bool = false

func _check_slot_idx(idx: int) -> bool:
	# returns if slot index is valid (in bounds)
	if idx < slot_min or idx > slot_max:
		push_error("Slot index %s is invalid." % current_slot)
		return false
	return true

func save_slot():
	# flush game state to slot
	if _check_slot_idx(current_slot):
		var slot_path: String = "user://slot%s.save" % current_slot
		var f = FileAccess.open(slot_path, FileAccess.WRITE)
		if f == null:
			push_error("Couldn't open %s" % slot_path)
			quit(1)
			return
		# create serializable data structure
		var data: Dictionary = {
			"last_entrypoint": last_entrypoint
		}
		var data_serialized = JSON.stringify(data)
		if data_serialized == null:
			push_error("Couldn't serialize save data for slot %s" % current_slot)
			quit(1)
			return
		f.store_string(data_serialized)

func load_slot():
	# load gamestate from slot
	if _check_slot_idx(current_slot):
		reset_gamestate() # init gamestate with defaults
		var slot_path: String = "user://slot%s.save" % current_slot
		if FileAccess.file_exists(slot_path):
			var f = FileAccess.open(slot_path, FileAccess.READ)
			if f == null:
				push_error("Couldn't open %s" % slot_path)
				quit(1)
				return
			var data_serialized = f.get_as_text()
			var data = JSON.parse_string(data_serialized)
			if data == null:
				push_error("Couldn't deserialize slot %s" % slot_path)
				quit(1)
				return
			# read values
			last_entrypoint = data["last_entrypoint"]
		else:
			save_slot() # new game; save defaults

func reset_slot(idx: int):
	# reset a save slot
	if _check_slot_idx(idx):
		if current_slot == idx:
			reset_gamestate()
		# delete slot file
		var slot_path: String = "user://slot%s.save" % idx
		if FileAccess.file_exists(slot_path):
			DirAccess.remove_absolute(slot_path)

func is_slot_used(idx: int):
	return FileAccess.file_exists("user://slot%s.save" % idx)

#

func quit(code: int):
	# defer get_tree().quit() to not lose the last error/stdout
	# see https://github.com/godotengine/godot/issues/90667
	await get_tree().create_timer(0.1).timeout
	get_tree().quit(code)

func _ready() -> void:
	reset_gamestate()
