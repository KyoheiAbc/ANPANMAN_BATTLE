class_name Select extends Node

static var PLAYER_INDEX: int = 0

const SPRITES: Array[Texture2D] = [
	preload("res://assets/a_edited.png"),
	preload("res://assets/b_edited.png"),
	preload("res://assets/a_edited.png"),
	preload("res://assets/a_edited.png"),
	preload("res://assets/a_edited.png"),
	preload("res://assets/a_edited.png"),
	preload("res://assets/a_edited.png"),
	preload("res://assets/a_edited.png"),
]

var sprites: Array[Sprite2D]

func _init() -> void:
	var window = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"),
	)

	for i in range(SPRITES.size()):
		sprites.append(Sprite2D.new())
		add_child(sprites.back())
		sprites.back().scale = Vector2(1, 1)
		sprites.back().texture = SPRITES[i]
		if i < 4:
			sprites.back().position = Vector2(i * 300, window.y / 4)
		else:
			sprites.back().position = Vector2((i - 4) * 300, window.y / 4 + 300)
		sprites.back().position.x += 150