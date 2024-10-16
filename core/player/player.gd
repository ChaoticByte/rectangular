extends CharacterBody2D

@onready var camera = $Camera2D

# die

func die():
	LevelsCore.load_entrypoint(Gamestate.last_entrypoint)

# movement and stuff

@export var movement_speed = 300.0
@export var jump_velocity = -350.0
@export var air_friction = 0.02
@export var floor_friction = 0.1
@export var max_jumps: int = 2
@export var rigidbody_impulse_mult: float = 0.04

var locked: bool = false
var jumps: int = 0

func _physics_process(delta: float) -> void:
	var gravity = get_gravity()
	var dir = Input.get_axis("player_left", "player_right")
	var on_floor = is_on_floor()
	var on_wall = is_on_wall()
	# left right movement
	if dir and not locked:
		velocity.x = move_toward(velocity.x, dir * movement_speed, movement_speed*floor_friction)
	elif on_floor:# or on_ceiling:
		velocity.x = move_toward(velocity.x, 0, movement_speed*floor_friction)
	elif not locked:
		velocity.x = move_toward(velocity.x, 0, movement_speed*air_friction)
	# gravity
	if not on_floor:
		velocity += gravity * delta
	# reset number of jumps
	if on_floor or on_wall:
		jumps = 0
	# jumping / dropping from ceiling
	if Input.is_action_just_pressed("player_jump") and not locked:
		if jumps < max_jumps: # (allows air jumps)
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
