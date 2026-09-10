extends Control

const DEFAULT_MODEL := "E:/sam-ai/examples/configs/output_q4_k_m.gguf"
const QWEN_CODER_14B_MODEL := "E:/sam-ai/models/Qwen2.5-Coder-14B-Instruct-Q4_K_M/qwen2.5-coder-14b-instruct-q4_k_m-00001-of-00002.gguf"
const QWEN_VISION_7B_MODEL := "E:/sam-ai/models/Qwen2.5-VL-7B-Instruct-Q4_K_M.gguf"
const QWEN_VISION_7B_MMPROJ := "E:/sam-ai/models/mmproj-Qwen2.5-VL-7B-F16.gguf"
const DEFAULT_SERVER := "E:/sam-ai/llama-cuda/llama-server.exe"
const DEFAULT_MEMORY := "E:/sam-ai/system_prompt.txt"
const SETTINGS_FILE := "user://settings.json"
const HISTORY_FILE := "user://last_session.json"
const SERVER_PID_FILE := "user://llama_server.pid"
const FIRST_RUN_FILE := "user://first_run_complete.json"
const CHAT_ARCHIVE_DIR := "E:/sam-ai/godot_chats"
const VOICE_PYTHON := "E:/sam-ai/.venv/Scripts/python.exe"
const VOICE_BRIDGE := "E:/sam-ai/voice/voice_bridge.py"
const VOICE_DAEMON := "E:/sam-ai/voice/tts_daemon.py"
const VOICE_DAEMON_PID_FILE := "user://tts_daemon.pid"
const LLAMA_WINDOWS_BUILD := "b10883"
const LLAMA_CPU_WINDOWS_URL := "https://github.com/ggml-org/llama.cpp/releases/download/b10883/llama-b10883-bin-win-cpu-x64.zip"
const LLAMA_CUDA_WINDOWS_URL := "https://github.com/ggml-org/llama.cpp/releases/download/b10883/llama-b10883-bin-win-cuda-12.4-x64.zip"
const LLAMA_CUDART_WINDOWS_URL := "https://github.com/ggml-org/llama.cpp/releases/download/b10883/cudart-llama-bin-win-cuda-12.4-x64.zip"
const KOKORO_MODEL_URL := "https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/kokoro-v1.0.onnx"
const KOKORO_VOICES_URL := "https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/voices-v1.0.bin"
const WHISPER_WINDOWS_URL := "https://github.com/ggml-org/whisper.cpp/releases/download/b4938/whisper-bin-x64.zip"
const WHISPER_MODEL_URL := "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en-q5_1.bin?download=true"
const HOST := "127.0.0.1"
const STARTUP_SCENE := preload("res://sam_ai_startup/SAMStartupBackground.tscn")
const STOP_TOKENS := ["<|im_end|>", "<|im_start|>", "<|eot_id|>", "<|end_of_text|>"]
const BUILTIN_BACKGROUNDS := ["res://assets/backgrounds/chat.png",
	"res://assets/backgrounds/memory.png", "res://assets/backgrounds/engine.png",
	"res://assets/backgrounds/debug.png"]

func voice_runtime_script(filename: String) -> String:
	var packaged := OS.get_executable_path().get_base_dir().path_join("voice").path_join(filename)
	if FileAccess.file_exists(packaged):
		return packaged
	return "E:/sam-ai/voice/" + filename

var colors := {
	"void": Color("#080b12"), "panel": Color("#111827"), "line": Color("#2b3c55"),
	"cyan": Color("#4deeea"), "pink": Color("#ff4ecd"), "amber": Color("#f9c74f"),
	"text": Color("#d8e7ff"), "muted": Color("#8292ad"), "green": Color("#76f7a6"),
	"red": Color("#ff667d")
}
var settings := {
	"model_path": DEFAULT_MODEL, "server_path": DEFAULT_SERVER, "memory_path": DEFAULT_MEMORY,
	"mmproj_path": "", "vision_model_path": "", "vision_mmproj_path": "", "auto_vision_switch": true,
	"background_path": "", "theme": "Neon Night",
	"port": 8080, "gpu_layers": 99, "context_size": 8192, "max_tokens": 4096,
	"temperature": 0.1, "voice_enabled": true, "voice_name": "af_heart",
	"voice_auto_send": false, "mic_notice_shown": false,
	"voice_python_path": VOICE_PYTHON,
	"kokoro_model_path": "E:/sam-ai/voice/kokoro/kokoro-v1.0.onnx",
	"kokoro_voices_path": "E:/sam-ai/voice/kokoro/voices-v1.0.bin",
	"whisper_exe_path": "E:/sam-ai/voice/whisper/runtime/Release/whisper-cli.exe",
	"whisper_model_path": "E:/sam-ai/voice/whisper/ggml-base.en-q5_1.bin",
	"module_url_coder_3b": "https://huggingface.co/Qwen/Qwen2.5-Coder-3B-Instruct-GGUF/resolve/main/qwen2.5-coder-3b-instruct-q4_k_m.gguf?download=true",
	"module_url_coder_7b": "https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/qwen2.5-coder-7b-instruct-q4_k_m.gguf?download=true",
	"module_url_coder_14b": "https://huggingface.co/Qwen/Qwen2.5-Coder-14B-Instruct-GGUF/tree/main",
	"module_url_vision_7b": "https://huggingface.co/ggml-org/Qwen2.5-VL-7B-Instruct-GGUF/resolve/main/Qwen2.5-VL-7B-Instruct-Q4_K_M.gguf?download=true",
	"module_url_vision_mmproj": "https://huggingface.co/ggml-org/Qwen2.5-VL-7B-Instruct-GGUF/resolve/main/mmproj-Qwen2.5-VL-7B-Instruct-Q8_0.gguf?download=true",
	"module_url_llama_cpu": LLAMA_CPU_WINDOWS_URL,
	"module_url_llama_cuda": LLAMA_CUDA_WINDOWS_URL,
	"module_url_llama_cudart": LLAMA_CUDART_WINDOWS_URL,
	"module_url_kokoro_model": KOKORO_MODEL_URL,
	"module_url_kokoro_voices": KOKORO_VOICES_URL,
	"module_url_whisper_windows": WHISPER_WINDOWS_URL,
	"module_url_whisper_model": WHISPER_MODEL_URL
}
var history: Array = []
var server_pid := -1
var server_owned := false
var server_ready := false
var generating := false
var health_client := HTTPClient.new()
var stream_client := HTTPClient.new()
var health_timer := 0.0
var load_started_ms := 0
var response_started_ms := 0
var response_text := ""
var pending_repair_error := ""
var pending_repair_language := ""
var force_chat_follow := false
var render_buffer := ""
var stream_finished := false
var stream_retry_count := 0
var visible_history_start := 0
var rendered_code_blocks: Array[String] = []
var rendered_code_languages: Array[String] = []
var sse_buffer := PackedByteArray()
var sent_messages: Array[String] = []
var history_cursor := -1
var history_draft := ""
var attached_image_path := ""
var attached_file_path := ""
var attached_file_text := ""
var attached_file_kind := ""
var engine_mode := "primary"
var pending_vision_send := false
var restore_primary_when_done := false
var thinking_elapsed := 0.0
var thinking_frame := -1
var loading_elapsed := 0.0
var background_rect: TextureRect
var attachment_label: Label
var attachment_preview: TextureRect
var toast_label: Label

var status_label: Label
var status_dot: Label
var chat_log: RichTextLabel
var input_box: TextEdit
var send_button: Button
var stop_button: Button
var memory_editor: TextEdit
var logs: RichTextLabel
var fields := {}
var session_id := ""
var microphone_player: AudioStreamPlayer
var voice_player: AudioStreamPlayer
var record_effect: AudioEffectRecord
var microphone_button: Button
var voice_status: Label
var auto_speak: CheckButton
var chat_auto_speak: CheckButton
var auto_send_voice: CheckButton
var voice_selector: OptionButton
var recording_voice := false
var voice_thread: Thread
var pending_speech := ""
var live_transcription_elapsed := 0.0
var voice_input_prefix := ""
var live_transcript_buffer := ""
var pending_final_audio := ""
var awaiting_synced_voice := false
var synced_voice_active := false
var synced_voice_failed := false
var synced_reply_text := ""
var synced_reply_index := 0
var streaming_voice_turn := false
var streaming_voice_started := false
var streaming_voice_cursor := 0
var streaming_voice_chunks: Array[String] = []
var streaming_audio_chunks: Array[AudioStreamWAV] = []
var streaming_voice_serial := 0
var streaming_pending_ids: Array[String] = []
var streaming_voice_wait_started_ms := 0
var voice_daemon_pid := -1
var voice_daemon_poll_elapsed := 0.0
var voice_daemon_announced := false
var setup_overlay: ColorRect
var setup_model_path: LineEdit
var setup_server_path: LineEdit
var setup_checks: RichTextLabel
var windows_runtime_request: HTTPRequest
var windows_runtime_download_path := ""
var startup_screen: Control
var startup_message: Label
var startup_detail: Label
var startup_progress: ProgressBar
var startup_shown_msec := 0
var startup_status_panel: PanelContainer
var system_report: RichTextLabel
var cached_system_summary := ""
var stats_report: RichTextLabel
var stats_refresh_elapsed := 0.0
var chat_search_bar: HBoxContainer
var chat_search_input: LineEdit
var chat_search_status: Label
var chat_search_matches: Array[int] = []
var chat_search_match_index := -1
var module_scroll: ScrollContainer
var module_requirement_banner: Label
var attachment_tools: HBoxContainer
var attachment_snippet: RichTextLabel

func _ready() -> void:
	var intro_completed := bool(ProjectSettings.get_setting("sam_ai/intro_completed", false))
	show_startup_screen()
	if intro_completed:
		startup_screen.transition_to_loading(0.0)
		startup_status_panel.visible = true
		set_startup_progress(0.0, "BEGINNING LOCAL STARTUP", "Preparing the local intelligence console")
	else:
		set_startup_progress(5.0, "INITIALIZING SAM-AI", "Preparing the local intelligence console")
	session_id = Time.get_datetime_string_from_system().replace(":", "-")
	load_settings()
	set_startup_progress(12.0, "LOADING SETTINGS", "Restoring your engine and interface preferences")
	load_history()
	save_history()
	set_startup_progress(20.0, "RESTORING CHAT MEMORY", "Loading saved conversations and MemoryCore")
	bind_editor_ui()
	apply_theme_recursive(self)
	redraw_history()
	force_chat_follow = true
	call_deferred("force_chat_to_live_edge")
	load_memory_editor()
	call_deferred("begin_startup")

func bind_editor_ui() -> void:
	background_rect = $BackgroundImage
	status_dot = $Page/Header/StatusDot
	status_label = $Page/Header/StatusLabel
	chat_log = $Page/Tabs/Chat/ChatLog
	input_box = $Page/Tabs/Chat/Composer/Input
	send_button = $Page/Tabs/Chat/Composer/Actions/Send
	stop_button = $Page/Tabs/Chat/Composer/Actions/Abort
	attachment_label = $Page/Tabs/Chat/AttachmentLabel
	attachment_preview = $Page/Tabs/Chat/Composer/AttachmentPreview
	microphone_player = $MicrophoneInput
	voice_player = $VoiceOutput
	microphone_button = $Page/Tabs/Chat/Composer/Actions/Microphone
	voice_status = $Page/Tabs/Chat/VoiceBar/VoiceStatus
	auto_speak = $Page/Tabs/EngineSetup/VoiceOptions/AutoSpeak
	chat_auto_speak = $Page/Tabs/Chat/VoiceBar/ChatAutoSpeak
	auto_send_voice = $Page/Tabs/EngineSetup/VoiceOptions/AutoSend
	voice_selector = $Page/Tabs/EngineSetup/VoiceOptions/Voice
	setup_overlay = $FirstRunSetup
	setup_model_path = $FirstRunSetup/Center/Panel/Margin/Content/ModelRow/ModelPath
	setup_server_path = $FirstRunSetup/Center/Panel/Margin/Content/ServerRow/ServerPath
	setup_checks = $FirstRunSetup/Center/Panel/Margin/Content/Checks
	system_report = $Page/Tabs/SystemSpecs/Report
	toast_label = $Toast
	memory_editor = $Page/Tabs/MemoryCore/MemoryEditor
	logs = $Page/Tabs/DebugTelemetry/Logs
	fields = {"model_path": $Page/Tabs/EngineSetup/SettingsScroll/Settings/ModelPath,
		"server_path": $Page/Tabs/EngineSetup/SettingsScroll/Settings/ServerPath,
		"mmproj_path": $Page/Tabs/EngineSetup/SettingsScroll/Settings/MmprojPath,
		"vision_model_path": $Page/Tabs/EngineSetup/SettingsScroll/Settings/VisionModelPath,
		"vision_mmproj_path": $Page/Tabs/EngineSetup/SettingsScroll/Settings/VisionMmprojPath,
		"memory_path": $Page/Tabs/EngineSetup/SettingsScroll/Settings/MemoryPath,
		"background_path": $Page/Tabs/EngineSetup/SettingsScroll/Settings/BackgroundPath,
		"port": $Page/Tabs/EngineSetup/SettingsScroll/Settings/Port,
		"gpu_layers": $Page/Tabs/EngineSetup/SettingsScroll/Settings/GpuLayers,
		"context_size": $Page/Tabs/EngineSetup/SettingsScroll/Settings/ContextSize,
		"max_tokens": $Page/Tabs/EngineSetup/SettingsScroll/Settings/MaxTokens,
		"temperature": $Page/Tabs/EngineSetup/SettingsScroll/Settings/Temperature}
	for key in fields:
		fields[key].text = setting_text(key)
	input_box.gui_input.connect(_on_input_gui)
	get_window().files_dropped.connect(_on_files_dropped)
	chat_log.meta_clicked.connect(_on_chat_meta_clicked)
	chat_log.gui_input.connect(_on_chat_log_gui_input)
	send_button.pressed.connect(send_message)
	stop_button.pressed.connect(stop_generation)
	$Page/Tabs/Chat/Composer/Actions/Attach.pressed.connect(choose_attachment)
	microphone_button.pressed.connect(toggle_microphone)
	$Page/Tabs/Chat/VoiceBar/StopVoice.pressed.connect(stop_voice)
	auto_speak.toggled.connect(_on_auto_speak_toggled)
	chat_auto_speak.toggled.connect(_on_chat_auto_speak_toggled)
	auto_send_voice.toggled.connect(_on_auto_send_toggled)
	voice_selector.item_selected.connect(_on_voice_selected)
	$Page/Tabs/EngineSetup/VoiceOptions/TestVoice.pressed.connect(test_selected_voice)
	voice_player.finished.connect(_on_voice_finished)
	$FirstRunSetup/Center/Panel/Margin/Content/ModelRow/BrowseModel.pressed.connect(func(): browse_setup_path(true))
	$FirstRunSetup/Center/Panel/Margin/Content/ServerRow/BrowseServer.pressed.connect(func(): browse_setup_path(false))
	$FirstRunSetup/Center/Panel/Margin/Content/Actions/CheckAgain.pressed.connect(func(): refresh_setup_checks(true))
	$FirstRunSetup/Center/Panel/Margin/Content/Actions/WindowsRuntime.pressed.connect(open_windows_runtime_download)
	$FirstRunSetup/Center/Panel/Margin/Content/Actions/Complete.pressed.connect(complete_first_run)
	$FirstRunSetup/Center/Panel/Margin/Content/TitleRow/SetupLater.pressed.connect(close_first_run_to_modules)
	$Page/Tabs/Chat/Composer/Actions/NewSession.pressed.connect(clear_session)
	$Page/Tabs/Chat/Composer/Actions/ClearScreen.pressed.connect(clear_screen)
	$Page/Tabs/Chat/Composer/Actions/CopyChat.pressed.connect(copy_chat)
	$Page/Tabs/Chat/VoiceBar/ThemeButton.pressed.connect(cycle_theme)
	$Page/Tabs/MemoryCore/MemoryActions/SaveMemory.pressed.connect(save_memory)
	$Page/Tabs/MemoryCore/MemoryActions/ReloadMemory.pressed.connect(load_memory_editor)
	$Page/Tabs/MemoryCore/MemoryActions/UndoMemory.pressed.connect(memory_editor.undo)
	$Page/Tabs/MemoryCore/MemoryActions/RedoMemory.pressed.connect(memory_editor.redo)
	$Page/Tabs/MemoryCore.move_child($Page/Tabs/MemoryCore/MemoryActions, 1)
	$Page/Tabs/EngineSetup/EngineActions/UseQwenCoder.pressed.connect(use_qwen_coder_preset)
	$Page/Tabs/EngineSetup/EngineActions/UseQwenVision.pressed.connect(use_qwen_vision_preset)
	$Page/Tabs/EngineSetup/EngineActions/SaveRestart.pressed.connect(save_and_restart)
	$Page/Tabs/EngineSetup/EngineActions/StopEngine.pressed.connect(stop_engine)
	$Page/Tabs/EngineSetup/EngineActions/ApplyBackground.pressed.connect(apply_background_setting)
	$Page/Tabs/EngineSetup/EngineActions/SetupCheck.pressed.connect(show_first_run_setup)
	$Page/Tabs/EngineSetup/AutoVisionSwitch.button_pressed = bool(settings.auto_vision_switch)
	$Page/Tabs/EngineSetup/AutoVisionSwitch.toggled.connect(func(enabled: bool): settings.auto_vision_switch = enabled; save_json(SETTINGS_FILE, settings); show_toast("Automatic vision switching enabled" if enabled else "Automatic vision switching disabled"))
	$Page/Tabs/DebugTelemetry/ClearLog.pressed.connect(func(): logs.clear())
	$Page/Tabs/DebugTelemetry/CopyLog.pressed.connect(copy_logs)
	$Page/Tabs/SystemSpecs/Header/Refresh.pressed.connect(refresh_system_specs)
	$Page/Tabs/SystemSpecs/Header/AskSam.pressed.connect(ask_sam_about_system)
	$Page/Tabs/SystemSpecs/Header.move_child($Page/Tabs/SystemSpecs/Header/AskSam, 1)
	$Page/Tabs.tab_changed.connect(_on_tab_changed)
	$Page/Tabs/EngineSetup/SettingsScroll/Settings/BrowseModel.pressed.connect(func(): browse_path("model_path"))
	$Page/Tabs/EngineSetup/SettingsScroll/Settings/BrowseServer.pressed.connect(func(): browse_path("server_path"))
	$Page/Tabs/EngineSetup/SettingsScroll/Settings/BrowseMmproj.pressed.connect(func(): browse_path("mmproj_path"))
	$Page/Tabs/EngineSetup/SettingsScroll/Settings/BrowseVisionModel.pressed.connect(func(): browse_path("vision_model_path"))
	$Page/Tabs/EngineSetup/SettingsScroll/Settings/BrowseVisionMmproj.pressed.connect(func(): browse_path("vision_mmproj_path"))
	$Page/Tabs/EngineSetup/SettingsScroll/Settings/BrowseMemory.pressed.connect(func(): browse_path("memory_path"))
	$Page/Tabs/EngineSetup/SettingsScroll/Settings/BrowseBackground.pressed.connect(func(): browse_path("background_path"))
	setup_modules_tab()
	setup_chat_workspace()
	setup_attachment_card()
	setup_context_help_buttons()
	setup_stats_tab()
	setup_about_tab()
	setup_voice_system()
	load_background()
	input_box.placeholder_text = "Type your message to Sam here…  Enter sends • Shift+Enter adds a new line • ↑/↓ recalls"
	input_box.editable = true
	refresh_system_specs()

