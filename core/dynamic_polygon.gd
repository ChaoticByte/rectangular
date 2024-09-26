@tool
extends CollisionPolygon2D

@export var color: Color = Color.WHITE:
	set(v):
		color = v
		update_polygon()
	get():
		return color

@export var update: bool:
	set(v):
		update_polygon()

func update_polygon():
	# normal polygon
	$Polygon2D.polygon = polygon
	$Polygon2D.color = color
	# light occluder
	var lo_polygon = OccluderPolygon2D.new()
	lo_polygon.polygon = polygon
	$LightOccluder2D.occluder = lo_polygon

func _ready() -> void:
	update_polygon()
