class_name SamBuilderCat
extends Control

var _progress := 0.0
var stalled_timer := 0.0
var state_timer := 0.0
var cat_state := "fetching"
var cat_dir := 1.0
var cat_target_x := 0.42
var cat_is_moving := true
var built_stage := 0
var pending_stage := 0
var storm_active := false
var lightning_timer := 0.0
var cat_root: Node3D
var animation_player: AnimationPlayer
var house_stages: Array[Node3D] = []
var smoke: GPUParticles3D
var rain: GPUParticles3D
var steam: GPUParticles3D
var lightning: OmniLight3D
var cargo: MeshInstance3D
var sled: Node3D
var sled_blocks: Node3D
var rope: MeshInstance3D
var light_item: MeshInstance3D
var house_light: OmniLight3D
var dream_label: Label3D
var scene_environment: Environment
var day_light: DirectionalLight3D
var night_amount := 0.0
var progress_label: Label
var state_label: Label
var text_column: VBoxContainer
var builder_viewport: SubViewport

const CAT_SCALE := 1.35
const CAT_GROUND_Y := 0.08
const CAT_PLANE_Z := 0.15
# The supplied mesh's profile axis is its native orientation. A 90-degree yaw
# shows its chest/head-on, which caused the front-facing screenshots.
const CAT_SIDE_YAW := 0.0

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
	var builder_viewport_container := SubViewportContainer.new()
	builder_viewport_container.stretch = true
	builder_viewport_container.custom_minimum_size = Vector2(220, 68)
	builder_viewport_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	builder_viewport_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	builder_viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_child(builder_viewport_container)
	builder_viewport = SubViewport.new()
	builder_viewport.size = Vector2i(440, 136)
	builder_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	builder_viewport_container.add_child(builder_viewport)
	var world := Node3D.new()
	builder_viewport.add_child(world)
	var environment := WorldEnvironment.new()
	scene_environment = Environment.new()
	scene_environment.background_mode = Environment.BG_COLOR
	scene_environment.background_color = Color("#07131f")
	scene_environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	scene_environment.ambient_light_color = Color("#8ac6d1")
	scene_environment.ambient_light_energy = 0.72
	environment.environment = scene_environment
	world.add_child(environment)
	var camera := Camera3D.new()
	# A straight-on orthographic camera makes this a true side-scroller. There
	# is no perspective axis for the cat to appear to run into.
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2.15
	camera.position = Vector3(0.0, 0.55, 5.0)
	camera.look_at_from_position(camera.position, Vector3(0.0, 0.55, 0.0), Vector3.UP)
	world.add_child(camera)
	day_light = DirectionalLight3D.new()
	day_light.rotation_degrees = Vector3(-35, -25, 0)
	day_light.light_color = Color("#bdefff")
	day_light.light_energy = 1.15
	world.add_child(day_light)
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
	cat_root.position = Vector3(-0.80, CAT_GROUND_Y, CAT_PLANE_Z)
	cat_root.scale = Vector3.ONE * CAT_SCALE
	cat_root.rotation_degrees = Vector3(0, CAT_SIDE_YAW, 0)
	world.add_child(cat_root)
	animation_player = find_animation_player(cat_root)
	disable_animation_root_motion()
	play_run(0.65)

func disable_animation_root_motion() -> void:
	if not is_instance_valid(animation_player):
		return
	for animation_name in animation_player.get_animation_list():
		var animation := animation_player.get_animation(animation_name)
		if animation == null:
			continue
		for track_index in range(animation.get_track_count()):
			# The imported Blender action contains a position track named
			# "reference". It is root motion and must not steer the display rig.
			if str(animation.track_get_path(track_index)) == "reference":
				animation.track_set_enabled(track_index, false)