func setup_modules_tab() -> void:
	var tabs: TabContainer = $Page/Tabs
	if tabs.has_node("Modules"):
		return
	var module_tab := VBoxContainer.new()
	module_tab.name = "Modules"
	module_tab.add_theme_constant_override("separation", 8)
	tabs.add_child(module_tab)
	tabs.move_child(module_tab, 2)
	var heading := Label.new()
	heading.text = "LOCAL AI MODULES"
	heading.add_theme_font_size_override("font_size", 22)
	heading.add_theme_color_override("font_color", colors.cyan)
	module_tab.add_child(heading)
	var hint := Label.new()
	hint.text = "Download standard GGUF models or load any compatible GGUF you already own. Models stay outside SAM-AI and are never bundled into the app."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_color_override("font_color", colors.muted)
	module_tab.add_child(hint)
	var top_actions := HBoxContainer.new()
	top_actions.name = "ModuleSetupActions"
	top_actions.add_theme_constant_override("separation", 8)
	module_tab.add_child(top_actions)
	var setup_button: Button = $Page/Tabs/EngineSetup/EngineActions/SetupCheck
	setup_button.text = "✓ RUN MODULE SETUP CHECK"
	setup_button.tooltip_text = "Check the selected GGUF, llama-server, Windows runtime, CUDA files, model shards, vision projector, and optional voice modules"
	setup_button.reparent(top_actions)
	module_requirement_banner = Label.new()
	module_requirement_banner.name = "ModuleRequirementsBanner"
	module_requirement_banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	module_requirement_banner.add_theme_font_size_override("font_size", 18)
	module_tab.add_child(module_requirement_banner)
	module_scroll = ScrollContainer.new()
	module_scroll.name = "ModuleScroll"
	module_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	module_tab.add_child(module_scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	module_scroll.add_child(content)
	var paths_heading := Label.new()
	paths_heading.text = "INSTALLED MODULES + RUNTIME"
	paths_heading.add_theme_color_override("font_color", colors.green)
	content.add_child(paths_heading)
	var module_grid := GridContainer.new()
	module_grid.columns = 3
	module_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	module_grid.add_theme_constant_override("h_separation", 10)
	module_grid.add_theme_constant_override("v_separation", 7)
	content.add_child(module_grid)
	var old_grid: GridContainer = $Page/Tabs/EngineSetup/SettingsScroll/Settings
	var module_controls := ["ModelLabel", "ModelPath", "BrowseModel", "ServerLabel", "ServerPath", "BrowseServer",
		"MmprojLabel", "MmprojPath", "BrowseMmproj", "VisionModelLabel", "VisionModelPath", "BrowseVisionModel",
		"VisionMmprojLabel", "VisionMmprojPath", "BrowseVisionMmproj", "GpuLabel", "GpuLayers", "GpuSpacer",
		"ContextLabel", "ContextSize", "ContextSpacer"]
	for node_name in module_controls:
		if old_grid.has_node(node_name):
			old_grid.get_node(node_name).reparent(module_grid)
	var engine_tab: VBoxContainer = $Page/Tabs/EngineSetup
	var note: Label = engine_tab.get_node("EngineNote")
	note.reparent(content)
	var auto_vision: CheckButton = engine_tab.get_node("AutoVisionSwitch")
	auto_vision.reparent(content)
	var module_actions := HBoxContainer.new()
	module_actions.name = "ModuleActions"
	module_actions.add_theme_constant_override("separation", 6)
	content.add_child(module_actions)
	var old_actions: HBoxContainer = engine_tab.get_node("EngineActions")
	for action_name in ["UseQwenCoder", "UseQwenVision", "SaveRestart", "StopEngine"]:
		if old_actions.has_node(action_name):
			old_actions.get_node(action_name).reparent(module_actions)
	var catalog_heading := Label.new()
	var runtime_heading := Label.new()
	runtime_heading.text = "LLAMA.CPP WINDOWS RUNTIME"
	runtime_heading.add_theme_font_size_override("font_size", 20)
	runtime_heading.add_theme_color_override("font_color", colors.cyan)
	content.add_child(runtime_heading)
	var runtime_note := Label.new()
	runtime_note.text = "SAM-AI needs llama-server.exe. CPU works without a supported GPU but is slower. NVIDIA users should choose Windows x64 CUDA 12 and also download the matching CUDA runtime DLL archive shown on the same official release. Extract both archives into the same folder."
	runtime_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	runtime_note.add_theme_color_override("font_color", colors.muted)
	content.add_child(runtime_note)
	add_runtime_download_row(content, "CPU-ONLY • UNIVERSAL FALLBACK", "module_url_llama_cpu", LLAMA_CPU_WINDOWS_URL, "Direct Windows x64 CPU package • no supported GPU required", "DOWNLOAD WINDOWS CPU")
	add_runtime_download_row(content, "NVIDIA CUDA • FAST GPU (1 OF 2)", "module_url_llama_cuda", LLAMA_CUDA_WINDOWS_URL, "Direct Windows x64 CUDA 12.4 engine package", "DOWNLOAD CUDA ENGINE")
	add_runtime_download_row(content, "NVIDIA CUDA DLLS (2 OF 2)", "module_url_llama_cudart", LLAMA_CUDART_WINDOWS_URL, "Required companion CUDA 12.4 DLL package • extract into the same folder", "DOWNLOAD CUDA DLLS")
	var browse_runtime := make_button("LOAD LLAMA-SERVER.EXE", func(): browse_path("server_path"), colors.green)
	content.add_child(browse_runtime)
	var voice_heading := Label.new()
	voice_heading.text = "VOICE + MICROPHONE MODULES (OPTIONAL)"
	voice_heading.add_theme_font_size_override("font_size", 20)
	voice_heading.add_theme_color_override("font_color", colors.cyan)
	content.add_child(voice_heading)
	var voice_note := Label.new()
	voice_note.text = "Kokoro reads Sam's replies aloud. Whisper converts microphone speech to text. Download both Kokoro files for speech output and both Whisper files for speech input. Voice setup remains optional and never prevents text chat."
	voice_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	voice_note.add_theme_color_override("font_color", colors.muted)
	content.add_child(voice_note)
	var voice_paths := GridContainer.new()
	voice_paths.columns = 3
	voice_paths.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(voice_paths)
	add_voice_module_path(voice_paths, "PYTHON RUNTIME", "voice_python_path", "Select python.exe containing kokoro-onnx", "*.exe", "Python executable")
	add_voice_module_path(voice_paths, "KOKORO MODEL", "kokoro_model_path", "Select the downloaded kokoro-v1.0.onnx", "*.onnx", "Kokoro ONNX model")
	add_voice_module_path(voice_paths, "KOKORO VOICES", "kokoro_voices_path", "Select the downloaded voices-v1.0.bin", "*.bin", "Kokoro voice library")
	add_voice_module_path(voice_paths, "WHISPER PROGRAM", "whisper_exe_path", "Select whisper-cli.exe from the extracted ZIP", "*.exe", "Whisper executable")
	add_voice_module_path(voice_paths, "WHISPER MODEL", "whisper_model_path", "Select ggml-base.en-q5_1.bin", "*.bin", "Whisper model")
	add_runtime_download_row(content, "KOKORO TEXT-TO-SPEECH (1 OF 2)", "module_url_kokoro_model", KOKORO_MODEL_URL, "Official Kokoro v1.0 ONNX voice model • about 310 MB", "DOWNLOAD KOKORO")
	add_runtime_download_row(content, "KOKORO VOICE LIBRARY (2 OF 2)", "module_url_kokoro_voices", KOKORO_VOICES_URL, "Required voice embeddings including Heart • about 27 MB", "DOWNLOAD VOICES")
	add_runtime_download_row(content, "WHISPER SPEECH-TO-TEXT (1 OF 2)", "module_url_whisper_windows", WHISPER_WINDOWS_URL, "Official Windows x64 whisper.cpp runtime", "DOWNLOAD WHISPER")
	add_runtime_download_row(content, "WHISPER ENGLISH MODEL (2 OF 2)", "module_url_whisper_model", WHISPER_MODEL_URL, "Base English Q5 model • about 57 MB", "DOWNLOAD STT MODEL")
	content.add_child(make_button("SAVE VOICE MODULE PATHS", save_voice_module_paths, colors.green))
	catalog_heading.text = "RECOMMENDED STARTER MODELS"
	catalog_heading.add_theme_font_size_override("font_size", 20)
	catalog_heading.add_theme_color_override("font_color", colors.cyan)
	content.add_child(catalog_heading)
	var catalog_note := Label.new()
	catalog_note.text = "Q4_K_M is the balanced choice. Downloading opens the official file in your browser; afterward use LOAD AS PRIMARY or LOAD AS VISION to select it. Vision also requires its matching MMPROJ."
	catalog_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	catalog_note.add_theme_color_override("font_color", colors.muted)
	content.add_child(catalog_note)
	add_module_catalog_card(content, "QWEN 2.5 CODER 3B • LIGHTWEIGHT", "About 2.1 GB • good starter for lower-end PCs and roughly 4–6 GB available RAM/VRAM.", "module_url_coder_3b", "https://huggingface.co/Qwen/Qwen2.5-Coder-3B-Instruct-GGUF/resolve/main/qwen2.5-coder-3b-instruct-q4_k_m.gguf?download=true", "https://huggingface.co/Qwen/Qwen2.5-Coder-3B-Instruct-GGUF", false)
	add_module_catalog_card(content, "QWEN 2.5 CODER 7B • BALANCED", "About 4.7 GB • stronger coding for midrange PCs; recommended when 8 GB or more memory is available.", "module_url_coder_7b", "https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct-GGUF/resolve/main/qwen2.5-coder-7b-instruct-q4_k_m.gguf?download=true", "https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct-GGUF", false)
	add_module_catalog_card(content, "QWEN 2.5 CODER 14B • CURRENT HIGH QUALITY", "About 9 GB split into two GGUF shards • best coding option here for the RTX 3060 12 GB; both files must share one folder.", "module_url_coder_14b", "https://huggingface.co/Qwen/Qwen2.5-Coder-14B-Instruct-GGUF/tree/main", "https://huggingface.co/Qwen/Qwen2.5-Coder-14B-Instruct-GGUF", false)
	add_module_catalog_card(content, "QWEN 2.5 VL 7B • IMAGE UNDERSTANDING", "About 4.7 GB plus an 853 MB matching MMPROJ • use as the vision model, not the primary coder.", "module_url_vision_7b", "https://huggingface.co/ggml-org/Qwen2.5-VL-7B-Instruct-GGUF/resolve/main/Qwen2.5-VL-7B-Instruct-Q4_K_M.gguf?download=true", "https://huggingface.co/ggml-org/Qwen2.5-VL-7B-Instruct-GGUF", true)
	var projector_row := HBoxContainer.new()
	projector_row.add_theme_constant_override("separation", 6)
	content.add_child(projector_row)
	var projector_label := Label.new()
	projector_label.text = "Qwen Vision matching projector (required for images)"
	projector_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	projector_row.add_child(projector_label)
	var projector_url := LineEdit.new()
	projector_url.text = str(settings.module_url_vision_mmproj)
	projector_url.placeholder_text = "Paste replacement MMPROJ download URL"
	projector_url.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	projector_row.add_child(projector_url)
	projector_row.add_child(make_button("SAVE LINK", func(): save_module_link("module_url_vision_mmproj", projector_url.text), colors.muted))
	projector_row.add_child(make_button("DOWNLOAD MMPROJ", func(): open_module_download(projector_url.text), colors.cyan))
	projector_row.add_child(make_button("LOAD MMPROJ", func(): browse_path("vision_mmproj_path"), colors.green))
	add_tab_help_button(module_actions, "Modules", "Explain primary GGUF models, vision GGUF and MMPROJ pairs, llama-server, GPU layers, context size, model sizes, and how to choose a suitable local model for this computer.")

func add_runtime_download_row(parent: VBoxContainer, title: String, link_key: String, official_url: String, instructions: String, download_label: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 7)
	parent.add_child(row)
	var label := Label.new()
	label.text = title + "\n" + instructions
	label.custom_minimum_size.x = 390
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(label)
	var link_edit := LineEdit.new()
	var saved_url := str(settings.get(link_key, official_url))
	# Migrate the former ambiguous release-page link to a direct Windows package.
	if saved_url == "https://github.com/ggml-org/llama.cpp/releases/latest":
		saved_url = official_url
		settings[link_key] = official_url
	link_edit.text = saved_url
	link_edit.placeholder_text = "Official or replacement llama.cpp download link"
	link_edit.custom_minimum_size.x = 280
	link_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(link_edit)
	row.add_child(make_button("SAVE LINK", func(): save_module_link(link_key, link_edit.text), colors.muted))
	row.add_child(make_button("RESTORE", func(): link_edit.text = official_url; save_module_link(link_key, official_url), colors.muted))
	row.add_child(make_button(download_label, func(): open_module_download(link_edit.text), colors.cyan))

func add_voice_module_path(parent: GridContainer, title: String, key: String, placeholder: String, pattern: String, description: String) -> void:
	var label := Label.new()
	label.text = title
	parent.add_child(label)
	var path_field := LineEdit.new()
	path_field.text = str(settings.get(key, ""))
	path_field.placeholder_text = placeholder
	path_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(path_field)
	fields[key] = path_field
	parent.add_child(make_button("BROWSE", func(): browse_voice_module(key, pattern, description), colors.cyan))

func browse_voice_module(key: String, pattern: String, description: String) -> void:
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.add_filter(pattern, description)
	dialog.file_selected.connect(func(path: String):
		fields[key].text = path
		settings[key] = path
		save_json(SETTINGS_FILE, settings)
		show_toast("Voice module selected • %s" % path.get_file())
		dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered_ratio(0.75)

func save_voice_module_paths() -> void:
	for key in ["voice_python_path", "kokoro_model_path", "kokoro_voices_path", "whisper_exe_path", "whisper_model_path"]:
		settings[key] = fields[key].text.strip_edges()
	save_json(SETTINGS_FILE, settings)
	stop_voice_daemon()
	start_voice_daemon()
	show_toast("Voice module paths saved")

func stop_voice_daemon() -> void:
	if voice_daemon_pid > 0 and OS.is_process_running(voice_daemon_pid):
		OS.kill(voice_daemon_pid)
	voice_daemon_pid = -1
	voice_daemon_announced = false

func add_module_catalog_card(parent: VBoxContainer, title: String, description: String, link_key: String, official_url: String, page_url: String, vision: bool) -> void:
	var panel := PanelContainer.new()
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("101a29")
	panel_style.border_color = colors.line
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", panel_style)
	parent.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 9)
	margin.add_theme_constant_override("margin_bottom", 9)
	panel.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	margin.add_child(row)
	var copy := VBoxContainer.new()
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(copy)
	var model_title := Label.new()
	model_title.text = title
	model_title.add_theme_color_override("font_color", colors.green if not vision else colors.cyan)
	copy.add_child(model_title)
	var details := Label.new()
	details.text = description
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.add_theme_color_override("font_color", colors.muted)
	copy.add_child(details)
	var link_edit := LineEdit.new()
	link_edit.text = str(settings.get(link_key, official_url))
	link_edit.placeholder_text = "Paste replacement download URL"
	link_edit.custom_minimum_size.x = 250
	link_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_child(link_edit)
	var link_actions := HBoxContainer.new()
	copy.add_child(link_actions)
	link_actions.add_child(make_button("SAVE LINK", func(): save_module_link(link_key, link_edit.text), colors.muted))
	link_actions.add_child(make_button("RESTORE OFFICIAL", func(): link_edit.text = official_url; save_module_link(link_key, official_url), colors.muted))
	row.add_child(make_button("DOWNLOAD", func(): open_module_download(link_edit.text), colors.cyan))
	row.add_child(make_button("MODEL PAGE", func(): open_web_url(page_url), colors.muted))
	row.add_child(make_button("LOAD AS VISION" if vision else "LOAD AS PRIMARY", func(): browse_path("vision_model_path" if vision else "model_path"), colors.green))

func save_module_link(key: String, url: String) -> void:
	var clean_url := url.strip_edges()
	if not clean_url.begins_with("https://") and not clean_url.begins_with("http://"):
		show_toast("Module link must begin with https:// or http://")
		return
	settings[key] = clean_url
	save_json(SETTINGS_FILE, settings)
	show_toast("Module download link saved")

func open_module_download(url: String) -> void:
	var clean_url := url.strip_edges()
	if not clean_url.begins_with("https://") and not clean_url.begins_with("http://"):
		show_toast("Enter and save a valid module download link first")
		return
	open_web_url(clean_url)

func open_web_url(url: String) -> void:
	# Fresh Windows Sandbox installations can have Edge present without a registered
	# HTTPS protocol handler. OS.shell_open() can falsely report success while Windows
	# displays a "We can't open this https link" dialog, so bypass it on Windows.
	var browser_candidates := PackedStringArray([
		"C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe",
		"C:/Program Files/Microsoft/Edge/Application/msedge.exe",
		"C:/Program Files/Google/Chrome/Application/chrome.exe",
		"C:/Program Files (x86)/Google/Chrome/Application/chrome.exe"
	])
	if OS.get_name() == "Windows":
		for browser_path in browser_candidates:
			if FileAccess.file_exists(browser_path):
				var browser_pid := OS.create_process(browser_path, PackedStringArray([url]))
				if browser_pid > 0:
					show_toast("Opening download in browser")
					return
	else:
		var open_error := OS.shell_open(url)
		if open_error == OK:
			return
	DisplayServer.clipboard_set(url)
	show_toast("No web browser is configured • link copied to clipboard")

func setup_chat_workspace() -> void:
	chat_log.scroll_following = false
	chat_log.selection_enabled = true
	chat_log.deselect_on_focus_loss_enabled = false
	var chat_page: VBoxContainer = $Page/Tabs/Chat
	var composer: VBoxContainer = input_box.get_parent()
	var toolbar := HBoxContainer.new()
	toolbar.name = "ChatNavigation"
	toolbar.add_theme_constant_override("separation", 6)
	chat_page.add_child(toolbar)
	chat_page.move_child(toolbar, chat_log.get_index())
	var find_button := make_button("⌕ FIND", show_chat_search, colors.cyan)
	find_button.tooltip_text = "Search this chat (Ctrl+F)"
	toolbar.add_child(find_button)
	toolbar.add_child(make_button("⇤ TOP", jump_chat_top, colors.muted))
	toolbar.add_child(make_button("⇥ LATEST", jump_chat_bottom, colors.muted))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_child(spacer)
	chat_search_status = Label.new()
	chat_search_status.add_theme_color_override("font_color", colors.muted)
	toolbar.add_child(chat_search_status)
	chat_search_bar = HBoxContainer.new()
	chat_search_bar.name = "ChatSearch"
	chat_search_bar.visible = false
	chat_search_bar.add_theme_constant_override("separation", 6)
	chat_page.add_child(chat_search_bar)
	chat_page.move_child(chat_search_bar, toolbar.get_index() + 1)
	chat_search_input = LineEdit.new()
	chat_search_input.placeholder_text = "Search conversation…"
	chat_search_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chat_search_input.text_submitted.connect(func(_value: String): find_chat_next())
	chat_search_input.text_changed.connect(func(_value: String): find_chat_first())
	chat_search_bar.add_child(chat_search_input)
	chat_search_bar.add_child(make_button("↑ PREVIOUS", find_chat_previous, colors.cyan))
	chat_search_bar.add_child(make_button("↓ NEXT", find_chat_next, colors.cyan))
	chat_search_bar.add_child(make_button("✕", hide_chat_search, colors.pink))
	var split := VSplitContainer.new()
	split.name = "ChatWorkspaceSplit"
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.split_offset = 430
	chat_page.add_child(split)
	chat_page.move_child(split, chat_search_bar.get_index() + 1)
	chat_log.reparent(split)
	composer.reparent(split)
	chat_log.custom_minimum_size.y = 180
	composer.custom_minimum_size.y = 150
	apply_theme_recursive(toolbar)
	apply_theme_recursive(chat_search_bar)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.keycode == KEY_F:
		show_chat_search()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and is_instance_valid(chat_search_bar) and chat_search_bar.visible:
		hide_chat_search()
		get_viewport().set_input_as_handled()

func show_chat_search() -> void:
	chat_search_bar.visible = true
	chat_search_input.grab_focus()
	chat_search_input.select_all()

func hide_chat_search() -> void:
	chat_search_bar.visible = false
	chat_log.deselect()
	chat_search_matches.clear()
	chat_search_match_index = -1
	chat_search_status.text = ""
	input_box.grab_focus()

func find_chat_first() -> void:
	refresh_chat_search_matches()
	if chat_search_matches.is_empty():
		chat_log.deselect()
		chat_search_status.text = "" if chat_search_input.text.is_empty() else "NO MATCH"
		return
	show_chat_search_match(0)

func find_chat_next() -> void:
	if chat_search_input.text.is_empty():
		return
	if chat_search_matches.is_empty():
		refresh_chat_search_matches()
	if chat_search_matches.is_empty():
		chat_search_status.text = "NO MATCH"
		return
	show_chat_search_match((chat_search_match_index + 1) % chat_search_matches.size())

func find_chat_previous() -> void:
	if chat_search_input.text.is_empty():
		return
	if chat_search_matches.is_empty():
		refresh_chat_search_matches()
	if chat_search_matches.is_empty():
		chat_search_status.text = "NO MATCH"
		return
	show_chat_search_match(posmod(chat_search_match_index - 1, chat_search_matches.size()))

func refresh_chat_search_matches() -> void:
	chat_search_matches.clear()
	chat_search_match_index = -1
	var query := chat_search_input.text.strip_edges()
	if query.is_empty():
		return
	var searchable_text := chat_log.get_parsed_text().to_lower()
	var searchable_query := query.to_lower()
	var search_from := 0
	while search_from < searchable_text.length():
		var found_at := searchable_text.find(searchable_query, search_from)
		if found_at < 0:
			break
		chat_search_matches.append(found_at)
		search_from = found_at + maxi(1, searchable_query.length())

func show_chat_search_match(index: int) -> void:
	if chat_search_matches.is_empty():
		chat_log.deselect()
		chat_search_status.text = "NO MATCH"
		return
	chat_search_match_index = clampi(index, 0, chat_search_matches.size() - 1)
	var match_start: int = chat_search_matches[chat_search_match_index]
	var match_end := match_start + chat_search_input.text.strip_edges().length()
	chat_log.select(match_start, match_end)
	var match_line := chat_log.get_character_line(match_start)
	chat_log.scroll_to_line(maxi(0, match_line - 2))
	force_chat_follow = false
	chat_search_status.text = "%d / %d MATCHES" % [chat_search_match_index + 1, chat_search_matches.size()]

func jump_chat_top() -> void:
	chat_log.scroll_to_line(0)

func jump_chat_bottom() -> void:
	force_chat_follow = true
	chat_log.scroll_to_line(chat_log.get_line_count())
	call_deferred("force_chat_to_live_edge")

func force_chat_to_live_edge() -> void:
	# RichTextLabel calculates its final scroll range after layout. Waiting for two
	# frames prevents startup/send jumps from landing above the actual last line.
	await get_tree().process_frame
	await get_tree().process_frame
	if is_instance_valid(chat_log) and force_chat_follow:
		chat_log.scroll_to_line(chat_log.get_line_count())
		var bar := chat_log.get_v_scroll_bar()
		bar.value = bar.max_value

func _on_chat_log_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			force_chat_follow = false
	elif event is InputEventKey and event.pressed:
		if event.keycode in [KEY_UP, KEY_PAGEUP, KEY_HOME]:
			force_chat_follow = false

func chat_is_near_bottom() -> bool:
	var bar := chat_log.get_v_scroll_bar()
	return bar.value >= bar.max_value - bar.page - 24.0

func setup_attachment_card() -> void:
	var composer: VBoxContainer = input_box.get_parent()
	attachment_tools = HBoxContainer.new()
	attachment_tools.visible = false
	attachment_tools.add_theme_constant_override("separation", 6)
	composer.add_child(attachment_tools)
	composer.move_child(attachment_tools, attachment_preview.get_index() + 1)
	var attachment_title := Label.new()
	attachment_title.text = "ATTACHMENT PREVIEW"
	attachment_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	attachment_title.add_theme_color_override("font_color", colors.muted)
	attachment_tools.add_child(attachment_title)
	attachment_tools.add_child(make_button("↗ OPEN / VIEW", open_current_attachment, colors.cyan))
	attachment_tools.add_child(make_button("✕ REMOVE", remove_current_attachment, colors.pink))
	attachment_snippet = RichTextLabel.new()
	attachment_snippet.bbcode_enabled = true
	attachment_snippet.fit_content = false
	attachment_snippet.custom_minimum_size = Vector2(0, 96)
	attachment_snippet.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	attachment_snippet.scroll_active = true
	attachment_snippet.scroll_following = false
	attachment_snippet.visible = false
	composer.add_child(attachment_snippet)
	composer.move_child(attachment_snippet, attachment_tools.get_index() + 1)
	apply_theme_recursive(attachment_tools)
	apply_theme_recursive(attachment_snippet)

func open_current_attachment() -> void:
	var path := attached_image_path if not attached_image_path.is_empty() else attached_file_path
	if path.is_empty():
		return
	OS.shell_open(ProjectSettings.globalize_path(path))

func remove_current_attachment() -> void:
	clear_attachment()
	show_toast("Attachment removed")

func attachment_excerpt(value: String, max_lines := 7, max_chars := 700) -> String:
	var lines := value.split("\n")
	var excerpt := ""
	for index in range(mini(lines.size(), max_lines)):
		excerpt += str(lines[index]) + ("\n" if index < mini(lines.size(), max_lines) - 1 else "")
	if excerpt.length() > max_chars:
		excerpt = excerpt.left(max_chars)
	if lines.size() > max_lines or value.length() > excerpt.length():
		excerpt += "\n… Preview truncated — use OPEN / VIEW for the complete attachment."
	return excerpt

func show_startup_screen() -> void:
	startup_screen = STARTUP_SCENE.instantiate()
	# Below the first-run setup (z=50), but above the regular application.
	startup_screen.z_index = 40
	add_child(startup_screen)
	startup_shown_msec = Time.get_ticks_msec()
	var safe_area: Control = startup_screen.get_node("Artwork/OverlayRoot/StatusSafeArea")
	var panel := PanelContainer.new()
	panel.name = "LiveStartupStatus"
	panel.visible = false
	startup_status_panel = panel
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 28)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.06, 0.105, 0.94)
	panel_style.border_color = colors.cyan
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(14)
	panel_style.shadow_color = Color(0, 0.8, 1, 0.24)
	panel_style.shadow_size = 18
	panel.add_theme_stylebox_override("panel", panel_style)
	safe_area.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 14)
	margin.add_child(stack)
	var logo := Label.new()
	logo.text = "SAM-AI  //  LOCAL INTELLIGENCE BOOT"
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logo.add_theme_color_override("font_color", colors.cyan)
	logo.add_theme_font_size_override("font_size", 20)
	stack.add_child(logo)
	startup_message = Label.new()
	startup_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	startup_message.add_theme_color_override("font_color", colors.text)
	startup_message.add_theme_font_size_override("font_size", 24)
	stack.add_child(startup_message)
	startup_detail = Label.new()
	startup_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	startup_detail.add_theme_color_override("font_color", colors.muted)
	stack.add_child(startup_detail)
	startup_progress = ProgressBar.new()
	startup_progress.custom_minimum_size = Vector2(0, 22)
	startup_progress.show_percentage = false
	startup_progress.min_value = 0
	startup_progress.max_value = 100
	stack.add_child(startup_progress)
	var percent := Label.new()
	percent.name = "Percent"
	percent.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	percent.add_theme_color_override("font_color", colors.green)
	stack.add_child(percent)
	# Avoid an infinite Tween here. The startup panel may be freed as soon as the
	# engine becomes ready, and a looping Tween targeting a freed control can spin
	# with zero-duration steps in Godot 4.6.
	panel.modulate.a = 1.0

