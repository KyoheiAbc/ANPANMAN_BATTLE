class_name Game extends Node

var player: Character
var rival: Character
var bot: Bot
var input_controller: InputController = InputController.new()

static var HIT_STOP_COUNT: int = 0
const DEBUG: bool = true

var ready_go_timer: Timer = Timer.new()

func _ready():
	camera()
	stage()

	if Main.PLAYER_INDEX == 0:
		player = Anpan.new()
		rival = Baikin.new()
	else:
		player = Baikin.new()
		rival = Anpan.new()
	add_child(player)
	player.position.x = -400

	add_child(rival)
	rival.position.x = 400

	player.rival = rival
	rival.rival = player

	bot = Bot.new(rival, player)
	add_child(bot)

	ready_go()

	add_child(input_controller)
	input_controller.rect.end.x = ProjectSettings.get_setting("display/window/size/viewport_width") * 0.75
	input_controller.signal_pressed.connect(func(position: Vector2) -> void:
		if position.y < ProjectSettings.get_setting("display/window/size/viewport_height") / 2:
			player.jump()
	)

	var input_controller_pressed = InputController.new()
	add_child(input_controller_pressed)
	input_controller_pressed.rect.position.x = ProjectSettings.get_setting("display/window/size/viewport_width") * 0.75
	input_controller_pressed.signal_pressed.connect(func(position: Vector2) -> void:
		if position.y > ProjectSettings.get_setting("display/window/size/viewport_height") / 2:
			player.attack()
		else:
			player.special()
	)

func _process(delta: float) -> void:
	if rival.hp <= 0 or player.hp <= 0:
		set_process(false)
		self.queue_free()
		Main.NODE.add_child(Main.Initial.new())
		return

	if HIT_STOP_COUNT > 0:
		HIT_STOP_COUNT -= 1
		player.model.visible = true
		rival.model.visible = true
		return

	if input_controller.drag.y < -64:
		player.jump()
	if input_controller.drag.x > 8:
		player.walk(1)
	if input_controller.drag.x < -8:
		player.walk(-1)

	player.process()
	rival.process()

	bot.process()

func _input(input: InputEvent) -> void:
	if not DEBUG:
		return
	if input is InputEventKey:
		if input.pressed:
			if input.keycode == KEY_W or input.keycode == KEY_UP or input.keycode == KEY_SPACE:
				player.jump()
			if input.keycode == KEY_A or input.keycode == KEY_LEFT:
				player.walk(-1)
			if input.keycode == KEY_D or input.keycode == KEY_RIGHT:
				player.walk(1)
			if input.keycode == KEY_ENTER:
				player.special()
			if input.keycode == KEY_SHIFT:
				player.attack()

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

func ready_go() -> void:
	var label = Main.label_new()
	add_child(label)
	label.text = "READY"
	label.position = Vector2.ZERO - label.size / 2

	set_process(false)
	player.process()
	rival.process()
	add_child(ready_go_timer)
	ready_go_timer.one_shot = true
	ready_go_timer.start(0.5)
	await ready_go_timer.timeout
	label.text = "GO!"
	ready_go_timer.start(0.5)
	await ready_go_timer.timeout
	label.queue_free()
	ready_go_timer.queue_free()
	set_process(true)


class CustomCollisionShape2D extends CollisionShape2D:
	var color_rect: ColorRect
	func _init(size: Vector2):
		self.shape = RectangleShape2D.new()
		self.shape.size = size

		color_rect = ColorRect.new()
		add_child(color_rect)
		color_rect.color = Color.from_hsv(randf(), 1, 1, 0.3 if Game.DEBUG else 0)
		color_rect.size = size
		color_rect.position = - size / 2
