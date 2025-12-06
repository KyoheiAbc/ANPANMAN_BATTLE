class_name Game extends Node

var player: Character
var rival: Character
var bot: Bot
var input_controller: InputController = InputController.new()
var hp_sliders: Array[Game.GameHSlider] = []
var sp_sliders: Array[Game.GameHSlider] = []


var label: Label

var game_over_count: float = 3.0

func _ready():
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

	sp_sliders.append(Game.GameHSlider.new(Vector2(700, 20), Color(1, 1, 0)))
	sp_sliders[0].position = Vector2(-750, -340)
	add_child(sp_sliders[0])

	sp_sliders.append(Game.GameHSlider.new(Vector2(700, 20), Color(1, 1, 0)))
	sp_sliders[1].position = Vector2(50, -340)
	add_child(sp_sliders[1])


	bot = Bot.new(rival, player)
	add_child(bot)

	set_process(false)
	player.model.update_position()
	rival.direction = -1
	rival.model.update_position()
	rival.model.rotation_degrees.y = -90

	label = Main.label_new()
	add_child(label)
	label.text = "READY"


	await get_tree().create_timer(1.0).timeout
	label.text = "GO!"
	await get_tree().create_timer(0.5).timeout
	label.text = ""
	set_process(true)

	add_child(input_controller)
	input_controller.rect.end.x = ProjectSettings.get_setting("display/window/size/viewport_width") * 0.75
	input_controller.signal_pressed.connect(func(position: Vector2) -> void:
		if is_game_over():
			quit()
			return
		if position.y < ProjectSettings.get_setting("display/window/size/viewport_height") / 2:
			player.jump()
	)

	var input_controller_pressed = InputController.new()
	add_child(input_controller_pressed)
	input_controller_pressed.rect.position.x = ProjectSettings.get_setting("display/window/size/viewport_width") * 0.75
	input_controller_pressed.signal_pressed.connect(func(position: Vector2) -> void:
		if is_game_over():
			quit()
			return
		if position.y > ProjectSettings.get_setting("display/window/size/viewport_height") / 2:
			player.attack()
		else:
			player.special()
	)

func _process(delta: float) -> void:
	if is_game_over():
		game_over_count -= delta
		Engine.max_fps = 15
		if game_over_count < 1.0:
			label.text = "YOU WIN" if rival.hp <= 0 else "YOU LOSE"

	if Main.HIT_STOP_COUNT > 0:
		Main.HIT_STOP_COUNT -= 1
		player.model.visible = true
		rival.model.visible = true
		return

	if not is_game_over():
		if input_controller.drag.y < -64:
			player.jump()
		if input_controller.drag.x > 8:
			player.walk(1)
		if input_controller.drag.x < -8:
			player.walk(-1)

	player.process()
	rival.process()

	if not is_game_over():
		bot.process()
		
	for area in player.get_overlapping_areas():
		if area == rival:
			var sign = sign(player.position.x - rival.position.x)
			player.velocity = Vector2(2 * sign, -2)
			rival.velocity = Vector2(-2 * sign, -2)

	hp_sliders[0].value = player.hp / float(player.hp_max) * hp_sliders[0].max_value
	hp_sliders[1].value = rival.hp / float(rival.hp_max) * hp_sliders[1].max_value

	sp_sliders[0].value = player.special_cool_time / float(player.special_cool_time_max) * sp_sliders[0].max_value
	sp_sliders[1].value = rival.special_cool_time / float(rival.special_cool_time_max) * sp_sliders[1].max_value

func quit() -> void:
	if game_over_count >= 0:
		return
	Engine.max_fps = 60
	self.queue_free()
	if player.hp <= 0:
		Main.NODE.add_child(Main.Initial.new())
	else:
		Main.RIVAL_INDEXES.pop_front()
		if Main.RIVAL_INDEXES.size() == 0:
			Main.NODE.add_child(Main.Initial.new())
		else:
			Main.NODE.add_child(Select.Arcade.new())

func is_game_over() -> bool:
	if player.hp <= 0 or rival.hp <= 0:
		return true
	return false

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