func set_startup_progress(percent: float, message: String, detail: String = "") -> void:
	if not is_instance_valid(startup_screen):
		return
	startup_progress.value = clampf(percent, 0.0, 100.0)
	startup_message.text = message
	startup_detail.text = detail
	var percent_label: Label = startup_progress.get_parent().get_node("Percent")
	percent_label.text = "%03d%%  %s" % [int(startup_progress.value), "▰".repeat(int(startup_progress.value / 5.0)) + "▱".repeat(20 - int(startup_progress.value / 5.0))]

func show_model_switch_overlay() -> void:
	if is_instance_valid(startup_screen):
		return
	var overlay := ColorRect.new()
	overlay.name = "ModelSwitchOverlay"
	overlay.z_index = 40
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.color = Color(0.005, 0.012, 0.025, 0.58)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	startup_screen = overlay
	startup_shown_msec = Time.get_ticks_msec()
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 255)
	startup_status_panel = panel
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.06, 0.105, 0.98)
	panel_style.border_color = colors.cyan
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(14)
	panel_style.shadow_color = Color(0, 0.8, 1, 0.30)
	panel_style.shadow_size = 22
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_top", 26)
	margin.add_theme_constant_override("margin_bottom", 26)
	panel.add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 14)
	margin.add_child(stack)
	var logo := Label.new()
	logo.text = "SAM-AI  //  MODULE HANDOFF"
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logo.add_theme_color_override("font_color", colors.cyan)
	logo.add_theme_font_size_override("font_size", 20)
	stack.add_child(logo)
	startup_message = Label.new()
	startup_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	startup_message.add_theme_color_override("font_color", colors.text)
	startup_message.add_theme_font_size_override("font_size", 24)
	stack.add_child(startup_message)
	startup_detail = Label.new()
	startup_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	startup_detail.add_theme_color_override("font_color", colors.muted)
	stack.add_child(startup_detail)
	startup_progress = ProgressBar.new()
	startup_progress.custom_minimum_size = Vector2(0, 22)
	startup_progress.show_percentage = false
	stack.add_child(startup_progress)
	var percent := Label.new()
	percent.name = "Percent"
	percent.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	percent.add_theme_color_override("font_color", colors.green)
	stack.add_child(percent)
	set_startup_progress(4.0, "SWITCHING TO VISION MODULE", "Keeping the interface responsive while the image model loads")

func finish_startup() -> void:
	set_startup_progress(100.0, "SAM-AI READY", "Model online • memory loaded • voice systems checked")
	var shown_seconds := (Time.get_ticks_msec() - startup_shown_msec) / 1000.0
	var remaining_minimum := maxf(0.45, 3.0 - shown_seconds)
	await get_tree().create_timer(remaining_minimum).timeout
	if is_instance_valid(startup_screen):
		if startup_screen.has_method("dismiss"):
			startup_screen.dismiss(0.45)
		else:
			var overlay_to_close := startup_screen
			var fade := create_tween()
			fade.tween_property(overlay_to_close, "modulate:a", 0.0, 0.25)
			fade.tween_callback(overlay_to_close.queue_free)
	startup_screen = null
	input_box.call_deferred("grab_focus")

func begin_startup() -> void:
	var intro_completed := bool(ProjectSettings.get_setting("sam_ai/intro_completed", false))
	if intro_completed:
		ProjectSettings.set_setting("sam_ai/intro_completed", false)
	else:
		# Editor runs that start main.tscn directly still get the complete intro.
		await get_tree().create_timer(5.0).timeout
		if is_instance_valid(startup_screen):
			await startup_screen.transition_to_loading(0.65)
		if is_instance_valid(startup_status_panel):
			startup_status_panel.modulate.a = 0.0
			startup_status_panel.visible = true
			var panel_fade := create_tween()
			panel_fade.tween_property(startup_status_panel, "modulate:a", 1.0, 0.35)
	set_startup_progress(0.0, "BEGINNING LOCAL STARTUP", "Preparing module checks")
	await get_tree().create_timer(0.65).timeout
	set_startup_progress(10.0, "CHECKING LOCAL MODULES", "Finding llama.cpp, CUDA libraries, voice engines, and model files")
	await get_tree().create_timer(0.55).timeout
	discover_portable_components()
	set_startup_progress(20.0, "RESTORING SETTINGS", "Applying local model, CUDA, context, and voice preferences")
	await get_tree().create_timer(0.55).timeout
	for key in fields:
		fields[key].text = setting_text(key)
	if not FileAccess.file_exists(FIRST_RUN_FILE):
		show_first_run_setup()
	else:
		set_startup_progress(28.0, "LOADING MEMORYCORE", "Reading the live system prompt and saved knowledge")
		await get_tree().create_timer(0.55).timeout
		start_engine()

func discover_portable_components() -> void:
	var portable_root := OS.get_executable_path().get_base_dir()
	var portable_server := portable_root.path_join("engine/llama-server.exe")
	if FileAccess.file_exists(portable_server):
		settings.server_path = portable_server
	var models_dir := portable_root.path_join("models")
	if DirAccess.dir_exists_absolute(models_dir):
		var directory := DirAccess.open(models_dir)
		if directory:
			for filename in directory.get_files():
				if filename.to_lower().ends_with(".gguf") and not filename.to_lower().contains("mmproj"):
					settings.model_path = models_dir.path_join(filename)
					break

func show_first_run_setup() -> void:
	setup_model_path.text = str(settings.model_path) if FileAccess.file_exists(str(settings.model_path)) else ""
	setup_server_path.text = str(settings.server_path) if FileAccess.file_exists(str(settings.server_path)) else ""
	# Do not show development-machine defaults as if they existed on a new PC.
	fields.model_path.text = setup_model_path.text
	fields.server_path.text = setup_server_path.text
	# The animated startup scene remains visible behind first-run setup. It must not
	# consume clicks while the setup panel is active, especially through a remote
	# desktop surface such as Windows Sandbox.
	if is_instance_valid(startup_screen):
		startup_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	setup_overlay.visible = true
	setup_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	setup_overlay.z_index = 100
	setup_overlay.move_to_front()
	refresh_setup_checks()
	$FirstRunSetup/Center/Panel/Margin/Content/Actions/CheckAgain.call_deferred("grab_focus")

func close_first_run_to_modules() -> void:
	setup_overlay.visible = false
	if is_instance_valid(startup_screen):
		if startup_screen.has_method("dismiss"):
			startup_screen.dismiss(0.25)
		else:
			startup_screen.queue_free()
	startup_screen = null
	var tabs: TabContainer = $Page/Tabs
	for tab_index in range(tabs.get_tab_count()):
		if tabs.get_tab_title(tab_index).to_lower() == "modules":
			tabs.current_tab = tab_index
			break
	highlight_missing_module_requirements()
	if is_instance_valid(module_scroll):
		module_scroll.set_deferred("scroll_vertical", 0)
	set_status("SETUP REQUIRED • SELECT MODEL + ENGINE", colors.amber)
	show_toast("Setup paused • choose or download components in Modules")

func highlight_missing_module_requirements() -> void:
	var model_missing := not FileAccess.file_exists(str(fields.model_path.text).strip_edges())
	var server_missing := not FileAccess.file_exists(str(fields.server_path.text).strip_edges())
	var missing_names: Array[String] = []
	if model_missing:
		missing_names.append("a GGUF language model")
	if server_missing:
		missing_names.append("llama-server.exe")
	if is_instance_valid(module_requirement_banner):
		if missing_names.is_empty():
			module_requirement_banner.text = "✓ REQUIRED MODULES SELECTED • Run Module Setup Check to verify dependencies."
			module_requirement_banner.add_theme_color_override("font_color", colors.green)
		else:
			module_requirement_banner.text = "⚠ REQUIRED NEXT: Select or download %s. Highlighted fields must be completed before SAM can start." % ", and ".join(PackedStringArray(missing_names))
			module_requirement_banner.add_theme_color_override("font_color", colors.amber)
	apply_missing_requirement_style(fields.model_path, model_missing)
	apply_missing_requirement_style(fields.server_path, server_missing)
	var module_grid: Node = fields.model_path.get_parent()
	if module_grid.has_node("BrowseModel"):
		apply_missing_requirement_style(module_grid.get_node("BrowseModel"), model_missing)
	if module_grid.has_node("BrowseServer"):
		apply_missing_requirement_style(module_grid.get_node("BrowseServer"), server_missing)

func apply_missing_requirement_style(control: Control, missing: bool) -> void:
	if not missing:
		control.remove_theme_stylebox_override("normal")
		return
	var highlight := StyleBoxFlat.new()
	highlight.bg_color = Color(0.20, 0.11, 0.025, 0.96)
	highlight.border_color = colors.amber
	highlight.set_border_width_all(2)
	highlight.set_corner_radius_all(7)
	control.add_theme_stylebox_override("normal", highlight)

func browse_setup_path(model: bool) -> void:
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	if model:
		dialog.add_filter("*.gguf", "GGUF language models")
	else:
		dialog.add_filter("*.exe", "Windows llama.cpp engine")
	dialog.file_selected.connect(func(path: String):
		if model:
			setup_model_path.text = path
		else:
			setup_server_path.text = path
		refresh_setup_checks()
		dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered_ratio(0.75)

func refresh_setup_checks(show_feedback: bool = false) -> void:
	var model_ok := FileAccess.file_exists(setup_model_path.text.strip_edges())
	var server_ok := FileAccess.file_exists(setup_server_path.text.strip_edges())
	var server_dir := setup_server_path.text.strip_edges().get_base_dir()
	var cuda_ok := false
	if DirAccess.dir_exists_absolute(server_dir):
		var runtime_dir := DirAccess.open(server_dir)
		var found_cublas := false
		var found_cudart := false
		if runtime_dir:
			for filename in runtime_dir.get_files():
				var lower_name := filename.to_lower()
				found_cublas = found_cublas or (lower_name.begins_with("cublas64_") and lower_name.ends_with(".dll"))
				found_cudart = found_cudart or (lower_name.begins_with("cudart64_") and lower_name.ends_with(".dll"))
		cuda_ok = found_cublas and found_cudart
	var windows_runtime_ok := FileAccess.file_exists("C:/Windows/System32/vcruntime140.dll")
	var voice_ok := FileAccess.file_exists(str(settings.voice_python_path)) and FileAccess.file_exists(voice_runtime_script("voice_bridge.py")) and FileAccess.file_exists(str(settings.kokoro_model_path)) and FileAccess.file_exists(str(settings.kokoro_voices_path)) and FileAccess.file_exists(str(settings.whisper_exe_path)) and FileAccess.file_exists(str(settings.whisper_model_path))
	var model_path := setup_model_path.text.strip_edges()
	var shard_ok := true
	if model_path.to_lower().contains("-00001-of-00002.gguf"):
		shard_ok = FileAccess.file_exists(model_path.replace("-00001-of-00002.gguf", "-00002-of-00002.gguf"))
	var vision_configured := not str(settings.vision_model_path).is_empty() or not str(settings.vision_mmproj_path).is_empty()
	var vision_ok := not vision_configured or (FileAccess.file_exists(str(settings.vision_model_path)) and FileAccess.file_exists(str(settings.vision_mmproj_path)))
	setup_checks.clear()
	setup_checks.append_text("[color=%s]%s[/color]  GGUF language model\n" % ["#76f7a6" if model_ok else "#ff667d", "✓" if model_ok else "✕"])
	setup_checks.append_text("[color=%s]%s[/color]  llama.cpp Windows engine\n" % ["#76f7a6" if server_ok else "#ff667d", "✓" if server_ok else "✕"])
	setup_checks.append_text("[color=%s]%s[/color]  NVIDIA CUDA runtime beside engine\n" % ["#76f7a6" if cuda_ok else "#f9c74f", "✓" if cuda_ok else "!"])
	setup_checks.append_text("[color=%s]%s[/color]  Microsoft Visual C++ runtime\n" % ["#76f7a6" if windows_runtime_ok else "#ff667d", "✓" if windows_runtime_ok else "✕"])
	setup_checks.append_text("[color=%s]%s[/color]  Kokoro + Whisper voice package (optional)" % ["#76f7a6" if voice_ok else "#f9c74f", "✓" if voice_ok else "!"])
	setup_checks.append_text("\n[color=%s]%s[/color]  Split GGUF companion shards\n" % ["#76f7a6" if shard_ok else "#ff667d", "✓" if shard_ok else "✕"])
	setup_checks.append_text("[color=%s]%s[/color]  Vision model + matching MMPROJ (optional)" % ["#76f7a6" if vision_ok else "#f9c74f", "✓" if vision_ok else "!"])
	if show_feedback:
		var all_required_ok := model_ok and server_ok and windows_runtime_ok and shard_ok
		setup_checks.append_text("\n\n[center][color=%s][b]COMPONENT CHECK COMPLETE • %s[/b][/color][/center]" % ["#76f7a6" if all_required_ok else "#f9c74f", Time.get_time_string_from_system()])
		show_toast("Component check complete • ready" if all_required_ok else "Component check complete • review warnings")
		set_status("COMPONENT CHECK COMPLETE", colors.green if all_required_ok else colors.amber)
	$FirstRunSetup/Center/Panel/Margin/Content/Actions/Complete.disabled = not (model_ok and server_ok and windows_runtime_ok)
	$FirstRunSetup/Center/Panel/Margin/Content/Actions/WindowsRuntime.disabled = windows_runtime_ok
	$FirstRunSetup/Center/Panel/Margin/Content/Actions/WindowsRuntime.text = "WINDOWS RUNTIME INSTALLED" if windows_runtime_ok else "GET WINDOWS RUNTIME"

func open_windows_runtime_download() -> void:
	if is_instance_valid(windows_runtime_request):
		show_toast("Windows runtime download is already running")
		return
	var downloads_dir := OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	if downloads_dir.is_empty() or not DirAccess.dir_exists_absolute(downloads_dir):
		downloads_dir = OS.get_user_data_dir()
	windows_runtime_download_path = downloads_dir.path_join("vc_redist.x64.exe")
	windows_runtime_request = HTTPRequest.new()
	windows_runtime_request.name = "WindowsRuntimeDownload"
	windows_runtime_request.download_file = windows_runtime_download_path
	windows_runtime_request.max_redirects = 8
	windows_runtime_request.request_completed.connect(finish_windows_runtime_download)
	add_child(windows_runtime_request)
	var runtime_button: Button = $FirstRunSetup/Center/Panel/Margin/Content/Actions/WindowsRuntime
	runtime_button.disabled = true
	runtime_button.text = "DOWNLOADING RUNTIME…"
	setup_checks.append_text("\n\n[color=#4deeea]Downloading the official Microsoft Visual C++ runtime…[/color]")
	show_toast("Downloading Microsoft Visual C++ runtime")
	var request_error := windows_runtime_request.request("https://aka.ms/vs/17/release/vc_redist.x64.exe")
	if request_error != OK:
		fail_windows_runtime_download("Download could not start (error %d)" % request_error)

func finish_windows_runtime_download(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	var succeeded := result == HTTPRequest.RESULT_SUCCESS and response_code >= 200 and response_code < 300 and FileAccess.file_exists(windows_runtime_download_path)
	if is_instance_valid(windows_runtime_request):
		windows_runtime_request.queue_free()
	windows_runtime_request = null
	if not succeeded:
		fail_windows_runtime_download("Microsoft runtime download failed (HTTP %d, result %d)" % [response_code, result])
		return
	setup_checks.append_text("\n[color=#76f7a6]✓ Download complete. Opening the Microsoft installer…[/color]")
	show_toast("Runtime downloaded • opening installer")
	var open_error := OS.shell_open(windows_runtime_download_path)
	if open_error != OK:
		show_toast("Installer saved in Downloads • open vc_redist.x64.exe")
	var runtime_button: Button = $FirstRunSetup/Center/Panel/Margin/Content/Actions/WindowsRuntime
	runtime_button.disabled = false
	runtime_button.text = "CHECK AFTER INSTALL"

func fail_windows_runtime_download(message: String) -> void:
	if is_instance_valid(windows_runtime_request):
		windows_runtime_request.queue_free()
	windows_runtime_request = null
	setup_checks.append_text("\n[color=#ff667d]✕ %s[/color]" % message)
	show_toast(message)
	var runtime_button: Button = $FirstRunSetup/Center/Panel/Margin/Content/Actions/WindowsRuntime
	runtime_button.disabled = false
	runtime_button.text = "RETRY RUNTIME DOWNLOAD"

func complete_first_run() -> void:
	if not FileAccess.file_exists(setup_model_path.text.strip_edges()) or not FileAccess.file_exists(setup_server_path.text.strip_edges()):
		refresh_setup_checks()
		return
	settings.model_path = setup_model_path.text.strip_edges()
	settings.server_path = setup_server_path.text.strip_edges()
	save_json(SETTINGS_FILE, settings)
	save_json(FIRST_RUN_FILE, {"complete": true, "completed_at": Time.get_datetime_string_from_system()})
	for key in fields:
		fields[key].text = setting_text(key)
	setup_overlay.visible = false
	show_toast("Setup complete • starting SAM")
	start_engine()

func build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = colors.void
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	background_rect = TextureRect.new()
	background_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_rect.modulate = Color(1, 1, 1, 0.16)
	background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background_rect)
	load_background()
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 18)
	root.add_theme_constant_override("separation", 12)
	add_child(root)
	var header := HBoxContainer.new()
	header.custom_minimum_size.y = 62
	root.add_child(header)
	var brand := Label.new()
	brand.text = "  SAM//AI  LOCAL INTELLIGENCE CONSOLE"
	brand.add_theme_font_size_override("font_size", 22)
	brand.add_theme_color_override("font_color", colors.cyan)
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(brand)
	status_dot = Label.new()
	status_dot.text = "●"
	status_dot.add_theme_font_size_override("font_size", 20)
	status_dot.add_theme_color_override("font_color", colors.amber)
	header.add_child(status_dot)
	status_label = Label.new()
	status_label.text = " BOOTING ENGINE"
	status_label.add_theme_color_override("font_color", colors.muted)
	header.add_child(status_label)
	var tabs := TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(tabs)
	tabs.add_child(build_chat_tab())
	tabs.add_child(build_memory_tab())
	tabs.add_child(build_engine_tab())
	tabs.add_child(build_logs_tab())
	apply_theme_recursive(self)

