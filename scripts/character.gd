class_name Character
extends Area2D

class Attack extends Node2D:
	var parent: Character
	var prepare_count: int = 0
	var active_count: int = 0
	var recover_count: int = 0
	var vector: Vector2 = Vector2.ZERO
	var area: Area2D = Area2D.new()

	var frame_count: int = 0
	func _init(parent: Character, size: Vector2, prepare_count: int, active_count: int, recover_count: int, vector: Vector2):
		self.parent = parent
		area.add_child(CustomCollisionShape2D.new(size))
		add_child(area)
		self.prepare_count = prepare_count
		self.active_count = active_count
		self.recover_count = recover_count
		self.vector = vector

		self.area.monitoring = false
		self.area.monitorable = false

	func _process(delta: float) -> void:
		frame_count += 1

		if frame_count > prepare_count + active_count + recover_count:
			parent.attack = null
			queue_free()
			parent.model.right_arm.scale = Vector3(1, 1, 1)
		elif frame_count > prepare_count + active_count:
			if self.area:
				self.area.queue_free()
		elif frame_count > prepare_count:
			self.area.monitoring = true
			self.area.visible = true
			parent.model.right_arm.rotation_degrees.x = 90
			parent.model.right_arm.scale = Vector3(2, 2, 2)
			parent.model.left_arm.rotation_degrees.x = -90
			parent.model.right_leg.rotation_degrees.x = -90
			parent.model.left_leg.rotation_degrees.x = 90
			for area in area.get_overlapping_areas():
				if area is Character and area != parent:
					area.damage(vector)
		else:
			area.visible = false
			parent.model.right_arm.rotation_degrees.x = -90

			
class CustomCollisionShape2D extends CollisionShape2D:
	func _init(size: Vector2):
		self.shape = RectangleShape2D.new()
		self.shape.size = size

		var color_rect = ColorRect.new()
		add_child(color_rect)
		color_rect.color = Color.from_hsv(randf(), 1, 1, 0)
		color_rect.size = size
		color_rect.position = - size / 2

var velocity: Vector2 = Vector2.ZERO
var size: Vector2 = Vector2.ZERO
var model: Model
var id: int = 0
var attack: Attack = null
var stun_count: int = 0
var direction: int = 1

func _init(id: int, size: Vector2):
	self.id = id
	self.size = size
	add_child(CustomCollisionShape2D.new(size))
	model = Model.new(self)
	add_child(model)

func _process(delta: float) -> void:
	position += velocity

	if stun_count > 0:
		stun_count -= 1


	for area in get_overlapping_areas():
		if area is Character:
			area.velocity.x += 1 if area.position.x > position.x else -1
			# area.velocity.y = -1
			

	velocity.y += 5
	velocity.x = clamp(velocity.x * 0.7, -10, 10)

	if not is_jumping():
		position.y = - size.y / 2
		velocity.y = 0
	position.x = clamp(position.x, -800 + size.x / 2, 800 - size.x / 2)


func walk(x: int) -> void:
	if attack != null:
		return
	if stun_count > 0:
		return
	direction = x
	velocity.x += x * 3


func jump() -> void:
	if attack != null:
		return
	if stun_count > 0:
		return
	if is_jumping():
		return
	velocity.y = -50

func damage(vector: Vector2) -> void:
	if stun_count > 0:
		return
	velocity += vector
	stun_count = 30

func is_jumping() -> bool:
	return position.y + size.y / 2 < 0

func execute_attack() -> bool:
	if attack != null:
		return false
	if stun_count > 0:
		return false
	if is_jumping():
		return false
	attack = Attack.new(self, Vector2(100, 100), 5, 10, 5, Vector2(30 * direction, -50))
	attack.position.x = 50 * direction
	add_child(attack)
	return true