@tool
class_name P extends CollisionPolygon2D

@export var color: Color = Color.WHITE:
	set(v):
		color = v
		update_polygon()
	get():
		return color

var polygon_2d: Polygon2D = null
var light_occluder_2d: LightOccluder2D = null

@export var update: bool:
	set(v):
		update_polygon()

func update_polygon():
	if polygon_2d == null:
		polygon_2d = Polygon2D.new()
		self.add_child(polygon_2d)
	if light_occluder_2d == null:
		light_occluder_2d = LightOccluder2D.new()
		self.add_child(light_occluder_2d)
	# visible polygon
	polygon_2d.polygon = polygon
	polygon_2d.color = color
	# light occluder
	var lo_polygon = OccluderPolygon2D.new()
	lo_polygon.polygon = polygon
	light_occluder_2d.occluder = lo_polygon

func _ready() -> void:
	update_polygon()
