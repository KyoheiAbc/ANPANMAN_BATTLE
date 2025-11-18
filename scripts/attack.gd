class_name Attack
extends Node2D

var character: Character
var frame_count: int = 0

var attack_instance: AttackInstance

func _init(character: Character):
	self.character = character

	attack_instance = Normal.new(self)
	add_child(attack_instance)
	
func process() -> bool:
	frame_count += 1
	return attack_instance.process()

class AttackInstance extends Area2D:
	var attack: Attack

	func _init(attack: Attack):
		self.attack = attack

class Normal extends AttackInstance:
	func process() -> bool:
		var model = attack.character.model

		if attack.frame_count < 20:
			model.right_arm.rotation_degrees.x = -90
			model.left_arm.rotation_degrees.x = 45
			model.right_leg.rotation_degrees.x = 90
			model.left_leg.rotation_degrees.x = -90

		if attack.frame_count == 20:
			add_child(Main.CustomCollisionShape2D.new(Vector2(100, 150)))
			position.x = attack.character.size.x * 0.5 * attack.character.direction
			model.right_arm.rotation_degrees.x = 90
			model.right_arm.scale = Vector3(2, 2, 2)
			model.left_arm.rotation_degrees.x = -45
			model.right_leg.rotation_degrees.x = -90
			model.left_leg.rotation_degrees.x = 90

		if attack.frame_count > 20:
			for area in get_overlapping_areas():
				if area is Character and area != attack.character:
					area.velocity.x = 15 * attack.character.direction
					area.velocity.y = -10

		return attack.frame_count < 60
