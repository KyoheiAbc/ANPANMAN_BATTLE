class_name Bot
extends Node


var character: Character
var rival: Character


func _init(character: Character, rival: Character) -> void:
	self.character = character
	self.rival = rival


func process() -> void:
	if character.state == Character.State.LOSE:
		return

	if character.state == Character.State.ATTACKING:
		character.attack()

	if randf() < 1 / 60.0:
		character.jump()

	if randf() < 1 / 60.0:
		character.special()

	var distance = abs(character.position.x - rival.position.x)
	if distance > 250:
		character.walk(character.direction)
	else:
		if randf() < 1 / 15.0:
			character.attack()