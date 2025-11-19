class_name Main
extends Node

var input_controller: InputController = InputController.new()

var player: Character = Character.new(0, Vector2(100, 150))
var rival: Character = Character.new(1, Vector2(100, 150))
var bot: Bot = Bot.new(rival)


func _ready():
	camera()

	var ground = MeshInstance3D.new()
	ground.mesh = QuadMesh.new()
	ground.mesh.size = Vector2(16, 4)
	ground.position = Vector3(0, -2, -1)
	add_child(ground)
	ground.material_override = StandardMaterial3D.new()
	ground.material_override.albedo_color = Color(0, 0.5, 0)

	add_child(player)
	player.position = Vector2(-200, -player.size.y / 2)
	player.rival = rival

	add_child(rival)
	rival.position = Vector2(200, -rival.size.y / 2)
	rival.rival = player

	add_child(bot)

	add_child(input_controller)
	input_controller.rect.end.x = ProjectSettings.get_setting("display/window/size/viewport_width") * 0.75
	

func _process(delta: float) -> void:
	if input_controller.drag.x > 8:
		player.walk(1)
	elif input_controller.drag.x < -8:
		player.walk(-1)
	if input_controller.drag.y < -64:
		player.jump()

	player.process()
	rival.process()

	bot.process()


func camera() -> void:
	RenderingServer.set_default_clear_color(Color.from_hsv(0.5, 1, 0.8))

	var window = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))

	var camera_3d = Camera3D.new()
	add_child(camera_3d)
	var light = DirectionalLight3D.new()
	camera_3d.add_child(light)
	light.shadow_enabled = false
	camera_3d.position = Vector3(0, 0, 8)
	camera_3d.rotation_degrees = Vector3(0, 0, 0)
	camera_3d.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera_3d.size = 8

	var camera_2d = Camera2D.new()
	add_child(camera_2d)

class CustomCollisionShape2D extends CollisionShape2D:
	func _init(size: Vector2):
		self.shape = RectangleShape2D.new()
		self.shape.size = size

		# var color_rect = ColorRect.new()
		# add_child(color_rect)
		# color_rect.color = Color.from_hsv(randf(), 1, 1, 0.5)
		# color_rect.size = size
		# color_rect.position = - size / 2
