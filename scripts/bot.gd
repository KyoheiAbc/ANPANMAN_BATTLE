class_name Bot
extends Node

var player: Character = null
var character: Character = null

var chase: bool = true
var attack_count: int = 0

func _init(character: Character, player: Character):
	self.character = character
	self.player = player

func _process(_delta: float) -> void:
	if player.position.x >= character.position.x:
		character.direction = 1
	else:
		character.direction = -1

	if abs(player.position.x - character.position.x) < 300:
		chase = false
	elif abs(player.position.x - character.position.x) > 600:
		chase = true


	if randf() < 0.005 and attack_count == 0:
		attack_count = 120
		character.jump()

	if attack_count > 0:
		attack_count -= 1
		character.walk(character.direction)
		if abs(player.position.x - character.position.x) < 50:
			attack_count = 0
		if attack_count == 0:
			if not character.execute_attack():
				attack_count = 1


	if chase:
		character.walk(character.direction)