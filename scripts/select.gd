class_name Select extends Node

const CELL_SIZE := 160

var sprites: Array[SubViewportContainer] = []
var cursor: ColorRect
var map := Array2D.new_array_2d(Vector2(4, 2), -1)
var model: Node3D
var old_index := -1
var relative_position := Vector2.ZERO

func _ready() -> void:
	Main.PLAYER_INDEX = 0
	Array2D.set_value(map, Array2D.value_to_vector2(map, Main.PLAYER_INDEX), 0)

	sprites = create_sprites()
	for sprite in sprites:
		add_child(sprite)

	cursor = ColorRect.new()
	cursor.color = Color.RED
	cursor.size = Vector2(150, 150)
	cursor.z_index = -1
	add_child(cursor)

	var button := Button.new()
	button.size = Vector2(360, 90)
	button.add_theme_font_size_override("font_size", 32)
	button.text = "START"
	button.position = - button.size / 2 + Vector2(0, 240)
	add_child(button)

	await get_tree().create_timer(0.5).timeout
	button.pressed.connect(func() -> void:
		Main.PLAYER_INDEX = Array2D.get_position_value(map, 0)
		Main.RIVAL_INDEXES.clear()
		for i in Main.MODELS.size():
			if i != Main.PLAYER_INDEX:
				Main.RIVAL_INDEXES.append(i)
		Main.RIVAL_INDEXES.shuffle()
		Main.NODE.add_child(Arcade.new())
		queue_free()
	)


static func create_sprites() -> Array[SubViewportContainer]:
	var colors: Array[Color] = [
		Color.from_hsv(0.0, 0.4, 1.0), # 赤系
		Color.from_hsv(0.8, 0.4, 1.0), # 紫
		Color.from_hsv(0.08, 0.4, 1.0), # オレンジ
		Color.from_hsv(0, 0, 0.85), # グレー
		Color.from_hsv(0.15, 0.4, 1.0), # 黄色
		Color.from_hsv(0.33, 0.4, 1.0), # 緑
		Color.from_hsv(0.6, 0.4, 1.0), # 青色
		Color.from_hsv(0.65, 0.4, 0.85), # 紺色
	]
	var containers: Array[SubViewportContainer] = []
	for i in Main.MODELS.size():
		var container := SubViewportContainer.new()
		container.size = Vector2(CELL_SIZE - 32, CELL_SIZE - 32)
		container.position = Vector2(i % 4, i / 4) * CELL_SIZE + -Vector2(1.5, 0.5) * CELL_SIZE - container.size / 2
		container.stretch = true

		var viewport := SubViewport.new()
		viewport.own_world_3d = true
		container.add_child(viewport)

		var camera := Camera3D.new()
		camera.position = Vector3(0, 0, 8.0)
		camera.projection = Camera3D.PROJECTION_ORTHOGONAL
		camera.size = 0.8
		viewport.add_child(camera)

		var env := Environment.new()
		env.background_mode = Environment.BG_COLOR
		env.background_color = colors[i % colors.size()]
		camera.environment = env

		camera.add_child(DirectionalLight3D.new())

		var model: Node3D = Main.MODELS[i].instantiate()
		viewport.add_child(model)
		model.position.y = -1.2
		model.rotation_degrees.y = -150
		containers.append(container)

	return containers


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		relative_position = Vector2.ZERO
	elif event is InputEventScreenDrag:
		relative_position += event.relative
		if relative_position.x > CELL_SIZE / 2:
			relative_position.x -= CELL_SIZE
			Array2D.move_value(map, 0, Vector2(1, 0))
		if relative_position.x < -CELL_SIZE / 2:
			relative_position.x += CELL_SIZE
			Array2D.move_value(map, 0, Vector2(-1, 0))
		if relative_position.y > CELL_SIZE / 2:
			relative_position.y -= CELL_SIZE
			Array2D.move_value(map, 0, Vector2(0, 1))
		if relative_position.y < -CELL_SIZE / 2:
			relative_position.y += CELL_SIZE
			Array2D.move_value(map, 0, Vector2(0, -1))

func _process(_delta: float) -> void:
	cursor.position = sprites[Array2D.get_position_value(map, Main.PLAYER_INDEX)].position + sprites[0].size / 2 - cursor.size / 2

	var idx := Array2D.get_position_value(map, 0)
	if old_index == idx:
		return
	old_index = idx
	if model:
		model.queue_free()
	model = Main.MODELS[idx].instantiate()
	model.position = Vector3(-4.8, -0.8, 0)
	model.rotation_degrees.y = -150
	model.scale = Vector3.ONE * 3
	add_child(model)


class Arcade extends Node:
	func _ready() -> void:
		var label := Main.label_new()
		add_child(label)
		label.text = "VS"
		label.position.y += 220

		var sprites: Array[SubViewportContainer] = Select.create_sprites()
		for sprite in sprites:
			add_child(sprite)
			sprite.modulate = Color(0.5, 0.5, 0.5, 0.5)

		for i in 2:
			var cursor := ColorRect.new()
			cursor.color = Color.RED if i == 0 else Color.BLUE
			cursor.size = Vector2(150, 150)
			cursor.z_index = -1
			add_child(cursor)
			if i == 0:
				cursor.position = sprites[Main.PLAYER_INDEX].position + sprites[0].size / 2 - cursor.size / 2
			else:
				cursor.position = sprites[Main.RIVAL_INDEXES[0]].position + sprites[0].size / 2 - cursor.size / 2

		sprites[Main.PLAYER_INDEX].modulate = Color(1, 1, 1, 1)

		for i in Main.RIVAL_INDEXES:
			sprites[i].modulate = Color(1, 1, 1, 1)
	
		var model: Node3D = null
		model = Main.MODELS[Main.PLAYER_INDEX].instantiate()
		model.position = Vector3(-4.8, -0.8, 0)
		model.rotation_degrees.y = -150
		model.scale = Vector3.ONE * 3
		add_child(model)

		model = Main.MODELS[Main.RIVAL_INDEXES[0]].instantiate()
		model.position = Vector3(4.8, -0.8, 0)
		model.rotation_degrees.y = 150
		model.scale = Vector3.ONE * 3
		add_child(model)

		await get_tree().create_timer(1.5).timeout
		Main.NODE.add_child(Game.new())
		self.queue_free()
