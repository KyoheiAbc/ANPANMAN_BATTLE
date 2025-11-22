class_name Character
extends Area2D

var size: Vector2
var velocity: Vector2

var attack_counts: Array[int]

var rival: Character

var control_enabled: bool = true
var physics_enabled: bool = true

var model: Model

func _init(size: Vector2):
	self.size = size
	add_child(Main.CustomCollisionShape2D.new(size))

	position.y = - size.y / 2

	match self.get_script():
		Anpan:
			model = Anpan.AnpanModel.new(self)
		Baikin:
			model = Baikin.BaikinModel.new(self)

	add_child(model)

func attack():
	if attack_counts.size() >= 3:
		return
	attack_counts.append(24)

func combo_count() -> int:
	for i in range(attack_counts.size()):
		if attack_counts[i] >= 0:
			return i + 1
	return 0

func is_on_floor() -> bool:
	return position.y + size.y / 2 >= 0

func direction() -> int:
	return 1 if rival.position.x > position.x else -1

func physics_process():
	if not physics_enabled:
		return
	position += velocity

	velocity.x *= 0.8
	if is_on_floor():
		velocity.y = 0
		position.y = - size.y / 2
	else:
		velocity.y += 2

func clamp_position():
	position.x = clamp(position.x, -800, 800)
	position.y = clamp(position.y, -400, -size.y / 2)

func process():
	physics_process()

	attack_process()

	clamp_position()

	model.process()

func walk(walk_direction: int):
	if control_enabled == false:
		return
	position.x += walk_direction * 8

func jump():
	if control_enabled == false:
		return
	if not is_on_floor():
		return
	velocity.y = -32

func attack_process():
	for i in range(attack_counts.size()):
		attack_counts[i] -= 1
		if attack_counts[i] >= 0:
			return
	attack_counts.clear()