func build_ground_and_house(world: Node3D) -> void:
	add_box(world, Vector3(0, -0.02, 0), Vector3(4.8, 0.07, 1.15), Color("#18323b"))
	var stages := [
		[Vector3(-1.18, 0.20, 0), Vector3(0.65, 0.40, 0.62), Color("#895a39"), 0.0],
		[Vector3(-1.18, 0.58, 0), Vector3(0.65, 0.35, 0.62), Color("#a66f45"), 0.0],
		[Vector3(-1.36, 0.88, 0), Vector3(0.48, 0.10, 0.72), Color("#c84d55"), 24.0],
		[Vector3(-1.00, 0.88, 0), Vector3(0.48, 0.10, 0.72), Color("#c84d55"), -24.0]
	]
	for data in stages:
		var part := add_box(world, data[0], data[1], data[2])
		part.rotation_degrees.z = data[3]
		part.visible = false
		house_stages.append(part)
	var door := add_box(world, Vector3(-1.18, 0.17, 0.325), Vector3(0.20, 0.31, 0.04), Color("#1b1114"))
	var door_mat := door.material_override as StandardMaterial3D
	door_mat.emission_enabled = true
	door_mat.emission = Color("#ffb84d")
	door_mat.emission_energy_multiplier = 1.6
	house_light = OmniLight3D.new()
	house_light.position = Vector3(-1.18, 0.45, 0.58)
	house_light.light_color = Color("#ffd477")
	house_light.light_energy = 0.0
	house_light.omni_range = 2.2
	world.add_child(house_light)
	# Supply depot, sled, load, rope, and final lamp are all separate so the
	# delivery story remains readable even in the smallest monitor.
	add_box(world, Vector3(1.15, 0.10, 0), Vector3(0.34, 0.20, 0.34), Color("#c69755"))
	sled = Node3D.new()
	world.add_child(sled)
	add_box(sled, Vector3.ZERO, Vector3(0.48, 0.055, 0.28), Color("#a85e35"))
	add_box(sled, Vector3(-0.16, -0.055, 0.0), Vector3(0.08, 0.08, 0.34), Color("#283640"))
	add_box(sled, Vector3(0.16, -0.055, 0.0), Vector3(0.08, 0.08, 0.34), Color("#283640"))
	sled.position = Vector3(1.12, 0.10, CAT_PLANE_Z)
	sled_blocks = Node3D.new()
	sled.add_child(sled_blocks)
	for block_data in [[-0.14, Color("#efb65b")], [0.0, Color("#75d5df")], [0.14, Color("#e9776f")]]:
		add_box(sled_blocks, Vector3(block_data[0], 0.12, 0), Vector3(0.13, 0.15, 0.16), block_data[1])
	sled_blocks.visible = false
	rope = add_box(world, Vector3(0, 0.17, CAT_PLANE_Z), Vector3(1.0, 0.018, 0.018), Color("#e8d5a7"))
	rope.visible = false
	light_item = add_box(world, Vector3(1.15, 0.28, 0.18), Vector3(0.10, 0.16, 0.10), Color("#fff27a"))
	var light_mat := light_item.material_override as StandardMaterial3D
	light_mat.emission_enabled = true
	light_mat.emission = Color("#fff27a")
	light_mat.emission_energy_multiplier = 2.2
	light_item.visible = false
	# A tiny coffee spot remains near the finished house; its steam is driven by
	# the existing particle system during rests and the final sleep scene.
	add_box(world, Vector3(-0.58, 0.095, 0.22), Vector3(0.10, 0.15, 0.10), Color("#63c7d4"))
	dream_label = Label3D.new()
	dream_label.text = "Z  z  z\nDreaming of tuna…"
	dream_label.position = Vector3(-0.72, 1.12, 0.35)
	dream_label.font_size = 28
	dream_label.modulate = Color("#d9f5ff")
	dream_label.outline_modulate = Color("#07131f")
	dream_label.outline_size = 5
	dream_label.visible = false
	world.add_child(dream_label)

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
	smoke.position = Vector3(-1.05, 0.38, 0.2)
	smoke.one_shot = true
	smoke.explosiveness = 0.92
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
	steam.position = Vector3(-0.58, 0.30, 0.24)
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
	var particle_material := material(color)
	particle_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	particle_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	particle_material.emission_enabled = true
	particle_material.emission = color
	particle_material.emission_energy_multiplier = 1.25
	quad.material = particle_material
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

