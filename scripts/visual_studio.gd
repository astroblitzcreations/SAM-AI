class_name SamVisualStudio
extends VBoxContainer

signal generate_requested(prompt: String, output_kind: String, duration_seconds: float, fps: int, reference_path: String, engine: String)
signal install_requested

var prompt_editor: TextEdit
var kind_selector: OptionButton
var engine_selector: OptionButton
var duration: SpinBox
var fps: SpinBox
var frame_summary: Label
var reference_path: LineEdit
var preset_selector: OptionButton
var status_label: Label
var result_preview: TextureRect
var result_path_label: Label
var latest_result_path := ""
var generate_button: Button

const PRESETS := [
	{"name": "Portrait • studio", "prompt": "A polished photorealistic studio portrait, natural expression, realistic skin and hair, soft key light, subtle rim light, elegant neutral background."},
	{"name": "Scene • neon city", "prompt": "A cinematic walk through a futuristic neon city at night, coherent reflections, realistic motion, detailed environment, stable camera."},
	{"name": "Motion • smile and wave", "prompt": "The subject smiles naturally and waves toward the camera, subtle realistic body motion, stable facial identity, coherent hands."},
	{"name": "Product • clean showcase", "prompt": "A clean professional product showcase on a simple surface, controlled studio lighting, crisp detail, realistic shadows."},
	{"name": "Reference • new setting", "prompt": "Use the selected reference image for identity and appearance. Place the same subject in a clearly different setting while preserving recognizable features and realistic anatomy."}
]

func _ready() -> void:
	name = "ImageVideoStudio"
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 9)
	build_ui()

func build_ui() -> void:
	var title := Label.new()
	title.text = "IMAGE + VIDEO STUDIO"
	title.add_theme_font_size_override("font_size", 22)
	add_child(title)
	var note := Label.new()
	note.text = "Visual generation is isolated here. Normal Chat never starts an image or video module."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(note)
	var settings_row := HFlowContainer.new()
	settings_row.add_theme_constant_override("h_separation", 8)
	settings_row.add_theme_constant_override("v_separation", 6)
	add_child(settings_row)
	kind_selector = labeled_option(settings_row, "OUTPUT", ["Image", "Video"])
	kind_selector.item_selected.connect(func(_index: int): update_mode())
	engine_selector = labeled_option(settings_row, "ENGINE", ["Automatic Best Available", "Wan 2.2 TI2V-5B", "SAM Local Inpainting"])
	duration = labeled_spin(settings_row, "DURATION (SECONDS)", 1.0, 30.0, 0.5, 5.0)
	duration.value_changed.connect(func(_value: float): update_frame_summary())
	fps = labeled_spin(settings_row, "FPS", 1.0, 60.0, 1.0, 16.0)
	fps.value_changed.connect(func(_value: float): update_frame_summary())
	frame_summary = Label.new()
	settings_row.add_child(frame_summary)
	var reference_row := HBoxContainer.new()
	add_child(reference_row)
	var reference_label := Label.new()
	reference_label.text = "REFERENCE IMAGE (OPTIONAL)"
	reference_row.add_child(reference_label)
	reference_path = LineEdit.new()
	reference_path.placeholder_text = "No reference selected • text-to-image/video"
	reference_path.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reference_row.add_child(reference_path)
	var browse := Button.new()
	browse.text = "BROWSE"
	browse.pressed.connect(browse_reference)
	reference_row.add_child(browse)
	var preset_row := HBoxContainer.new()
	add_child(preset_row)
	var preset_label := Label.new()
	preset_label.text = "QUICK PROMPT"
	preset_row.add_child(preset_label)
	preset_selector = OptionButton.new()
	preset_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for preset in PRESETS:
		preset_selector.add_item(str(preset.name))
	preset_row.add_child(preset_selector)
	var load_preset := Button.new()
	load_preset.text = "LOAD PRESET"
	load_preset.pressed.connect(apply_preset)
	preset_row.add_child(load_preset)
	prompt_editor = TextEdit.new()
	prompt_editor.placeholder_text = "Describe only the image or video you want to create…"
	prompt_editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	prompt_editor.custom_minimum_size.y = 180
	add_child(prompt_editor)
	status_label = Label.new()
	status_label.text = "Studio idle • choose Image or Video, review settings, then generate"
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(status_label)
	result_preview = TextureRect.new()
	result_preview.custom_minimum_size = Vector2(0, 260)
	result_preview.size_flags_vertical = Control.SIZE_EXPAND_FILL
	result_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	result_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	result_preview.visible = false
	add_child(result_preview)
	result_path_label = Label.new()
	result_path_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_path_label.visible = false
	add_child(result_path_label)
	var actions := HFlowContainer.new()
	actions.add_theme_constant_override("h_separation", 8)
	add_child(actions)
	generate_button = Button.new()
	generate_button.text = "GENERATE IMAGE / VIDEO"
	generate_button.pressed.connect(submit)
	actions.add_child(generate_button)
	var install := Button.new()
	install.text = "INSTALL / REPAIR VISUAL MODULE"
	install.pressed.connect(func(): install_requested.emit())
	actions.add_child(install)
	var clear := Button.new()
	clear.text = "CLEAR"
	clear.pressed.connect(func(): prompt_editor.clear(); reference_path.clear(); clear_result(); status_label.text = "Studio cleared")
	actions.add_child(clear)
	var open_result := Button.new()
	open_result.text = "OPEN RESULT"
	open_result.pressed.connect(func():
		if not latest_result_path.is_empty() and FileAccess.file_exists(latest_result_path):
			OS.shell_open(latest_result_path))
	actions.add_child(open_result)
	var open_folder := Button.new()
	open_folder.text = "OPEN OUTPUT FOLDER"
	open_folder.pressed.connect(func():
		if not latest_result_path.is_empty():
			OS.shell_open(latest_result_path.get_base_dir()))
	actions.add_child(open_folder)
	update_mode()

