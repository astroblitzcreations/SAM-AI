extends Control
## Decorative loading background only. The host application owns all engine work,
## real progress, error handling and the decision to call dismiss().
## Intended for Godot 4.4+; this pack does not modify the host application's code.

signal dismissed

@export var reduced_motion: bool = false:
	set(value):
		reduced_motion = value
		if is_node_ready():
			_apply_motion_mode()

## False preserves the complete image. True fills the window but crops artwork.
@export var crop_to_fill: bool = false:
	set(value):
		crop_to_fill = value
		if is_node_ready():
			_fit_artwork()

@onready var artwork: Control = $Artwork
@onready var video: VideoStreamPlayer = $Artwork/Video
@onready var frame_animation: TextureRect = $Artwork/FrameAnimation
@onready var scan_glow: ColorRect = $Artwork/ScanGlow
@onready var scan_core: ColorRect = $Artwork/ScanCore
@onready var intro_status: Label = $Artwork/IntroStatus
@onready var overlay_root: Control = $Artwork/OverlayRoot
@onready var status_safe_area: Control = $Artwork/OverlayRoot/StatusSafeArea

const ART_SIZE: Vector2 = Vector2(1920.0, 1080.0)
var _dismissing: bool = false
var _waiting_for_first_frame: bool = false
var _play_started_msec: int = 0
var _playing_frames: bool = false
const INTRO_FPS := 15.0
const INTRO_FRAME_COUNT := 75
const INTRO_FRAME_PATTERN := "res://sam_ai_startup/media/intro_frames/frame_%03d.webp"

func _ready() -> void:
	resized.connect(_fit_artwork)
	visibility_changed.connect(_on_visibility_changed)
	_fit_artwork()
	_apply_motion_mode()

func _fit_artwork() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var ratio_x: float = size.x / ART_SIZE.x
	var ratio_y: float = size.y / ART_SIZE.y
	var fit: float = maxf(ratio_x, ratio_y) if crop_to_fill else minf(ratio_x, ratio_y)
	artwork.size = ART_SIZE * fit
	artwork.position = (size - artwork.size) * 0.5

func _apply_motion_mode() -> void:
	if reduced_motion or not is_visible_in_tree():
		video.stop()
		video.visible = false
		frame_animation.visible = false
		scan_glow.visible = false
		scan_core.visible = false
		intro_status.visible = false
		_playing_frames = false
		_waiting_for_first_frame = false
		set_process(false)
		return
	# Use exported WebP frames instead of VideoStreamPlayer. Theora playback can
	# advance without presenting a texture on some Compatibility-renderer systems.
	video.stop()
	video.visible = false
	frame_animation.visible = true
	frame_animation.modulate.a = 1.0
	frame_animation.pivot_offset = ART_SIZE * 0.5
	scan_glow.visible = true
	scan_core.visible = true
	intro_status.visible = true
	_play_started_msec = Time.get_ticks_msec()
	_playing_frames = true
	_set_intro_frame(1)
	set_process(true)

func _process(_delta: float) -> void:
	if not _playing_frames:
		set_process(false)
		return
	var elapsed := (Time.get_ticks_msec() - _play_started_msec) / 1000.0
	var frame_number := mini(int(elapsed * INTRO_FPS) + 1, INTRO_FRAME_COUNT)
	_set_intro_frame(frame_number)
	var phase := clampf(elapsed / 5.0, 0.0, 1.0)
	# An unmistakable cinematic move supplements the source pack's intentionally
	# restrained peripheral motion, which otherwise reads as a still image.
	var zoom := lerpf(1.035, 1.0, phase)
	frame_animation.scale = Vector2(zoom, zoom)
	var scan_y := lerpf(105.0, 930.0, fmod(elapsed / 2.15, 1.0))
	scan_glow.position.y = scan_y
	scan_core.position.y = scan_y + 2.5
	var pulse := 0.72 + sin(elapsed * 4.2) * 0.20
	scan_glow.modulate.a = pulse
	intro_status.text = "SAM-AI  //  INITIALIZING" + ".".repeat(int(elapsed * 3.0) % 4)
	intro_status.modulate.a = 0.68 + sin(elapsed * 3.4) * 0.28

func _set_intro_frame(frame_number: int) -> void:
	var path := INTRO_FRAME_PATTERN % frame_number
	var next_texture := load(path) as Texture2D
	if next_texture != null and frame_animation.texture != next_texture:
		frame_animation.texture = next_texture

func _on_visibility_changed() -> void:
	if is_node_ready() and not _dismissing:
		_apply_motion_mode()

func transition_to_loading(duration: float = 0.65) -> void:
	# Fade the animated layer away to reveal the matching still artwork beneath.
	# The host then reveals its real module-loading panel over that still.
	_playing_frames = false
	_waiting_for_first_frame = false
	set_process(false)
	scan_glow.visible = false
	scan_core.visible = false
	intro_status.visible = false
	if not is_instance_valid(frame_animation) or not frame_animation.visible:
		return
	if duration > 0.0:
		var video_fade := create_tween()
		video_fade.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		video_fade.tween_property(frame_animation, "modulate:a", 0.0, duration)
		await video_fade.finished
	video.stop()
	video.visible = false
	frame_animation.visible = false
	frame_animation.modulate.a = 1.0
	frame_animation.scale = Vector2.ONE

func dismiss(duration: float = 0.35) -> void:
	# Call only when the host app has genuinely become ready.
	# The 12-second decorative loop never controls readiness or progress.
	if _dismissing:
		return
	_dismissing = true
	if duration <= 0.0:
		_finish_dismiss()
		return
	var fade: Tween = create_tween()
	fade.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade.tween_property(self, "modulate:a", 0.0, duration)
	fade.finished.connect(_finish_dismiss)

func _finish_dismiss() -> void:
	video.stop()
	video.stream = null
	frame_animation.texture = null
	set_process(false)
	dismissed.emit()
	queue_free()

func _exit_tree() -> void:
	if is_instance_valid(video):
		video.stop()
