extends CharacterBody2D


@export var movement_speed = 300.0
@export var jump_velocity = -350.0
@export var max_jumps: int = 2

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
