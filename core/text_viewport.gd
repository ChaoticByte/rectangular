extends SubViewport

# All nodes from the MainViewport that are in the text_viewport group
# are shadowed in this SubViewport

@onready var camera: Camera2D = $Camera2D
@onready var container: Node2D = %LevelTextRootContainer

# map nodes to its shadowed nodes
var mapping: Dictionary = {}

func update_mapping():
	var nodes = get_tree().get_nodes_in_group("text_viewport")
	for k in mapping.keys():
		if not is_instance_valid(k): # check if node is gone
			container.remove_child(mapping[k])
			mapping.erase(k)
	for n in nodes:
		if not n in mapping.keys():
			var dup = n.duplicate()
			dup.remove_from_group("text_viewport")
			mapping[n] = dup
			container.add_child(dup)

func _process(_delta: float) -> void:
	update_mapping()
	# update shadowed nodes
	for k in mapping:
		var v =  mapping[k]
		if k is Label and k.text != v.text:
			v.text = k.text
		if (k is Label or k is Node2D):
			mapping[k].global_position = k.global_position
	# camera position
	var orig_camera: Camera2D = NodeRegistry.player.camera
	camera.global_position = -orig_camera.get_viewport_transform().origin
