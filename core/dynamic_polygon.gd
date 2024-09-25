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
	$Polygon2D.polygon = polygon
	$Polygon2D.color = color

func _ready() -> void:
	update_polygon()
