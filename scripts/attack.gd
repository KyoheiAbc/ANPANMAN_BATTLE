class_name Attack
extends Node2D
var character: Character
var attack_instance: AttackInstance
var combo: int = 0

class AttackInstance extends Area2D:
	var character: Character
	var frame_counter: int = 0
	func _init(character: Character):
		self.character = character
		add_child(Main.CustomCollisionShape2D.new(Vector2(100, 150)))

	func process() -> bool:
		frame_counter += 1
		if frame_counter < 10:
			pass
		elif frame_counter < 20:
			if self.monitoring:
				for area in get_overlapping_areas():
					if area is Character and area != character:
						if area.stun_counter == 0:
							var combo = character.attack.combo
							area.damage(Vector2(2.5 * character.direction, -10 * combo))
							self.monitoring = false
							Main.PAUSE_COUNTER = 20
							

		elif frame_counter < 30:
			pass
		else:
			return false
		return true
	
func _init(character: Character):
	self.character = character

func execute() -> void:
	if combo >= 3:
		return

	if attack_instance == null:
		attack_instance = AttackInstance.new(character)
		character.add_child(attack_instance)
		attack_instance.position.x = 100 * character.direction
		combo += 1
	elif attack_instance.frame_counter > 15:
		attack_instance.queue_free()
		attack_instance = null
		execute()

func process():
	if attack_instance != null:
		if not attack_instance.process():
			attack_instance.queue_free()
			attack_instance = null
			combo = 0
