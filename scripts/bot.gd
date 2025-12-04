class_name Bot
extends Node

var character: Character
var rival: Character

var walk_direction: int = 0
var frame_count: int = 0

func _init(character: Character, rival: Character) -> void:
	self.character = character
	self.rival = rival

	frame_count = randi_range(15, 45)


func process() -> void:
	if character.state == Character.State.ATTACKING:
		if randf() < 1 / 15.0:
			character.attack()

	var direction = 1 if rival.position.x > character.position.x else -1

	frame_count -= 1
	if frame_count < 0:
		frame_count = randi_range(15, 45)
		var directions = [direction, direction, direction, direction, direction, 0, 0, 0, -direction, ]
		directions.shuffle()
		walk_direction = directions[0]
	# if character.state == Character.State.ATTACKING or character.state == Character.State.SPECIAL:
		# walk_direction = - direction if randf() < 0.5 else 0
	character.walk(walk_direction)

	if randf() < 1 / 180.0:
		character.jump()
	if rival.is_jumping():
		if randf() < 1 / 15.0:
			character.jump()


	if randf() < 1 / 180.0:
		character.attack()

	if randf() < 1 / 300.0:
		character.special()

	var distance = abs(rival.position.x - character.position.x)
	if distance < 200:
		if randf() < 1 / 15.0:
			character.attack()