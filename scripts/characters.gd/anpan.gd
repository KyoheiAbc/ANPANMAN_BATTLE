class_name Anpan
extends Character

var attack_area: Area2D

func _init():
	super._init(Vector2(100, 150))
	attack_area = Area2D.new()
	add_child(attack_area)
	attack_area.add_child(Main.CustomCollisionShape2D.new(Vector2(100, 100)))

func attack_process():
	super.attack_process()

	if combo_count() == 0:
		control_enabled = true
		physics_enabled = true
		return

	control_enabled = false
	physics_enabled = false

	attack_area.position.x = 50 * direction()
	if attack_counts[combo_count() - 1] == 23:
		position.x += 3 * direction()

	if attack_counts[combo_count() - 1] < 12:
		for area in attack_area.get_overlapping_areas():
			if area == rival:
				rival.damage(Vector2(1 * combo_count(), -7 * combo_count()))
	

class AnpanModel extends Model:
	func process():
		if character.combo_count() > 0:
			if character.combo_count() == 1:
				punch(true, 1.0)
			elif character.combo_count() == 2:
				punch(false, 1.5)
			elif character.combo_count() == 3:
				punch(true, 2)

		super.process()