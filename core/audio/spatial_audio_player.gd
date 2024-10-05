class_name SpatialAudioStreamPlayer2D
extends AudioStreamPlayer2D

# EXPORTED VARS

@export var radius: float = 1000.0

# DETERMINE REVERB AMOUNT

const RAYCAST_VECS: Array[Vector2] = [
	Vector2(-1, 0),	 # 0 - left
	Vector2(-1, -1), # 1 - top left
	Vector2(0, -1),	 # 2 - top
	Vector2(1, -1),	 # 3 - top right
	Vector2(1, 0),	 # 4 - right
	Vector2(1, 1),	 # 5 - bottom right
	Vector2(0, 1),	 # 6 - bottom
	Vector2(-1, 1)	 # 7 - bottom left
]
const REVERB_MULT_PARALLEL = 2.0
const REVERB_MULT_OPP_45DEG = 1.0
const REVERB_MULT_90DEG = 0.5
const REVERB_PAIRS = [
	# [<index in raycasts array>, <index in raycasts array>, <multiplier>]
	# parallel walls
	[0, 4, REVERB_MULT_PARALLEL], # left : right
	[2, 6, REVERB_MULT_PARALLEL], # top : bottom
	[1, 5, REVERB_MULT_PARALLEL], # top left : bottom right
	[3, 7, REVERB_MULT_PARALLEL], # top right : bottom left
	# opposing walls at an 45deg angle
	[0, 3, REVERB_MULT_OPP_45DEG],
	[0, 5, REVERB_MULT_OPP_45DEG],
	[1, 4, REVERB_MULT_OPP_45DEG],
	[1, 6, REVERB_MULT_OPP_45DEG],
	[2, 5, REVERB_MULT_OPP_45DEG],
	[2, 7, REVERB_MULT_OPP_45DEG],
	[3, 6, REVERB_MULT_OPP_45DEG],
	[4, 7, REVERB_MULT_OPP_45DEG],
	# walls at an 90deg angle
	[0, 2, REVERB_MULT_90DEG],
	[0, 6, REVERB_MULT_90DEG],
	[1, 3, REVERB_MULT_90DEG],
	[1, 7, REVERB_MULT_90DEG],
	[2, 4, REVERB_MULT_90DEG],
	[3, 5, REVERB_MULT_90DEG],
	[4, 6, REVERB_MULT_90DEG],
	[5, 7, REVERB_MULT_90DEG]
]

var max_reverb_pairs_sum: float = ( # i'm shure I messed up this calculation
	radius * (						# but it works
		  (4.0 * REVERB_MULT_PARALLEL)
		+ (8.0 * REVERB_MULT_OPP_45DEG)
		+ (8.0 * REVERB_MULT_90DEG)
	)
)

var raycasts: Array[RayCast2D] = []

func create_raycasts():
	for v in RAYCAST_VECS:
		var r = RayCast2D.new()
		r.target_position = v.normalized() * radius
		raycasts.append(r)
		self.add_child(r)

func determine_reverb_params() -> Array[float]:
	# returns [room_size, wetness]
	var n_coll = 0
	var collision_points: Array[Vector2] = []
	for r in raycasts:
		if r.is_colliding():
			var collider = r.get_collider()
			if collider is StaticBody2D or collider is RigidBody2D:
				n_coll += 1
				var collision_point = r.get_collision_point()
				collision_points.append(collision_point)
			else:
				collision_points.append(Vector2(INF, INF))
		else:
			collision_points.append(Vector2(INF, INF))
	var reverb_pairs_sum: float = 0.0
	for p in REVERB_PAIRS:
		if collision_points[p[0]] != Vector2(INF, INF) and collision_points[p[1]] != Vector2(INF, INF):
			reverb_pairs_sum += (
				collision_points[p[0]].distance_to(collision_points[p[1]])
				* p[2]
			)
	var room_size =  reverb_pairs_sum / max_reverb_pairs_sum
	var wetness = n_coll / 8.0
	return [room_size, wetness]

# AUDIO EFFECTS

var audio_effect_reverb = AudioEffectReverb.new()

func update_reverb(room_size: float, wetness: float):
	audio_effect_reverb.room_size = room_size
	audio_effect_reverb.wet = wetness

# AUDIO BUS

const BUS_NAME_PREFIX = "Spatial2DBus#"
const BUS_EFFECT_POS_REVERB = 0
var bus_idx: int = -1
var bus_name: String = ""

func create_audio_bus():
	bus_idx = AudioServer.bus_count
	bus_name = "BUS_NAME_PREFIX%s" % bus_idx
	AudioServer.add_bus(bus_idx)
	AudioServer.set_bus_name(bus_idx, bus_name)
	AudioServer.set_bus_send(bus_idx, bus)
	self.bus = bus_name

func create_audio_bus_effects():
	if bus_idx == -1:
		push_error("Audio bus isn't created yet, bus create_audio_effects is called!")
		return
	# reverb
	AudioServer.add_bus_effect(bus_idx, audio_effect_reverb, BUS_EFFECT_POS_REVERB)

#

func _ready() -> void:
	create_audio_bus()
	create_audio_bus_effects()
	create_raycasts()

func _physics_process(_delta: float) -> void:
	var reverb_params = determine_reverb_params()
	update_reverb(reverb_params[0], reverb_params[1])
