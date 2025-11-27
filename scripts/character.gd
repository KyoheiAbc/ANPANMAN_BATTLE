class_name Character
extends Area2D

var size: Vector2
var velocity: Vector2
var direction: int = 1

var attack_counts: Array[int] = []
var one_attack_duration: int = 24
var max_combos: int = 3

var special_count: int = -1
var special_duration: int = 60

var attack_areas: Array[AttackArea]

var rival: Character

var control_enabled: bool = true

var model: Model

var walk_step: float = 8.0
var jump_power: float = 24.0
var velocity_x_decay: float = 0.8
var custom_gravity: float = 2.0


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

func walk(walk_direction: int):
	if control_enabled == false:
		return
	position.x += walk_direction * walk_step

func is_on_floor() -> bool:
	return position.y + size.y / 2 >= 0
	
func jump():
	if control_enabled == false:
		return
	if not is_on_floor():
		return
	velocity.y = - jump_power

func attack():
	if special_count >= 0:
		return
	if attack_counts.size() >= max_combos:
		return
	if attack_counts.size() == 0:
		attack_counts.append(one_attack_duration)
		return
	if attack_counts[attack_counts.size() - 1] < one_attack_duration / 2:
		attack_counts.append(one_attack_duration)


func attack_process():
	for i in range(attack_counts.size()):
		if attack_counts[i] >= 0:
			unique_process()
			attack_counts[i] -= 1
			return

	attack_counts.clear()

func combo_count() -> int:
	for i in range(attack_counts.size()):
		if attack_counts[i] >= 0:
			return i + 1
	return 0

func current_attack_progress() -> float:
	for i in range(attack_counts.size()):
		if attack_counts[i] >= 0:
			return float(one_attack_duration - attack_counts[i]) / one_attack_duration
	return 0.0

func special():
	if attack_counts.size() > 0:
		return
	if special_count >= 0:
		return
	special_count = special_duration

func is_special_active() -> bool:
	return special_count >= 0

func special_process():
	unique_process()
	special_count -= 1

func unique_process():
	pass

func physics_process():
	position += velocity

	velocity.x *= velocity_x_decay
	if is_on_floor():
		velocity.y = 0
		position.y = - size.y / 2
	else:
		velocity.y += custom_gravity

func clamp_position():
	position.x = clamp(position.x, -800, 800)
	position.y = clamp(position.y, -400, -size.y / 2)

func process():
	if special_count >= 0:
		special_process()

	elif attack_counts.size() > 0:
		attack_process()

	else:
		direction = 1 if rival.position.x > position.x else -1

		physics_process()

	clamp_position()

	model.process()

class Damage:
	var amount: int
	var vector: Vector2
	var duration: int
	func _init(amount: int, vector: Vector2, duration: int):
		self.amount = amount
		self.vector = vector
		self.duration = duration

class AttackArea extends Area2D:
	var damage: Damage
	func _init(size: Vector2, damage: Damage):
		self.damage = damage
		add_child(Main.CustomCollisionShape2D.new(size))

	func process(character: Character) -> void:
		for area in get_overlapping_areas():
			if area == character.rival:
				print(area)