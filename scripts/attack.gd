class_name Attack
extends Area2D

var character: Character
var frame_count: int = 0

func _init(character: Character):
	self.character = character

class Normal extends Attack:
	var enabled: bool = true
	func process() -> bool:
		frame_count += 1

		var model = character.model

		if frame_count < 10:
			model.set_attack_pose(false)

		elif frame_count == 10:
			add_child(Main.CustomCollisionShape2D.new(Vector2(100, 150)))
			position.x = character.size.x * 0.5 * character.direction
			model.set_attack_pose(true)

		elif frame_count < 20:
			position.x = character.size.x * 0.5 * character.direction
			if enabled:
				for area in get_overlapping_areas():
					if area is Character and area != character:
						area.velocity.x += 10 * character.direction
						area.velocity.y = -5
						enabled = false
						Main.FREEZE_COUNT = 20
						
		return frame_count < 30
