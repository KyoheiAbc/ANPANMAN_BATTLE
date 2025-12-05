class_name Character
extends Area2D

var size: Vector2
var velocity: Vector2 = Vector2.ZERO
var direction: int = 1

var hp: int

var rival: Character

var frame_count: int = -1

var model: Model

var attacks: Array[Attack] = []
var special_cool_time: int = 0
var special_cool_time_max: int = 90
var hp_max: int = 10
var walk_acceleration: float = 0.8
var jump_velocity: float = -16
var friction: float = 0.92
var character_gravity: float = 0.8

enum State {
	IDLE,
	ATTACKING,
	SPECIAL,
	FREEZE,
}
var state: State = State.IDLE

var attack_infos: Array[Attack.Info] = [
	Attack.Info.new([16, 2, 8], Vector2(50, 0), Vector2(100, 100), 10, Vector2(0, -4), 16, 16),
	Attack.Info.new([16, 2, 8], Vector2(50, 0), Vector2(100, 100), 10, Vector2(0, -8), 16, 16),
	Attack.Info.new([16, 2, 16], Vector2(50, 0), Vector2(100, 100), 20, Vector2(16, -16), 16, 16),
	Attack.Info.new([32, 60, 32], Vector2(50, 0), Vector2(100, 100), 30, Vector2(16, -32), 20, 32),
]

static func character_new(index: int) -> Character:
	var character: Character
	var model_scene: PackedScene = Main.MODELS[index]
	match index:
		0:
			character = Anpan.new()
			character.model = Anpan.AnpanModel.new(character, model_scene)
		1:
			character = Baikin.new()
			character.model = Baikin.BaikinModel.new(character, model_scene)
	character.add_child(character.model)
	return character

func _init(size: Vector2):
	self.size = size
	add_child(Game.CustomCollisionShape2D.new(size))

	position.y = - size.y / 2

	hp = hp_max


func walk(walk_direction: int) -> void:
	if state != State.IDLE:
		return
	velocity.x += walk_direction * walk_acceleration

func is_jumping() -> bool:
	return position.y + size.y / 2 < 0

func jump():
	if state != State.IDLE:
		return
	if is_jumping():
		return
	velocity.y = jump_velocity

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
	hp -= attack.info.damage
	frame_count = attack.info.freeze_count
	velocity = attack.info.knockback
	velocity.x *= attack.direction
	Main.HIT_STOP_COUNT = attack.info.hit_stop

func collision() -> void:
	if state != State.IDLE:
		return
	idle()
	state = State.FREEZE
	frame_count = 15
	velocity.x = - direction * 8
	velocity.y = -8

func special():
	if state != State.IDLE:
		return
	if special_cool_time >= 0:
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
			special_cool_time = special_cool_time_max

	special_cool_time -= 1

	frame_count -= 1
	if frame_count < 0:
		if state != State.IDLE:
			idle()

	if state == State.IDLE:
		look_at_rival()

	for area in get_overlapping_areas():
		if area == rival:
			collision()
			rival.collision()
	
	physics_process()

	clamp_position()

	model.process()

func idle() -> void:
	state = State.IDLE

	velocity = Vector2.ZERO

	for attack in attacks:
		attack.queue_free()
	attacks.clear()

	model.idle()

func look_at_rival() -> void:
	direction = 1 if position.x < rival.position.x else -1

func physics_process():
	position += velocity

	velocity.x *= friction

	if is_jumping():
		velocity.y += character_gravity
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

	func is_preparing() -> bool:
		return frame_count >= info.counts[1] + info.counts[2]
	func is_active() -> bool:
		return info.counts[2] < frame_count and frame_count < info.counts[1] + info.counts[2]
	func is_recovering() -> bool:
		return frame_count <= info.counts[2]

	func process() -> bool:
		if frame_count < 0:
			return false
		if frame_count == info.counts[0] + info.counts[1] + info.counts[2]:
			character.model.prepare_attack()
		elif frame_count == info.counts[1] + info.counts[2]:
			character.model.finish_attack()
		elif frame_count == 0:
			character.model.idle()
		character.unique_process(self)
		frame_count -= 1
		if info.counts[2] < frame_count and frame_count < info.counts[1] + info.counts[2]:
			for area in get_overlapping_areas():
				if area == character.rival:
					area.damage(self)

		return frame_count >= 0