func build_chat_tab() -> Control:
	var tab := VBoxContainer.new()
	tab.name = "CHAT"
	tab.add_theme_constant_override("separation", 10)
	chat_log = RichTextLabel.new()
	chat_log.bbcode_enabled = true
	chat_log.scroll_following = true
	chat_log.selection_enabled = true
	chat_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab.add_child(chat_log)
	redraw_history()
	var composer := HBoxContainer.new()
	composer.custom_minimum_size.y = 108
	composer.add_theme_constant_override("separation", 10)
	tab.add_child(composer)
	input_box = TextEdit.new()
	input_box.placeholder_text = "Message Sam...  Enter sends • Shift+Enter adds a line • ↑/↓ recalls"
	input_box.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	input_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input_box.gui_input.connect(_on_input_gui)
	composer.add_child(input_box)
	var actions := VBoxContainer.new()
	actions.custom_minimum_size.x = 150
	composer.add_child(actions)
	send_button = make_button("TRANSMIT", send_message, colors.cyan)
	actions.add_child(send_button)
	stop_button = make_button("ABORT", stop_generation, colors.pink)
	stop_button.disabled = true
	actions.add_child(stop_button)
	actions.add_child(make_button("📎 ATTACH", choose_attachment, colors.amber))
	actions.add_child(make_button("NEW SESSION", clear_session, colors.muted))
	attachment_label = Label.new()
	attachment_label.text = "No image attached"
	attachment_label.add_theme_color_override("font_color", colors.muted)
	tab.add_child(attachment_label)
	return tab

func build_memory_tab() -> Control:
	var tab := VBoxContainer.new()
	tab.name = "MEMORY CORE"
	var hint := Label.new()
	hint.text = "LIVE SYSTEM MEMORY  •  Reloaded from disk before every response"
	hint.add_theme_color_override("font_color", colors.amber)
	tab.add_child(hint)
	memory_editor = TextEdit.new()
	memory_editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	memory_editor.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	tab.add_child(memory_editor)
	var row := HBoxContainer.new()
	tab.add_child(row)
	row.add_child(make_button("SAVE MEMORY", save_memory, colors.cyan))
	row.add_child(make_button("RELOAD FROM DISK", load_memory_editor, colors.muted))
	return tab

func build_engine_tab() -> Control:
	var tab := VBoxContainer.new()
	tab.name = "ENGINE + SETUP"
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	tab.add_child(grid)
	add_setting_row(grid, "MODEL (.GGUF)", "model_path", true)
	add_setting_row(grid, "LLAMA SERVER", "server_path", true)
	add_setting_row(grid, "VISION MMPROJ (VLM ONLY)", "mmproj_path", true)
	add_setting_row(grid, "MEMORY FILE", "memory_path", true)
	add_setting_row(grid, "BACKGROUND IMAGE", "background_path", true)
	add_setting_row(grid, "PORT", "port")
	add_setting_row(grid, "GPU LAYERS", "gpu_layers")
	add_setting_row(grid, "CONTEXT", "context_size")
	add_setting_row(grid, "MAX TOKENS", "max_tokens")
	add_setting_row(grid, "TEMPERATURE", "temperature")
	var note := Label.new()
	note.text = "Godot owns the app; llama.cpp remains the private local CUDA engine. Settings persist per user."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_color_override("font_color", colors.muted)
	tab.add_child(note)
	var row := HBoxContainer.new()
	tab.add_child(row)
	row.add_child(make_button("SAVE + RELOAD ENGINE", save_and_restart, colors.cyan))
	row.add_child(make_button("STOP ENGINE", stop_engine, colors.pink))
	row.add_child(make_button("APPLY BACKGROUND", apply_background_setting, colors.amber))
	return tab

func build_logs_tab() -> Control:
	var tab := VBoxContainer.new()
	tab.name = "DEBUG TELEMETRY"
	logs = RichTextLabel.new()
	logs.bbcode_enabled = true
	logs.selection_enabled = true
	logs.scroll_following = true
	logs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab.add_child(logs)
	tab.add_child(make_button("CLEAR LOG", func(): logs.clear(), colors.muted))
	return tab

func add_setting_row(grid: GridContainer, title: String, key: String, browse := false) -> void:
	var label := Label.new()
	label.text = title
	label.add_theme_color_override("font_color", colors.cyan)
	grid.add_child(label)
	var edit := LineEdit.new()
	edit.text = str(settings[key])
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fields[key] = edit
	grid.add_child(edit)
	if browse:
		var button := Button.new()
		button.text = "BROWSE"
		button.pressed.connect(func(): browse_path(key))
		grid.add_child(button)
	else:
		grid.add_child(Control.new())

func make_button(text_value: String, callback: Callable, accent: Color) -> Button:
	var button := Button.new()
	button.text = text_value
	button.custom_minimum_size.y = 38
	button.add_theme_color_override("font_color", accent)
	button.pressed.connect(callback)
	return button

func apply_theme_recursive(node: Node) -> void:
	if node is Control:
		node.add_theme_font_size_override("font_size", 15)
		node.add_theme_color_override("font_color", colors.text)
	if node is TextEdit or node is LineEdit or node is RichTextLabel:
		var box := StyleBoxFlat.new()
		box.bg_color = Color(colors.panel.r, colors.panel.g, colors.panel.b, 0.72)
		box.border_color = colors.line
		box.set_border_width_all(1)
		box.set_corner_radius_all(6)
		box.content_margin_left = 14
		box.content_margin_right = 14
		box.content_margin_top = 12
		box.content_margin_bottom = 12
		node.add_theme_stylebox_override("normal", box)
	if node is Button:
		var normal := StyleBoxFlat.new()
		normal.bg_color = Color(0.06, 0.14, 0.20, 0.96)
		normal.border_color = colors.cyan
		normal.set_border_width_all(1)
		normal.set_corner_radius_all(5)
		normal.content_margin_left = 14
		normal.content_margin_right = 14
		normal.content_margin_top = 8
		normal.content_margin_bottom = 8
		var hover := normal.duplicate()
		hover.bg_color = Color(colors.cyan.r, colors.cyan.g, colors.cyan.b, 0.28)
		hover.set_border_width_all(2)
		var pressed := normal.duplicate()
		pressed.bg_color = Color(colors.cyan.r, colors.cyan.g, colors.cyan.b, 0.46)
		node.add_theme_stylebox_override("normal", normal)
		node.add_theme_stylebox_override("hover", hover)
		node.add_theme_stylebox_override("pressed", pressed)
		node.add_theme_color_override("font_color", colors.text)
		node.add_theme_color_override("font_hover_color", Color.WHITE)
	for child in node.get_children():
		apply_theme_recursive(child)

func _on_input_gui(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	if event.keycode == KEY_V and event.ctrl_pressed:
		if DisplayServer.clipboard_has_image():
			attach_clipboard_image()
			get_viewport().set_input_as_handled()
			return
		var clipboard_text := DisplayServer.clipboard_get()
		if clipboard_text.length() >= 6000:
			attach_large_paste(clipboard_text)
			get_viewport().set_input_as_handled()
			return
	if event.keycode == KEY_ENTER and not event.shift_pressed:
		send_message()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_UP and input_box.get_line_count() == 1:
		recall_message(-1)
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_DOWN and input_box.get_line_count() == 1:
		recall_message(1)
		get_viewport().set_input_as_handled()

func recall_message(direction: int) -> void:
	if sent_messages.is_empty():
		return
	if history_cursor < 0:
		history_draft = input_box.text
		history_cursor = sent_messages.size()
	history_cursor = clampi(history_cursor + direction, 0, sent_messages.size())
	input_box.text = history_draft if history_cursor == sent_messages.size() else sent_messages[history_cursor]
	var last_line := input_box.get_line_count() - 1
	input_box.set_caret_line(last_line)
	input_box.set_caret_column(input_box.get_line(last_line).length())

func start_engine() -> void:
	set_startup_progress(44.0, "STARTING LOCAL ENGINE", "Preparing llama.cpp and checking for stale processes")
	recover_orphaned_server()
	stop_engine()
	stop_stale_llama_servers()
	if not FileAccess.file_exists(str(settings.server_path)):
		set_status("SERVER FILE NOT FOUND", colors.red)
		log_line("ERROR", "Missing server: " + str(settings.server_path))
		set_startup_progress(0.0, "ENGINE MODULE NOT FOUND", "Open Setup Check and select llama-server.exe")
		return
	var active_model := str(settings.vision_model_path) if engine_mode == "vision" else str(settings.model_path)
	var active_mmproj := str(settings.vision_mmproj_path) if engine_mode == "vision" else str(settings.mmproj_path)
	if not FileAccess.file_exists(active_model):
		set_status("MODEL FILE NOT FOUND", colors.red)
		log_line("ERROR", "Missing model: " + active_model)
		set_startup_progress(0.0, "MODEL NOT FOUND", "Open Setup Check and select a GGUF model")
		return
	var args := ["-m", active_model, "-ngl", str(int(settings.gpu_layers)), "-c", str(int(settings.context_size)), "-np", "1", "--cache-ram", "256", "--port", str(int(settings.port)), "--host", HOST]
	if not active_mmproj.is_empty() and FileAccess.file_exists(active_mmproj):
		args.append_array(["--mmproj", active_mmproj])
	server_pid = OS.create_process(str(settings.server_path), args, false)
	if server_pid <= 0:
		set_status("ENGINE COULD NOT START", colors.red)
		show_toast("The local model engine could not be started — open Debug Telemetry")
		log_line("ERROR", "Failed to create llama-server process for " + active_model)
		recover_failed_vision_switch("Vision engine could not start")
		return
	server_owned = server_pid > 0
	if server_owned:
		var pid_file := FileAccess.open(SERVER_PID_FILE, FileAccess.WRITE)
		if pid_file:
			pid_file.store_string(str(server_pid))
			pid_file.close()
	server_ready = false
	load_started_ms = Time.get_ticks_msec()
	loading_elapsed = 0.0
	health_timer = 0.0
	set_status("LOADING MODEL INTO VRAM", colors.amber)
	set_startup_progress(52.0, "LOADING MODEL INTO VRAM", "GPU layers are being allocated • this can take a moment")
	log_line("ENGINE", "Started %s PID %s • %s" % [engine_mode.to_upper(), server_pid, active_model])
	log_line("ENGINE", "Requested CUDA layers %s • context %s • port %s" % [int(settings.gpu_layers), int(settings.context_size), int(settings.port)])

func stop_engine() -> void:
	if server_owned and server_pid > 0 and OS.is_process_running(server_pid):
		OS.kill(server_pid)
		log_line("ENGINE", "Stopped llama server PID %s" % server_pid)
	server_pid = -1
	server_owned = false
	server_ready = false
	health_client.close()
	stream_client.close()
	if FileAccess.file_exists(SERVER_PID_FILE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SERVER_PID_FILE))

func recover_orphaned_server() -> void:
	if not FileAccess.file_exists(SERVER_PID_FILE):
		return
	var old_pid := int(FileAccess.get_file_as_string(SERVER_PID_FILE))
	if old_pid > 0 and OS.is_process_running(old_pid):
		OS.kill(old_pid)
		log_line("ENGINE", "Recovered and stopped orphan server PID %s" % old_pid)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SERVER_PID_FILE))

func stop_stale_llama_servers() -> void:
	# SAM owns this dedicated llama-server executable. Clear every stale copy before
	# binding the configured port so a health check can never hit an older model.
	if OS.get_name() != "Windows" or str(settings.server_path).get_file().to_lower() != "llama-server.exe":
		return
	var output: Array = []
	var exit_code := OS.execute("taskkill.exe", PackedStringArray(["/F", "/IM", "llama-server.exe"]), output, true, false)
	if exit_code == 0:
		log_line("ENGINE", "Stopped stale llama-server instances before launch")

func setting_text(key: String) -> String:
	if key in ["port", "gpu_layers", "context_size", "max_tokens"]:
		return str(int(settings[key]))
	return str(settings[key])

func _process(delta: float) -> void:
	voice_daemon_poll_elapsed += delta
	if voice_daemon_poll_elapsed >= 0.05:
		voice_daemon_poll_elapsed = 0.0
		poll_voice_daemon()
	if not server_ready and server_pid > 0:
		loading_elapsed += delta
		update_loading_animation()
		if not OS.is_process_running(server_pid):
			server_pid = -1
			set_status("ENGINE EXITED • CHECK DEBUG", colors.red)
			log_line("ERROR", "llama-server exited during startup")
			show_toast("Model engine exited while loading — see Debug Telemetry")
			recover_failed_vision_switch("Vision model exited while loading")
			return
		health_timer += delta
		if health_timer >= 0.5:
			health_timer = 0.0
			poll_health()
	if generating:
		thinking_elapsed += delta
		if synced_voice_active:
			update_synced_voice_reveal()
		else:
			if response_text.is_empty():
				update_thinking_animation()
			drain_render_buffer()
			if not stream_finished:
				poll_stream()
	if recording_voice:
		live_transcription_elapsed += delta
		if live_transcription_elapsed >= 1.5 and (voice_thread == null or not voice_thread.is_started()):
			capture_live_transcription()
	if is_instance_valid(stats_report):
		stats_refresh_elapsed += delta
		if stats_refresh_elapsed >= 1.0 and $Page/Tabs.current_tab == $Page/Tabs.get_tab_idx_from_control(stats_report.get_parent() as Control):
			stats_refresh_elapsed = 0.0
			refresh_nerd_stats()

func drain_render_buffer() -> void:
	if streaming_voice_turn and not streaming_voice_started:
		# A short answer may not contain a sentence boundary. Queue its remainder as
		# soon as generation ends instead of waiting for the hidden render buffer.
		if stream_finished:
			queue_streaming_voice(true)
		update_thinking_animation()
		# Never let a failed/slow speech backend hold the text UI hostage forever.
		if streaming_voice_wait_started_ms > 0 and Time.get_ticks_msec() - streaming_voice_wait_started_ms >= 12000:
			log_line("VOICE", "Speech prebuffer exceeded 12s; releasing text while audio continues")
			begin_streaming_voice_playback()
		if streaming_voice_turn and not streaming_voice_started:
			return
	if not render_buffer.is_empty():
		var follow_output := force_chat_follow or chat_is_near_bottom()
		var count := clampi(1 + render_buffer.length() / 24, 1, 16)
		var visible_chunk := render_buffer.left(count)
		render_buffer = render_buffer.substr(visible_chunk.length())
		chat_log.append_text(escape_bbcode(visible_chunk))
		if follow_output:
			chat_log.scroll_to_line(chat_log.get_line_count())
	if stream_finished and render_buffer.is_empty():
		if streaming_voice_turn:
			queue_streaming_voice(true)
		finish_generation()

func update_loading_animation() -> void:
	var glyphs := ["◐", "◓", "◑", "◒"]
	var dots := ".".repeat(int(loading_elapsed * 2.0) % 4)
	set_status("%s LOADING MODEL INTO VRAM%s" % [glyphs[int(loading_elapsed * 6.0) % 4], dots], colors.amber)
	var visual_progress := minf(94.0, 52.0 + loading_elapsed * 3.2)
	set_startup_progress(visual_progress, "%s LOADING MODEL INTO VRAM%s" % [glyphs[int(loading_elapsed * 6.0) % 4], dots], "Starting CUDA layers, context cache, and local API")

func poll_health() -> void:
	if health_client.get_status() == HTTPClient.STATUS_DISCONNECTED:
		health_client.connect_to_host(HOST, int(settings.port))
	health_client.poll()
	if health_client.get_status() == HTTPClient.STATUS_CONNECTED:
		if health_client.request(HTTPClient.METHOD_GET, "/health", []) != OK:
			return
	elif health_client.get_status() == HTTPClient.STATUS_BODY:
		health_client.read_response_body_chunk()
		if health_client.get_response_code() == 200:
			server_ready = true
			set_status("ONLINE • MODEL READY", colors.green)
			log_line("READY", "Health check passed in %.1fs" % ((Time.get_ticks_msec() - load_started_ms) / 1000.0))
			health_client.close()
			finish_startup()
			if pending_vision_send and engine_mode == "vision":
				pending_vision_send = false
				call_deferred("send_message")
	if Time.get_ticks_msec() - load_started_ms > 90000 and not server_ready:
		set_status("ENGINE START TIMEOUT", colors.red)
		show_toast("Model loading timed out — see Debug Telemetry")
		log_line("ERROR", "%s engine did not become ready within 90 seconds" % engine_mode)
		stop_engine()
		recover_failed_vision_switch("Vision model timed out")