func labeled_option(parent: Control, label_text: String, items: Array[String]) -> OptionButton:
	var label := Label.new()
	label.text = label_text
	parent.add_child(label)
	var option := OptionButton.new()
	for item in items:
		option.add_item(item)
	parent.add_child(option)
	return option

func labeled_spin(parent: Control, label_text: String, minimum: float, maximum: float, step_value: float, initial: float) -> SpinBox:
	var label := Label.new()
	label.text = label_text
	parent.add_child(label)
	var spin := SpinBox.new()
	spin.min_value = minimum
	spin.max_value = maximum
	spin.step = step_value
	spin.value = initial
	parent.add_child(spin)
	return spin

func update_mode() -> void:
	var video := kind_selector.selected == 1
	duration.editable = video
	fps.editable = video
	update_frame_summary()

func update_frame_summary() -> void:
	frame_summary.text = "1 still frame" if kind_selector.selected == 0 else "%d frames @ %d FPS" % [maxi(1, roundi(duration.value * fps.value)), roundi(fps.value)]

func apply_preset() -> void:
	if preset_selector.selected >= 0 and preset_selector.selected < PRESETS.size():
		prompt_editor.text = str(PRESETS[preset_selector.selected].prompt)
		prompt_editor.grab_focus()

func browse_reference() -> void:
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.add_filter("*.png,*.jpg,*.jpeg,*.webp", "Reference images")
	dialog.file_selected.connect(func(path: String): reference_path.text = path; dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered_ratio(0.75)

func submit() -> void:
	if generate_button.disabled:
		return
	var prompt := prompt_editor.text.strip_edges()
	if prompt.is_empty():
		status_label.text = "Describe the visual you want before generating."
		prompt_editor.grab_focus()
		return
	var output_kind := "video" if kind_selector.selected == 1 else "image"
	status_label.text = "Sending an isolated %s request to SAM…" % output_kind
	generate_requested.emit(prompt, output_kind, duration.value, roundi(fps.value), reference_path.text.strip_edges(), engine_selector.get_item_text(engine_selector.selected))

func set_prompt(value: String, output_kind := "image") -> void:
	prompt_editor.text = value
	kind_selector.select(1 if output_kind == "video" else 0)
	update_mode()
	prompt_editor.grab_focus()

func set_status(value: String) -> void:
	status_label.text = value

func set_busy(value: bool) -> void:
	generate_button.disabled = value
	generate_button.text = "GENERATION RUNNING…" if value else "GENERATE IMAGE / VIDEO"

func show_result(path: String) -> void:
	latest_result_path = path
	result_path_label.text = "RESULT: " + path
	result_path_label.visible = true
	var extension := path.get_extension().to_lower()
	if extension in ["png", "jpg", "jpeg", "webp", "bmp"]:
		var image := Image.load_from_file(path)
		if not image.is_empty():
			result_preview.texture = ImageTexture.create_from_image(image)
			result_preview.visible = true
	status_label.text = "COMPLETE • Result is ready below. Use Open Result or Open Output Folder."
	set_busy(false)

func clear_result() -> void:
	latest_result_path = ""
	result_preview.texture = null
	result_preview.visible = false
	result_path_label.text = ""
	result_path_label.visible = false

func reset_for_session() -> void:
	prompt_editor.clear()
	reference_path.clear()
	kind_selector.select(0)
	update_mode()
	clear_result()
	set_busy(false)
	status_label.text = "Studio idle • fresh project session"
