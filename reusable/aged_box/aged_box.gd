extends RigidBody2D

@export var demolition_minmax: float = 0.1

func _ready() -> void:
	var p: P = $P
	for i in range(len(p.polygon)):
		p.polygon[i].x = p.polygon[i].x * randf_range(1.0-demolition_minmax, 1.0+demolition_minmax)
		p.polygon[i].y = p.polygon[i].y * randf_range(1.0-demolition_minmax, 1.0+demolition_minmax)
	p.update_polygon()
	# make visible polygon a bit bigger than collision polygon
	for i in range(len(p.polygon_2d.polygon)):
		p.polygon_2d.polygon[i].x += sign(p.polygon[i].x) # make bigger by 1 pixel
		p.polygon_2d.polygon[i].y += sign(p.polygon[i].y)
