class_name Bot
extends Node

var character: Character

var frame_count: int = 0

func _init(character: Character) -> void:
	self.character = character

func process() -> void:
	var player = character.rival

	frame_count += 1

	if frame_count > 90:
		frame_count = 0
		character.walk_direction = randi_range(-1, 2)
	character.walk(character.walk_direction)

	if randf() < 0.005:
		character.jump()

	if randf() < 0.075:
		character.attack_action()
