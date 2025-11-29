class_name Main
extends Node

var characters: Array[Character] = []
var input_controller: InputController = InputController.new()

static var FREEZE_COUNT: int = 0

func _ready():
	camera()
	stage()

	characters.append(Anpan.new(characters))
	characters.append(Baikin.new(characters))
	characters.append(Baikin.new(characters))
	characters.append(Baikin.new(characters))
	for character in characters:
		add_child(character)
	characters[0].position.x = -600
	characters[1].position.x = -200
	characters[2].position.x = 200
	characters[3].position.x = 600

	add_child(input_controller)
	input_controller.rect.end.x = ProjectSettings.get_setting("display/window/size/viewport_width") * 0.75

	var input_controller_pressed = InputController.new()
	add_child(input_controller_pressed)
	input_controller_pressed.rect.position.x = ProjectSettings.get_setting("display/window/size/viewport_width") * 0.75
	input_controller_pressed.signal_pressed.connect(func(position: Vector2) -> void:
		if position.y > ProjectSettings.get_setting("display/window/size/viewport_height") / 2:
			characters[0].attack()
		else:
			characters[0].special()
	)

func _process(delta: float) -> void:
	FREEZE_COUNT -= 1
	if FREEZE_COUNT >= 0:
		for character in characters:
			character.model.visible = true
		return

	if input_controller.drag.y < -64:
		characters[0].jump()
	if input_controller.drag.x > 8:
		characters[0].walk(1)
	if input_controller.drag.x < -8:
		characters[0].walk(-1)

	for character in characters:
		character.process()


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
	stage.mesh.size = Vector2(16, 4)
	stage.position = Vector3(0, -2, -1)
	add_child(stage)
	stage.material_override = StandardMaterial3D.new()
	stage.material_override.albedo_color = Color(0, 0.5, 0)

class CustomCollisionShape2D extends CollisionShape2D:
	func _init(size: Vector2):
		self.shape = RectangleShape2D.new()
		self.shape.size = size

		var color_rect = ColorRect.new()
		add_child(color_rect)
		color_rect.color = Color.from_hsv(randf(), 1, 1, 0.1)
		color_rect.size = size
		color_rect.position = - size / 2