func set_display_size_level(level: int) -> void:
	if not is_instance_valid(progress_label) or not is_instance_valid(state_label) or not is_instance_valid(text_column):
		return
	var safe_level := clampi(level, 0, 2)
	text_column.custom_minimum_size.x = [132.0, 184.0, 240.0][safe_level]
	progress_label.add_theme_font_size_override("font_size", [12, 18, 24][safe_level])
	state_label.add_theme_font_size_override("font_size", [10, 15, 20][safe_level])

func set_progress(value: float) -> void:
	var next := clampf(value, 0.0, 100.0)
	if not is_equal_approx(next, _progress): stalled_timer = 0.0
	_progress = next
	var new_stage := mini(4, int(ceil(_progress / 25.0)))
	if new_stage > built_stage:
		pending_stage = new_stage
		if cat_state not in ["fetching", "carrying"]:
			set_state("fetching")
	for index in range(house_stages.size()): house_stages[index].visible = index < built_stage
	if not is_instance_valid(rain) or not is_instance_valid(cat_root):
		update_text()
		return
	set_storm(_progress >= 66.0 and _progress < 78.0)
	update_text()

func _process(delta: float) -> void:
	if not is_instance_valid(cat_root): return
	state_timer += delta
	stalled_timer += delta
	if lightning.light_energy > 0.0: lightning.light_energy = move_toward(lightning.light_energy, 0.0, delta * 14.0)
	if cat_state in ["install_light", "sleep"]:
		night_amount = move_toward(night_amount, 1.0, delta * 0.24)
	else:
		night_amount = move_toward(night_amount, 0.0, delta * 0.45)
	update_day_night()
	if storm_active:
		lightning_timer -= delta
		if lightning_timer <= 0.0:
			lightning.light_energy = 7.5
			lightning_timer = 3.2
			set_state("scared")
	elif state_timer > 4.2 and _progress < 100.0 and pending_stage <= built_stage and cat_state not in ["fetch_light", "carrying_light", "install_light", "sleep"]:
		set_state("coffee" if stalled_timer > 8.0 else "fetching")
	match cat_state:
		"fetching":
			set_sled_loaded(false)
			cat_is_moving = true
			cat_dir = 1.0
			cat_root.position.x = move_toward(cat_root.position.x, 1.02, delta * 0.78)
			if cat_root.position.x >= 0.99:
				set_sled_loaded(true)
				set_state("carrying")
		"carrying":
			cat_is_moving = true
			cat_dir = -1.0
			cat_root.position.x = move_toward(cat_root.position.x, -0.83, delta * 0.62)
			update_sled_and_rope()
			if cat_root.position.x <= -0.80:
				set_sled_loaded(false)
				built_stage = mini(pending_stage, built_stage + 1)
				for index in range(house_stages.size()): house_stages[index].visible = index < built_stage
				if is_instance_valid(smoke):
					smoke.restart()
					smoke.emitting = true
				set_state("building")
		"building":
			cat_is_moving = false
			if state_timer > 1.4:
				set_state("fetch_light" if _progress >= 90.0 and built_stage >= 4 else "fetching")
		"fetch_light":
			cat_dir = 1.0
			cat_root.position.x = move_toward(cat_root.position.x, 1.03, delta * 0.72)
			if cat_root.position.x >= 1.0:
				light_item.visible = true
				set_state("carrying_light")
		"carrying_light":
			cat_dir = -1.0
			cat_root.position.x = move_toward(cat_root.position.x, -0.86, delta * 0.58)
			light_item.position = cat_root.position + Vector3(-0.02, 0.34, 0.05)
			if cat_root.position.x <= -0.83:
				light_item.visible = false
				set_state("install_light")
		"install_light":
			if state_timer > 1.7:
				house_light.light_energy = 2.4
				set_state("sleep")
		"sleep":
			cat_root.position.x = -0.72
			steam.emitting = true
			dream_label.visible = true
			dream_label.modulate.a = 0.55 + sin(Time.get_ticks_msec() / 600.0) * 0.35
		"running", "scared":
			cat_dir = -1.0
			cat_root.position.x = move_toward(cat_root.position.x, -1.18, delta * 1.8)
			if cat_root.position.x <= -1.12: set_state("shelter")
		"coffee": cat_root.position.x = move_toward(cat_root.position.x, -0.12, delta * 0.45)
		"celebrate": cat_root.position.x = -0.72 + sin(Time.get_ticks_msec() / 150.0) * 0.12
	# Reassert the two-dimensional lane after animation evaluation. Direction is
	# represented by a mirror, never by rotating the model into camera depth.
	cat_root.position.y = CAT_GROUND_Y
	cat_root.position.z = CAT_PLANE_Z
	cat_root.rotation_degrees = Vector3(0, CAT_SIDE_YAW, -14.0 if cat_state == "sleep" else 0.0)
	cat_root.scale = Vector3(CAT_SCALE * (-1.0 if cat_dir < 0 else 1.0), CAT_SCALE, CAT_SCALE)
	update_text()

