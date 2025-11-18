class_name Character
extends Area2D

var id: int
var model: Model
var size: Vector2
var direction: int = 1

var velocity: Vector2 = Vector2.ZERO

var rival: Character

var walk_direction: int = 0
var attack: Attack
var attack_freeze: int = 0

var stun_count: int = 0

func _init(id: int, size: Vector2):
	self.id = id
	self.size = size
	add_child(Main.CustomCollisionShape2D.new(size))
	model = Model.new(self)
	add_child(model)

func attack_action() -> void:
	if attack == null:
		if walk_direction == 0 or not on_ground():
			attack = Attack.Normal.new(self)
		elif walk_direction == direction:
			attack = Attack.Stinger.new(self)
		else:
			attack = Attack.Missile.new(self)
		add_child(attack)

func damage(vector: Vector2, stun: int) -> void:
	if stun_count != 0:
		return
	if attack != null:
		attack.queue_free()
		attack = null
		attack_freeze = false
	velocity += vector
	stun_count = stun
	Main.PAUSE_COUNT = 20

func jump() -> void:
	if attack_freeze:
		return
	if on_ground():
		velocity.y = -15

func walk(_walk_direction: int) -> void:
	if attack_freeze:
		return
	walk_direction = _walk_direction
	position.x += walk_direction * 8

func on_ground() -> bool:
	return position.y + size.y / 2 >= 0

func process():
	if not attack_freeze:
		if position.x < rival.position.x:
			direction = 1
		else:
			direction = -1

		position.x += velocity.x
		velocity.x *= 0.9

		position.y += velocity.y
		velocity.y += 0.5

	if stun_count > 0:
		stun_count -= 1

	if attack != null:
		if not attack.process():
			attack.queue_free()
			attack = null

	position.x = clamp(position.x, -800, 800)
	if on_ground():
		position.y = - size.y / 2
		velocity.y = 0

	model.process()
