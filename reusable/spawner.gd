class_name Spawner extends Node2D

@export var spawn_interval_secs: float = 1.0
@export var spawn_interval_rand: float = 0.0
@export var stop_after_secs: float = 0.0
@export var amount_per_interval: int = 1
@export var jitter_spawnpoint: bool = false
@export var scene: PackedScene = null

func _ready() -> void:
	pass # Replace with function body.

var dt_total = 0.0
var dt = 0.0

func _process(delta: float) -> void:
	if stop_after_secs > 0.0 and dt_total < stop_after_secs:
		dt_total += delta
	if stop_after_secs > 0.0 and dt_total >= stop_after_secs:
		return
	dt += delta
	if spawn_interval_rand > 0.0:
		dt += randf_range(-spawn_interval_rand, spawn_interval_rand)
	var spawn = dt > spawn_interval_secs
	dt = fmod(dt, spawn_interval_secs)
	if spawn and scene != null:
		for i in range(amount_per_interval):
			var c = scene.instantiate()
			if jitter_spawnpoint:
				c.position += Vector2(randf_range(-12, 12), randf_range(-12, 12))
			self.add_child(c)
