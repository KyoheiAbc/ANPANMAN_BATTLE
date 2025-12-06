class_name Bot
extends Node

const FRAME_COUNT_MIN := 15
const FRAME_COUNT_MAX := 45
const WALK_DIRECTION_PROB := 0.333
const WALK_DIRECTION_CHOICE_PROB := 0.5
const JUMP_PROB := 1 / 180.0
const JUMP_WHEN_RIVAL_JUMP_PROB := 1 / 60.0
const ATTACK_PROB := 1 / 180.0
const SPECIAL_PROB := 1 / 180.0
const ATTACK_IF_CLOSE_DIST := 200
const RIVAL_ATTACK_SPECIAL_PROB := 1 / 15.0

var character: Character
var rival: Character

var frame_count: int = 0
var walk_direction: int = 0

func _init(character: Character, rival: Character) -> void:
	self.character = character
	self.rival = rival

	frame_count = randi_range(FRAME_COUNT_MIN, FRAME_COUNT_MAX)

func process() -> void:
	if character.state == Character.State.ATTACKING:
		character.attack()

	frame_count -= 1
	if frame_count < 0:
		frame_count = randi_range(FRAME_COUNT_MIN, FRAME_COUNT_MAX)
		walk_direction = character.direction
		if randf() < WALK_DIRECTION_PROB:
			walk_direction = 0 if randf() < WALK_DIRECTION_CHOICE_PROB else -character.direction

	character.walk(walk_direction)

	if randf() < JUMP_PROB:
		character.jump()
	if rival.is_jumping() and randf() < JUMP_WHEN_RIVAL_JUMP_PROB:
		character.jump()

	if randf() < ATTACK_PROB:
		character.attack()

	if randf() < SPECIAL_PROB:
		character.special()

	var diff_x = abs(character.position.x - rival.position.x)
	if diff_x < ATTACK_IF_CLOSE_DIST:
		character.attack()

	if rival.state == Character.State.ATTACKING or rival.state == Character.State.SPECIAL:
		if randf() < RIVAL_ATTACK_SPECIAL_PROB:
			walk_direction = 0 if randf() < WALK_DIRECTION_CHOICE_PROB else -character.direction

	if rival.attack_cool_time < rival.attack_cool_time_max or rival.special_cool_time < rival.special_cool_time_max:
		walk_direction = character.direction