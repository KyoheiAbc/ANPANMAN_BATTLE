class_name Bot
extends Node


var character: Character
var rival: Character

var frame_count: int = 0
var walk_direction: int = 0

func _init(character: Character, rival: Character) -> void:
	self.character = character
	self.rival = rival

	frame_count = randi_range(15, 45)

func process() -> void:
	if character.state == Character.State.ATTACKING:
		character.attack()

	frame_count -= 1
	if frame_count < 0:
		frame_count = randi_range(15, 45)
		walk_direction = character.direction
		if randf() < 0.333:
			walk_direction = 0 if randf() < 0.5 else -character.direction

	character.walk(walk_direction)

	if randf() < 1 / 180.0:
		character.jump()
	if rival.is_jumping() and randf() < 1 / 60.0:
		character.jump()

	if randf() < 1 / 180.0:
		character.attack()

	if randf() < 1 / 180.0:
		character.special()

	var diff_x = abs(character.position.x - rival.position.x)
	if diff_x < 200:
		character.attack()

	if rival.state == Character.State.ATTACKING or rival.state == Character.State.SPECIAL:
		if randf() < 1 / 15.0:
			walk_direction = 0 if randf() < 0.5 else -character.direction

	if rival.attack_cool_time < rival.attack_cool_time_max or rival.special_cool_time < rival.special_cool_time_max:
		walk_direction = character.direction