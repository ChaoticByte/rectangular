class_name SpatialAudioStreamPlayer2D
extends AudioStreamPlayer2D

# EXPORTED VARS

@export var lowpass_cutoff_mult: float = 1000
@export var lowpass_cutoff_min: float = 100
@export var dampening_distance_divisor_mult: float = 500

# DETERMINE REVERB EFFECT PARAMETERS

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
const REVERB_MULT_PARALLEL = 1.0
const REVERB_MULT_OPP_45DEG = 0.5
const REVERB_MULT_90DEG = 0.25
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
const REVERB_PAIRS_SUM_DIVISOR = 2500.0 # i dunno
var raycasts: Array[RayCast2D] = []

func create_raycasts():
	# raycasts used for reverb
	for v in RAYCAST_VECS:
		var r = RayCast2D.new()
		r.target_position = v.normalized() * max_distance
		raycasts.append(r)
		self.add_child(r)

func determine_reverb_params() -> Array[float]:
	# returns [room_size, wetness]
	var n_coll: int = 0
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
				collision_points[p[0]].distance_to(collision_points[p[1]]) * p[2]
			)
	var room_size = reverb_pairs_sum / REVERB_PAIRS_SUM_DIVISOR
	var wetness = n_coll / 8.0
	return [room_size, wetness]

# DETERMINE DAMPENING (LOWPASS) EFFECT PARAMETERS

const N_POINTCASTS_TO_PLAYER: int = 25
const POINTCAST_TO_PLAYER_COLL_MASK: int = 0b00000000_00000000_00000000_00000001
const LOWPASS_CUTOFF_MAX: float = 20000

func determine_distance_amount_blocked() -> float:
	# returns how many points (in relation to the amount of points)
	# between this and the player are intersecting
	# and therefore an obstacle for the sound
	var position_player = NodeRegistry.player.global_position
	var distance_to_player = self.global_position.distance_to(position_player)
	# get n collisions
	var n_coll: int = 0
	# cast points towards player
	var space_state = get_world_2d().direct_space_state
	for i in range(N_POINTCASTS_TO_PLAYER):
		# linear interpolate between own position and player position
		var point_pos = lerp(self.global_position, position_player, i/float(N_POINTCASTS_TO_PLAYER))
		var query_params = PhysicsPointQueryParameters2D.new()
		query_params.collision_mask = POINTCAST_TO_PLAYER_COLL_MASK
		query_params.position = point_pos
		var result = space_state.intersect_point(query_params)
		if len(result) > 0:
			n_coll += 1
	return (n_coll*distance_to_player) / (float(N_POINTCASTS_TO_PLAYER)*dampening_distance_divisor_mult)

# AUDIO EFFECTS

var audio_effect_reverb = AudioEffectReverb.new()
var audio_effect_dampen = AudioEffectLowPassFilter.new()

func update_reverb(room_size: float, wetness: float):
	audio_effect_reverb.room_size = room_size
	audio_effect_reverb.wet = wetness

func update_dampening(distance_blocked: float):
	audio_effect_dampen.cutoff_hz = clamp(
		lowpass_cutoff_mult / max(0.001, distance_blocked),
		lowpass_cutoff_min, LOWPASS_CUTOFF_MAX
	)

# AUDIO BUS

const BUS_NAME_PREFIX = "Spatial2DBus#"
const BUS_EFFECT_POS_REVERB = 0
const BUS_EFFECT_POS_LOWPASS = 1
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
	# dampeing (lowpass)
	AudioServer.add_bus_effect(bus_idx, audio_effect_dampen, BUS_EFFECT_POS_LOWPASS)

#

func _ready() -> void:
	create_audio_bus()
	create_audio_bus_effects()
	create_raycasts()

func _physics_process(_delta: float) -> void:
	var reverb_params = determine_reverb_params()
	var blocked_amount = determine_distance_amount_blocked()
	update_reverb(reverb_params[0], reverb_params[1])
	update_dampening(blocked_amount)
