extends CharacterBody2D

@onready var camera = $Camera2D

# die

func die():
	Levels.load_entrypoint(Gamestate.last_entrypoint)

# movement and stuff

@export var movement_speed = 300.0
@export var jump_velocity = -350.0
@export var max_jumps: int = 2
@export var rigidbody_impulse_mult: float = 0.04

@onready var ceiling_raycast1 = $RayCastUp1
@onready var ceiling_raycast2 = $RayCastUp2

var jumps = 0

func _physics_process(delta: float) -> void:
	var dir = Input.get_axis("player_left", "player_right")
	var on_floor = is_on_floor()
	var on_wall = is_on_wall()
	var on_ceiling = ceiling_raycast1.is_colliding() or ceiling_raycast2.is_colliding()
	# left right movement
	if dir:
		velocity.x = dir * movement_speed
	else:
		velocity.x = move_toward(velocity.x, 0, movement_speed)
	# gravity
	if not (on_floor or on_ceiling):
		velocity += get_gravity() * delta
	# reset number of jumps
	if on_ceiling or on_floor or on_wall:
		jumps = 0
	# jumping / dropping from ceiling
	if Input.is_action_just_pressed("player_jump"):
		if on_ceiling: # drop from ceiling
			velocity += get_gravity() * delta
		elif jumps < max_jumps: # (allows air jumps)
			velocity.y = jump_velocity
			jumps += 1
	move_and_slide()
	# affect rigid bodies
	# adapted solution from
	# https://kidscancode.org/godot_recipes/4.x/physics/character_vs_rigid/index.html
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D:
			var impulse = -collision.get_normal() * (velocity.length() / collider.mass) * rigidbody_impulse_mult
			collider.apply_central_impulse(impulse)

func _ready() -> void:
	$AudioListener2D.make_current()
