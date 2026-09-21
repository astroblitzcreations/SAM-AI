class_name SamBuilderCat
extends Control

var _progress := 0.0
var stalled_timer := 0.0
var state_timer := 0.0
var cat_state := "building"
var cat_dir := 1.0
var cat_target_x := 0.42
var cat_is_moving := true
var built_stage := 0
var storm_active := false
var lightning_timer := 0.0
var cat_root: Node3D
var animation_player: AnimationPlayer
var house_stages: Array[Node3D] = []
var smoke: GPUParticles3D
var rain: GPUParticles3D
var steam: GPUParticles3D
var lightning: OmniLight3D
var progress_label: Label
var state_label: Label
var text_column: VBoxContainer

func _ready() -> void:
	custom_minimum_size = Vector2(360, 68)
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	build_scene()

func build_scene() -> void:
	var layout := HBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(layout)
	text_column = VBoxContainer.new()
	text_column.custom_minimum_size = Vector2(132, 0)
	text_column.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	layout.add_child(text_column)
	build_labels()
	var container := SubViewportContainer.new()
	container.stretch = true
	container.custom_minimum_size = Vector2(220, 68)
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_child(container)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(720, 136)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(viewport)
	var world := Node3D.new()
	viewport.add_child(world)
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#07131f")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#8ac6d1")
	env.ambient_light_energy = 0.72
	environment.environment = env
	world.add_child(environment)
	var camera := Camera3D.new()
	camera.position = Vector3(0.30, 0.92, 3.15)
	camera.look_at_from_position(camera.position, Vector3(0.30, 0.35, 0.0))
	camera.fov = 31.0
	world.add_child(camera)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-35, -25, 0)
	key.light_color = Color("#bdefff")
	key.light_energy = 1.15
	world.add_child(key)
	lightning = OmniLight3D.new()
	lightning.position = Vector3(0, 2.2, 1.4)
	lightning.light_color = Color("#d9eeff")
	lightning.omni_range = 8.0
	world.add_child(lightning)
	build_ground_and_house(world)
	build_particles(world)
	var cat_scene := load("res://assets/models/builder_cat/builder_cat_run.glb") as PackedScene
	if cat_scene == null:
		push_warning("Builder cat model could not be loaded; compact monitor will continue without the 3D cat.")
		return
	cat_root = cat_scene.instantiate() as Node3D
	cat_root.position = Vector3(-0.85, 0.08, 0.15)
	cat_root.scale = Vector3.ONE * 2.15
	cat_root.rotation_degrees = Vector3(0, 90, 0)
	world.add_child(cat_root)
	animation_player = find_animation_player(cat_root)
	play_run(0.65)

func build_ground_and_house(world: Node3D) -> void:
	add_box(world, Vector3(0, -0.02, 0), Vector3(4.8, 0.07, 1.15), Color("#18323b"))
	var stages := [
		[Vector3(1.22, 0.20, 0), Vector3(0.65, 0.40, 0.62), Color("#895a39"), 0.0],
		[Vector3(1.22, 0.58, 0), Vector3(0.65, 0.35, 0.62), Color("#a66f45"), 0.0],
		[Vector3(1.04, 0.88, 0), Vector3(0.48, 0.10, 0.72), Color("#c84d55"), 24.0],
		[Vector3(1.40, 0.88, 0), Vector3(0.48, 0.10, 0.72), Color("#c84d55"), -24.0]
	]
	for data in stages:
		var part := add_box(world, data[0], data[1], data[2])
		part.rotation_degrees.z = data[3]
		part.visible = false
		house_stages.append(part)
	var door := add_box(world, Vector3(1.22, 0.17, 0.325), Vector3(0.20, 0.31, 0.04), Color("#1b1114"))
	var door_mat := door.material_override as StandardMaterial3D
	door_mat.emission_enabled = true
	door_mat.emission = Color("#ffb84d")
	door_mat.emission_energy_multiplier = 1.6

func add_box(parent: Node3D, position: Vector3, box_size: Vector3, color: Color) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = box_size
	part.mesh = mesh
	part.position = position
	part.material_override = material(color)
	parent.add_child(part)
	return part

func build_particles(world: Node3D) -> void:
	smoke = make_particles(Color(0.72, 0.78, 0.82, 0.60), 22, 0.85, 0.055)
	smoke.position = Vector3(0.65, 0.30, 0.2)
	smoke.one_shot = true
	world.add_child(smoke)
	rain = make_particles(Color(0.35, 0.68, 1.0, 0.70), 80, 1.1, 0.018)
	var rain_process := rain.process_material as ParticleProcessMaterial
	rain_process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	rain_process.emission_box_extents = Vector3(2.2, 0.1, 0.5)
	rain_process.direction = Vector3(-0.15, -1.0, 0)
	rain_process.initial_velocity_min = 2.2
	rain_process.initial_velocity_max = 3.0
	rain.position = Vector3(0, 1.55, 0.25)
	world.add_child(rain)
	steam = make_particles(Color(0.82, 0.88, 0.90, 0.38), 10, 1.2, 0.025)
	steam.position = Vector3(-0.15, 0.48, 0.20)
	world.add_child(steam)
	smoke.emitting = false
	rain.emitting = false
	steam.emitting = false

