class_name Character
extends Area2D

var size: Vector2
var velocity: Vector2 = Vector2.ZERO
var direction: int = 1

var rival: Character

var frame_count: int = -1

var model: Model

var attacks: Array[Attack] = []

enum State {
	IDLE,
	ATTACKING,
	SPECIAL,
	FREEZE,
}
var state: State = State.IDLE

var attack_infos: Array[Attack.Info] = [
	Attack.Info.new([8, 8, 8], Vector2(96, 0), Vector2(64, 64), 10, Vector2(0, -4), 20, 10),
	Attack.Info.new([8, 8, 8], Vector2(96, 0), Vector2(64, 64), 10, Vector2(2, -8), 20, 10),
	Attack.Info.new([8, 8, 8], Vector2(96, 0), Vector2(64, 64), 20, Vector2(4, -16), 20, 10),
	Attack.Info.new([8, 60, 32], Vector2(96, 0), Vector2(64, 64), 30, Vector2(16, -32), 20, 10),
]


func _init(size: Vector2):
	self.size = size
	add_child(Game.CustomCollisionShape2D.new(size))

	position.y = - size.y / 2

	match self.get_script():
		Anpan:
			model = Anpan.AnpanModel.new(self)
		Baikin:
			model = Baikin.BaikinModel.new(self)

	add_child(model)


func walk(walk_direction: int) -> void:
	if state != State.IDLE:
		return
	velocity.x += walk_direction * 0.8

func is_jumping() -> bool:
	return position.y + size.y / 2 < 0

func jump():
	if state != State.IDLE:
		return
	if is_jumping():
		return
	velocity.y = -16

func attack():
	if state == State.ATTACKING:
		pass
	elif state != State.IDLE:
		return

	if attacks.size() == 0:
		attacks.append(Attack.new(self, attack_infos[0], 1))
		add_child(attacks[-1])
		state = State.ATTACKING
		frame_count = 1000000

	elif attacks.size() >= 3:
		return

	var last_attack = attacks[-1]
	if last_attack.frame_count < attack_infos[attacks.size()].counts[1] + attack_infos[attacks.size()].counts[2]:
		attacks.append(Attack.new(self, attack_infos[attacks.size()], attacks.size() + 1))
		add_child(attacks[-1])
		state = State.ATTACKING
		frame_count = 1000000
	
func damage(attack: Attack) -> void:
	if state == State.FREEZE:
		return
	idle()
	state = State.FREEZE
	frame_count = attack.info.freeze_count
	velocity = attack.info.knockback
	velocity.x *= attack.direction
	Game.HIT_STOP_COUNT = attack.info.hit_stop

func special():
	if state != State.IDLE:
		return
	state = State.SPECIAL
	attacks.append(Attack.new(self, attack_infos[3], 1000))
	add_child(attacks[-1])
	frame_count = 1000000

func unique_process(attack: Attack) -> void:
	pass

func process():
	if state == State.ATTACKING:
		var attack_finished = true
		for attack in attacks:
			if attack.process():
				attack_finished = false
				break
		if attack_finished:
			frame_count = 0
	elif state == State.SPECIAL:
		var attack = attacks[0]
		if not attack.process():
			frame_count = 0


	frame_count -= 1
	if frame_count < 0:
		if state != State.IDLE:
			idle()

	if state == State.IDLE:
		look_at_rival()
	
	physics_process()

	clamp_position()

	model.process()

func idle() -> void:
	state = State.IDLE

	velocity = Vector2.ZERO

	for attack in attacks:
		attack.queue_free()
	attacks.clear()

func look_at_rival() -> void:
	direction = 1 if position.x < rival.position.x else -1

func physics_process():
	position += velocity

	velocity.x *= 0.92

	if is_jumping():
		velocity.y += 0.8
	else:
		velocity.y = 0
		position.y = - size.y / 2

func clamp_position():
	position.x = clamp(position.x, -800, 800)
	position.y = clamp(position.y, -400, -size.y / 2)


class Attack extends Area2D:
	var character: Character
	var frame_count: int = 0
	var info: Info
	var direction: int = 1
	var collision_shape: Game.CustomCollisionShape2D
	var current_combo: int = 0
	class Info:
		var counts: Array[int]
		var position: Vector2
		var size: Vector2
		var damage: int
		var knockback: Vector2
		var freeze_count: int
		var hit_stop: int
		func _init(counts: Array[int], position: Vector2, size: Vector2, damage: int, knockback: Vector2, freeze_count: int, hit_stop: int) -> void:
			self.counts = counts
			self.position = position
			self.size = size
			self.damage = damage
			self.knockback = knockback
			self.freeze_count = freeze_count
			self.hit_stop = hit_stop

	func _init(character: Character, info: Info, current_combo: int) -> void:
		self.character = character
		self.info = info
		direction = character.direction
		frame_count = info.counts[0] + info.counts[1] + info.counts[2]
		position = info.position * Vector2(direction, 1)
		collision_shape = Game.CustomCollisionShape2D.new(info.size)
		self.current_combo = current_combo
		add_child(collision_shape)

	func process() -> bool:
		if frame_count < 0:
			return false
		character.unique_process(self)
		frame_count -= 1
		if info.counts[2] < frame_count and frame_count < info.counts[1] + info.counts[2]:
			if Game.DEBUG:
				collision_shape.color_rect.color.a = 0.9
			for area in get_overlapping_areas():
				if area == character.rival:
					area.damage(self)
		else:
			if Game.DEBUG:
				collision_shape.color_rect.color.a = 0.3

		return frame_count >= 0