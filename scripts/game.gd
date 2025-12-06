class_name Game extends Node

var player: Character
var rival: Character
var bot: Bot
var input_controller: InputController = InputController.new()
var hp_sliders: Array[Game.GameHSlider] = []

var game_over: bool = false
var game_over_timer: float = 0.0
var result_label: Label = null
var is_player_winner: bool = false

func _ready():
	camera()
	stage()

	player = Character.character_new(Main.PLAYER_INDEX)
	rival = Character.character_new(Main.RIVAL_INDEXES[0])
	add_child(player)
	player.position.x = -400

	add_child(rival)
	rival.position.x = 400

	player.rival = rival
	rival.rival = player

	hp_sliders.append(Game.GameHSlider.new(Vector2(700, 30), Color(0, 1, 0)))
	hp_sliders[0].position = Vector2(-750, -380)
	add_child(hp_sliders[0])

	hp_sliders.append(Game.GameHSlider.new(Vector2(700, 30), Color(0, 1, 0)))
	hp_sliders[1].position = Vector2(50, -380)
	add_child(hp_sliders[1])

	bot = Bot.new(rival, player)
	add_child(bot)


	add_child(input_controller)
	input_controller.rect.end.x = ProjectSettings.get_setting("display/window/size/viewport_width") * 0.75
	input_controller.signal_pressed.connect(func(position: Vector2) -> void:
		if game_over:
			return
		if position.y < ProjectSettings.get_setting("display/window/size/viewport_height") / 2:
			player.jump()
	)

	var input_controller_pressed = InputController.new()
	add_child(input_controller_pressed)
	input_controller_pressed.rect.position.x = ProjectSettings.get_setting("display/window/size/viewport_width") * 0.75
	input_controller_pressed.signal_pressed.connect(func(position: Vector2) -> void:
		if game_over:
			return
		if position.y > ProjectSettings.get_setting("display/window/size/viewport_height") / 2:
			player.attack()
		else:
			player.special()
	)

func _process(delta: float) -> void:
	if game_over:
		game_over_timer += delta
		if game_over_timer >= 1.0 and result_label == null:
			_show_result()

	if Main.HIT_STOP_COUNT > 0:
		Main.HIT_STOP_COUNT -= 1
		player.model.visible = true
		rival.model.visible = true
		return

	if not game_over:
		if input_controller.drag.y < -64:
			player.jump()
		if input_controller.drag.x > 8:
			player.walk(1)
		if input_controller.drag.x < -8:
			player.walk(-1)

	player.process()
	rival.process()

	if not game_over:
		bot.process()


	hp_sliders[0].value = player.hp / float(player.hp_max) * hp_sliders[0].max_value
	hp_sliders[1].value = rival.hp / float(rival.hp_max) * hp_sliders[1].max_value

	# Check for game over
	if player.hp <= 0 or rival.hp <= 0:
		_start_game_over(rival.hp <= 0)

func _start_game_over(player_wins: bool) -> void:
	game_over = true
	is_player_winner = player_wins
	Engine.max_fps = 15

func _show_result() -> void:
	result_label = Main.label_new()
	result_label.text = "YOU WIN" if is_player_winner else "YOU LOSE"
	add_child(result_label)
	result_label.position = Vector2.ZERO - result_label.size / 2

func _input(event: InputEvent) -> void:
	if game_over and result_label != null:
		if event is InputEventScreenTouch and event.pressed:
			Engine.max_fps = 60
			queue_free()
			Main.NODE.add_child(Main.Initial.new())

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
	var color_rect: ColorRect
	func _init(size: Vector2):
		self.shape = RectangleShape2D.new()
		self.shape.size = size

		color_rect = ColorRect.new()
		add_child(color_rect)
		color_rect.color = Color.from_hsv(randf(), 1, 1, 0.0)
		color_rect.size = size
		color_rect.position = - size / 2


class GameHSlider extends HSlider:
	func _init(_size: Vector2, color: Color) -> void:
		var empty_image = Image.create(1, 1, false, Image.FORMAT_RGBA8)
		empty_image.fill(Color(0, 0, 0, 0))
		var empty_texture = ImageTexture.create_from_image(empty_image)
		add_theme_icon_override("grabber", empty_texture)
		add_theme_icon_override("grabber_highlight", empty_texture)
		add_theme_icon_override("grabber_disabled", empty_texture)

		var stylebox = StyleBoxFlat.new()
		stylebox.bg_color = color
		add_theme_stylebox_override("grabber_area_highlight", stylebox)
		add_theme_stylebox_override("grabber_area", stylebox)
		stylebox = StyleBoxFlat.new()
		stylebox.bg_color = Color(0.4, 0.4, 0.4)
		stylebox.content_margin_top = _size.y
		add_theme_stylebox_override("slider", stylebox)

		size = _size

		min_value = 0
		max_value = 1000
		editable = false
		value = max_value