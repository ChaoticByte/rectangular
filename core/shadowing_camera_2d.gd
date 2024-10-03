extends Camera2D

func _physics_process(_delta: float) -> void:
	var orig_camera: Camera2D = NodeRegistry.player.camera
	self.global_position = -orig_camera.get_viewport_transform().origin
