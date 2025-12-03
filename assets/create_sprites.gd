extends SceneTree

const SIZE = 128

func _init():
	var square = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	square.fill(Color(1, 1, 1, 1))
	square.save_png(get_script().resource_path.get_base_dir() + "/square.png")

	var circle = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	circle.fill(Color(0, 0, 0, 0))
	var center = Vector2((SIZE - 1) / 2.0, (SIZE - 1) / 2.0)
	var radius = SIZE / 2.0
	for x in range(SIZE):
		for y in range(SIZE):
			if (Vector2(x, y) - center).length() < radius:
				circle.set_pixel(x, y, Color(1, 1, 1, 1))
	circle.save_png(get_script().resource_path.get_base_dir() + "/circle.png")
	
	quit()
