class_name Bot
extends Node


var character: Character
var rival: Character

var frame_count: int = 0
var walk_direction: int = 0

var attack_probability_close = 1 / 16.0


func _init(character: Character, rival: Character) -> void:
	self.character = character
	self.rival = rival

	frame_count = randi_range(16, 32)
	walk_direction = character.direction

	# character.attack_cool_time_max /= 2.0
	# character.special_cool_time_max /= 2.0


func process() -> void:
	if character.state == Character.State.LOSE:
		return

	if character.state == Character.State.ATTACKING:
		if randf() < 1 / 16.0:
			character.attack()

	frame_count -= 1
	if frame_count < 0:
		frame_count = randi_range(16, 32)
		walk_direction = character.direction
		if randf() > 0.5:
			walk_direction = 0 if randf() < 0.5 else character.direction * -1


	if randf() < 1 / 160.0:
		character.jump()
	if rival.is_jumping():
		if randf() < 1 / 16.0:
			character.jump()

	if randf() < 1 / 32.0:
		character.special()


	var distance = abs(character.position.x - rival.position.x)
	if distance < 200:
		if randf() < attack_probability_close:
			character.attack()

	if randf() < 1 / 128.0:
		character.dash()


	character.walk(walk_direction)