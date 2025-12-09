extends SceneTree

const SIZE = 128

const ASSETS = [
	"anpanman.gltf",
	"baikinman.gltf",
	"dokin.gltf",
	"syokupanman.gltf",
	"kare.gltf",
	"meron.gltf",
	"kokin.gltf",
	"roll.gltf",
]

func _init():
	RenderingServer.set_default_clear_color(Color.from_hsv(0, 0, 0, 0))

	ProjectSettings.set_setting("display/window/size/viewport_width", SIZE)
	ProjectSettings.set_setting("display/window/size/viewport_height", SIZE)

	var root = get_root()
	root.transparent_bg = true

	var camera = Camera3D.new()
	root.add_child(camera)
	camera.position = Vector3(0, 0, 8)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 0.8
	var light = DirectionalLight3D.new()
	camera.add_child(light)
	light.shadow_enabled = false

	for asset in ASSETS:
		var gltf = load("res://assets/" + asset).instantiate()
		root.add_child(gltf)
		gltf.position.y = -1.2
		gltf.rotation_degrees.y = -150
	
		await create_timer(1).timeout

		root.get_viewport().get_texture().get_image().save_png(get_script().resource_path.get_base_dir() + "/" + asset.get_basename() + ".png")

		gltf.queue_free()

	quit()
