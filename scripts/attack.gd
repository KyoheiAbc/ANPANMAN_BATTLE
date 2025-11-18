class_name Attack
extends Area2D

var character: Character
var frame_count: int = 0

func _init(character: Character):
	self.character = character

class Normal extends Attack:
	func process() -> bool:
		frame_count += 1

		var model = character.model

		if frame_count < 20:
			model.set_attack_pose(false)

		if frame_count == 20:
			add_child(Main.CustomCollisionShape2D.new(Vector2(100, 150)))
			position.x = character.size.x * 0.5 * character.direction
			model.set_attack_pose(true)

		if frame_count > 20:
			for area in get_overlapping_areas():
				if area is Character and area != character:
					area.damage(Vector2(10 * character.direction, -10), 20)

		return frame_count < 60


class Stinger extends Attack:
	var velocity: Vector2 = Vector2.ZERO
	func _init(character: Character):
		self.character = character
		self.velocity.x = character.direction * 15
	func process() -> bool:
		frame_count += 1

		character.position += velocity
		character.attack_freeze = true

		var model = character.model

		if frame_count < 20:
			model.set_attack_pose(false)

		if frame_count == 20:
			add_child(Main.CustomCollisionShape2D.new(Vector2(100, 150)))
			position.x = character.size.x * 0.5 * character.direction
			model.set_attack_pose(true)

		if frame_count > 20:
			for area in get_overlapping_areas():
				if area is Character and area != character:
					area.damage(Vector2(10 * character.direction, -10), 20)

		if frame_count == 60:
			character.attack_freeze = false
		return frame_count < 60

class Missile extends Attack:
	var velocity: Vector2 = Vector2.ZERO
	func _init(character: Character):
		self.character = character
		self.velocity.x = character.direction * 20
		var color_rect = ColorRect.new()
		add_child(color_rect)
		color_rect.color = Color.from_hsv(randf(), 1, 1, 0.5)
		color_rect.size = Vector2(100, 100)
		color_rect.position = - color_rect.size / 2
	func process() -> bool:
		frame_count += 1
		character.attack_freeze = true

		var model = character.model

		if frame_count < 20:
			model.set_attack_pose(false)

		if frame_count == 20:
			add_child(Main.CustomCollisionShape2D.new(Vector2(100, 100)))
			model.set_attack_pose(true)

		if frame_count > 20:
			position += velocity
			for area in get_overlapping_areas():
				if area is Character and area != character:
					area.damage(Vector2(15 * character.direction, -5), 30)

		if frame_count == 60:
			character.attack_freeze = false
		return frame_count < 60