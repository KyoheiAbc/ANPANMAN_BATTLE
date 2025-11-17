class_name Bot
extends Node

var player: Character
var rival: Character

var is_chasing: bool = false
var attack_counter: int = 0
var cool_counter: int = 0

func _init(player: Character, rival: Character) -> void:
	self.player = player
	self.rival = rival

func process() -> void:
	if randf() < 0.007:
		rival.jump()
	if cool_counter > 0:
		cool_counter -= 1

	if randf() < 0.05 and cool_counter == 0 and attack_counter == 0:
		attack_counter = 180

	if abs(rival.position.x - player.position.x) > 600:
		is_chasing = true
	if abs(rival.position.x - player.position.x) < 250:
		is_chasing = false

	if is_chasing:
		rival.is_walking = true
		rival.direction = 1 if player.position.x > rival.position.x else -1
	else:
		rival.is_walking = false

	if attack_counter > 0:
		attack_counter -= 1
		rival.is_walking = true
		rival.direction = 1 if player.position.x > rival.position.x else -1
		if abs(rival.position.x - player.position.x) < 150:
			rival.attack_execute()
		if attack_counter == 0:
			cool_counter = 180