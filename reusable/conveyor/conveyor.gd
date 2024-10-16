@tool
class_name Conveyor extends Node2D

const GAP = 8.0
const SPEED = 0.0041 # ~ the targeted physics tick time

@export var conveyor_segments: int = 20:
	set(v):
		conveyor_segments = v
		create_segments()
	get:
		return conveyor_segments

@export var speed_mult: float = 20.0

var conveyor_seg_scn = preload("uid://be7ki66sskav5")
var segments_top: Array[Node2D] = []
var segments_bottom: Array[Node2D] = []

func create_segments():
	for c in self.get_children():
		c.call_deferred("queue_free")
	segments_top = []
	segments_bottom = []
	# top
	for i in range(0, conveyor_segments + 1):
		var c = conveyor_seg_scn.instantiate()
		c.position.x = i*8.0
		self.segments_top.append(c)
		self.add_child(c)
	# bottom
	for i in range(0, conveyor_segments + 1):
		var c = conveyor_seg_scn.instantiate()
		c.position.x = i*8.0
		c.position.y = 5.0
		self.segments_bottom.append(c)
		self.add_child(c)

func _ready() -> void:
	create_segments()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	# make it NOT framerate-depedent bc this would fuck up the positioning over time
	var s = sign(speed_mult)
	for p in segments_top:
		if s > 0.0:
			if p.position.x > conveyor_segments * GAP:
				p.position.x = 0.0
		else:
			if p.position.x < 0.0:
				p.position.x = conveyor_segments * GAP
		p.position.x += SPEED * speed_mult
	for p in segments_bottom:
		if s > 0.0:
			if p.position.x < 0.0:
				p.position.x = conveyor_segments * GAP
		else:
			if p.position.x > conveyor_segments * GAP:
				p.position.x = 0.0
		p.position.x -= SPEED * speed_mult
