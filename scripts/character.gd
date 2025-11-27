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

var stunned_count: int = -1

var invincible_count: int = -1

var is_guarding: bool = false

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
	if is_guarding:
		return
	if stunned_count >= 0:
		return
	if control_enabled == false:
		return
	position.x += walk_direction * walk_step

func is_on_floor() -> bool:
	return position.y + size.y / 2 >= 0
	
func jump():
	if is_guarding:
		return
	if stunned_count >= 0:
		return
	if control_enabled == false:
		return
	if not is_on_floor():
		return
	velocity.y = - jump_power

func attack():
	if is_guarding:
		return
	if stunned_count >= 0:
		return
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
	if is_guarding:
		return
	if stunned_count >= 0:
		return
	if attack_counts.size() > 0:
		return
	if special_count >= 0:
		return
	special_count = special_duration

func special_process():
	unique_process()
	special_count -= 1

func unique_process():
	if special_count >= 0:
		if special_count == special_duration:
			model.finish()
			attack_areas.append(AttackArea.new(Vector2(100, 100), Damage.new(20, Vector2(0, -64), 30)))
			add_child(attack_areas[-1])
			attack_areas[-1].position.x = 100 * direction
		elif special_count == 1.0:
			for i in range(attack_areas.size() - 1, -1, -1):
				attack_areas[i].queue_free()
			attack_areas.clear()

		position.x += 8 * direction

		invincible_count = 30

		for area in attack_areas:
			area.process(self)

		return

	if current_attack_progress() == 0.0:
		model.finish()
	elif current_attack_progress() > 0.5 and attack_areas.size() == 0:
		attack_areas.append(AttackArea.new(Vector2(100, 100), Damage.new(10, Vector2(2 * direction, -16), 20)))
		attack_areas[-1].position.x = 100 * direction
		add_child(attack_areas[-1])
	elif current_attack_progress() == 1.0:
		for i in range(attack_areas.size() - 1, -1, -1):
			attack_areas[i].queue_free()
		attack_areas.clear()

	for area in attack_areas:
		area.process(self)

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

func guard(enable: bool) -> void:
	if stunned_count >= 0:
		return
	if control_enabled == false:
		return
	if attack_counts.size() > 0:
		return
	if special_count >= 0:
		return
	is_guarding = enable
	model.guard()

func process():
	if special_count >= 0:
		special_process()

	elif attack_counts.size() > 0:
		attack_process()

	else:
		direction = 1 if rival.position.x > position.x else -1

		invincible_count -= 1
		
		stunned_count -= 1

		physics_process()

	for area in get_overlapping_areas():
		if area == rival:
			model.finish()
			rival.take_damage(Damage.new(0, Vector2(8 * direction, -8), 20))

	clamp_position()

	model.process()

func take_damage(damage: Damage) -> void:
	if invincible_count >= 0:
		return
	if stunned_count >= 0:
		return

	# If guarding, reduce damage and knockback
	if is_guarding:
		print("Guarded the attack!")
	
	stunned_count = damage.duration
	velocity += damage.vector
	attack_counts.clear()
	for i in range(attack_areas.size() - 1, -1, -1):
		attack_areas[i].queue_free()
	attack_areas.clear()

	special_count = -1

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
				character.rival.take_damage(damage)
