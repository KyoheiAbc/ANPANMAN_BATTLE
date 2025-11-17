class_name Character
extends Area2D

var id: int
var model: Model
var size: Vector2

var velocity: Vector2 = Vector2.ZERO
var direction: int = 1

var is_walking: bool = false

var jump_counter: int = 0
var attack: Attack

var stun_counter: int = 0

func _init(id: int, size: Vector2):
	self.id = id
	self.size = size
	add_child(Main.CustomCollisionShape2D.new(size))
	model = Model.new(self)
	add_child(model)
	attack = Attack.new(self)
	add_child(attack)

func attack_execute() -> void:
	if stun_counter > 0:
		return
	if not on_ground():
		return
	attack.execute()

func damage(vector: Vector2) -> void:
	velocity += vector
	stun_counter = 20
	if attack.attack_instance != null:
		attack.attack_instance.queue_free()
		attack.attack_instance = null
		attack.combo = 0

func jump() -> void:
	if stun_counter > 0:
		return
	if jump_counter < 2:
		velocity.y = -20
		jump_counter += 1

func walk(walk_direction: int) -> void:
	if stun_counter > 0:
		return
	if walk_direction == 0:
		is_walking = false
		return
	is_walking = true
	direction = 1 if walk_direction > 0 else -1

func on_ground() -> bool:
	return position.y + size.y / 2 >= 0

func process():
	velocity.x *= 0.9
	velocity.y += 1
	position += velocity

	if stun_counter > 0:
		stun_counter -= 1

	if on_ground():
		position.y = - size.y / 2
		velocity.y = 0
		jump_counter = 0

	for area in get_overlapping_areas():
		if area is Character:
			area.velocity.x += 3 if area.position.x > position.x else -3
			area.velocity.y = -3
			
	position.x = clamp(position.x, -800, 800)
	position.y = clamp(position.y, -400, size.y / 2)

	attack.process()

	if is_walking:
		model.walk()
		position.x += direction * 7.5
	elif attack.attack_instance == null:
		model.idle()
	if not on_ground():
		model.jump()

	if attack.attack_instance != null:
		model.attack()

	if direction == 1:
		model.rotation_degrees.y = 0
	else:
		model.rotation_degrees.y = -90

	if stun_counter > 0:
		model.visible = Time.get_ticks_msec() % 100 < 50
	elif not model.visible:
		model.visible = true


	model.position = Vector3(position.x / 100, -position.y / 100, 0)