class_name Main
extends Node

var input_controller: InputController = InputController.new()

var player: Character
var rival: Character

func _ready():
	camera()
	stage()

	player = Anpan.new()
	add_child(player)
	player.position.x = -200

	rival = Baikin.new()
	add_child(rival)
	rival.position.x = 200

	player.rival = rival
	rival.rival = player

	add_child(input_controller)
	input_controller.rect.end.x = ProjectSettings.get_setting("display/window/size/viewport_width") * 0.75

	var input_controller_pressed = InputController.new()
	add_child(input_controller_pressed)
	input_controller_pressed.rect.position.x = ProjectSettings.get_setting("display/window/size/viewport_width") * 0.75
	input_controller_pressed.signal_pressed.connect(func(position: Vector2) -> void:
		player.attack()
	)

func _process(delta: float) -> void:
	if input_controller.drag.y < -64:
		player.jump()
	if input_controller.drag.x > 8:
		player.walk(1)
	if input_controller.drag.x < -8:
		player.walk(-1)

	player.process()
	rival.process()

func camera() -> void:
	RenderingServer.set_default_clear_color(Color.from_hsv(0.5, 1, 0.8))

	var window = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))

	var camera_3d = Camera3D.new()
	add_child(camera_3d)
	camera_3d.position = Vector3(0, 0, 8)
	camera_3d.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera_3d.size = 8
	var light = DirectionalLight3D.new()
	camera_3d.add_child(light)
	light.shadow_enabled = false

	var camera_2d = Camera2D.new()
	add_child(camera_2d)

func stage() -> void:
	var stage = MeshInstance3D.new()
	stage.mesh = QuadMesh.new()
	stage.mesh.size = Vector2(16, 8)
	stage.position = Vector3(0, -4, -1)
	add_child(stage)
	stage.material_override = StandardMaterial3D.new()
	stage.material_override.albedo_color = Color(0, 0.5, 0)

class CustomCollisionShape2D extends CollisionShape2D:
	func _init(size: Vector2):
		self.shape = RectangleShape2D.new()
		self.shape.size = size

		var color_rect = ColorRect.new()
		add_child(color_rect)
		color_rect.color = Color.from_hsv(randf(), 1, 1, 0.3)
		color_rect.size = size
		color_rect.position = - size / 2