func make_particles(color: Color, amount: int, lifetime: float, particle_size: float) -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.amount = amount
	particles.lifetime = lifetime
	var process := ParticleProcessMaterial.new()
	process.direction = Vector3(0, 1, 0)
	process.spread = 28.0
	process.initial_velocity_min = 0.35
	process.initial_velocity_max = 0.75
	particles.process_material = process
	var quad := QuadMesh.new()
	quad.size = Vector2(particle_size, particle_size)
	quad.material = material(color)
	particles.draw_pass_1 = quad
	return particles

func material(color: Color) -> StandardMaterial3D:
	var value := StandardMaterial3D.new()
	value.albedo_color = color
	value.roughness = 0.8
	value.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if color.a < 0.99 else BaseMaterial3D.TRANSPARENCY_DISABLED
	return value

func build_labels() -> void:
	progress_label = Label.new()
	progress_label.add_theme_color_override("font_color", Color.WHITE)
	progress_label.add_theme_font_size_override("font_size", 12)
	text_column.add_child(progress_label)
	state_label = Label.new()
	state_label.add_theme_color_override("font_color", Color("#7feaf2"))
	state_label.add_theme_font_size_override("font_size", 10)
	state_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_column.add_child(state_label)
	update_text()

func set_progress(value: float) -> void:
	var next := clampf(value, 0.0, 100.0)
	if not is_equal_approx(next, _progress): stalled_timer = 0.0
	_progress = next
	var new_stage := mini(4, int(ceil(_progress / 25.0)))
	if new_stage > built_stage:
		built_stage = new_stage
		if is_instance_valid(smoke): smoke.restart()
	for index in range(house_stages.size()): house_stages[index].visible = index < new_stage
	if not is_instance_valid(rain) or not is_instance_valid(cat_root):
		update_text()
		return
	set_storm(_progress >= 52.0 and _progress < 82.0)
	if _progress >= 100.0: set_state("celebrate")
	update_text()

func _process(delta: float) -> void:
	if not is_instance_valid(cat_root): return
	state_timer += delta
	stalled_timer += delta
	if lightning.light_energy > 0.0: lightning.light_energy = move_toward(lightning.light_energy, 0.0, delta * 14.0)
	if storm_active:
		lightning_timer -= delta
		if lightning_timer <= 0.0:
			lightning.light_energy = 7.5
			lightning_timer = 3.2
			set_state("scared")
	elif state_timer > 4.2 and _progress < 100.0:
		set_state("coffee" if stalled_timer > 7.0 else ("walking" if cat_state == "building" else "building"))
	match cat_state:
		"building":
			cat_is_moving = false
		"walking":
			cat_is_moving = true
			cat_root.position.x = move_toward(cat_root.position.x, cat_target_x, delta * 0.72)
			if absf(cat_root.position.x - cat_target_x) < 0.025:
				cat_target_x = -0.78 if cat_target_x > 0.0 else 0.42
				cat_dir = -1.0 if cat_target_x < cat_root.position.x else 1.0
		"running", "scared":
			cat_root.position.x = move_toward(cat_root.position.x, 1.18, delta * 1.8)
			if cat_root.position.x >= 1.12: set_state("shelter")
		"coffee": cat_root.position.x = move_toward(cat_root.position.x, -0.12, delta * 0.45)
		"celebrate": cat_root.position.y = 0.08 + abs(sin(Time.get_ticks_msec() / 130.0)) * 0.08
	cat_root.rotation_degrees = Vector3(0, -90 if cat_dir < 0 else 90, 0)
	update_text()

func set_storm(enabled: bool) -> void:
	if enabled == storm_active: return
	storm_active = enabled
	rain.emitting = enabled
	lightning_timer = 0.45
	if enabled: set_state("running")
	else:
		lightning.light_energy = 0.0
		set_state("building")

func set_state(next: String) -> void:
	cat_state = next
	state_timer = 0.0
	steam.emitting = next == "coffee"
	cat_root.visible = next != "shelter"
	if next in ["running", "scared", "building", "walking", "celebrate"]: play_run(2.0 if next in ["running", "scared"] else 0.7)
	elif is_instance_valid(animation_player): animation_player.pause()

func find_animation_player(root: Node) -> AnimationPlayer:
	if root is AnimationPlayer: return root
	for child in root.get_children():
		var found := find_animation_player(child)
		if found != null: return found
	return null

func play_run(speed := 1.0) -> void:
	if not is_instance_valid(animation_player): return
	for animation_name in animation_player.get_animation_list():
		if str(animation_name).to_lower() != "reset":
			animation_player.speed_scale = speed
			animation_player.play(animation_name)
			return

func update_text() -> void:
	if not is_instance_valid(progress_label): return
	progress_label.text = "BUILD %d%%" % int(_progress)
	var message := "Building with the run rig…"
	match cat_state:
		"coffee": message = "Coffee and steam break"
		"running": message = "Rain! Running for shelter"
		"scared": message = "Thunder!"
		"shelter": message = "Safe inside the glowing house"
		"celebrate": message = "Build complete!"
	state_label.text = message
