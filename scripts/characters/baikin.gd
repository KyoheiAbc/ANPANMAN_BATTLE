class_name Baikin
extends Character

func _init(characters: Array[Character]) -> void:
	attack_damages = [
		Damage.new(self, 10, Vector2(2, -16), 20),
		Damage.new(self, 10, Vector2(4, -32), 20),
		Damage.new(self, 20, Vector2(4, -64), 20),
		Damage.new(self, 30, Vector2(32, -128), 60),
	]
	special_duration *= 0.3
	one_attack_duration *= 1.5
	walk_step *= 1.2

	super._init(characters, Vector2(100, 150))

func special_process(progress: float) -> void:
	if progress == 0:
		model.attack(false)
		attack_areas.append(AttackArea.new(self, size / 2, attack_damages[3].duplicate()))
		add_child(attack_areas[-1])
		attack_areas[-1].position.x = size.x * 0.75 * direction
		velocity.y = - jump_power
		velocity.x = direction * walk_step * 2
	elif 0 < progress and progress < 1.0:
		model.attack(true)
		attack_areas[-1].process()
	elif progress == 1.0:
		var attack_area = attack_areas.pop_back()
		attack_area.queue_free()
	

class BaikinModel extends Model:
	func attack(finish: bool) -> void:
		kick(finish)