func set_sled_loaded(loaded: bool) -> void:
	if is_instance_valid(sled_blocks): sled_blocks.visible = loaded
	if is_instance_valid(sled): sled.visible = loaded or cat_state == "fetching"
	if is_instance_valid(rope): rope.visible = loaded
	if not loaded and is_instance_valid(sled): sled.position = Vector3(1.12, 0.10, CAT_PLANE_Z)

func update_sled_and_rope() -> void:
	if not is_instance_valid(sled) or not is_instance_valid(rope): return
	sled.position = Vector3(cat_root.position.x + 0.43, 0.10, CAT_PLANE_Z)
	var rope_start := cat_root.position.x + 0.15
	var rope_end := sled.position.x - 0.24
	rope.position = Vector3((rope_start + rope_end) * 0.5, 0.18, CAT_PLANE_Z)
	rope.scale = Vector3(maxf(0.05, absf(rope_end - rope_start)), 1.0, 1.0)

func update_day_night() -> void:
	if not is_instance_valid(scene_environment) or not is_instance_valid(day_light): return
	scene_environment.background_color = Color("#07131f").lerp(Color("#020611"), night_amount)
	scene_environment.ambient_light_color = Color("#8ac6d1").lerp(Color("#365080"), night_amount)
	day_light.light_color = Color("#bdefff").lerp(Color("#728bd1"), night_amount)
	day_light.light_energy = lerpf(1.15, 0.18, night_amount)

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
	steam.emitting = next in ["coffee", "sleep"]
	if is_instance_valid(dream_label): dream_label.visible = next == "sleep"
	cat_root.visible = next != "shelter"
	if next in ["fetching", "carrying", "fetch_light", "carrying_light", "running", "scared", "building", "celebrate"]: play_run(2.0 if next in ["running", "scared"] else (1.15 if next in ["fetching", "carrying", "fetch_light", "carrying_light"] else 0.55))
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
	var message := "Going to get supplies…"
	match cat_state:
		"fetching": message = "Running right for supplies"
		"carrying": message = "Carrying materials left"
		"building": message = "Building the next house stage"
		"fetch_light": message = "Fetching the house light"
		"carrying_light": message = "Bringing the light home"
		"install_light": message = "Installing the warm light"
		"sleep": message = "Night-night • dreaming of tuna"
		"coffee": message = "Coffee and steam break"
		"running": message = "Rain! Running for shelter"
		"scared": message = "Thunder!"
		"shelter": message = "Safe inside the glowing house"
		"celebrate": message = "Build complete!"
	state_label.text = message