func send_message() -> void:
	var user_text := input_box.text.strip_edges()
	if user_text.is_empty() or generating:
		return
	if not attached_image_path.is_empty() and bool(settings.auto_vision_switch) and engine_mode != "vision":
		if FileAccess.file_exists(str(settings.vision_model_path)) and FileAccess.file_exists(str(settings.vision_mmproj_path)):
			pending_vision_send = true
			restore_primary_when_done = true
			engine_mode = "vision"
			set_status("SWITCHING TO VISION ENGINE", colors.amber)
			show_toast("Image ready • loading the vision model…")
			log_line("VISION", "Switching from the primary model to the configured vision model")
			show_model_switch_overlay()
			start_engine()
			return
	if not server_ready:
		log_line("WAIT", "The model is still loading.")
		return
	input_box.clear()
	set_microphone_available(false)
	sent_messages.append(user_text)
	history_cursor = -1
	history_draft = ""
	capture_explicit_memory(user_text)
	var user_item := {"role": "user", "content": user_text}
	if not attached_image_path.is_empty():
		user_item.image_path = attached_image_path
	if not attached_file_path.is_empty():
		user_item.file_path = attached_file_path
	history.append(user_item)
	save_history()
	append_chat("user", user_text, attached_image_path, attached_file_path)
	# Sending a new turn explicitly returns the user to the live edge and restores
	# normal follow-along behavior for Sam's incoming response.
	jump_chat_bottom()
	response_text = ""
	render_buffer = ""
	streaming_voice_turn = bool(settings.voice_enabled)
	streaming_voice_started = not streaming_voice_turn
	streaming_voice_wait_started_ms = 0
	streaming_voice_cursor = 0
	streaming_voice_chunks.clear()
	streaming_pending_ids.clear()
	streaming_audio_chunks.clear()
	stream_finished = false
	stream_retry_count = 0
	sse_buffer.clear()
	stream_client.close()
	stream_client = HTTPClient.new()
	var memory := read_memory()
	var active_mmproj := str(settings.vision_mmproj_path) if engine_mode == "vision" else str(settings.mmproj_path)
	if not attached_image_path.is_empty() and active_mmproj.is_empty():
		show_toast("Image added to chat • configure Vision MMPROJ for visual understanding")
	var request_text := user_text
	if not attached_file_text.is_empty():
		request_text = build_text_attachment_prompt(user_text)
	memory = build_memory_for_request(memory, request_text)
	var code_mode := is_code_request(request_text) or attached_file_kind == "code"
	var detected_language := detect_code_language(request_text, attached_file_path)
	pending_repair_error = extract_code_error_signature(request_text) if code_mode else ""
	pending_repair_language = "Godot 4 / GDScript" if detected_language == "Godot 4 GDScript" else (detected_language if not detected_language.is_empty() else "General code")
	if code_mode:
		memory += "\n\nACTIVE MODE FOR THIS TURN: CODE ENGINEERING. Preserve every supplied feature. Work from the actual source rather than replacing it with a demo. Before answering, silently audit identifiers, calls, ownership, state mutations, bounds, and every requested feature. If a full file is requested, return the complete integrated file with no placeholders or omitted functions."
		if not detected_language.is_empty():
			memory += "\nACTIVE LANGUAGE TARGET: %s. Keep the response and corrected code in %s. Do not convert it to Godot, GDScript, or another language unless the user explicitly asks to convert it." % [detected_language, detected_language]
		if detected_language == "Godot 4 GDScript" or (detected_language.is_empty() and is_godot_request(request_text)):
			memory += "\nACTIVE GODOT TARGET: GODOT 4.x ONLY. Reject Godot 3 syntax during your silent audit. For multiplayer code, trace player and AI state independently, verify both settled grids and active pieces are drawn with the right-board offset, keep grid height fixed, and ensure generic helpers never hardcode player variables. Random moves do not satisfy a heuristic-AI request."
		log_line("MODE", "Automatic Code Repair mode activated")
	var messages: Array = [{"role": "system", "content": memory}]
	if code_mode and (request_text.to_lower().contains("fileaccess") or request_text.to_lower().contains("not declared")):
		messages.append({"role": "user", "content": "Error: Identifier FileAccesssssss not declared. Code: return FileAccesssssss.get_file_as_string(path)"})
		messages.append({"role": "assistant", "content": "The identifier is misspelled. Use FileAccess:\n```gdscript\nreturn FileAccess.get_file_as_string(path)\n```"})
	var history_start := calculate_history_start(memory.length() + attached_file_text.length())
	if code_mode:
		# Do not condition repairs on earlier refusal or hallucination responses.
		history_start = history.size() - 1
	for index in range(history_start, history.size()):
		var item: Dictionary = history[index]
		if index == history.size() - 1 and item.role == "user" and not attached_image_path.is_empty() and not active_mmproj.is_empty():
			messages.append({"role": "user", "content": make_multimodal_content(str(item.content))})
		elif index == history.size() - 1 and item.role == "user" and not attached_file_text.is_empty():
			messages.append({"role": "user", "content": request_text})
		else:
			messages.append({"role": str(item.get("role", "user")), "content": str(item.get("content", ""))})
	var payload := JSON.stringify({"messages": messages, "stream": true,
		"max_tokens": int(settings.max_tokens), "temperature": float(settings.temperature),
		"presence_penalty": 0.1, "frequency_penalty": 0.2, "stop": STOP_TOKENS})
	# A submitted attachment belongs to exactly one message. Its path/content is now
	# captured in history and the payload, so clear the composer before generation.
	clear_attachment()
	stream_client.connect_to_host(HOST, int(settings.port))
	set_meta("pending_payload", payload)
	set_meta("request_sent", false)
	generating = true
	thinking_elapsed = 0.0
	thinking_frame = -1
	response_started_ms = Time.get_ticks_msec()
	chat_log.append_text("\n[color=#76f7a6][b]SAM[/b][/color]\n[color=#8292ad]Thinking…[/color]")
	send_button.disabled = true
	stop_button.disabled = false
	set_status("GENERATING RESPONSE", colors.green)
	log_line("CHAT", "Sent %s chars with %s bytes of live memory" % [user_text.length(), memory.length()])
	if code_mode and history_start > 0:
		log_line("CONTEXT", "Code Repair isolated this turn from %s older chat messages" % history_start)
	elif history_start > 0:
		log_line("CONTEXT", "Excluded %s oldest messages to stay within the context window" % history_start)

func calculate_history_start(memory_chars: int) -> int:
	# Conservative approximation: one token per three characters, with output room reserved.
	var char_budget := maxi(1500, (int(settings.context_size) - int(settings.max_tokens) - 256) * 3 - memory_chars)
	var used := 0
	var start := history.size()
	for index in range(history.size() - 1, -1, -1):
		var item: Dictionary = history[index]
		var cost := str(item.get("content", "")).length() + 40
		if used + cost > char_budget and start < history.size():
			break
		used += cost
		start = index
	return start

func is_code_request(text: String) -> bool:
	var lower := text.to_lower()
	var code_markers := ["error at (", "not declared", "traceback", "exception", "func ",
		"def ", "class ", "null", "parse_string", "can you fix", "fix this code",
		"compiler", "syntax error", "runtime error", "godot", "gdscript", "write code",
		"write a script", "full code", "source code"]
	for marker in code_markers:
		if lower.contains(marker):
			return true
	return text.contains("```")

func is_godot_request(text: String) -> bool:
	var lower := text.to_lower()
	return lower.contains("godot") or lower.contains("gdscript") or lower.contains("extends node") or lower.contains(".gd") or lower.contains("queue_redraw") or lower.contains("fileaccess")

func detect_code_language(text: String, file_path: String = "") -> String:
	var extension := file_path.get_extension().to_lower()
	var extension_languages := {"py": "Python", "gd": "Godot 4 GDScript", "js": "JavaScript", "jsx": "JavaScript", "ts": "TypeScript", "tsx": "TypeScript", "cs": "C#", "cpp": "C++", "cc": "C++", "c": "C", "h": "C/C++", "hpp": "C++", "java": "Java", "rs": "Rust", "go": "Go", "ps1": "PowerShell", "sh": "Shell", "html": "HTML", "css": "CSS", "sql": "SQL"}
	if extension_languages.has(extension):
		return str(extension_languages[extension])
	var lower := text.to_lower()
	if lower.contains("```python") or lower.contains("#!/usr/bin/env python") or lower.contains("import pygame") or lower.contains("def __init__(") or lower.contains("if __name__ =="):
		return "Python"
	if is_godot_request(text):
		return "Godot 4 GDScript"
	if lower.contains("```javascript") or (lower.contains("const ") and lower.contains("=>")):
		return "JavaScript"
	if lower.contains("```typescript") or (lower.contains("interface ") and lower.contains(": string")):
		return "TypeScript"
	if lower.contains("using system;") or lower.contains("```csharp"):
		return "C#"
	if lower.contains("#include <"):
		return "C++"
	return ""

func extract_code_error_signature(text: String) -> String:
	var markers := ["error at", "parser error", "parse error", "syntax error", "runtime error",
		"not declared", "invalid operand", "invalid call", "nonexistent function", "exception",
		"traceback", "doesn't work", "doesnt work", "didn't work", "didnt work",
		"forgot to add", "missing variable", "missing var"]
	for raw_line in text.split("\n", false):
		var line := str(raw_line).strip_edges()
		var lower := line.to_lower()
		for marker in markers:
			if lower.contains(marker):
				return " ".join(line.split(" ", false)).left(220)
	return ""

func save_automatic_repair_lesson(answer: String) -> void:
	if pending_repair_error.is_empty():
		return
	# Only promote a lesson when Sam actually supplied a repair, rather than a refusal.
	var answer_lower := answer.to_lower()
	var supplied_repair := answer.contains("```") or answer_lower.contains("replace") or answer_lower.contains("change ") or answer_lower.contains("use ")
	if not supplied_repair:
		pending_repair_error = ""
		pending_repair_language = ""
		return
	var prevention := "Re-check the exact reported failure and verify the corrected identifiers, types, calls, and required state before returning code."
	var error_lower := pending_repair_error.to_lower()
	if error_lower.contains("not declared") or error_lower.contains("missing var") or error_lower.contains("missing variable") or error_lower.contains("forgot to add"):
		prevention = "Verify every referenced identifier is declared in the correct scope and spelled consistently before returning code."
	elif error_lower.contains("parser") or error_lower.contains("parse error") or error_lower.contains("syntax error"):
		prevention = "Validate syntax for the requested language/version and remove unsupported or legacy syntax before returning code."
	elif error_lower.contains("invalid operand"):
		prevention = "Verify operand and return types are compatible on every expression involved in the reported failure."
	elif error_lower.contains("invalid call") or error_lower.contains("nonexistent function"):
		prevention = "Verify every method exists on that object in the requested framework version and that its arguments match the API."
	if pending_repair_language == "Godot 4 / GDScript":
		prevention += " Use Godot 4.x APIs and GDScript syntax only."
	var signature := pending_repair_error.replace("`", "'").replace("\r", " ").replace("\n", " ").strip_edges()
	var entry := "- [%s] Error seen: %s | Prevention: %s" % [pending_repair_language, signature, prevention]
	var heading := "### AUTOMATIC CODE REPAIR LESSONS:"
	var current := read_memory()
	var prefix := current.strip_edges()
	var lessons: Array[String] = []
	var heading_at := current.find(heading)
	if heading_at >= 0:
		prefix = current.left(heading_at).strip_edges()
		for raw_line in current.substr(heading_at + heading.length()).split("\n", false):
			var old_entry := str(raw_line).strip_edges()
			if old_entry.begins_with("- "):
				lessons.append(old_entry)
	var normalized_signature := signature.to_lower().left(140)
	for old_entry in lessons:
		if old_entry.to_lower().contains(normalized_signature):
			pending_repair_error = ""
			pending_repair_language = ""
			return
	lessons.append(entry)
	# Keep a deep archive on disk. Only relevant lessons are placed in an individual
	# model request by build_memory_for_request(), so this does not consume the full context.
	while lessons.size() > 500:
		lessons.pop_front()
	var updated := prefix + "\n\n" + heading + "\n" + "\n".join(lessons) + "\n"
	var file := FileAccess.open(str(settings.memory_path), FileAccess.WRITE)
	if file:
		file.store_string(updated)
		file.close()
		if is_instance_valid(memory_editor):
			memory_editor.text = updated
		log_line("LEARNED", "Saved repair lesson: " + signature)
		show_toast("Repair lesson saved to MemoryCore")
	pending_repair_error = ""
	pending_repair_language = ""

func update_thinking_animation() -> void:
	var frame := int(thinking_elapsed * 4.0) % 6
	if frame == thinking_frame:
		return
	thinking_frame = frame
	var dots := [
		"[color=#75f7f3]●[/color] [color=#315c73]●[/color] [color=#1c3448]●[/color]",
		"[color=#4deeea]●[/color] [color=#75f7f3]●[/color] [color=#315c73]●[/color]",
		"[color=#315c73]●[/color] [color=#4deeea]●[/color] [color=#75f7f3]●[/color]",
		"[color=#1c3448]●[/color] [color=#315c73]●[/color] [color=#4deeea]●[/color]",
		"[color=#315c73]●[/color] [color=#4deeea]●[/color] [color=#75f7f3]●[/color]",
		"[color=#4deeea]●[/color] [color=#75f7f3]●[/color] [color=#315c73]●[/color]"]
	var bar := chat_log.get_v_scroll_bar()
	var previous_scroll := bar.value
	var follow_output := force_chat_follow or chat_is_near_bottom()
	redraw_history()
	chat_log.append_text("\n[color=#76f7a6][b]SAM[/b][/color]\n[color=#a9bad3]Sam is thinking[/color]  %s\n" % dots[frame])
	if follow_output:
		chat_log.scroll_to_line(chat_log.get_line_count())
	else:
		bar.value = previous_scroll

func make_multimodal_content(text: String) -> Array:
	var image := Image.load_from_file(attached_image_path)
	var bytes := PackedByteArray()
	var mime := "image/jpeg"
	if not image.is_empty():
		var longest := maxi(image.get_width(), image.get_height())
		if longest > 1280:
			var scale := 1280.0 / float(longest)
			image.resize(maxi(1, int(image.get_width() * scale)), maxi(1, int(image.get_height() * scale)), Image.INTERPOLATE_LANCZOS)
		bytes = image.save_jpg_to_buffer(0.88)
	else:
		bytes = FileAccess.get_file_as_bytes(attached_image_path)
	var uri := "data:%s;base64,%s" % [mime, Marshalls.raw_to_base64(bytes)]
	return [{"type": "text", "text": text}, {"type": "image_url", "image_url": {"url": uri}}]

func capture_explicit_memory(user_text: String) -> void:
	# Deterministic memory beats asking a small model to decide whether it remembered.
	# Only explicit "remember" requests are stored automatically; everything else remains user-controlled.
	var lower := user_text.to_lower()
	var marker_at := lower.find("remember that ")
	var marker_length := 14
	if marker_at < 0:
		marker_at = lower.find("remember ")
		marker_length = 9
	if marker_at < 0:
		marker_at = lower.find("save to memorycore ")
		marker_length = 19
	if marker_at < 0:
		return
	var fact := user_text.substr(marker_at + marker_length).strip_edges()
	# Keep durable facts concise. Saving a whole pasted script here pollutes every
	# later prompt and makes the model less reliable, not more knowledgeable.
	if fact.to_lower().contains("godot 4"):
		fact = "This project uses Godot 4.x; always generate Godot 4 GDScript syntax and APIs, never Godot 3 syntax."
	else:
		var fact_lines := fact.split("\n", false)
		if not fact_lines.is_empty():
			fact = str(fact_lines[0])
		fact = fact.left(400).strip_edges().trim_suffix(".")
	if fact.is_empty():
		return
	var vague_facts := ["that", "this", "it", "not to forget that", "don't forget that", "dont forget that"]
	if vague_facts.has(fact.to_lower()):
		show_toast("Tell Sam the specific fact you want remembered")
		return
	var current := read_memory()
	var entry := "- " + fact.trim_suffix(".")
	if current.to_lower().contains(entry.to_lower()):
		return
	if not current.contains("### LEARNED FACTS & MEMORY:"):
		current += "\n\n### LEARNED FACTS & MEMORY:"
	var repair_heading := "### AUTOMATIC CODE REPAIR LESSONS:"
	var repair_at := current.find(repair_heading)
	if repair_at >= 0:
		current = current.left(repair_at).strip_edges() + "\n" + entry + "\n\n" + current.substr(repair_at).strip_edges()
	else:
		current += "\n" + entry
	var file := FileAccess.open(str(settings.memory_path), FileAccess.WRITE)
	if file:
		file.store_string(current.strip_edges() + "\n")
		file.close()
		if is_instance_valid(memory_editor):
			memory_editor.text = current
		log_line("MEMORY", "Captured explicit memory: " + fact)

func poll_stream() -> void:
	var err := stream_client.poll()
	if err != OK:
		if response_text.is_empty() and stream_retry_count < 3:
			retry_stream_request(err)
		else:
			fail_generation("Connection failed after %s retries (Godot error %s)" % [stream_retry_count, err])
		return
	if stream_client.get_status() == HTTPClient.STATUS_CONNECTED and not bool(get_meta("request_sent", false)):
		var headers := ["Content-Type: application/json", "Accept: text/event-stream"]
		err = stream_client.request(HTTPClient.METHOD_POST, "/v1/chat/completions", headers, str(get_meta("pending_payload")))
		if err != OK:
			fail_generation("Request error %s" % err)
			return
		set_meta("request_sent", true)
	elif stream_client.get_status() == HTTPClient.STATUS_BODY:
		var response_code := stream_client.get_response_code()
		var chunk := stream_client.read_response_body_chunk()
		if not chunk.is_empty():
			if response_code >= 400:
				fail_generation("Model server HTTP %s: %s" % [response_code, chunk.get_string_from_utf8()])
				return
			sse_buffer.append_array(chunk)
			consume_sse_lines()
	elif bool(get_meta("request_sent", false)) and stream_client.get_status() == HTTPClient.STATUS_DISCONNECTED:
		if not response_text.is_empty():
			stream_finished = true
		elif stream_retry_count < 3:
			retry_stream_request(ERR_CONNECTION_ERROR)
		else:
			fail_generation("The model server disconnected before returning a response")

func retry_stream_request(error_code: int) -> void:
	stream_retry_count += 1
	log_line("RETRY", "Reconnecting chat request %s/3 after error %s" % [stream_retry_count, error_code])
	stream_client.close()
	stream_client = HTTPClient.new()
	set_meta("request_sent", false)
	stream_client.connect_to_host(HOST, int(settings.port))
	set_status("RECONNECTING • ATTEMPT %s/3" % stream_retry_count, colors.amber)

func consume_sse_lines() -> void:
	var raw := sse_buffer.get_string_from_utf8()
	var split := raw.split("\n")
	if not raw.ends_with("\n"):
		sse_buffer = split[-1].to_utf8_buffer()
		split.resize(split.size() - 1)
	else:
		sse_buffer.clear()
	for line_variant in split:
		var line := str(line_variant).strip_edges()
		if not line.begins_with("data: "):
			continue
		var data := line.substr(6)
		if data == "[DONE]":
			stream_finished = true
			stream_client.close()
			return
		var parsed = JSON.parse_string(data)
		if parsed is Dictionary and parsed.has("choices") and not parsed.choices.is_empty():
			var delta = parsed.choices[0].get("delta", {})
			var content = delta.get("content", "")
			# Role/tool chunks can contain JSON null; never stringify that as "<null>".
			var token: String = content if content is String else ""
			if not token.is_empty():
				if response_text.is_empty() and not bool(settings.voice_enabled):
					redraw_history()
					chat_log.append_text("\n[color=#76f7a6][b]SAM[/b][/color]\n")
				response_text += token
				render_buffer += token
				if streaming_voice_turn:
					queue_streaming_voice(false)

func finish_generation() -> void:
	if not generating:
		return
	generating = false
	stream_client.close()
	var cleaned := clean_output(response_text)
	if cleaned.is_empty():
		log_line("ERROR", "The model server completed without returning any response text")
		redraw_history()
		chat_log.append_text("\n[color=#ff667d][b]SAM DID NOT RECEIVE A USABLE RESPONSE[/b][/color]\nThe model returned no text. Reattach the image to retry after the engine is online.\n")
		set_status("EMPTY MODEL RESPONSE", colors.red)
		show_toast("No response was returned — reattach the image to retry")
		send_button.disabled = false
		stop_button.disabled = true
		set_microphone_available(true)
		restore_primary_engine_if_needed()
		return
	if not cleaned.is_empty():
		history.append({"role": "assistant", "content": cleaned})
		save_history()
		save_automatic_repair_lesson(cleaned)
	clear_attachment()
	redraw_history()
	var elapsed := (Time.get_ticks_msec() - response_started_ms) / 1000.0
	var chars_per_second := cleaned.length() / maxf(elapsed, 0.01)
	set_status("DONE • %.1fs • %.1f chars/s" % [elapsed, chars_per_second], colors.green)
	log_line("DONE", "Generated %s chars in %.2fs" % [cleaned.length(), elapsed])
	send_button.disabled = false
	stop_button.disabled = true
	set_microphone_available(not streaming_voice_busy())
	if not cleaned.is_empty() and bool(settings.voice_enabled) and not streaming_voice_turn and not synced_voice_failed:
		speak_text(cleaned)
	synced_voice_failed = false
	restore_primary_engine_if_needed()

func queue_streaming_voice(force_remainder: bool) -> void:
	if not streaming_voice_turn or response_text.length() <= streaming_voice_cursor:
		return
	var pending := response_text.substr(streaming_voice_cursor)
	var cut := -1
	for marker in [". ", "? ", "! ", "\n"]:
		cut = maxi(cut, pending.rfind(marker))
	if force_remainder:
		cut = pending.length() - 1
	elif cut < 55:
		return
	var raw_chunk := pending.left(cut + 1)
	streaming_voice_cursor += cut + 1
	var spoken := prepare_speech_text(raw_chunk)
	if not spoken.is_empty():
		streaming_voice_chunks.append(spoken)
		if streaming_voice_wait_started_ms == 0:
			streaming_voice_wait_started_ms = Time.get_ticks_msec()
		start_next_streaming_voice_job()
	elif force_remainder and streaming_pending_ids.is_empty() and streaming_audio_chunks.is_empty():
		streaming_voice_started = true
		streaming_voice_turn = false

