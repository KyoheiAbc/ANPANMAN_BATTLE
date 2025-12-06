class_name Select extends Node

const CELL_SIZE := 160
const CURSOR_SIZE := Vector2(150, 150)
const CURSOR_Z_INDEX := -1
const BUTTON_SIZE := Vector2(360, 90)
const BUTTON_FONT_SIZE := 32
const BUTTON_TEXT := "START"
const BUTTON_POSITION_OFFSET := Vector2(0, 300)
const MODEL_POS_PLAYER := Vector3(-5.5, -1.8, 0)
const MODEL_POS_RIVAL := Vector3(5.5, -1.8, 0)
const MODEL_ROT_PLAYER := -150
const MODEL_ROT_RIVAL := 150
const MODEL_SCALE := Vector3.ONE * 3
const ARCADE_CURSOR_COLORS := [Color.RED, Color.BLUE]
const SPRITE_MODULATE_ARCADE := Color(0.5, 0.5, 0.5, 0.5)
const SPRITE_MODULATE_SELECTED := Color(1, 1, 1, 1)
const ARCADE_TIMER := 1.5
const SELECT_TIMER := 0.5

var sprites: Array[Sprite2D] = []
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
	cursor.size = CURSOR_SIZE
	cursor.z_index = CURSOR_Z_INDEX
	add_child(cursor)

	var button := Button.new()
	button.size = BUTTON_SIZE
	button.add_theme_font_size_override("font_size", BUTTON_FONT_SIZE)
	button.text = BUTTON_TEXT
	button.position = - button.size / 2 + BUTTON_POSITION_OFFSET
	add_child(button)

	await get_tree().create_timer(SELECT_TIMER).timeout
	button.pressed.connect(func() -> void:
		Main.PLAYER_INDEX = Array2D.get_position_value(map, 0)
		Main.RIVAL_INDEXES.clear()
		for i in Main.SPRITES.size():
			if i != Main.PLAYER_INDEX:
				Main.RIVAL_INDEXES.append(i)
		Main.RIVAL_INDEXES.shuffle()
		Main.NODE.add_child(Arcade.new())
		queue_free()
	)


static func create_sprites() -> Array[Sprite2D]:
	var sprites: Array[Sprite2D] = []
	for i in Main.SPRITES.size():
		var sprite := Sprite2D.new()
		sprite.texture = Main.SPRITES[i]
		sprite.position = Vector2(i % 4, i / 4) * CELL_SIZE + -Vector2(1.5, 0.5) * CELL_SIZE
		sprites.append(sprite)
	return sprites


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
	cursor.position = sprites[Array2D.get_position_value(map, Main.PLAYER_INDEX)].position - CURSOR_SIZE / 2

	var idx := Array2D.get_position_value(map, 0)
	if old_index == idx:
		return
	old_index = idx
	if model:
		model.queue_free()
	model = Main.MODELS[1 if idx == 1 else 0].instantiate()
	model.position = MODEL_POS_PLAYER
	model.rotation_degrees.y = MODEL_ROT_PLAYER
	model.scale = MODEL_SCALE
	add_child(model)


class Arcade extends Node:
	func _ready() -> void:
		var sprites: Array[Sprite2D] = Select.create_sprites()
		for sprite in sprites:
			add_child(sprite)
			sprite.modulate = SPRITE_MODULATE_ARCADE

		for i in 2:
			var cursor := ColorRect.new()
			cursor.color = ARCADE_CURSOR_COLORS[i]
			cursor.size = CURSOR_SIZE
			cursor.z_index = CURSOR_Z_INDEX
			add_child(cursor)
			if i == 0:
				cursor.position = sprites[Main.PLAYER_INDEX].position - CURSOR_SIZE / 2
			else:
				cursor.position = sprites[Main.RIVAL_INDEXES[0]].position - CURSOR_SIZE / 2

		sprites[Main.PLAYER_INDEX].modulate = SPRITE_MODULATE_SELECTED

		for i in Main.RIVAL_INDEXES:
			sprites[i].modulate = SPRITE_MODULATE_SELECTED
	
		var model: Node3D = null
		model = Main.MODELS[1 if Main.PLAYER_INDEX == 1 else 0].instantiate()
		model.position = MODEL_POS_PLAYER
		model.rotation_degrees.y = MODEL_ROT_PLAYER
		model.scale = MODEL_SCALE
		add_child(model)

		model = Main.MODELS[1 if Main.RIVAL_INDEXES[0] == 1 else 0].instantiate()
		model.position = MODEL_POS_RIVAL
		model.rotation_degrees.y = MODEL_ROT_RIVAL
		model.scale = MODEL_SCALE
		add_child(model)

		await get_tree().create_timer(ARCADE_TIMER).timeout
		Main.NODE.add_child(Game.new())
		self.queue_free()