func start_next_streaming_voice_job() -> void:
	if streaming_voice_chunks.is_empty():
		return
	var chunk: String = streaming_voice_chunks.pop_front()
	streaming_voice_serial += 1
	if voice_daemon_pid > 0 and OS.is_process_running(voice_daemon_pid):
		var job_id := "%s_%08d" % [session_id.validate_filename(), streaming_voice_serial]
		var queue_dir := ProjectSettings.globalize_path("user://tts_queue")
		var job_path := queue_dir.path_join(job_id + ".job")
		var job := FileAccess.open(job_path, FileAccess.WRITE)
		if job:
			job.store_string(JSON.stringify({"id": job_id, "text": chunk, "voice": str(settings.voice_name), "speed": 1.08}))
			job.close()
			streaming_pending_ids.append(job_id)
			set_voice_status("VOICE • BUFFERING SENTENCE %d…" % streaming_pending_ids.size(), colors.green)
		return
	if voice_thread != null and voice_thread.is_started():
		streaming_voice_chunks.push_front(chunk)
		return
	var text_path := ProjectSettings.globalize_path("user://voice_stream_%04d.txt" % streaming_voice_serial)
	var file := FileAccess.open(text_path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(chunk)
	file.close()
	set_voice_status("VOICE • BUFFERING NEXT SENTENCE…", colors.green)
	voice_thread = Thread.new()
	voice_thread.start(_voice_worker.bind("tts_stream", text_path, str(settings.voice_name)))

func streaming_voice_busy() -> bool:
	return streaming_voice_turn and (not streaming_voice_chunks.is_empty() or not streaming_pending_ids.is_empty() or not streaming_audio_chunks.is_empty() or (voice_thread != null and voice_thread.is_started()) or voice_player.playing)

func start_voice_daemon() -> void:
	var python_path := str(settings.voice_python_path)
	var model_path := str(settings.kokoro_model_path)
	var voices_path := str(settings.kokoro_voices_path)
	var daemon_path := voice_runtime_script("tts_daemon.py")
	if not FileAccess.file_exists(python_path) or not FileAccess.file_exists(daemon_path) or not FileAccess.file_exists(model_path) or not FileAccess.file_exists(voices_path):
		log_line("VOICE", "Persistent Kokoro worker unavailable; using compatibility mode")
		return
	if FileAccess.file_exists(VOICE_DAEMON_PID_FILE):
		var previous_pid := int(FileAccess.get_file_as_string(VOICE_DAEMON_PID_FILE))
		if previous_pid > 0 and OS.is_process_running(previous_pid):
			OS.kill(previous_pid)
	var queue_dir := ProjectSettings.globalize_path("user://tts_queue")
	DirAccess.make_dir_recursive_absolute(queue_dir)
	var ready_path := queue_dir.path_join("daemon.ready")
	if FileAccess.file_exists(ready_path):
		DirAccess.remove_absolute(ready_path)
	voice_daemon_pid = OS.create_process(python_path, PackedStringArray([daemon_path, "--queue-dir", queue_dir, "--kokoro-model", model_path, "--kokoro-voices", voices_path]), false)
	if voice_daemon_pid > 0:
		var pid_file := FileAccess.open(VOICE_DAEMON_PID_FILE, FileAccess.WRITE)
		if pid_file:
			pid_file.store_string(str(voice_daemon_pid))
			pid_file.close()
		log_line("VOICE", "Started persistent Kokoro worker PID %d" % voice_daemon_pid)

func poll_voice_daemon() -> void:
	if voice_daemon_pid <= 0:
		return
	var queue_dir := ProjectSettings.globalize_path("user://tts_queue")
	if not voice_daemon_announced and FileAccess.file_exists(queue_dir.path_join("daemon.ready")):
		voice_daemon_announced = true
		log_line("VOICE", "Persistent Kokoro model is loaded and ready")
	if streaming_pending_ids.is_empty():
		return
	var job_id := streaming_pending_ids[0]
	var done_path := queue_dir.path_join(job_id + ".done")
	var error_path := queue_dir.path_join(job_id + ".error")
	if FileAccess.file_exists(error_path):
		log_line("VOICE ERROR", FileAccess.get_file_as_string(error_path))
		DirAccess.remove_absolute(error_path)
		streaming_pending_ids.pop_front()
		if not streaming_voice_started:
			begin_streaming_voice_playback()
		return
	if not FileAccess.file_exists(done_path):
		return
	var wav_path := queue_dir.path_join(job_id + ".wav")
	var audio: AudioStreamWAV = AudioStreamWAV.load_from_file(wav_path)
	DirAccess.remove_absolute(done_path)
	streaming_pending_ids.pop_front()
	if audio == null:
		if not streaming_voice_started:
			begin_streaming_voice_playback()
		return
	DirAccess.remove_absolute(wav_path)
	if voice_player.playing:
		streaming_audio_chunks.append(audio)
	else:
		begin_streaming_voice_playback()
		voice_player.stream = audio
		voice_player.play()
		set_voice_status("VOICE • SAM IS SPEAKING", colors.green)

func begin_streaming_voice_playback() -> void:
	if streaming_voice_started:
		return
	var bar := chat_log.get_v_scroll_bar()
	var previous_scroll := bar.value
	var follow_output := force_chat_follow or chat_is_near_bottom()
	streaming_voice_started = true
	streaming_voice_wait_started_ms = 0
	redraw_history()
	chat_log.append_text("[color=%s][b]SAM[/b][/color]\n" % colors.green.to_html())
	if follow_output:
		chat_log.scroll_to_line(chat_log.get_line_count())
	else:
		bar.value = previous_scroll

func begin_synced_voice_reply() -> void:
	awaiting_synced_voice = true
	var spoken_text := prepare_speech_text(clean_output(response_text))
	if spoken_text.is_empty():
		awaiting_synced_voice = false
		synced_voice_failed = true
		log_line("VOICE", "Code-only response will be displayed without speech")
		return
	var text_path := ProjectSettings.globalize_path("user://voice_reply.txt")
	var file := FileAccess.open(text_path, FileAccess.WRITE)
	if file == null:
		awaiting_synced_voice = false
		synced_voice_failed = true
		return
	file.store_string(spoken_text)
	file.close()
	set_voice_status("VOICE • PREPARING SAM…", colors.green)
	voice_thread = Thread.new()
	voice_thread.start(_voice_worker.bind("tts_sync", text_path, str(settings.voice_name)))

func start_synced_voice_reveal(stream: AudioStreamWAV) -> void:
	awaiting_synced_voice = false
	synced_voice_active = true
	synced_reply_text = clean_output(response_text)
	synced_reply_index = 0
	render_buffer = ""
	redraw_history()
	chat_log.append_text("\n[color=#76f7a6][b]SAM[/b][/color]\n")
	voice_player.stream = stream
	voice_player.play()
	set_voice_status("VOICE • SAM IS SPEAKING", colors.green)
	set_status("SAM IS SPEAKING", colors.green)

func update_synced_voice_reveal() -> void:
	if not voice_player.playing or voice_player.stream == null:
		return
	var duration := maxf(voice_player.stream.get_length(), 0.1)
	var progress := clampf(voice_player.get_playback_position() / duration, 0.0, 1.0)
	var target := clampi(int(ceil(progress * synced_reply_text.length())), synced_reply_index, synced_reply_text.length())
	if target > synced_reply_index:
		var follow_output := force_chat_follow or chat_is_near_bottom()
		chat_log.append_text(escape_bbcode(synced_reply_text.substr(synced_reply_index, target - synced_reply_index)))
		synced_reply_index = target
		if follow_output:
			chat_log.scroll_to_line(chat_log.get_line_count())

func setup_voice_system() -> void:
	# Migration and privacy default: existing installs that have never seen the
	# microphone choice are returned to manual-send before their first use.
	if not bool(settings.get("mic_notice_shown", false)):
		settings.voice_auto_send = false
		save_json(SETTINGS_FILE, settings)
	auto_speak.button_pressed = bool(settings.voice_enabled)
	chat_auto_speak.set_pressed_no_signal(bool(settings.voice_enabled))
	auto_send_voice.button_pressed = bool(settings.voice_auto_send)
	var voices := ["af_heart", "af_sarah", "am_adam", "am_michael"]
	voice_selector.select(maxi(voices.find(str(settings.voice_name)), 0))
	if AudioServer.get_bus_index("Record") < 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Record")
	var record_bus := AudioServer.get_bus_index("Record")
	AudioServer.set_bus_mute(record_bus, true)
	record_effect = AudioEffectRecord.new()
	record_effect.format = AudioStreamWAV.FORMAT_16_BITS
	AudioServer.add_bus_effect(record_bus, record_effect)
	microphone_player.stream = AudioStreamMicrophone.new()
	microphone_player.bus = "Record"
	microphone_player.play()
	set_voice_status("VOICE • READY", colors.cyan)
	start_voice_daemon()

func toggle_microphone() -> void:
	if not recording_voice:
		if voice_thread != null and voice_thread.is_started():
			show_toast("Voice engine is busy")
			return
		if not bool(settings.get("mic_notice_shown", false)):
			show_first_microphone_notice()
			return
		start_microphone_recording()
		return
	record_effect.set_recording_active(false)
	recording_voice = false
	microphone_button.text = "🎙 START TALKING"
	var recording := record_effect.get_recording()
	if recording == null or recording.get_length() < 0.2:
		set_voice_status("VOICE • RECORDING TOO SHORT", colors.amber)
		return
	var audio_stem := ProjectSettings.globalize_path("user://voice_input")
	var error := recording.save_to_wav(audio_stem)
	if error != OK:
		set_voice_status("VOICE • COULD NOT SAVE RECORDING", colors.red)
		return
	pending_final_audio = audio_stem + ".wav"
	set_voice_status("VOICE • FINALIZING TRANSCRIPT…", colors.amber)
	if voice_thread == null or not voice_thread.is_started():
		start_transcription("stt_final", pending_final_audio)
		pending_final_audio = ""

func show_first_microphone_notice() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "SAM-AI  //  MICROPHONE PRIVACY"
	dialog.dialog_text = "🎙  PUSH-TO-TALK • PRIVATE • LOCAL\n\nSAM-AI listens only after you press START TALKING. Your speech is transcribed on this PC and appears live in the message box for review.\n\nManual Send is the privacy default. Auto-Send can be changed anytime under Engine Setup → Voice + Microphone."
	dialog.ok_button_text = "✓ KEEP MANUAL SEND"
	dialog.add_button("⚡ ENABLE AUTO-SEND", true, "enable_auto_send")
	dialog.get_cancel_button().hide()
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#08111f")
	panel_style.border_color = colors.cyan
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	panel_style.set_content_margin_all(24)
	dialog.add_theme_stylebox_override("panel", panel_style)
	dialog.add_theme_color_override("title_color", colors.cyan)
	dialog.confirmed.connect(func():
		settings.mic_notice_shown = true
		settings.voice_auto_send = false
		save_json(SETTINGS_FILE, settings)
		auto_send_voice.set_pressed_no_signal(false)
		dialog.queue_free()
		start_microphone_recording())
	dialog.custom_action.connect(func(action: StringName):
		if action == &"enable_auto_send":
			settings.mic_notice_shown = true
			settings.voice_auto_send = true
			save_json(SETTINGS_FILE, settings)
			auto_send_voice.set_pressed_no_signal(true)
			dialog.queue_free()
			show_toast("Auto-send enabled — change it anytime in Engine Setup")
			start_microphone_recording())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	dialog.popup_centered(Vector2i(720, 300))

func start_microphone_recording() -> void:
	stop_voice()
	voice_input_prefix = input_box.text.strip_edges()
	live_transcript_buffer = ""
	live_transcription_elapsed = 0.0
	pending_final_audio = ""
	record_effect.set_recording_active(true)
	recording_voice = true
	microphone_button.text = "■ STOP + TRANSCRIBE"
	var finish_action := "send automatically" if bool(settings.voice_auto_send) else "place text in the composer"
	set_voice_status("● LISTENING… CLICK AGAIN TO %s" % finish_action.to_upper(), colors.red)

func test_selected_voice() -> void:
	if voice_thread != null and voice_thread.is_started():
		show_toast("Voice engine is busy")
		return
	speak_text("Hello. I am Sam. This is the selected local voice.")

func capture_live_transcription() -> void:
	live_transcription_elapsed = 0.0
	var recording := record_effect.get_recording()
	if recording == null or recording.get_length() < 0.5:
		return
	var audio_stem := ProjectSettings.globalize_path("user://voice_live_preview")
	if recording.save_to_wav(audio_stem) != OK:
		return
	set_voice_status("● LISTENING + LIVE TRANSCRIPTION…", colors.red)
	start_transcription("stt_preview", audio_stem + ".wav")

func start_transcription(kind: String, audio_path: String) -> void:
	voice_thread = Thread.new()
	voice_thread.start(_voice_worker.bind(kind, audio_path, ""))

func speak_text(text: String) -> void:
	var spoken_text := prepare_speech_text(text)
	if spoken_text.is_empty():
		log_line("VOICE", "Skipped code-only response")
		return
	if (voice_thread != null and voice_thread.is_started()) or voice_player.playing:
		pending_speech = spoken_text
		log_line("VOICE", "Queued the newest reply until current speech finishes")
		return
	var text_path := ProjectSettings.globalize_path("user://voice_reply.txt")
	var file := FileAccess.open(text_path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(spoken_text)
	file.close()
	set_voice_status("VOICE • KOKORO IS WORKING…", colors.green)
	voice_thread = Thread.new()
	voice_thread.start(_voice_worker.bind("tts", text_path, str(settings.voice_name)))

func _voice_worker(kind: String, source: String, voice: String) -> void:
	var captured: Array = []
	var output_path := ProjectSettings.globalize_path("user://voice_transcript.txt")
	var bridge_path := voice_runtime_script("voice_bridge.py")
	var arguments := PackedStringArray([bridge_path, "stt", "--audio", source, "--output", output_path, "--whisper-exe", str(settings.whisper_exe_path), "--whisper-model", str(settings.whisper_model_path)])
	if kind.begins_with("tts"):
		output_path = source.get_basename() + ".wav" if kind == "tts_stream" else ProjectSettings.globalize_path("user://voice_reply.wav")
		arguments = PackedStringArray([bridge_path, "tts", "--text-file", source, "--output", output_path, "--voice", voice, "--kokoro-model", str(settings.kokoro_model_path), "--kokoro-voices", str(settings.kokoro_voices_path)])
	var exit_code := OS.execute(str(settings.voice_python_path), arguments, captured, true, false)
	call_deferred("_voice_job_finished", kind, exit_code, output_path, "\n".join(captured))

func _voice_job_finished(kind: String, exit_code: int, output_path: String, detail: String) -> void:
	if voice_thread != null:
		voice_thread.wait_to_finish()
		voice_thread = null
	if exit_code != 0 or not FileAccess.file_exists(output_path):
		set_voice_status("VOICE • ENGINE ERROR", colors.red)
		log_line("VOICE ERROR", detail)
		if kind == "tts_sync":
			awaiting_synced_voice = false
			synced_voice_failed = true
		if kind == "stt_preview" and not pending_final_audio.is_empty():
			var final_audio := pending_final_audio
			pending_final_audio = ""
			start_transcription("stt_final", final_audio)
		if kind == "tts_stream":
			if not streaming_voice_started:
				begin_streaming_voice_playback()
			start_next_streaming_voice_job()
		return
	if kind.begins_with("stt"):
		var transcript := FileAccess.get_file_as_string(output_path).strip_edges()
		live_transcript_buffer = merge_live_transcript(live_transcript_buffer, transcript)
		input_box.text = (voice_input_prefix + (" " if not voice_input_prefix.is_empty() and not live_transcript_buffer.is_empty() else "") + live_transcript_buffer).strip_edges()
		input_box.grab_focus()
		input_box.set_caret_line(input_box.get_line_count() - 1)
		input_box.set_caret_column(input_box.get_line(input_box.get_line_count() - 1).length())
		if kind == "stt_preview":
			set_voice_status("● LISTENING • " + transcript.right(70), colors.red)
			if not pending_final_audio.is_empty():
				var final_audio := pending_final_audio
				pending_final_audio = ""
				start_transcription("stt_final", final_audio)
			return
		set_voice_status(("VOICE • AUTO-SENDING: " if bool(settings.voice_auto_send) else "VOICE • TRANSCRIPT READY — PRESS ENTER: ") + transcript.left(55), colors.cyan)
		if bool(settings.voice_auto_send) and not input_box.text.is_empty():
			send_message()
		return

	var stream := AudioStreamWAV.load_from_file(output_path)
	if stream == null:
		set_voice_status("VOICE • AUDIO LOAD ERROR", colors.red)
		if kind == "tts_sync":
			awaiting_synced_voice = false
			synced_voice_failed = true
		return
	if kind == "tts_stream":
		if voice_player.playing:
			streaming_audio_chunks.append(stream)
		else:
			begin_streaming_voice_playback()
			voice_player.stream = stream
			voice_player.play()
			set_voice_status("VOICE • SAM IS SPEAKING", colors.green)
		start_next_streaming_voice_job()
		return
	if kind == "tts_sync":
		if not generating:
			return
		start_synced_voice_reveal(stream)
		return
	voice_player.stream = stream
	voice_player.play()
	set_voice_status("VOICE • SAM IS SPEAKING", colors.green)

func merge_live_transcript(existing: String, incoming: String) -> String:
	var old := existing.strip_edges()
	var fresh := incoming.strip_edges()
	if fresh.is_empty() or fresh == old:
		return old
	if fresh.begins_with(old):
		return fresh
	if old.begins_with(fresh):
		return old
	var old_words := old.split(" ", false)
	var new_words := fresh.split(" ", false)
	var max_overlap := mini(old_words.size(), new_words.size())
	for overlap in range(max_overlap, 0, -1):
		var matches := true
		for index in range(overlap):
			if str(old_words[old_words.size() - overlap + index]).to_lower() != str(new_words[index]).to_lower():
				matches = false
				break
		if matches:
			return (old + " " + " ".join(new_words.slice(overlap))).strip_edges()
	return (old + " " + fresh).strip_edges()

func prepare_speech_text(text: String) -> String:
	# Keep the human explanation and omit fenced source code from spoken replies.
	var prose: Array[String] = []
	var inside_code := false
	for raw_line in text.split("\n"):
		var line := str(raw_line)
		if line.strip_edges().begins_with("```"):
			inside_code = not inside_code
			continue
		if inside_code:
			continue
		line = line.strip_edges()
		while line.begins_with("#") or line.begins_with("-") or line.begins_with("*"):
			line = line.substr(1).strip_edges()
		line = line.replace("`", "")
		line = line.replace("!", ".")
		for symbol in ["~", "@", "#", "$", "%", "^", "&", "*", "(", ")", "_", "+", "[", "]", "{", "}", "\\", "/", "|", "<", ">", "=", ";"]:
			line = line.replace(symbol, " ")
		line = line.replace("  ", " ").replace("  ", " ")
		var contains_spoken_content := false
		for character in line:
			if str(character).to_lower() != str(character).to_upper() or str(character).is_valid_int():
				contains_spoken_content = true
				break
		if not line.is_empty() and contains_spoken_content:
			prose.append(line)
	return " ".join(prose).strip_edges()

func _on_voice_finished() -> void:
	if streaming_voice_turn:
		if not streaming_audio_chunks.is_empty():
			voice_player.stream = streaming_audio_chunks.pop_front()
			voice_player.play()
			set_voice_status("VOICE • SAM IS SPEAKING", colors.green)
			return
		start_next_streaming_voice_job()
		if generating or (voice_thread != null and voice_thread.is_started()) or not streaming_voice_chunks.is_empty():
			set_voice_status("VOICE • BUFFERING NEXT SENTENCE…", colors.green)
			return
		streaming_voice_turn = false
		set_voice_status("VOICE • READY", colors.cyan)
		set_microphone_available(true)
		return
	if synced_voice_active:
		if synced_reply_index < synced_reply_text.length():
			chat_log.append_text(escape_bbcode(synced_reply_text.substr(synced_reply_index)))
		synced_voice_active = false
		awaiting_synced_voice = false
		generating = false
		if not synced_reply_text.is_empty():
			history.append({"role": "assistant", "content": synced_reply_text})
			save_history()
		clear_attachment()
		redraw_history()
		var elapsed := (Time.get_ticks_msec() - response_started_ms) / 1000.0
		var chars_per_second := synced_reply_text.length() / maxf(elapsed, 0.01)
		set_status("DONE • %.1fs • %.1f chars/s" % [elapsed, chars_per_second], colors.green)
		log_line("DONE", "Generated and spoke %s chars in %.2fs" % [synced_reply_text.length(), elapsed])
		send_button.disabled = false
		stop_button.disabled = true
		set_microphone_available(true)
		synced_reply_text = ""
		synced_reply_index = 0
		set_voice_status("VOICE • READY", colors.cyan)
		restore_primary_engine_if_needed()
		return
	set_voice_status("VOICE • READY", colors.cyan)
	if not pending_speech.is_empty() and bool(settings.voice_enabled):
		var next_speech := pending_speech
		pending_speech = ""
		speak_text(next_speech)

func stop_voice() -> void:
	pending_speech = ""
	streaming_voice_chunks.clear()
	streaming_pending_ids.clear()
	streaming_audio_chunks.clear()
	streaming_voice_turn = false
	streaming_voice_started = true
	streaming_voice_wait_started_ms = 0
	if synced_voice_active:
		_on_voice_finished()
	if is_instance_valid(voice_player):
		voice_player.stop()
	set_voice_status("VOICE • READY", colors.cyan)

func set_microphone_available(available: bool) -> void:
	if not is_instance_valid(microphone_button):
		return
	microphone_button.disabled = not available
	if not recording_voice:
		microphone_button.text = "🎙 START TALKING" if available else "🔒 MIC BUSY"

func set_voice_status(message: String, color: Color) -> void:
	if is_instance_valid(voice_status):
		voice_status.text = message
		voice_status.add_theme_color_override("font_color", color)

func _on_auto_speak_toggled(enabled: bool) -> void:
	settings.voice_enabled = enabled
	auto_speak.set_pressed_no_signal(enabled)
	chat_auto_speak.set_pressed_no_signal(enabled)
	save_json(SETTINGS_FILE, settings)
	if not enabled:
		stop_voice()
	set_voice_status("SAM SPEAKS • %s" % ("ENABLED" if enabled else "DISABLED"), colors.green if enabled else colors.muted)
	show_toast("Sam Speaks enabled" if enabled else "Sam Speaks disabled")

func _on_chat_auto_speak_toggled(enabled: bool) -> void:
	_on_auto_speak_toggled(enabled)

func _on_auto_send_toggled(enabled: bool) -> void:
	settings.voice_auto_send = enabled
	settings.mic_notice_shown = true
	save_json(SETTINGS_FILE, settings)
	set_voice_status("AUTO-SEND MIC • %s" % ("ENABLED" if enabled else "DISABLED"), colors.green if enabled else colors.muted)
	show_toast("Auto-send microphone enabled" if enabled else "Auto-send microphone disabled")

func _on_voice_selected(index: int) -> void:
	var voices := ["af_heart", "af_sarah", "am_adam", "am_michael"]
	settings.voice_name = voices[clampi(index, 0, voices.size() - 1)]
	save_json(SETTINGS_FILE, settings)
	show_toast("Kokoro voice • " + voice_selector.get_item_text(index))

func stop_generation() -> void:
	if generating:
		generating = false
		streaming_voice_chunks.clear()
		streaming_pending_ids.clear()
		streaming_audio_chunks.clear()
		streaming_voice_turn = false
		streaming_voice_wait_started_ms = 0
		awaiting_synced_voice = false
		synced_voice_active = false
		synced_voice_failed = false
		synced_reply_text = ""
		synced_reply_index = 0
		voice_player.stop()
		stream_client.close()
		pending_repair_error = ""
		pending_repair_language = ""
		if not response_text.is_empty():
			history.append({"role": "assistant", "content": clean_output(response_text)})
		save_history()
		redraw_history()
		send_button.disabled = false
		stop_button.disabled = true
		set_microphone_available(true)
		set_status("GENERATION ABORTED", colors.pink)
		restore_primary_engine_if_needed()

func restore_primary_engine_if_needed() -> void:
	if not restore_primary_when_done or engine_mode != "vision":
		return
	restore_primary_when_done = false
	engine_mode = "primary"
	set_status("RESTORING CODING ENGINE", colors.amber)
	show_toast("Image analyzed • restoring the primary model")
	call_deferred("start_engine")

func recover_failed_vision_switch(reason: String) -> void:
	if engine_mode != "vision":
		return
	pending_vision_send = false
	restore_primary_when_done = false
	engine_mode = "primary"
	log_line("VISION ERROR", reason + " • restoring the primary model")
	show_toast(reason + " • restoring the primary model")
	call_deferred("start_engine")

func fail_generation(message: String) -> void:
	log_line("ERROR", message)
	stop_generation()
	set_status("GENERATION ERROR", colors.red)
	redraw_history()
	chat_log.append_text("\n[color=#ff667d][b]SAM COULD NOT COMPLETE THIS REQUEST[/b][/color]\n%s\n[color=#8292ad]Open Debug Telemetry for technical details. You can retry after the engine is ready.[/color]\n" % escape_bbcode(message.left(300)))
	chat_log.scroll_to_line(chat_log.get_line_count())
	show_toast("Request failed — details were added to the chat and Debug Telemetry")
	recover_failed_vision_switch("Image analysis failed")

func append_chat(role: String, content: String, image_path := "", file_path := "", history_index := -1) -> void:
	var follow_output := force_chat_follow or chat_is_near_bottom()
	var who := "YOU" if role == "user" else "SAM"
	var color := "#4deeea" if role == "user" else "#76f7a6"
	if role == "assistant" and history_index >= 0:
		chat_log.append_text("\n[table=2][cell][color=%s][b]%s[/b][/color][/cell][cell][right][url=speak:%s][color=#4deeea]🔊 READ ALOUD[/color][/url][/right][/cell][/table]\n" % [color, who, history_index])
	else:
		chat_log.append_text("\n[color=%s][b]%s[/b][/color]\n" % [color, who])
	if role == "assistant" and content.contains("```"):
		append_formatted_code_message(content)
	else:
		chat_log.append_text(escape_bbcode(content))
	chat_log.append_text("\n")
	if not image_path.is_empty() and FileAccess.file_exists(image_path):
		var image := Image.load_from_file(image_path)
		if not image.is_empty():
			var texture := ImageTexture.create_from_image(image)
			chat_log.add_image(texture, 144, 96)
			chat_log.append_text("\n")
	if not file_path.is_empty():
		chat_log.append_text("[bgcolor=#17283a][color=#4deeea]  📄 %s  [/color][/bgcolor]\n" % escape_bbcode(file_path.get_file()))
	if follow_output:
		chat_log.scroll_to_line(chat_log.get_line_count())

func redraw_history() -> void:
	if not is_instance_valid(chat_log):
		return
	chat_log.clear()
	rendered_code_blocks.clear()
	rendered_code_languages.clear()
	chat_log.append_text("[center][color=#8292ad]SAM/OS READY • PRIVATE • LOCAL • OFFLINE[/color][/center]\n")
	for item_index in range(visible_history_start, history.size()):
		var item: Dictionary = history[item_index]
		append_chat(str(item.get("role", "assistant")), str(item.get("content", "")), str(item.get("image_path", "")), str(item.get("file_path", "")), item_index)

func append_formatted_code_message(content: String) -> void:
	var cursor := 0
	while cursor < content.length():
		var fence_start := content.find("```", cursor)
		if fence_start < 0:
			chat_log.append_text(escape_bbcode(content.substr(cursor)))
			break
		chat_log.append_text(escape_bbcode(content.substr(cursor, fence_start - cursor)))
		var first_newline := content.find("\n", fence_start + 3)
		if first_newline < 0:
			chat_log.append_text(escape_bbcode(content.substr(fence_start)))
			break
		var language := content.substr(fence_start + 3, first_newline - fence_start - 3).strip_edges()
		var fence_end := content.find("```", first_newline + 1)
		if fence_end < 0:
			fence_end = content.length()
		var code := content.substr(first_newline + 1, fence_end - first_newline - 1).strip_edges(false, true)
		var code_id := rendered_code_blocks.size()
		rendered_code_blocks.append(code)
		var language_label := language if not language.is_empty() else "code"
		rendered_code_languages.append(language_label)
		var save_action := "     [url=savecode:%s][color=#76f7a6][b]⇩ SAVE FILE[/b][/color][/url]" % code_id if code.length() >= 1200 else ""
		chat_log.append_text("\n[table=1][cell bg=#17283a border=#2b3c55][color=#8da4be]  %s[/color]     [url=copycode:%s][color=#4deeea][b]⧉ COPY CODE[/b][/color][/url]%s\n\n[bgcolor=#0a111c][color=#d8e7ff][indent]%s[/indent][/color][/bgcolor]\n\n[right][url=copycode:%s][color=#4deeea][b]⧉ COPY CODE[/b][/color][/url]%s  [/right][/cell][/table]\n" % [escape_bbcode(language_label), code_id, save_action, escape_bbcode(code), code_id, save_action])
		cursor = fence_end + 3 if fence_end < content.length() else content.length()

func _on_chat_meta_clicked(meta: Variant) -> void:
	var value := str(meta)
	if value.begins_with("speak:"):
		var message_index := int(value.trim_prefix("speak:"))
		if message_index >= 0 and message_index < history.size():
			var item: Dictionary = history[message_index]
			if str(item.get("role", "")) == "assistant":
				stop_voice()
				speak_text(str(item.get("content", "")))
				show_toast("Reading Sam's response aloud")
		return
	if value.begins_with("savecode:"):
		var save_id := int(value.trim_prefix("savecode:"))
		if save_id >= 0 and save_id < rendered_code_blocks.size():
			show_save_code_dialog(save_id)
		return
	if not value.begins_with("copycode:"):
		return
	var code_id := int(value.trim_prefix("copycode:"))
	if code_id < 0 or code_id >= rendered_code_blocks.size():
		return
	DisplayServer.clipboard_set(rendered_code_blocks[code_id])
	show_toast("✓ Code copied to clipboard")

func show_save_code_dialog(code_id: int) -> void:
	var language := rendered_code_languages[code_id].to_lower() if code_id < rendered_code_languages.size() else "code"
	var extensions := {"gdscript": "gd", "python": "py", "javascript": "js", "typescript": "ts", "csharp": "cs", "c#": "cs", "cpp": "cpp", "c++": "cpp", "c": "c", "java": "java", "rust": "rs", "go": "go", "html": "html", "css": "css", "json": "json", "sql": "sql", "powershell": "ps1", "bash": "sh", "shell": "sh"}
	var extension := str(extensions.get(language, "txt"))
	var dialog := FileDialog.new()
	dialog.title = "Save Sam's code"
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.current_file = "sam_code.%s" % extension
	dialog.add_filter("*.%s" % extension, "%s source file" % language.capitalize())
	dialog.file_selected.connect(func(path: String): save_rendered_code(code_id, path); dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered_ratio(0.7)

func save_rendered_code(code_id: int, path: String) -> void:
	if code_id < 0 or code_id >= rendered_code_blocks.size():
		return
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		show_toast("Could not save that code file")
		return
	file.store_string(rendered_code_blocks[code_id])
	file.close()
	show_toast("Code saved • " + path.get_file())

func escape_bbcode(value: String) -> String:
	return value.replace("[", "[lb]")

func clean_output(value: String) -> String:
	var result := value
	for token in STOP_TOKENS:
		var at := result.find(token)
		if at >= 0:
			result = result.left(at)
	return result.strip_edges()

func read_memory() -> String:
	var path := str(settings.memory_path)
	if not FileAccess.file_exists(path):
		return "You are Sam, a direct and intelligent local AI assistant."
	return FileAccess.get_file_as_string(path).strip_edges()

func build_memory_for_request(full_memory: String, request_text: String) -> String:
	var heading := "### AUTOMATIC CODE REPAIR LESSONS:"
	var heading_at := full_memory.find(heading)
	if heading_at < 0:
		return full_memory
	var base_memory := full_memory.left(heading_at).strip_edges()
	var archive: Array[String] = []
	for raw_line in full_memory.substr(heading_at + heading.length()).split("\n", false):
		var lesson := str(raw_line).strip_edges()
		if lesson.begins_with("- "):
			archive.append(lesson)
	if archive.is_empty():
		return base_memory
	var search := request_text.to_lower()
	for punctuation in ["`", "\"", "'", "(", ")", "[", "]", "{", "}", ":", ";", ",", ".", "\n", "\t", "/", "\\"]:
		search = search.replace(punctuation, " ")
	var keywords: Array[String] = []
	var ignored := ["this", "that", "with", "from", "have", "code", "error", "please", "what", "when", "then", "your", "into", "doesnt", "didnt"]
	for raw_word in search.split(" ", false):
		var word := str(raw_word).strip_edges()
		if word.length() >= 4 and not ignored.has(word) and not keywords.has(word):
			keywords.append(word)
	var selected: Array[String] = []
	# Relevant matches come first, while a few recent lessons remain available for
	# vague reports such as "it broke again".
	for lesson in archive:
		var lower_lesson := lesson.to_lower()
		for word in keywords:
			if lower_lesson.contains(word):
				selected.append(lesson)
				break
		if selected.size() >= 16:
			break
	for index in range(archive.size() - 1, -1, -1):
		if selected.size() >= 20:
			break
		if not selected.has(archive[index]):
			selected.append(archive[index])
	if selected.is_empty():
		return base_memory
	return base_memory + "\n\n" + heading + "\n" + "\n".join(selected)

func load_memory_editor() -> void:
	if is_instance_valid(memory_editor):
		memory_editor.text = read_memory()
		log_line("MEMORY", "Reloaded live memory from disk")
		show_toast("↻ Memory reloaded from disk")

func save_memory() -> void:
	var file := FileAccess.open(str(settings.memory_path), FileAccess.WRITE)
	if file == null:
		log_line("ERROR", "Could not write memory file")
		return
	file.store_string(memory_editor.text.strip_edges() + "\n")
	file.close()
	log_line("MEMORY", "Saved live memory; next message will use it")
	set_status("MEMORY SAVED", colors.cyan)
	show_toast("✓ Memory saved successfully")

func browse_path(key: String) -> void:
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	if key == "model_path": dialog.add_filter("*.gguf", "GGUF models")
	if key == "server_path": dialog.add_filter("*.exe", "Windows executables")
	if key == "mmproj_path": dialog.add_filter("*.gguf", "Vision projector")
	if key == "vision_model_path": dialog.add_filter("*.gguf", "Vision GGUF model")
	if key == "vision_mmproj_path": dialog.add_filter("*.gguf", "Matching vision projector")
	if key == "background_path": dialog.add_filter("*.png,*.jpg,*.jpeg,*.webp", "Images")
	dialog.file_selected.connect(func(path: String): fields[key].text = path; highlight_missing_module_requirements(); dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered_ratio(0.75)

func save_and_restart() -> void:
	settings.model_path = fields.model_path.text.strip_edges()
	settings.server_path = fields.server_path.text.strip_edges()
	settings.mmproj_path = fields.mmproj_path.text.strip_edges()
	settings.vision_model_path = fields.vision_model_path.text.strip_edges()
	settings.vision_mmproj_path = fields.vision_mmproj_path.text.strip_edges()
	settings.memory_path = fields.memory_path.text.strip_edges()
	settings.background_path = fields.background_path.text.strip_edges()
	settings.port = int(fields.port.text)
	settings.gpu_layers = int(fields.gpu_layers.text)
	settings.context_size = int(fields.context_size.text)
	settings.max_tokens = int(fields.max_tokens.text)
	settings.temperature = float(fields.temperature.text)
	save_json(SETTINGS_FILE, settings)
	load_memory_editor()
	load_background()
	engine_mode = "primary"
	start_engine()

func use_qwen_coder_preset() -> void:
	fields.model_path.text = QWEN_CODER_14B_MODEL
	fields.gpu_layers.text = "99"
	fields.context_size.text = "8192"
	fields.max_tokens.text = "4096"
	fields.temperature.text = "0.15"
	show_toast("Qwen Coder 14B selected • click SAVE + RELOAD ENGINE")

func use_qwen_vision_preset() -> void:
	fields.vision_model_path.text = QWEN_VISION_7B_MODEL
	fields.vision_mmproj_path.text = QWEN_VISION_7B_MMPROJ
	show_toast("Qwen Vision 7B auto-switch configured • click SAVE + RELOAD ENGINE")

func choose_attachment() -> void:
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.add_filter("*.png,*.jpg,*.jpeg,*.webp,*.gif,*.bmp", "Images")
	dialog.add_filter("*.txt,*.md,*.log,*.json,*.csv,*.xml,*.yaml,*.yml,*.ini,*.cfg", "Text and data")
	dialog.add_filter("*.gd,*.py,*.js,*.ts,*.tsx,*.jsx,*.cs,*.cpp,*.c,*.h,*.hpp,*.java,*.rs,*.go,*.html,*.css,*.scss,*.sql,*.sh,*.ps1,*.bat", "Source code")
	dialog.file_selected.connect(func(path: String): attach_file(path); dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered_ratio(0.75)

func _on_files_dropped(files: PackedStringArray) -> void:
	if files.is_empty():
		return
	var supported := ["png", "jpg", "jpeg", "webp", "gif", "bmp", "txt", "md", "log", "json", "csv", "xml", "yaml", "yml", "ini", "cfg", "gd", "py", "js", "ts", "tsx", "jsx", "cs", "cpp", "c", "h", "hpp", "java", "rs", "go", "html", "css", "scss", "sql", "sh", "ps1", "bat"]
	for path in files:
		if path.get_extension().to_lower() in supported:
			show_toast("Preparing %s…" % path.get_file())
			call_deferred("attach_file", path)
			return
	show_toast("No supported image, text, or code file was found")

func attach_large_paste(pasted_text: String) -> void:
	clear_attachment()
	var timestamp := Time.get_datetime_string_from_system().replace(":", "-")
	var virtual_path := ProjectSettings.globalize_path("user://pasted-text-%s.txt" % timestamp)
	var stored := FileAccess.open(virtual_path, FileAccess.WRITE)
	if stored:
		stored.store_string(pasted_text)
		stored.close()
	attached_file_path = virtual_path
	attached_file_text = pasted_text.left(12000)
	if pasted_text.length() > 12000:
		attached_file_text += "\n\n[Pasted content truncated by SAM-AI after 12,000 characters to protect the context window.]"
	attached_file_kind = "code" if is_code_request(pasted_text.left(3000)) else "text"
	attachment_preview.visible = false
	attachment_tools.visible = true
	attachment_snippet.visible = true
	attachment_snippet.clear()
	attachment_snippet.append_text("[color=#8292ad]%s[/color]\n[bgcolor=#0a111c][color=#d8e7ff]%s[/color][/bgcolor]" % ["CODE PASTE" if attached_file_kind == "code" else "TEXT PASTE", escape_bbcode(attachment_excerpt(pasted_text))])
	attachment_label.text = "%s Large paste converted to attachment • %d characters" % ["⌨" if attached_file_kind == "code" else "📄", pasted_text.length()]
	attachment_label.add_theme_color_override("font_color", colors.cyan)
	show_toast("Large paste attached instead of inserting it into the message box")
	input_box.grab_focus()

func attach_clipboard_image() -> void:
	var clipboard_image: Image = DisplayServer.clipboard_get_image()
	if clipboard_image == null or clipboard_image.is_empty():
		show_toast("The clipboard image could not be decoded")
		return
	var stamp := "%s-%d" % [Time.get_datetime_string_from_system().replace(":", "-"), Time.get_ticks_msec()]
	var image_path := ProjectSettings.globalize_path("user://clipboard-image-%s.png" % stamp)
	var save_error := clipboard_image.save_png(image_path)
	if save_error != OK:
		show_toast("SAM-AI could not save the clipboard image")
		return
	if attach_file(image_path):
		show_toast("Clipboard screenshot attached • add a question, then press Enter")

func attach_file(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var extension := path.get_extension().to_lower()
	var image_extensions := ["png", "jpg", "jpeg", "webp", "gif", "bmp"]
	var code_extensions := ["gd", "py", "js", "ts", "tsx", "jsx", "cs", "cpp", "c", "h", "hpp", "java", "rs", "go", "html", "css", "scss", "sql", "sh", "ps1", "bat"]
	var text_extensions := ["txt", "md", "log", "json", "csv", "xml", "yaml", "yml", "ini", "cfg"]
	clear_attachment()
	if extension in image_extensions:
		var preview_image := Image.load_from_file(path)
		if preview_image.is_empty():
			show_toast("That image could not be decoded")
			return false
		attached_image_path = path
		var preview_longest := maxi(preview_image.get_width(), preview_image.get_height())
		if preview_longest > 640:
			var preview_scale := 640.0 / float(preview_longest)
			preview_image.resize(maxi(1, int(preview_image.get_width() * preview_scale)), maxi(1, int(preview_image.get_height() * preview_scale)), Image.INTERPOLATE_BILINEAR)
		attachment_preview.texture = ImageTexture.create_from_image(preview_image)
		attachment_preview.visible = true
		attachment_tools.visible = true
		attachment_snippet.visible = false
		var vision_ready := (FileAccess.file_exists(str(settings.vision_model_path)) and FileAccess.file_exists(str(settings.vision_mmproj_path))) or not str(settings.mmproj_path).is_empty()
		attachment_label.text = "🖼 %s • %s" % [path.get_file(), "vision ready" if vision_ready else "preview only — configure a vision model + MMPROJ"]
		attachment_label.add_theme_color_override("font_color", colors.green if vision_ready else colors.amber)
		input_box.grab_focus()
		return true
	if extension in code_extensions or extension in text_extensions:
		var source := FileAccess.open(path, FileAccess.READ)
		if source == null:
			show_toast("The file could not be opened")
			return false
		var byte_count := source.get_length()
		if byte_count > 1048576:
			show_toast("File is larger than 1 MB • attach a smaller excerpt")
			return false
		attached_file_text = source.get_as_text()
		if attached_file_text.length() > 12000:
			attached_file_text = attached_file_text.left(12000) + "\n\n[File truncated by SAM-AI after 12,000 characters to protect the context window.]"
		attached_file_path = path
		attached_file_kind = "code" if extension in code_extensions else "text"
		attachment_tools.visible = true
		attachment_snippet.visible = true
		attachment_snippet.clear()
		attachment_snippet.append_text("[color=#8292ad]%s • %s[/color]\n[bgcolor=#0a111c][color=#d8e7ff]%s[/color][/bgcolor]" % ["SOURCE PREVIEW" if attached_file_kind == "code" else "TEXT PREVIEW", escape_bbcode(path.get_file()), escape_bbcode(attachment_excerpt(attached_file_text))])
		attachment_label.text = "%s %s • %.1f KB ready for Sam" % ["⌨" if attached_file_kind == "code" else "📄", path.get_file(), byte_count / 1024.0]
		attachment_label.add_theme_color_override("font_color", colors.cyan)
		input_box.grab_focus()
		show_toast("File attached • tell Sam what you want done, then press Enter")
		return true
	return false

func build_text_attachment_prompt(instruction: String) -> String:
	var kind_note := "source code" if attached_file_kind == "code" else "text document"
	return "%s\n\nATTACHED %s: %s\nRead the attached contents literally and follow the user's instruction. If this is code, inspect it for syntax errors, incorrect identifiers, logic problems, security issues, and incomplete behavior. Cite relevant lines or snippets and provide corrected code when requested.\n\n--- BEGIN ATTACHED FILE ---\n%s\n--- END ATTACHED FILE ---" % [instruction, kind_note, attached_file_path.get_file(), attached_file_text]

func clear_attachment() -> void:
	attached_image_path = ""
	attached_file_path = ""
	attached_file_text = ""
	attached_file_kind = ""
	if is_instance_valid(attachment_preview):
		attachment_preview.texture = null
		attachment_preview.visible = false
	if is_instance_valid(attachment_tools):
		attachment_tools.visible = false
	if is_instance_valid(attachment_snippet):
		attachment_snippet.clear()
		attachment_snippet.visible = false
	if is_instance_valid(attachment_label):
		attachment_label.text = "Drop an image, text, code, JSON, Markdown, or log file here • No file attached"
		attachment_label.add_theme_color_override("font_color", colors.muted)

func apply_background_setting() -> void:
	settings.background_path = fields.background_path.text.strip_edges()
	save_json(SETTINGS_FILE, settings)
	load_background()

func load_background() -> void:
	if not is_instance_valid(background_rect):
		return
	var path := str(settings.background_path)
	if path.is_empty():
		var tab_index := 0
		if is_node_ready() and has_node("Page/Tabs"):
			tab_index = $Page/Tabs.current_tab
		background_rect.texture = load(BUILTIN_BACKGROUNDS[clampi(tab_index, 0, BUILTIN_BACKGROUNDS.size() - 1)])
		background_rect.modulate = Color(1, 1, 1, 0.38)
		return
	if not FileAccess.file_exists(path):
		background_rect.texture = load("res://assets/backgrounds/sam-ai.png")
		return
	var image := Image.load_from_file(path)
	if image.is_empty():
		log_line("ERROR", "Could not load background image")
		return
	background_rect.texture = ImageTexture.create_from_image(image)
	background_rect.modulate = Color(1, 1, 1, 0.38)

func _on_tab_changed(_tab: int) -> void:
	if str(settings.background_path).is_empty():
		load_background()

func refresh_system_specs() -> void:
	if not is_instance_valid(system_report):
		return
	var memory := OS.get_memory_info()
	var total_ram_gb := float(memory.get("physical", 0)) / 1073741824.0
	var available_ram_gb := float(memory.get("available", memory.get("free", 0))) / 1073741824.0
	var gpu_name := RenderingServer.get_video_adapter_name()
	var gpu_api := RenderingServer.get_video_adapter_api_version()
	var gpu_vram_mb := 0.0
	var gpu_used_mb := 0.0
	var gpu_temp := -1.0
	var gpu_load := -1.0
	var smi_output: Array = []
	if OS.get_name() == "Windows":
		var smi_args := PackedStringArray(["--query-gpu=name,memory.total,memory.used,temperature.gpu,utilization.gpu", "--format=csv,noheader,nounits"])
		if OS.execute("nvidia-smi.exe", smi_args, smi_output, true, false) == 0 and not smi_output.is_empty():
			var values := str(smi_output[0]).strip_edges().split(",")
			if values.size() >= 5:
				gpu_name = values[0].strip_edges()
				gpu_vram_mb = float(values[1].strip_edges())
				gpu_used_mb = float(values[2].strip_edges())
				gpu_temp = float(values[3].strip_edges())
				gpu_load = float(values[4].strip_edges())
	var model_gb := get_selected_model_size_gb()
	var verdict := "GPU memory could not be measured; SAM will test CUDA during engine startup."
	var verdict_color := "#f9c74f"
	if gpu_vram_mb > 0.0:
		var vram_gb := gpu_vram_mb / 1024.0
		var estimated_need := model_gb + maxf(1.0, float(settings.context_size) / 8192.0 * 1.6)
		if estimated_need <= vram_gb * 0.86:
			verdict = "Good fit: this model should fit mostly or fully on the GPU at the selected context."
			verdict_color = "#76f7a6"
		elif model_gb <= vram_gb:
			verdict = "Close fit: weights fit, but context and runtime buffers may spill into system RAM. Reduce context if generation slows or VRAM fills."
		else:
			verdict = "Partial GPU offload expected: some layers will use system RAM and CPU. Consider a smaller model or quantization for better speed."
			verdict_color = "#f9c74f"
	var temp_note := "Temperature unavailable"
	if gpu_temp >= 0.0:
		temp_note = "%.0f°C • %s" % [gpu_temp, "warm—watch cooling" if gpu_temp >= 83.0 else "normal operating range"]
	cached_system_summary = "CPU: %s (%d logical threads)\nRAM: %.1f GB total, %.1f GB available\nGPU: %s\nVRAM: %.1f GB total, %.1f GB currently used\nGPU API: %s\nGPU load/temperature: %.0f%%, %s\nSelected model: %s (%.2f GB across GGUF shards)\nContext: %d tokens\nAssessment: %s" % [OS.get_processor_name(), OS.get_processor_count(), total_ram_gb, available_ram_gb, gpu_name, gpu_vram_mb / 1024.0, gpu_used_mb / 1024.0, gpu_api, maxf(gpu_load, 0.0), temp_note, str(settings.model_path).get_file(), model_gb, int(settings.context_size), verdict]
	system_report.clear()
	system_report.append_text("[font_size=24][color=#4deeea]LIVE HARDWARE REPORT[/color][/font_size]\n\n")
	system_report.append_text("[color=#8292ad]OPERATING SYSTEM[/color]\n%s\n\n" % escape_bbcode("%s • %s" % [OS.get_name(), OS.get_version()]))
	system_report.append_text("[color=#8292ad]PROCESSOR[/color]\n%s\n%d logical threads\n\n" % [escape_bbcode(OS.get_processor_name()), OS.get_processor_count()])
	system_report.append_text("[color=#8292ad]SYSTEM MEMORY[/color]\n%.1f GB total • %.1f GB available\n\n" % [total_ram_gb, available_ram_gb])
	system_report.append_text("[color=#8292ad]GRAPHICS[/color]\n%s\n%.1f GB VRAM • %.1f GB used • %.0f%% load • %s\n%s\n\n" % [escape_bbcode(gpu_name), gpu_vram_mb / 1024.0, gpu_used_mb / 1024.0, maxf(gpu_load, 0.0), temp_note, escape_bbcode(gpu_api)])
	system_report.append_text("[color=#8292ad]SELECTED MODEL[/color]\n%s\n%.2f GB GGUF • %d-token context • %d requested GPU layers\n\n" % [escape_bbcode(str(settings.model_path).get_file()), model_gb, int(settings.context_size), int(settings.gpu_layers)])
	system_report.append_text("[font_size=20][color=%s]SAM'S COMPATIBILITY GUIDANCE[/color][/font_size]\n%s\n\n" % [verdict_color, escape_bbcode(verdict)])
	system_report.append_text("[color=#8292ad]CPU fallback is not inherently dangerous, but sustained inference can run the processor hot. Keep vents clear and monitor temperatures. If the machine becomes unstable, reduce GPU layers/context or choose a smaller model.[/color]")

func get_selected_model_size_gb() -> float:
	var model_path := str(settings.model_path)
	if not FileAccess.file_exists(model_path):
		return 0.0
	var total_bytes := 0
	var filename := model_path.get_file()
	var split_marker := filename.find("-00001-of-")
	if split_marker >= 0:
		var prefix := filename.left(split_marker)
		var directory := DirAccess.open(model_path.get_base_dir())
		if directory:
			for entry in directory.get_files():
				if entry.begins_with(prefix) and entry.to_lower().ends_with(".gguf"):
					var shard := FileAccess.open(model_path.get_base_dir().path_join(entry), FileAccess.READ)
					if shard:
						total_bytes += shard.get_length()
	else:
		var file := FileAccess.open(model_path, FileAccess.READ)
		if file:
			total_bytes = file.get_length()
	return float(total_bytes) / 1073741824.0

func ask_sam_about_system() -> void:
	$Page/Tabs.current_tab = 0
	input_box.text = "Analyze my computer and selected local model. Explain compatibility, expected performance, and the best safe settings in plain language.\n\n" + cached_system_summary
	input_box.grab_focus()
	input_box.set_caret_line(input_box.get_line_count() - 1)
	show_toast("System report placed in the composer — review it, then press Enter")

func setup_context_help_buttons() -> void:
	add_tab_help_button($Page/Tabs/MemoryCore/MemoryActions, "MemoryCore", "Explain the MemoryCore tab, what should be stored here, how Save, Reload, Undo, and Redo work, and safe ways to help you remember useful facts.")
	add_tab_help_button($Page/Tabs/EngineSetup/EngineActions, "Engine Setup", "Explain every Engine Setup option in plain language, including the primary model, vision model and MMPROJ, GPU layers, context, tokens, temperature, voice controls, and when changes require an engine reload.")
	add_tab_help_button($Page/Tabs/DebugTelemetry, "Debug Telemetry", "Explain how to read SAM-AI Debug Telemetry, what the common ENGINE, READY, CHAT, DONE, RETRY, VOICE, VISION, and ERROR entries mean, and what information is useful when diagnosing a problem.")

func add_tab_help_button(parent: Control, topic: String, prompt: String) -> void:
	var button := Button.new()
	button.text = "✦ ASK SAM ABOUT THIS"
	button.tooltip_text = "Place a plain-language explanation request in the Chat composer"
	button.pressed.connect(func(): prepare_context_question(topic, prompt))
	parent.add_child(button)

func prepare_context_question(topic: String, prompt: String) -> void:
	$Page/Tabs.current_tab = 0
	input_box.text = prompt
	input_box.grab_focus()
	input_box.set_caret_line(input_box.get_line_count() - 1)
	show_toast(topic + " question placed in the composer — review it, then press Enter")

func setup_stats_tab() -> void:
	var tabs: TabContainer = $Page/Tabs
	var page := VBoxContainer.new()
	page.name = "Stats for Nerds"
	page.add_theme_constant_override("separation", 10)
	tabs.add_child(page)
	var header := HBoxContainer.new()
	page.add_child(header)
	var title := Label.new()
	title.text = "LIVE MODEL TELEMETRY  //  STATS FOR NERDS"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", colors.cyan)
	header.add_child(title)
	var ask := Button.new()
	ask.text = "✦ ASK SAM ABOUT THIS"
	ask.pressed.connect(func(): prepare_context_question("Stats for Nerds", "Explain the current SAM-AI model telemetry and recent events in plain language. Tell me which numbers matter for speed, memory, GPU offload, context, and voice buffering."))
	header.add_child(ask)
	var refresh := Button.new()
	refresh.text = "↻ REFRESH STATS"
	refresh.pressed.connect(refresh_nerd_stats)
	header.add_child(refresh)
	var copy := Button.new()
	copy.text = "⧉ COPY LOG"
	copy.pressed.connect(copy_nerd_stats)
	header.add_child(copy)
	stats_report = RichTextLabel.new()
	stats_report.bbcode_enabled = true
	stats_report.selection_enabled = true
	stats_report.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(stats_report)
	refresh_nerd_stats()

func refresh_nerd_stats() -> void:
	if not is_instance_valid(stats_report):
		return
	var active_model := str(settings.vision_model_path) if engine_mode == "vision" else str(settings.model_path)
	var elapsed := 0.0
	if response_started_ms > 0:
		elapsed = (Time.get_ticks_msec() - response_started_ms) / 1000.0
	var live_rate: float = response_text.length() / maxf(elapsed, 0.01) if generating else 0.0
	var memory_bytes := read_memory().to_utf8_buffer().size()
	var daemon_state: String = "READY" if voice_daemon_announced and voice_daemon_pid > 0 and OS.is_process_running(voice_daemon_pid) else "LOADING / FALLBACK"
	var recent_lines := logs.get_parsed_text().split("\n", false)
	var recent_start := maxi(0, recent_lines.size() - 12)
	var recent := ""
	for index in range(recent_start, recent_lines.size()):
		recent += str(recent_lines[index]) + "\n"
	stats_report.clear()
	stats_report.append_text("[font_size=20][color=#76f7a6]ENGINE + MODEL[/color][/font_size]\n")
	stats_report.append_text("State: [color=%s]%s[/color] • mode: %s • PID: %d\n" % ["#76f7a6" if server_ready else "#f9c74f", "ONLINE" if server_ready else "LOADING / OFFLINE", engine_mode.to_upper(), server_pid])
	stats_report.append_text("Model: %s\nSize: %.2f GB • context: %d tokens • max output: %d • GPU layers: %d\nTemperature: %.2f • port: %d\n\n" % [escape_bbcode(active_model.get_file()), get_selected_model_size_gb(), int(settings.context_size), int(settings.max_tokens), int(settings.gpu_layers), float(settings.temperature), int(settings.port)])
	stats_report.append_text("[font_size=20][color=#4deeea]CURRENT TURN[/color][/font_size]\n")
	stats_report.append_text("Generating: %s • elapsed: %.1fs • received: %d characters • live rate: %.1f chars/s\nRender buffer: %d characters • HTTP retries: %d • history messages: %d\n\n" % ["YES" if generating else "NO", elapsed, response_text.length(), live_rate, render_buffer.length(), stream_retry_count, history.size()])
	stats_report.append_text("[font_size=20][color=#4deeea]MEMORY + VOICE PIPELINE[/color][/font_size]\n")
	stats_report.append_text("MemoryCore payload: %d bytes • visible history begins at: %d\nKokoro worker: %s • text chunks waiting: %d • synthesis jobs: %d • audio chunks buffered: %d • playback begun: %s • playing: %s\n\n" % [memory_bytes, visible_history_start, daemon_state, streaming_voice_chunks.size(), streaming_pending_ids.size(), streaming_audio_chunks.size(), "YES" if streaming_voice_started else "NO", "YES" if voice_player.playing else "NO"])
	stats_report.append_text("[font_size=20][color=#8292ad]RECENT EVENT LOG[/color][/font_size]\n[color=#a9bad3]%s[/color]" % escape_bbcode(recent.strip_edges()))

func copy_nerd_stats() -> void:
	refresh_nerd_stats()
	DisplayServer.clipboard_set(stats_report.get_parsed_text())
	show_toast("Stats for Nerds log copied to clipboard")

func setup_about_tab() -> void:
	var tabs: TabContainer = $Page/Tabs
	if tabs.has_node("About"):
		return
	var about := VBoxContainer.new()
	about.name = "About"
	about.add_theme_constant_override("separation", 14)
	tabs.add_child(about)
	var top_space := Control.new()
	top_space.custom_minimum_size.y = 8
	about.add_child(top_space)
	var heading := Label.new()
	heading.text = "SAM-AI  //  PRIVATE LOCAL INTELLIGENCE"
	heading.add_theme_font_size_override("font_size", 26)
	heading.add_theme_color_override("font_color", colors.cyan)
	about.add_child(heading)
	var info := RichTextLabel.new()
	info.bbcode_enabled = true
	info.selection_enabled = true
	info.size_flags_vertical = Control.SIZE_EXPAND_FILL
	info.append_text("[font_size=19][color=#76f7a6]Built for ownership, privacy, and creative independence.[/color][/font_size]\n\n")
	info.append_text("SAM-AI is a local desktop AI workspace for private chat, code assistance, persistent user-controlled MemoryCore, image understanding, file analysis, speech recognition, and natural local voice. Your configured models run on your own computer through llama.cpp.\n\n")
	info.append_text("[color=#8292ad]CREATED BY[/color]\n[b]Steadyforge[/b] from [b]Astroblitz Creations[/b] & [b]Makazhan[/b]\n\n")
	info.append_text("[color=#8292ad]DESIGN PRINCIPLES[/color]\n• Private and local by default\n• User-owned models, memory, and conversations\n• Transparent performance and debug information\n• Useful on both gaming PCs and lower-end hardware with appropriately sized models\n\n")
	info.append_text("[color=#8292ad]SUPPORT DEVELOPMENT[/color]\nIf SAM-AI is useful to you, you can support continued development through Buy Me a Coffee.\n[url=https://buymeacoffee.com/astroblitzcreations][color=#4deeea][u]https://buymeacoffee.com/astroblitzcreations[/u][/color][/url]\n\n[color=#8292ad]Version 1.0.2 • Windows desktop edition[/color]")
	info.meta_clicked.connect(func(meta: Variant):
		var target := str(meta)
		if target.begins_with("https://buymeacoffee.com/"):
			open_web_url(target))
	about.add_child(info)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	about.add_child(actions)
	var donate := Button.new()
	donate.text = "☕ SUPPORT ASTROBLITZ CREATIONS"
	donate.tooltip_text = "Open buymeacoffee.com/astroblitzcreations in your browser"
	donate.pressed.connect(func(): open_web_url("https://buymeacoffee.com/astroblitzcreations"))
	actions.add_child(donate)
	var ask := Button.new()
	ask.text = "✦ ASK SAM ABOUT THIS"
	ask.pressed.connect(func(): prepare_context_question("About SAM-AI", "Explain what SAM-AI is, its private local design, its main features, and how a new user can get started."))
	actions.add_child(ask)

func show_toast(message: String) -> void:
	toast_label.text = message
	toast_label.modulate = Color(1, 1, 1, 1)
	toast_label.visible = true
	var tween := create_tween()
	tween.tween_interval(1.4)
	tween.tween_property(toast_label, "modulate:a", 0.0, 0.7)
	tween.tween_callback(func(): toast_label.visible = false)

func clear_session() -> void:
	if generating:
		stop_generation()
	history.clear()
	visible_history_start = 0
	save_history()
	redraw_history()
	set_status("NEW SESSION", colors.cyan)

func clear_screen() -> void:
	visible_history_start = history.size()
	chat_log.clear()
	chat_log.append_text("[center][color=#8292ad]SCREEN CLEARED • CHAT CONTEXT PRESERVED[/color][/center]\n")
	set_status("SCREEN CLEARED", colors.cyan)

func copy_chat() -> void:
	DisplayServer.clipboard_set(chat_log.get_parsed_text())
	set_status("CHAT COPIED", colors.cyan)

func copy_logs() -> void:
	DisplayServer.clipboard_set(logs.get_parsed_text())
	set_status("DEBUG LOG COPIED", colors.cyan)

func cycle_theme() -> void:
	var current := str(settings.theme)
	if current == "Neon Night":
		settings.theme = "Amber Terminal"
		colors.cyan = Color("#ffbf47")
		colors.green = Color("#ffe29a")
		colors.void = Color("#100b03")
	elif current == "Amber Terminal":
		settings.theme = "Synthwave"
		colors.cyan = Color("#52f7ff")
		colors.green = Color("#ff70d5")
		colors.void = Color("#100525")
	else:
		settings.theme = "Neon Night"
		colors.cyan = Color("#4deeea")
		colors.green = Color("#76f7a6")
		colors.void = Color("#080b12")
	$Background.color = colors.void
	$Page/Header/Brand.add_theme_color_override("font_color", colors.cyan)
	$Page/Tabs/Chat/VoiceBar/ThemeButton.text = "🎨 " + str(settings.theme)
	save_json(SETTINGS_FILE, settings)
	set_status("THEME • " + str(settings.theme).to_upper(), colors.cyan)

func set_status(text_value: String, color: Color) -> void:
	if is_instance_valid(status_label):
		status_label.text = " " + text_value
	if is_instance_valid(status_dot):
		status_dot.add_theme_color_override("font_color", color)

func log_line(kind: String, message: String) -> void:
	if is_instance_valid(logs):
		logs.append_text("[color=#8292ad]%s[/color] [color=#4deeea][%s][/color] %s\n" % [Time.get_time_string_from_system(), kind, escape_bbcode(message)])

func load_settings() -> void:
	var loaded = load_json(SETTINGS_FILE)
	if loaded is Dictionary:
		settings.merge(loaded, true)
		# Earlier builds capped Qwen Coder at 1,024 tokens (about 3,800 chars),
		# which routinely truncated complete source files. Upgrade that legacy value
		# once while preserving any newer/custom output limit chosen by the user.
		if not bool(loaded.get("long_output_limit_migrated", false)) and int(settings.max_tokens) <= 1024:
			settings.max_tokens = 4096
			settings.long_output_limit_migrated = true
			save_json(SETTINGS_FILE, settings)

func load_history() -> void:
	var loaded = load_json(HISTORY_FILE)
	if loaded is Array:
		history = loaded
		# Repair responses saved by the old JSON-null streaming bug.
		for item in history:
			if item is Dictionary and item.get("content", "") is String:
				item.content = str(item.content).replace("<null>", "")

func save_history() -> void:
	save_json(HISTORY_FILE, history)
	DirAccess.make_dir_recursive_absolute(CHAT_ARCHIVE_DIR)
	save_json(CHAT_ARCHIVE_DIR.path_join("session_" + session_id + ".json"), history)
	var readable := "SAM-AI CHAT TRANSCRIPT\nSession: %s\n\n" % session_id
	for item in history:
		var speaker := "YOU" if str(item.get("role", "")) == "user" else "SAM"
		readable += "%s\n%s\n\n" % [speaker, str(item.get("content", ""))]
		if item.has("image_path"):
			readable += "[Attached image: %s]\n\n" % str(item.image_path)
	var transcript := FileAccess.open(CHAT_ARCHIVE_DIR.path_join("session_" + session_id + ".txt"), FileAccess.WRITE)
	if transcript:
		transcript.store_string(readable)
		transcript.close()

func save_json(path: String, data: Variant) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "  "))
		file.close()

func load_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	return JSON.parse_string(FileAccess.get_file_as_string(path))

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if generating and not response_text.is_empty():
			history.append({"role": "assistant", "content": clean_output(response_text)})
		save_history()
		stop_engine()
		if voice_daemon_pid > 0 and OS.is_process_running(voice_daemon_pid):
			OS.kill(voice_daemon_pid)
		if FileAccess.file_exists(VOICE_DAEMON_PID_FILE):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(VOICE_DAEMON_PID_FILE))
		get_tree().quit()
