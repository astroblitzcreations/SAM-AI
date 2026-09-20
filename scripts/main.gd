extends Control

const DEFAULT_MODEL := "E:/sam-ai/examples/configs/output_q4_k_m.gguf"
const QWEN_CODER_14B_MODEL := "E:/sam-ai/models/Qwen2.5-Coder-14B-Instruct-Q4_K_M/qwen2.5-coder-14b-instruct-q4_k_m-00001-of-00002.gguf"
const QWEN_VISION_7B_MODEL := "E:/sam-ai/models/Qwen2.5-VL-7B-Instruct-Q4_K_M.gguf"
const QWEN_VISION_7B_MMPROJ := "E:/sam-ai/models/mmproj-Qwen2.5-VL-7B-F16.gguf"
const DEFAULT_SERVER := "E:/sam-ai/llama-cuda/llama-server.exe"
const DEFAULT_MEMORY := "E:/sam-ai/system_prompt.txt"
const SETTINGS_FILE := "user://settings.json"
const HISTORY_FILE := "user://last_session.json"
const SESSION_INDEX_FILE := "user://sessions/index.json"
const SESSION_DATA_DIR := "user://sessions/data"
const SERVER_PID_FILE := "user://llama_server.pid"
const FIRST_RUN_FILE := "user://first_run_complete.json"
const CHAT_ARCHIVE_DIR := "E:/sam-ai/godot_chats"
const DEFAULT_KNOWLEDGE_DIR := "user://knowledge_vault"
const KNOWLEDGE_CHUNK_SECONDS := 10.0
const KNOWLEDGE_SCHEMA_VERSION := 4
const VOICE_PYTHON := "E:/sam-ai/.venv/Scripts/python.exe"
const VOICE_BRIDGE := "E:/sam-ai/voice/voice_bridge.py"
const VOICE_DAEMON := "E:/sam-ai/voice/tts_daemon.py"
const VOICE_DAEMON_PID_FILE := "user://tts_daemon.pid"
const LLAMA_WINDOWS_BUILD := "b11064"
const LLAMA_CPU_WINDOWS_URL := "https://github.com/ggml-org/llama.cpp/releases/download/b11064/llama-b11064-bin-win-cpu-x64.zip"
const LLAMA_CUDA_WINDOWS_URL := "https://github.com/ggml-org/llama.cpp/releases/download/b11064/llama-b11064-bin-win-cuda-12.4-x64.zip"
const LLAMA_CUDART_WINDOWS_URL := "https://github.com/ggml-org/llama.cpp/releases/download/b11064/cudart-llama-bin-win-cuda-12.4-x64.zip"
const KOKORO_MODEL_URL := "https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/kokoro-v1.0.onnx"
const KOKORO_VOICES_URL := "https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/voices-v1.0.bin"
const WHISPER_WINDOWS_URL := "https://github.com/ggml-org/whisper.cpp/releases/download/b4938/whisper-bin-x64.zip"
const WHISPER_MODEL_URL := "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en-q5_1.bin?download=true"
# Auto-context recovery v1: reload the actual engine, never fake n_ctx in JSON.
const AUTO_CONTEXT_DEFAULT_MAX := 16384
const AUTO_CONTEXT_HARD_MAX := 131072
const CONTEXT_SAFETY_TOKENS := 512
const CONTEXT_MIN_OUTPUT_TOKENS := 128
const CONTEXT_GROWTH_STEP := 2048
const CONTEXT_MAX_RELOADS := 3
const CONTEXT_MAX_OVERFLOW_RETRIES := 6
const ENGINE_READY_TIMEOUT_MS := 180000
const GPU_FIRST_TOKEN_TIMEOUT_MS := 180000
const CPU_FIRST_TOKEN_TIMEOUT_MS := 600000
const HOST := "127.0.0.1"
const ESP_BRIDGE_HOST := "127.0.0.1"
const ESP_BRIDGE_PORT := 8765
const ESP_TRANSCRIPT_DIR := "E:/sam-ai/external_audio"
const STARTUP_SCENE := preload("res://sam_ai_startup/SAMStartupBackground.tscn")
const STOP_TOKENS := ["<|im_end|>", "<|im_start|>", "<|eot_id|>", "<|end_of_text|>"]
const BUILTIN_BACKGROUNDS := ["res://assets/backgrounds/chat.png",
	"res://assets/backgrounds/memory.png", "res://assets/backgrounds/engine.png",
	"res://assets/backgrounds/debug.png"]

const COMMAND_CENTER_CONNECT_RECOVERY_MS := 15000
const COMMAND_CENTER_FIRST_TOKEN_RECOVERY_MS := 45000
const COMMAND_CENTER_PLAN_HARD_TIMEOUT_MS := 120000
const COMMAND_CENTER_REVIEW_HARD_TIMEOUT_MS := 300000

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
	"port": 8080, "gpu_layers": 99, "context_size": 4992, "max_tokens": 4096,
	"auto_context_enabled": true, "auto_context_max": AUTO_CONTEXT_DEFAULT_MAX,
	"temperature": 0.1, "voice_enabled": true, "voice_name": "af_heart",
	"voice_auto_send": false, "mic_notice_shown": false, "microphone_muted": true,
	"live_voice_notice_shown": false, "live_voice_silence_seconds": 4.0,
	"live_voice_vad_threshold_db": -46.0, "live_voice_barge_threshold_db": -44.0, "live_voice_barge_in": true,
	"live_voice_echo_guard": true, "live_voice_sync_text": true, "live_voice_chunk_seconds": 3,
	"live_voice_duplex_v2_migrated": false,
	"humor_enabled": true, "humor_level": 2,
	"rag_enabled": true, "rag_top_k": 5, "rag_context_chars": 5600, "rag_diversity": true,
	"audio_input_device": "Default", "knowledge_source_mode": "Microphone",
	"knowledge_storage_path": "", "knowledge_limit_gb": 10.0,
	"knowledge_compress_audio": true, "knowledge_keep_audio": false,
	"knowledge_transcript_only_migrated": false,
	"discovery_interest_terms": [],
	"spellcheck_enabled": true, "spellcheck_ignored_words": ["godot", "sam", "gguf", "whisper", "kokoro", "llama"],
	"pc_commands_enabled": false, "command_workspace_path": "",
	"command_center_mode": "safe", "command_center_shell": "PowerShell", "command_center_run_preference": "ask",
	"vault_auto_maintenance": true, "vault_last_maintenance_date": "",
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
	"module_url_whisper_model": WHISPER_MODEL_URL,
	"module_url_wan22": "https://huggingface.co/Wan-AI/Wan2.2-TI2V-5B-Diffusers",
	"image_generation_engine": "SAM Local Inpainting",
	"video_generation_engine": "Wan 2.2 TI2V-5B",
	"visual_module_preference": "auto",
	"ai_visual_planning_enabled": true,
	"generation_fallback_enabled": true,
	"network_guard_enabled": false
}
var history: Array = []
var server_pid := -1
var server_owned := false
var server_ready := false
var generating := false
var health_client := HTTPClient.new()
var stream_client := HTTPClient.new()
var esp_bridge := StreamPeerTCP.new()
var esp_bridge_buffer := PackedByteArray()
var esp_bridge_enabled := true
var esp_bridge_hello_sent := false
var esp_transcript_seen: Dictionary = {}
var esp_transcript_elapsed := 0.0
var health_timer := 0.0
var health_retry_at_ms := 0
var health_request_started_ms := 0
var health_request_sent := false
var context_request_serial := 0
var context_engine_serial := 0
var context_runtime_size := 0
var context_model_train_limit := 0
var context_metadata_loaded := false
var context_tokenizer_available := true
var context_prompt_tokens := -1
var context_protected_tail_count := 1
var context_desired_output := 4096
var context_reload_pending := false
var context_rollback_pending := false
var context_resume_serial := -1
var context_previous_size := 0
var context_reload_attempts := 0
var context_overflow_retries := 0
var context_growth_blocked: Dictionary = {}
var stream_response_code := 0
var stream_http_body := PackedByteArray()
var stream_json_response := false
var stream_error_started_ms := 0
var load_started_ms := 0
var response_started_ms := 0
var stream_request_sent_ms := 0
var response_text := ""
var pending_repair_error := ""
var pending_repair_language := ""
var force_chat_follow := false
var render_buffer := ""
var stream_chat_started := false
var stream_finished := false
var stream_repetition_stopped := false
var active_artifact_builder_mode := false
var active_artifact_language := ""
var active_artifact_request := ""
var artifact_auto_retry_count := 0
var artifact_retry_in_progress := false
var artifact_partial_response := ""
var artifact_output_token_budget := 0
var artifact_progress_next_chars := 0
var artifact_progress_step := 500
var active_image_edit_action := false
var stream_retry_count := 0
var stream_retry_not_before_ms := 0
var visible_history_start := 0
var rendered_code_blocks: Array[String] = []
var rendered_code_languages: Array[String] = []
var rendered_code_paths: Array[String] = []
var sse_buffer := PackedByteArray()
var sent_messages: Array[String] = []
var history_cursor := -1
var history_draft := ""
var attached_image_path := ""
var attached_file_path := ""
var attached_file_text := ""
var attached_file_kind := ""
var skip_attachment_learning_confirm := false
var engine_mode := "primary"
var pending_vision_send := false
var restore_primary_when_done := false
var thinking_elapsed := 0.0
var thinking_frame := -1
var thinking_indicator: Label
var pending_message_queue: Array[String] = []
var queued_message_already_shown := false
var new_chat_welcome_active := false
var new_chat_welcome_visible := false
var new_chat_welcome_text := ""
var new_chat_welcome_index := 0
var new_chat_welcome_elapsed := 0.0
var request_preparing := false
var shutdown_started := false
var loading_elapsed := 0.0
var background_rect: TextureRect
var attachment_label: Label
var attachment_preview: TextureRect
var toast_label: Label
var toast_tween: Tween

var status_label: Label
var status_dot: Label
var privacy_button: MenuButton
var microphone_privacy_button: Button
var pc_commands_button: MenuButton
var command_process_pids: Array[int] = []
var command_center_output: RichTextLabel
var command_center_input: TextEdit
var command_center_status: Label
var command_center_mode_selector: OptionButton
var command_center_shell_selector: OptionButton
var command_center_jobs: Array[Dictionary] = []
var command_center_request_active := false
var command_center_original_task := ""
var command_center_last_status_ms := 0
var command_center_history_checkpoint := -1
var command_center_attachment_path := ""
var command_center_attachment_text := ""
var command_center_attachment_kind := ""
var command_center_attachment_hash := ""
var command_center_attachment_label: Label
var command_center_last_result_path := ""
var command_center_last_plan_script := ""
var command_center_result_panel: RichTextLabel
var command_center_last_result_source_path := ""
var command_center_last_result_source_hash := ""
var command_center_last_review_report := ""
var command_center_plan_started_ms := 0
var command_center_plan_retry_count := 0
var command_center_plan_last_stream_chars := 0
var command_center_plan_last_progress_ms := 0
var command_center_watchdog_abort := false
var command_center_file_review_active := false
var command_center_stage := ""
var command_center_vision_notes := ""
var command_center_pending_primary_followup := false
var command_center_image_paths: Array[String] = []
var command_center_image_label: Label
var command_center_run_regular_check: CheckButton
var command_center_run_admin_check: CheckButton
var supervised_run_jobs: Array[Dictionary] = []
var visual_job_previous_max_fps := 0
var automatic_path_repairs: Dictionary = {}
var pending_image_capability_request := ""
var pending_image_capability_path := ""
var pc_admin_request_active := false
var admin_status_path := ""
var admin_helper_pid := -1
var admin_console_pid := -1
var playground_list: ItemList
var playground_status: Label
var playground_entries: Array[Dictionary] = []
var privacy_activity_active := false
var privacy_activity_title := "No internet access"
var privacy_activity_destination := "None"
var privacy_activity_reason := "SAM is running its model and tools locally on this computer."
var privacy_activity_detail := "Localhost traffic stays on this PC and is not internet access."
var privacy_safety_score := 10
var privacy_reset_at_msec := 0
var chat_log: RichTextLabel
var input_box: TextEdit
var send_button: Button
var stop_button: Button
var memory_editor: TextEdit
var logs: RichTextLabel
const TELEMETRY_PAGE_SIZE := 50
const TELEMETRY_MAX_ENTRIES := 5000
var telemetry_entries: Array[Dictionary] = []
var telemetry_page := 0
var telemetry_follow_latest := true
var telemetry_dirty := false
var telemetry_render_due := 0
var telemetry_page_label: Label
var telemetry_first_button: Button
var telemetry_previous_button: Button
var telemetry_next_button: Button
var telemetry_last_button: Button
var fields := {}
var session_id := ""
var sessions: Array[Dictionary] = []
var session_sidebar: PanelContainer
var session_list: Tree
var session_stats_label: Label
var session_active_label: Label
var session_sidebar_open := false
var session_edge_button: Button
var session_resize_grip: ColorRect
var session_sidebar_width := 360.0
var session_sidebar_resizing := false
var session_sidebar_hide_ticket := 0
var session_sidebar_tween: Tween
var session_scroll_was_bottom := true
var session_scroll_ratio := 1.0
var pending_session_switch := ""
var local_tool_inventory := ""
var microphone_player: AudioStreamPlayer
var voice_player: AudioStreamPlayer
var record_effect: AudioEffectRecord
var microphone_button: Button
var voice_status: Label
var auto_speak: CheckButton
var chat_auto_speak: CheckButton
var auto_send_voice: CheckButton
var voice_selector: OptionButton
var live_voice_button: Button
var live_voice_silence_spin: SpinBox
var live_voice_vad_spin: SpinBox
var live_voice_barge_spin: SpinBox
var live_voice_barge_toggle: CheckButton
var live_voice_enabled := false
var live_voice_state := "IDLE"
var live_voice_level_db := -60.0
var live_voice_speech_seen := false
var live_voice_speech_started_ms := 0
var live_voice_last_speech_ms := 0
var live_voice_barge_candidate_ms := 0
var live_voice_tts_guard_until_ms := 0
var live_voice_finalize_requested := false
var live_voice_restart_pending := false
var live_voice_interrupt_count := 0
var live_voice_barge_in_active := false
var live_voice_status_poll_due := 0
var live_voice_ui_due := 0
var live_voice_turn_counter := 0
var live_voice_audio_parts: Array[String] = []
var live_voice_echo_reference := ""
var live_voice_echo_floor_db := -60.0
var live_voice_echo_floor_ready := false
var live_voice_text_reveal_credit := 0.0
var live_voice_heard_assistant_text := ""
var live_voice_last_reveal_ms := 0
var live_voice_text_gate_open := false
var streaming_voice_code_fence_open := false
var humor_laugh_pending := false
var humor_laugh_injected := false
var voice_discard_current_tts := false
var voice_thread_kind := ""
var recording_voice := false
var voice_capture_pid := -1
var voice_capture_stop_path := ""
var voice_capture_status_path := ""
var voice_capture_owner := ""
var voice_capture_audio_path := ""
var voice_capture_dir := ""
var voice_capture_session := ""
var voice_capture_next_chunk := 1
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
var setup_check_poll_elapsed := 0.0
var setup_last_required_state := ""
var windows_runtime_request: HTTPRequest
var windows_runtime_download_path := ""
var startup_screen: Control
var startup_message: Label
var startup_detail: Label
var startup_visual_prompt: Label
var startup_telemetry: Label
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
var spellcheck_bar: HBoxContainer
var spellcheck_dirty := false
var spellcheck_elapsed := 0.0
var spellcheck_pid := -1
var spellcheck_input_path := ""
var spellcheck_output_path := ""
var applying_spellcheck := false
var spellcheck_last_results: Dictionary = {}
var spellcheck_context_actions: Dictionary = {}
var spellcheck_context_word := ""
const KNOWLEDGE_QUEUE_LIMIT := 64
const KNOWLEDGE_ORPHAN_RECOVERY_BATCH := 64
const KNOWLEDGE_SILENCE_LOG_INTERVAL_MS := 5000
const KNOWLEDGE_REVIEW_LATER_LIMIT := 100
var knowledge_recording := false
var knowledge_elapsed := 0.0
var knowledge_chunk_elapsed := 0.0
var knowledge_session_id := ""
var knowledge_chunk_number := 0
var knowledge_queue: Array[Dictionary] = []
var knowledge_process_pid := -1
var knowledge_capture_pid := -1
var knowledge_capture_status_path := ""
var knowledge_capture_stop_path := ""
var knowledge_capture_level_db := -60.0
var knowledge_capture_source := ""
var knowledge_signal_seen := false
var knowledge_silence_elapsed := 0.0
var knowledge_silent_skip_count := 0
var knowledge_last_silence_log_ms := 0
var knowledge_active_job: Dictionary = {}
var knowledge_active_output := ""
var knowledge_entries: Array = []
var knowledge_status: Label
var knowledge_record_button: Button
var knowledge_search: LineEdit
var knowledge_category: OptionButton
var knowledge_report: RichTextLabel
var knowledge_live_transcript: RichTextLabel
var knowledge_source_selector: OptionButton
var knowledge_device_selector: OptionButton
var knowledge_level_meter: ProgressBar
var knowledge_device_hint: Label
var knowledge_storage_path_label: Label
var knowledge_storage_stats: RichTextLabel
var knowledge_limit_field: SpinBox
var knowledge_compress_toggle: CheckButton
var knowledge_keep_audio_toggle: CheckButton
var knowledge_inner_tabs: TabContainer
var knowledge_for_you_report: RichTextLabel
var knowledge_discovery_button: Button
var knowledge_discovery_tween: Tween
var study_queue_count: Label
var study_working_title: Label
var study_relevant_count: Label
var study_discard_count: Label
var study_paper: Label
var study_cat: Label
var study_activity: RichTextLabel
var study_elapsed := 0.0
var study_process_elapsed := 0.0
var study_animation_frame := 0
var study_current_id := ""
var study_stage: Control
var study_inbox_icon: Label
var study_desk_icon: Label
var study_retain_icon: Label
var study_review_icon: Label
var study_archive_icon: Label
var study_animation_state := "idle"
var study_animation_elapsed := 0.0
var study_worker_done := false
var study_pending_worker_result: Dictionary = {}
var study_pending_archive_panel: PanelContainer
var study_pending_archive_text: RichTextLabel
var study_pending_archive_countdown: Label
var study_pending_archive: Dictionary = {}
var study_archive_deadline_ms := 0
var study_last_archive_before: Dictionary = {}
var study_last_archive_id := ""
const STUDY_WALK_SECONDS := 0.65
const STUDY_READ_SECONDS := 1.0
const STUDY_ARCHIVE_CONFIRM_MS := 6500
var security_report: RichTextLabel
var security_audit_pid := -1
var security_audit_output := ""
var security_snapshot_pid := -1
var security_snapshot_output := ""
var security_process_tree: Tree
var security_connection_tree: Tree
var security_guard_label: Label
var security_selected_pid := -1
var security_selected_name := ""
var security_selected_path := ""
var security_blocked_rules := 0
var network_guard_button: Button
var network_guard_header_button: Button
var slow_inference_notice_shown := false
var security_startup_tree: Tree
var security_services_tree: Tree
var security_rules_tree: Tree
var security_context_menu: PopupMenu
var security_processes: Array = []
var security_connections: Array = []
var security_startup_items: Array = []
var security_services: Array = []
var security_rules: Array = []
var security_process_sort_column := 0
var security_process_sort_ascending := true
var security_connection_sort_column := 0
var security_connection_sort_ascending := true
var security_selected_rule := ""
var security_seen_connections: Dictionary = {}
var security_alert_baseline_ready := false
var security_alert_queue: Array[Dictionary] = []
var security_alert_dialog_open := false
var security_refresh_due_ms := 0
var security_verify_requested := false
var security_lockdown_active := false
var security_wfp_driver_state := "Not installed"

func _ready() -> void:
	# We stage shutdown ourselves so llama.cpp can release CUDA before Godot tears
	# down the window/rendering device.  Closing both at once can stall Windows.
	get_tree().auto_accept_quit = false
	var intro_completed := bool(ProjectSettings.get_setting("sam_ai/intro_completed", false))
	show_startup_screen()
	if intro_completed:
		startup_screen.transition_to_loading(0.0)
		startup_status_panel.visible = true
		set_startup_progress(0.0, "BEGINNING LOCAL STARTUP", "Preparing the local intelligence console")
	else:
		set_startup_progress(5.0, "INITIALIZING SAM-AI", "Preparing the local intelligence console")
	load_settings()
	local_tool_inventory = discover_local_tool_inventory()
	load_session_index()
	set_startup_progress(12.0, "LOADING SETTINGS", "Restoring your engine and interface preferences")
	load_history()
	save_history()
	set_startup_progress(20.0, "RESTORING CHAT MEMORY", "Loading saved conversations and MemoryCore")
	bind_editor_ui()
	setup_session_sidebar()
	apply_theme_recursive(self)
	redraw_history()
	if history.is_empty():
		call_deferred("start_new_chat_welcome")
	force_chat_follow = true
	call_deferred("force_chat_to_live_edge")
	load_memory_editor()
	call_deferred("begin_startup")
	call_deferred("connect_esp_bridge")
func connect_esp_bridge() -> void:
	if not esp_bridge_enabled:
		return
	var result := esp_bridge.connect_to_host(ESP_BRIDGE_HOST, ESP_BRIDGE_PORT)
	log_line("ESP", "Bridge connection requested on %s:%d (result %d)" % [ESP_BRIDGE_HOST, ESP_BRIDGE_PORT, result])


func poll_esp_bridge() -> void:
	if not esp_bridge_enabled:
		return
	esp_bridge.poll()
	if esp_bridge.get_status() == StreamPeerTCP.STATUS_CONNECTED:
		if not esp_bridge_hello_sent:
			var hello := JSON.stringify({"type":"hello","version":1,"device":"sam-ai"}) + "\n"
			esp_bridge.put_data(hello.to_utf8_buffer())
			esp_bridge_hello_sent = true
		var available := esp_bridge.get_available_bytes()
		if available > 0:
			esp_bridge_buffer.append_array(esp_bridge.get_data(available)[1])
			while true:
				var newline := esp_bridge_buffer.find(10)
				if newline < 0:
					break
				var line := esp_bridge_buffer.slice(0, newline).get_string_from_utf8()
				esp_bridge_buffer = esp_bridge_buffer.slice(newline + 1)
				var frame = JSON.parse_string(line)
				if frame is Dictionary:
					log_line("ESP", "Received " + JSON.stringify(frame))

func send_esp_state(value: String, text_value := "") -> void:
	if esp_bridge.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		return
	var frame := JSON.stringify({"type":"state","value":value,"text":text_value}) + "\n"
	esp_bridge.put_data(frame.to_utf8_buffer())

func send_esp_audio(stream: AudioStreamWAV) -> void:
	if esp_bridge.get_status() != StreamPeerTCP.STATUS_CONNECTED or stream == null:
		return
	var pcm := stream.data
	if pcm.is_empty():
		return
	var length := PackedByteArray()
	length.resize(4)
	length.encode_u32(0, pcm.size())
	esp_bridge.put_data(length)
	esp_bridge.put_data(pcm)

func bind_editor_ui() -> void:
	background_rect = $BackgroundImage
	status_dot = $Page/Header/StatusDot
	status_label = $Page/Header/StatusLabel
	setup_privacy_indicator()
	setup_playground_manager()
	setup_command_center()
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
	setup_toast_card()
	memory_editor = $Page/Tabs/MemoryCore/MemoryEditor
	logs = $Page/Tabs/DebugTelemetry/Logs
	setup_debug_telemetry_pager()
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
	install_auto_context_controls()
	install_personality_rag_controls()
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
	$Page/Tabs/DebugTelemetry/ClearLog.pressed.connect(_telemetry_clear)
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
	setup_quick_image_prompts()
	setup_context_help_buttons()
	setup_security_center()
	setup_stats_tab()
	setup_voice_system()
	setup_knowledge_vault()
	setup_about_tab()
	configure_all_tab_scrolling()
	load_background()
	input_box.placeholder_text = "Type your message to Sam here…  Enter sends • Shift+Enter adds a new line • ↑/↓ recalls"
	input_box.editable = true
	input_box.caret_blink = true
	input_box.caret_blink_interval = 0.53
	input_box.add_theme_color_override("caret_color", colors.cyan)
	refresh_system_specs()

func configure_all_tab_scrolling() -> void:
	# Every long-form view either owns a ScrollContainer or a text/tree control
	# with a native scrollbar. Force scrollbars visible so new users can tell that
	# more content exists instead of assuming it was cut off.
	var pending: Array[Node] = [$Page/Tabs]
	while not pending.is_empty():
		var node: Node = pending.pop_back()
		for child in node.get_children():
			pending.append(child)
		if node is ScrollContainer:
			(node as ScrollContainer).vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
		elif node is RichTextLabel:
			(node as RichTextLabel).scroll_active = true

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
	var reset_button := make_button("↻ FACTORY RESET SAM-AI", request_factory_reset, colors.red)
	reset_button.tooltip_text = "Erase SAM-AI settings, chats, sessions, logs, and local app data, then restart at first-time setup. Downloaded models are not deleted."
	top_actions.add_child(reset_button)
	module_requirement_banner = Label.new()
	module_requirement_banner.name = "ModuleRequirementsBanner"
	module_requirement_banner.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	module_requirement_banner.add_theme_font_size_override("font_size", 18)
	module_tab.add_child(module_requirement_banner)
	module_scroll = ScrollContainer.new()
	module_scroll.name = "ModuleScroll"
	module_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	module_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
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
	var main_model_button := make_button("USE MAIN CHAT MODEL", switch_to_primary_model, colors.green)
	main_model_button.tooltip_text = "Return to the configured primary local GGUF used for normal chat, knowledge, and coding"
	module_actions.add_child(main_model_button)
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
	var runtime_actions := HBoxContainer.new()
	runtime_actions.add_theme_constant_override("separation", 7)
	content.add_child(runtime_actions)
	runtime_actions.add_child(make_button("CHECK OFFICIAL LATEST RELEASE", func(): open_web_url("https://github.com/ggml-org/llama.cpp/releases", "Open the official llama.cpp releases page to check for a newer Windows runtime"), colors.cyan))
	var browse_runtime := make_button("LOAD LLAMA-SERVER.EXE", func(): browse_path("server_path"), colors.green)
	runtime_actions.add_child(browse_runtime)
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
	add_visual_generation_engine_controls(content)
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

func request_factory_reset() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "RESET SAM-AI TO A FRESH INSTALL?"
	dialog.dialog_text = "This removes SAM-AI's saved settings, chats, project sessions, KnowledgeVault database, logs, and cached state from its private app-data folder.\n\nIt does NOT delete GGUF models, llama.cpp, voice modules, generated projects, or other files outside SAM-AI's private app-data folder.\n\nSAM-AI will close, restart, and show the first-time setup again. This cannot be undone."
	dialog.ok_button_text = "RESET EVERYTHING + RESTART"
	dialog.confirmed.connect(func():
		dialog.queue_free()
		perform_factory_reset())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, colors.red)
	dialog.popup_centered(Vector2i(760, 470))

func perform_factory_reset() -> void:
	stop_generation()
	stop_voice_daemon()
	stop_engine()
	var private_root := ProjectSettings.globalize_path("user://").simplify_path().replace("\\", "/").trim_suffix("/")
	if private_root.is_empty() or private_root.length() < 8:
		show_toast("Reset stopped because the private app-data path could not be verified")
		return
	var reset_targets := [
		"settings.json", "last_session.json", "first_run_complete.json", "llama_server.pid",
		"tts_daemon.pid", "sessions", "knowledge_vault", "logs", "cache", "temp"
	]
	for relative_path in reset_targets:
		var target := private_root.path_join(relative_path).simplify_path().replace("\\", "/")
		if target == private_root or not target.begins_with(private_root + "/"):
			continue
		if DirAccess.dir_exists_absolute(target):
			remove_directory_tree(target)
		elif FileAccess.file_exists(target):
			DirAccess.remove_absolute(target)
	var executable := OS.get_executable_path()
	if OS.has_feature("editor"):
		OS.create_process(executable, PackedStringArray(["--path", ProjectSettings.globalize_path("res://")]), false)
	else:
		OS.create_process(executable, PackedStringArray(), false)
	get_tree().quit()

func remove_directory_tree(path: String) -> void:
	var directory := DirAccess.open(path)
	if directory == null:
		return
	for filename in directory.get_files():
		DirAccess.remove_absolute(path.path_join(filename))
	for child in directory.get_directories():
		remove_directory_tree(path.path_join(child))
	DirAccess.remove_absolute(path)

func add_visual_generation_engine_controls(parent: VBoxContainer) -> void:
	var heading := Label.new()
	heading.text = "IMAGE + VIDEO GENERATION ENGINES"
	heading.add_theme_font_size_override("font_size", 20)
	heading.add_theme_color_override("font_color", colors.cyan)
	parent.add_child(heading)
	var note := Label.new()
	note.text = "Keep multiple local engines installed and choose which one SAM uses. The current segmentation/inpainting editor remains available so you can switch back when Wan performs poorly. Wan 2.2 TI2V-5B is official and open-weight, but its documented minimum is 24 GB VRAM. On this RTX 3060 12 GB it is experimental, uses aggressive CPU offload, and may be very slow or run out of memory."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_color_override("font_color", colors.muted)
	parent.add_child(note)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 8)
	parent.add_child(grid)
	var image_label := Label.new()
	image_label.text = "IMAGE / CLOTHING ENGINE"
	grid.add_child(image_label)
	var image_selector := OptionButton.new()
	for title in ["SAM Local Inpainting", "Wan 2.2 TI2V-5B (video; photo edits use inpainting)", "Automatic Best Available"]:
		image_selector.add_item(title)
	var saved_image := str(settings.get("image_generation_engine", "SAM Local Inpainting"))
	for index in range(image_selector.item_count):
		if image_selector.get_item_text(index) == saved_image:
			image_selector.select(index)
	image_selector.item_selected.connect(func(index: int):
		settings.image_generation_engine = image_selector.get_item_text(index)
		settings.visual_module_preference = "wan" if str(settings.image_generation_engine).begins_with("Wan 2.2") else ("local" if str(settings.image_generation_engine).begins_with("SAM Local") else "auto")
		save_json(SETTINGS_FILE, settings)
		show_toast("Image engine set to " + str(settings.image_generation_engine)))
	grid.add_child(image_selector)
	var video_label := Label.new()
	video_label.text = "VIDEO ENGINE"
	grid.add_child(video_label)
	var video_selector := OptionButton.new()
	for title in ["Wan 2.2 TI2V-5B", "Disabled"]:
		video_selector.add_item(title)
	var saved_video := str(settings.get("video_generation_engine", "Wan 2.2 TI2V-5B"))
	for index in range(video_selector.item_count):
		if video_selector.get_item_text(index) == saved_video:
			video_selector.select(index)
	video_selector.item_selected.connect(func(index: int):
		settings.video_generation_engine = video_selector.get_item_text(index)
		if str(settings.video_generation_engine).begins_with("Wan 2.2"):
			settings.visual_module_preference = "wan"
		save_json(SETTINGS_FILE, settings)
		show_toast("Video engine set to " + str(settings.video_generation_engine)))
	grid.add_child(video_selector)
	var fallback := CheckButton.new()
	fallback.text = "USE THE LOCAL INPAINTING EDITOR FOR ATTACHED-PHOTO EDITS"
	fallback.button_pressed = bool(settings.get("generation_fallback_enabled", true))
	fallback.toggled.connect(func(enabled: bool):
		settings.generation_fallback_enabled = enabled
		save_json(SETTINGS_FILE, settings))
	parent.add_child(fallback)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	parent.add_child(actions)
	actions.add_child(make_button("INSTALL / REPAIR CURRENT IMAGE EDITOR", show_image_edit_capability_dialog, colors.green))
	var wan_status := Label.new()
	var wan_marker := command_workspace_dir().path_join("WanRuntime/wan22_ti2v_5b.ok")
	var wan_cuda_marker := command_workspace_dir().path_join("WanRuntime/wan_cuda.ok")
	if FileAccess.file_exists(wan_marker) and FileAccess.file_exists(wan_cuda_marker):
		wan_status.text = "WAN STATUS: MODEL WEIGHTS + CUDA RUNTIME READY"
		wan_status.add_theme_color_override("font_color", colors.green)
	elif FileAccess.file_exists(wan_marker):
		wan_status.text = "WAN STATUS: MODEL WEIGHTS INSTALLED • CUDA RUNTIME NEEDS REPAIR"
		wan_status.add_theme_color_override("font_color", colors.amber)
	else:
		wan_status.text = "WAN STATUS: MODEL + CUDA RUNTIME NOT INSTALLED"
		wan_status.add_theme_color_override("font_color", colors.amber)
	parent.add_child(wan_status)
	var wan_link_row := HBoxContainer.new()
	wan_link_row.add_theme_constant_override("separation", 7)
	parent.add_child(wan_link_row)
	var wan_link := LineEdit.new()
	var official_wan_url := "https://huggingface.co/Wan-AI/Wan2.2-TI2V-5B-Diffusers"
	wan_link.text = str(settings.get("module_url_wan22", official_wan_url))
	wan_link.placeholder_text = "Official or replacement Wan model page"
	wan_link.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wan_link_row.add_child(wan_link)
	wan_link_row.add_child(make_button("SAVE LINK", func(): save_module_link("module_url_wan22", wan_link.text), colors.muted))
	wan_link_row.add_child(make_button("RESTORE OFFICIAL", func(): wan_link.text = official_wan_url; save_module_link("module_url_wan22", official_wan_url), colors.muted))
	wan_link_row.add_child(make_button("INSTALL / REPAIR WAN + CUDA", show_wan22_install_dialog, colors.cyan))
	wan_link_row.add_child(make_button("MODEL PAGE", func(): open_web_url(wan_link.text, "Open the selected Wan model page"), colors.muted))

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
	if FileAccess.file_exists(VOICE_DAEMON_PID_FILE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(VOICE_DAEMON_PID_FILE))

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
	open_web_url(clean_url, "Download a user-selected local AI module")

func url_host(url: String) -> String:
	var without_scheme := url.get_slice("://", 1)
	return without_scheme.get_slice("/", 0).get_slice("?", 0)

func open_web_url(url: String, reason := "Open a user-requested web page") -> void:
	set_privacy_activity(true, "External access handed to browser", url_host(url), reason, 8, "SAM opens the address in your web browser. The browser performs the transfer; SAM does not upload MemoryCore, chats, or KnowledgeVault.", 15000)
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
	set_privacy_activity(false)

func setup_chat_workspace() -> void:
	chat_log.scroll_following = false
	chat_log.selection_enabled = true
	chat_log.deselect_on_focus_loss_enabled = false
	var chat_page: VBoxContainer = $Page/Tabs/Chat
	var composer: VBoxContainer = input_box.get_parent()
	thinking_indicator = Label.new()
	thinking_indicator.name = "LiveThinkingIndicator"
	thinking_indicator.text = ""
	thinking_indicator.visible = false
	thinking_indicator.add_theme_color_override("font_color", colors.green)
	thinking_indicator.add_theme_font_size_override("font_size", 16)
	composer.add_child(thinking_indicator)
	composer.move_child(thinking_indicator, input_box.get_index())
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
	var new_chat_button := make_button("＋ NEW CHAT", create_new_session, colors.green)
	new_chat_button.tooltip_text = "Start a fresh project session while keeping MemoryCore and approved KnowledgeVault learning"
	toolbar.add_child(new_chat_button)
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
	# Add Ctrl+C support for copying selected chat text
	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.keycode == KEY_C:
		if is_instance_valid(chat_log):
			var selected := chat_log.get_selected_text()
			if not selected.is_empty():
				DisplayServer.clipboard_set(selected)
				get_viewport().set_input_as_handled()
				return

	if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.keycode == KEY_F:
		show_chat_search()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and is_instance_valid(chat_search_bar) and chat_search_bar.visible:
		hide_chat_search()
		get_viewport().set_input_as_handled()
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
	chat_log.text = raw_chat_text # Clear highlights by restoring clean text
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

var raw_chat_text: String = "" # Keep a clean backup of your full chat text here
func show_chat_search_match(index: int) -> void:
	if chat_search_matches.is_empty():
		chat_search_status.text = "NO MATCH"
		return
		
	chat_search_match_index = clampi(index, 0, chat_search_matches.size() - 1)
	var match_start: int = chat_search_matches[chat_search_match_index]
	
	# Scroll the RichTextLabel to the line containing the match
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
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# Fetch Godot's built-in RichTextLabel context menu
			var menu := chat_log.get_menu()
			if menu:
				# Position the menu at the current global mouse coordinates and display it
				menu.position = Vector2i(get_viewport().get_mouse_position())
				menu.popup()
				get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed:
		if event.keycode in [KEY_UP, KEY_PAGEUP, KEY_HOME]:
			force_chat_follow = false

func chat_is_near_bottom() -> bool:
	var bar := chat_log.get_v_scroll_bar()
	return bar.value >= bar.max_value - bar.page - 24.0

func setup_spellcheck_bar(composer: VBoxContainer) -> void:
	spellcheck_bar = HBoxContainer.new()
	spellcheck_bar.name = "LocalSpellCheck"
	spellcheck_bar.add_theme_constant_override("separation", 6)
	composer.add_child(spellcheck_bar)
	composer.move_child(spellcheck_bar, input_box.get_index() + 1)
	input_box.text_changed.connect(_on_composer_text_changed)
	var spelling_menu := input_box.get_menu()
	if spelling_menu:
		spelling_menu.about_to_popup.connect(_prepare_spellcheck_context_menu)
		spelling_menu.id_pressed.connect(_on_spellcheck_context_action)
	show_spellcheck_results([])

func _on_composer_text_changed() -> void:
	if applying_spellcheck or not bool(settings.get("spellcheck_enabled", true)):
		return
	spellcheck_dirty = true
	spellcheck_elapsed = 0.0

func poll_spellcheck(delta: float) -> void:
	if spellcheck_pid > 0 and not OS.is_process_running(spellcheck_pid):
		spellcheck_pid = -1
		var parsed = load_json(spellcheck_output_path)
		if parsed is Dictionary and str(parsed.get("text", "")) != input_box.text.strip_edges():
			_on_composer_text_changed()
		elif parsed is Dictionary and parsed.get("misspellings", []) is Array:
			show_spellcheck_results(parsed.get("misspellings", []))
		else:
			show_spellcheck_unavailable()
	if not spellcheck_dirty or spellcheck_pid > 0 or not bool(settings.get("spellcheck_enabled", true)):
		return
	spellcheck_elapsed += delta
	if spellcheck_elapsed < 0.7:
		return
	spellcheck_dirty = false
	var value := input_box.text.strip_edges()
	if value.length() < 3:
		show_spellcheck_results([])
		return
	spellcheck_input_path = ProjectSettings.globalize_path("user://spellcheck_input.txt")
	spellcheck_output_path = ProjectSettings.globalize_path("user://spellcheck_result.json")
	var input_file := FileAccess.open(spellcheck_input_path, FileAccess.WRITE)
	if input_file == null:
		return
	input_file.store_string(value.left(8000))
	input_file.close()
	if FileAccess.file_exists(spellcheck_output_path):
		DirAccess.remove_absolute(spellcheck_output_path)
	var ignored_words: Array = settings.get("spellcheck_ignored_words", [])
	var ignored_parts: Array[String] = []
	for ignored_word in ignored_words:
		ignored_parts.append(str(ignored_word))
	var helper := ProjectSettings.globalize_path("res://tools/sam_spellcheck.py")
	spellcheck_pid = OS.create_process(str(settings.voice_python_path), PackedStringArray([helper, "--input", spellcheck_input_path, "--output", spellcheck_output_path, "--ignore", ",".join(ignored_parts)]), false)
	if spellcheck_pid <= 0:
		show_spellcheck_unavailable()

func show_spellcheck_results(misspellings: Array) -> void:
	if not is_instance_valid(spellcheck_bar):
		return
	spellcheck_last_results.clear()
	for item in misspellings:
		if item is Dictionary:
			var issue: Dictionary = item
			spellcheck_last_results[str(issue.get("word", "")).to_lower()] = issue.get("suggestions", [])
	for child in spellcheck_bar.get_children():
		child.queue_free()
	var toggle := CheckButton.new()
	toggle.text = "ABC"
	toggle.tooltip_text = "Offline live spelling suggestions"
	toggle.button_pressed = bool(settings.get("spellcheck_enabled", true))
	toggle.toggled.connect(_on_spellcheck_toggled)
	spellcheck_bar.add_child(toggle)
	var status := Label.new()
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if misspellings.is_empty():
		status.text = "SPELLING • LOCAL • READY"
		status.add_theme_color_override("font_color", colors.muted)
	else:
		status.text = "%d POSSIBLE SPELLING %s • RIGHT-CLICK THE WORD" % [misspellings.size(), "ISSUE" if misspellings.size() == 1 else "ISSUES"]
		status.add_theme_color_override("font_color", colors.amber)
	spellcheck_bar.add_child(status)

func _word_at_composer_caret() -> Dictionary:
	var line_index := input_box.get_caret_line()
	var column := input_box.get_caret_column()
	if line_index < 0 or line_index >= input_box.get_line_count():
		return {}
	var line := input_box.get_line(line_index)
	column = clampi(column, 0, line.length())
	var left := column
	var right := column
	while left > 0 and (line.substr(left - 1, 1).to_lower() != line.substr(left - 1, 1).to_upper() or line.substr(left - 1, 1).is_valid_int() or line.substr(left - 1, 1) in ["'", "-"]):
		left -= 1
	while right < line.length() and (line.substr(right, 1).to_lower() != line.substr(right, 1).to_upper() or line.substr(right, 1).is_valid_int() or line.substr(right, 1) in ["'", "-"]):
		right += 1
	return {"word": line.substr(left, right - left), "line": line_index, "left": left, "right": right}

func _prepare_spellcheck_context_menu() -> void:
	var menu := input_box.get_menu()
	spellcheck_context_actions.clear()
	if not menu or not bool(settings.get("spellcheck_enabled", true)):
		return
	for item_index in range(menu.item_count - 1, -1, -1):
		if menu.get_item_id(item_index) >= 9100:
			menu.remove_item(item_index)
	var location := _word_at_composer_caret()
	spellcheck_context_word = str(location.get("word", ""))
	var suggestions: Array = spellcheck_last_results.get(spellcheck_context_word.to_lower(), [])
	if spellcheck_context_word.is_empty() or suggestions.is_empty():
		return
	menu.add_separator("SAM SPELLING", 9100)
	for index in range(mini(6, suggestions.size())):
		var action_id := 9101 + index
		menu.add_item("Replace with “%s”" % str(suggestions[index]), action_id)
		spellcheck_context_actions[action_id] = {"correction": str(suggestions[index]), "location": location}
	menu.add_item("Add “%s” to local dictionary" % spellcheck_context_word, 9199)
	spellcheck_context_actions[9199] = {"ignore": true, "location": location}

func _on_spellcheck_context_action(action_id: int) -> void:
	if not spellcheck_context_actions.has(action_id):
		return
	var action: Dictionary = spellcheck_context_actions[action_id]
	if bool(action.get("ignore", false)):
		ignore_spellcheck_word(spellcheck_context_word)
		return
	var location: Dictionary = action.get("location", {})
	applying_spellcheck = true
	input_box.select(int(location.get("line", 0)), int(location.get("left", 0)), int(location.get("line", 0)), int(location.get("right", 0)))
	input_box.insert_text_at_caret(str(action.get("correction", spellcheck_context_word)))
	applying_spellcheck = false
	_on_composer_text_changed()
	input_box.grab_focus()

func _on_spellcheck_toggled(enabled: bool) -> void:
	settings.spellcheck_enabled = enabled
	save_json(SETTINGS_FILE, settings)
	if enabled:
		_on_composer_text_changed()
	else:
		spellcheck_dirty = false
		show_spellcheck_results([])

func show_spellcheck_unavailable() -> void:
	show_spellcheck_results([])
	if is_instance_valid(spellcheck_bar) and spellcheck_bar.get_child_count() > 1:
		var status := spellcheck_bar.get_child(1) as Label
		if status:
			status.text = "SPELLING • LOCAL CHECKER UNAVAILABLE"
			status.add_theme_color_override("font_color", colors.red)

func apply_spellcheck_suggestion(word: String, correction: String) -> void:
	applying_spellcheck = true
	input_box.text = input_box.text.replace(word, correction).replace(word.capitalize(), correction.capitalize())
	input_box.set_caret_line(input_box.get_line_count() - 1)
	input_box.set_caret_column(input_box.get_line(input_box.get_line_count() - 1).length())
	applying_spellcheck = false
	_on_composer_text_changed()
	input_box.grab_focus()

func ignore_spellcheck_word(word: String) -> void:
	var ignored: Array = settings.get("spellcheck_ignored_words", []).duplicate()
	if not ignored.has(word.to_lower()):
		ignored.append(word.to_lower())
	settings.spellcheck_ignored_words = ignored
	save_json(SETTINGS_FILE, settings)
	_on_composer_text_changed()
	show_toast("Added '%s' to SAM's local spelling dictionary" % word)

func setup_attachment_card() -> void:
	var composer: VBoxContainer = input_box.get_parent()
	setup_spellcheck_bar(composer)
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
	attachment_tools.add_child(make_button("＋ ADD FILE TO KNOWLEDGE", import_current_attachment_to_knowledge, colors.green))
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

func quick_image_prompt_presets() -> Array[Dictionary]:
	return [
		{"name": "WINDOW PORTRAIT • COZY LIVING ROOM", "prompt": "Create a photorealistic portrait of an adult woman sitting beside a window in a cozy living room, looking directly at the camera with a natural gentle smile. Medium shot, face clearly visible, symmetrical eyes, realistic skin texture, detailed hair, soft cinematic lighting. Save both the original Wan image and the face-restored version."},
		{"name": "PROFESSIONAL STUDIO PORTRAIT", "prompt": "Create a polished photorealistic studio portrait of an adult person looking naturally toward the camera with a relaxed confident expression. Chest-up composition, face clearly visible, realistic skin texture, detailed hair, proportional eyes, subtle depth of field, soft key light and gentle rim lighting, neutral elegant background. Save both the original Wan image and the face-restored version."},
		{"name": "FULL BODY • GOLDEN-HOUR CITY", "prompt": "Create a photorealistic full-body image of an adult woman standing naturally on a quiet city street during golden hour. Balanced relaxed pose, hands visible, anatomically correct body proportions, detailed clothing and hair, warm cinematic sunlight, realistic shadows, shallow depth of field, face clearly visible. Save both the original Wan image and the face-restored version."},
		{"name": "COZY KITCHEN • CANDID", "prompt": "Create a photorealistic candid image of an adult woman standing at a kitchen counter in a warm modern kitchen, gently smiling toward the camera. Natural posture and hand placement, realistic anatomy, detailed face and hair, coherent appliances and furnishings, soft window light, believable contact shadows. Save both the original Wan image and the face-restored version."},
		{"name": "BEDROOM • PEACEFUL MORNING", "prompt": "Create a tasteful photorealistic morning portrait of an adult woman sitting comfortably on the edge of a neatly made bed in a cozy bedroom. Natural seated pose, appropriate casual clothing, face clearly visible, detailed hair, realistic skin texture and anatomy, soft morning window light, calm cinematic atmosphere. Save both the original Wan image and the face-restored version."},
		{"name": "OUTDOOR PARK • NATURAL SMILE", "prompt": "Create a photorealistic portrait of an adult woman walking slowly through a green park and looking toward the camera with a natural smile. Three-quarter composition, realistic stride and anatomy, detailed face and hair, soft overcast daylight, subtle background bokeh, natural colors and believable shadows. Save both the original Wan image and the face-restored version."},
		{"name": "REFERENCE • SIT ON COUCH", "prompt": "Use the attached image as the identity and appearance reference. Create a clearly changed photorealistic scene of the same person sitting naturally on a comfortable couch in a cozy living room. Preserve the recognizable face, hair, skin tone, clothing, and accessories unless explicitly changed. Use realistic seated anatomy, hands, contact shadows, perspective, and warm window lighting. Save both the original Wan image and the face-restored version."},
		{"name": "REFERENCE • SLEEPING ON BED", "prompt": "Use the attached image as the identity and appearance reference. Create a clearly changed photorealistic scene of the same person sleeping peacefully on a bed with eyes closed and a relaxed natural expression. Preserve the recognizable face, hair, skin tone, clothing, and accessories unless explicitly changed. Use realistic reclining anatomy, believable pillow and mattress contact, soft bedroom lighting, and coherent shadows. Save both the original Wan image and the face-restored version."},
		{"name": "REFERENCE • NEW ROOM AND POSE", "prompt": "Use the attached image as the identity and appearance reference. Place the same person in a clearly different realistic room and pose while preserving the recognizable face, hair, skin tone, clothing, and accessories unless explicitly changed. Create a visible compositional transformation rather than a near-copy. Use anatomically correct proportions, natural hands, coherent perspective, environmental lighting, and contact shadows. Save both the original Wan image and the face-restored version."}
	]

func setup_quick_image_prompts() -> void:
	# The editor scene and exported startup shell can reparent/rename the Chat
	# containers. Anchor to the already-resolved Send button instead of looking
	# the container up again through a brittle absolute node path.
	var actions := send_button.get_parent()
	if actions == null:
		log_line("UI", "Quick Image menu skipped because the live chat action bar was unavailable")
		return
	var menu := MenuButton.new()
	menu.name = "QuickImagePrompts"
	menu.text = "✨ QUICK IMAGE"
	menu.tooltip_text = "Insert a polished image prompt into the composer"
	var popup := menu.get_popup()
	var presets := quick_image_prompt_presets()
	for index in range(presets.size()):
		popup.add_item(str(presets[index].name), index)
	popup.id_pressed.connect(func(id: int): insert_quick_image_prompt(id))
	actions.add_child(menu)
	var new_session := actions.get_node_or_null("NewSession")
	if new_session != null:
		actions.move_child(menu, new_session.get_index())
	apply_theme_recursive(menu)

func insert_quick_image_prompt(preset_id: int) -> void:
	var presets := quick_image_prompt_presets()
	if preset_id < 0 or preset_id >= presets.size():
		return
	var selected: Dictionary = presets[preset_id]
	input_box.text = str(selected.prompt)
	input_box.grab_focus()
	input_box.set_caret_line(input_box.get_line_count() - 1)
	if str(selected.name).begins_with("REFERENCE") and attached_image_path.is_empty():
		show_toast("Quick reference prompt added • attach an image before transmitting")
	else:
		show_toast("Quick image prompt added • review or customize, then transmit")

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
	logo.text = "SAM-AI LOCAL INTELLIGENCE"
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
	startup_telemetry = Label.new()
	startup_telemetry.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	startup_telemetry.add_theme_color_override("font_color", colors.cyan)
	stack.add_child(startup_telemetry)
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

func set_startup_progress(percent: float, message: String, detail: String = "", telemetry: String = "") -> void:
	if not is_instance_valid(startup_screen):
		return
	startup_progress.value = clampf(percent, 0.0, 100.0)
	startup_message.text = message
	startup_detail.text = detail
	if is_instance_valid(startup_telemetry):
		startup_telemetry.text = telemetry
	var percent_label: Label = startup_progress.get_parent().get_node("Percent")
	percent_label.text = "%03d%%  %s" % [int(startup_progress.value), "▰".repeat(int(startup_progress.value / 5.0)) + "▱".repeat(20 - int(startup_progress.value / 5.0))]

func style_visual_progress_bar(bar: ProgressBar) -> void:
	var track := StyleBoxFlat.new()
	track.bg_color = Color("#050b14")
	track.border_color = Color(0.0, 0.90, 1.0, 0.30)
	track.set_border_width_all(1)
	track.set_corner_radius_all(6)
	bar.add_theme_stylebox_override("background", track)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("#00c9ff")
	fill.border_color = Color("#46f5ff")
	fill.set_border_width_all(1)
	fill.set_corner_radius_all(6)
	fill.shadow_color = Color(0.0, 0.75, 1.0, 0.45)
	fill.shadow_size = 5
	bar.add_theme_stylebox_override("fill", fill)

func visual_scanner() -> String:
	var frames := ["[■□□□□]", "[□■□□□]", "[□□■□□]", "[□□□■□]", "[□□□□■]", "[□□□■□]", "[□□■□□]", "[□■□□□]"]
	return str(frames[int(Time.get_ticks_msec() / 80) % frames.size()])

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
	panel.custom_minimum_size = Vector2(760, 330)
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
	margin.add_theme_constant_override("margin_left", 26)
	margin.add_theme_constant_override("margin_right", 26)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	margin.add_child(stack)
	var logo := Label.new()
	logo.text = "SAM-AI VISUAL ENGINE"
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logo.clip_text = true
	logo.add_theme_color_override("font_color", colors.cyan)
	logo.add_theme_font_size_override("font_size", 20)
	stack.add_child(logo)
	startup_message = Label.new()
	startup_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	startup_message.clip_text = true
	startup_message.custom_minimum_size = Vector2(0, 34)
	startup_message.add_theme_color_override("font_color", colors.text)
	startup_message.add_theme_font_size_override("font_size", 24)
	stack.add_child(startup_message)
	startup_detail = Label.new()
	startup_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	startup_detail.clip_text = true
	startup_detail.custom_minimum_size = Vector2(0, 24)
	startup_detail.add_theme_color_override("font_color", colors.muted)
	stack.add_child(startup_detail)
	startup_visual_prompt = Label.new()
	startup_visual_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	startup_visual_prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	startup_visual_prompt.custom_minimum_size = Vector2(0, 52)
	startup_visual_prompt.add_theme_color_override("font_color", Color("#a9bad3"))
	startup_visual_prompt.add_theme_font_size_override("font_size", 14)
	startup_visual_prompt.text = "PROMPT  Preparing request details…"
	stack.add_child(startup_visual_prompt)
	startup_telemetry = Label.new()
	startup_telemetry.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	startup_telemetry.clip_text = true
	startup_telemetry.custom_minimum_size = Vector2(0, 24)
	startup_telemetry.add_theme_color_override("font_color", Color("#00e5ff"))
	startup_telemetry.add_theme_font_size_override("font_size", 17)
	stack.add_child(startup_telemetry)
	startup_progress = ProgressBar.new()
	startup_progress.custom_minimum_size = Vector2(0, 22)
	startup_progress.show_percentage = false
	style_visual_progress_bar(startup_progress)
	stack.add_child(startup_progress)
	var percent := Label.new()
	percent.name = "Percent"
	percent.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	percent.add_theme_color_override("font_color", Color("#00e5ff"))
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
		# The bundled runtime is deliberately CPU-only so every supported Windows
		# computer can start. Users can replace it with CUDA/Vulkan from Modules.
		if not server_directory_has_acceleration(portable_server):
			settings.gpu_layers = 0
	var models_dir := portable_root.path_join("models")
	if DirAccess.dir_exists_absolute(models_dir):
		var directory := DirAccess.open(models_dir)
		if directory:
			for filename in directory.get_files():
				if filename.to_lower().ends_with(".gguf") and not filename.to_lower().contains("mmproj"):
					settings.model_path = models_dir.path_join(filename)
					break

func server_directory_has_acceleration(server_path: String) -> bool:
	var directory_path := server_path.strip_edges().get_base_dir()
	var directory := DirAccess.open(directory_path)
	if directory == null:
		return false
	var found_cublas := false
	var found_cudart := false
	for filename in directory.get_files():
		var lower := filename.to_lower()
		found_cublas = found_cublas or (lower.begins_with("cublas64_") and lower.ends_with(".dll"))
		found_cudart = found_cudart or (lower.begins_with("cudart64_") and lower.ends_with(".dll"))
		if lower in ["ggml-vulkan.dll", "ggml-hip.dll", "ggml-sycl.dll"]:
			return true
	return found_cublas and found_cudart

func running_in_windows_sandbox() -> bool:
	return OS.get_name() == "Windows" and OS.get_environment("USERNAME").to_lower() == "wdagutilityaccount"

func detected_gpu_name() -> String:
	var name := RenderingServer.get_video_adapter_name().strip_edges()
	return name if not name.is_empty() else "No GPU name reported by Windows"

func model_size_gb_for_path(model_path: String) -> float:
	if not FileAccess.file_exists(model_path):
		return 0.0
	var total_bytes := 0
	var filename := model_path.get_file()
	var split_marker := filename.find("-00001-of-")
	if split_marker >= 0:
		var prefix := filename.left(split_marker)
		var directory := DirAccess.open(model_path.get_base_dir())
		if directory:
			for candidate in directory.get_files():
				if candidate.begins_with(prefix) and candidate.to_lower().ends_with(".gguf"):
					var shard := FileAccess.open(model_path.get_base_dir().path_join(candidate), FileAccess.READ)
					if shard:
						total_bytes += shard.get_length()
						shard.close()
	else:
		var file := FileAccess.open(model_path, FileAccess.READ)
		if file:
			total_bytes = file.get_length()
			file.close()
	return float(total_bytes) / 1073741824.0

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
	var model_gb := model_size_gb_for_path(model_path)
	var memory := OS.get_memory_info()
	var physical_gb := float(memory.get("physical", 0)) / 1073741824.0
	var accelerated_runtime := server_directory_has_acceleration(setup_server_path.text.strip_edges())
	var memory_warning := model_ok and not accelerated_runtime and physical_gb > 0.0 and model_gb + 1.0 > physical_gb
	var gpu_name := detected_gpu_name()
	var sandbox := running_in_windows_sandbox()
	var shard_ok := true
	if model_path.to_lower().contains("-00001-of-00002.gguf"):
		shard_ok = FileAccess.file_exists(model_path.replace("-00001-of-00002.gguf", "-00002-of-00002.gguf"))
	var vision_configured := not str(settings.vision_model_path).is_empty() or not str(settings.vision_mmproj_path).is_empty()
	var vision_ok := not vision_configured or (FileAccess.file_exists(str(settings.vision_model_path)) and FileAccess.file_exists(str(settings.vision_mmproj_path)))
	setup_checks.clear()
	setup_checks.append_text("[color=#4deeea][b]THIS COMPUTER[/b][/color]  %.1f GB physical RAM • %s\n" % [physical_gb, escape_bbcode(gpu_name)])
	setup_checks.append_text("[color=#4deeea][b]ENGINE MODE[/b][/color]  %s\n" % ("GPU acceleration available" if accelerated_runtime else "Bundled CPU runtime • CUDA is optional"))
	if sandbox:
		setup_checks.append_text("[color=#f9c74f]WINDOWS SANDBOX:[/color] Windows can show the host GPU name while CUDA/VRAM passthrough remains unavailable. Test GPU acceleration on a normal Windows installation.\n\n")
	else:
		setup_checks.append_text("\n")
	setup_checks.append_text("[color=%s]%s[/color]  GGUF language model\n" % ["#76f7a6" if model_ok else "#ff667d", "✓" if model_ok else "✕"])
	setup_checks.append_text("[color=%s]%s[/color]  llama.cpp Windows engine\n" % ["#76f7a6" if server_ok else "#ff667d", "✓" if server_ok else "✕"])
	setup_checks.append_text("[color=%s]%s[/color]  %s\n" % ["#76f7a6" if cuda_ok else "#8292ad", "✓" if cuda_ok else "○", "NVIDIA CUDA acceleration detected" if cuda_ok else "NVIDIA CUDA acceleration not installed (optional; CPU mode will be used)"])
	setup_checks.append_text("[color=%s]%s[/color]  Microsoft Visual C++ runtime\n" % ["#76f7a6" if windows_runtime_ok else "#ff667d", "✓" if windows_runtime_ok else "✕"])
	if memory_warning:
		setup_checks.append_text("[color=#f9c74f]⚠ CPU MEMORY WARNING[/color]  %.2f GB model + working memory on %.1f GB physical RAM. SAM will let you start, but Windows may page to disk and replies can be extremely slow. Recommended: Qwen 3B, or install the matching CUDA runtime on a normal NVIDIA PC.\n" % [model_gb, physical_gb])
	else:
		setup_checks.append_text("[color=#76f7a6]✓[/color]  Model/runtime memory check has no obvious blocking issue\n")
	setup_checks.append_text("[color=%s]%s[/color]  Kokoro + Whisper voice package (optional)" % ["#76f7a6" if voice_ok else "#f9c74f", "✓" if voice_ok else "!"])
	setup_checks.append_text("\n[color=%s]%s[/color]  Split GGUF companion shards\n" % ["#76f7a6" if shard_ok else "#ff667d", "✓" if shard_ok else "✕"])
	setup_checks.append_text("[color=%s]%s[/color]  Vision model + matching MMPROJ (optional)" % ["#76f7a6" if vision_ok else "#f9c74f", "✓" if vision_ok else "!"])
	if show_feedback:
		var all_required_ok := model_ok and server_ok and windows_runtime_ok and shard_ok
		setup_checks.append_text("\n\n[center][color=%s][b]COMPONENT CHECK COMPLETE • %s[/b][/color][/center]" % ["#76f7a6" if all_required_ok else "#f9c74f", Time.get_time_string_from_system()])
		show_toast("Component check complete • ready" if all_required_ok else "Component check complete • review warnings")
		set_status("COMPONENT CHECK COMPLETE", colors.green if all_required_ok else colors.amber)
	var setup_ready := model_ok and server_ok and windows_runtime_ok and shard_ok
	var complete_button: Button = $FirstRunSetup/Center/Panel/Margin/Content/Actions/Complete
	complete_button.disabled = not setup_ready
	complete_button.text = ("START ANYWAY — CPU MAY BE VERY SLOW" if memory_warning else "STEP 4 — START SAM") if setup_ready else "STEP 4 — COMPLETE REQUIRED ITEMS ABOVE"
	apply_ready_action_style(complete_button, setup_ready, memory_warning)
	var runtime_button: Button = $FirstRunSetup/Center/Panel/Margin/Content/Actions/WindowsRuntime
	runtime_button.disabled = windows_runtime_ok
	runtime_button.text = "✓ STEP 3 — WINDOWS RUNTIME INSTALLED" if windows_runtime_ok else "STEP 3 — INSTALL WINDOWS RUNTIME (REQUIRED)"
	apply_missing_requirement_style(runtime_button, not windows_runtime_ok)
	apply_missing_requirement_style($FirstRunSetup/Center/Panel/Margin/Content/ModelRow/BrowseModel, not model_ok)
	apply_missing_requirement_style($FirstRunSetup/Center/Panel/Margin/Content/ServerRow/BrowseServer, not server_ok)
	setup_last_required_state = "%s|%s|%s" % [model_ok, server_ok, windows_runtime_ok]

func apply_ready_action_style(button: Button, ready: bool, warning: bool = false) -> void:
	button.remove_theme_stylebox_override("normal")
	if not ready:
		return
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.24, 0.16, 0.025, 0.98) if warning else Color(0.035, 0.25, 0.17, 0.98)
	style.border_color = colors.amber if warning else colors.green
	style.set_border_width_all(2)
	style.set_corner_radius_all(7)
	button.add_theme_stylebox_override("normal", style)

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
	set_privacy_activity(true, "Downloading trusted runtime", "aka.ms (Microsoft)", "Install the Microsoft Visual C++ runtime required by the local inference engine.", 9, "SAM downloads one installer to your Downloads folder. No chats, memories, recordings, or device data are uploaded.")
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
	set_privacy_activity(false)
	setup_checks.append_text("\n[color=#76f7a6]✓ Download complete. Opening the Microsoft installer…[/color]")
	show_toast("Runtime downloaded • opening installer")
	var open_error := OS.shell_open(windows_runtime_download_path)
	if open_error != OK:
		show_toast("Installer saved in Downloads • open vc_redist.x64.exe")
	var runtime_button: Button = $FirstRunSetup/Center/Panel/Margin/Content/Actions/WindowsRuntime
	runtime_button.disabled = false
	runtime_button.text = "CHECK AFTER INSTALL"

func fail_windows_runtime_download(message: String) -> void:
	set_privacy_activity(false)
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
	var memory := OS.get_memory_info()
	var physical_gb := float(memory.get("physical", 0)) / 1073741824.0
	if physical_gb > 0.0 and physical_gb <= 6.0:
		settings.context_size = 4096
		settings.max_tokens = 1536
		settings.auto_context_max = 8192
	elif int(settings.context_size) < 8192:
		settings.context_size = 8192
	for key in ["context_size", "max_tokens"]:
		if fields.has(key):
			fields[key].text = setting_text(key)
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
	chat_log.context_menu_enabled = true
	chat_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	chat_log.gui_input.connect(_on_chat_log_gui_input)
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

func start_engine(context_reload: bool = false) -> void:
	if not context_reload:
		# A manual engine/model change cancels a queued automatic replay.
		if context_reload_pending:
			set_context_setting(context_previous_size)
		context_reload_pending = false
		context_rollback_pending = false
		context_resume_serial = -1
		if generating:
			restore_primary_when_done = false
			stop_generation()
	context_engine_serial += 1
	context_runtime_size = maxi(512, int(settings.context_size))
	context_model_train_limit = 0
	context_metadata_loaded = false
	context_tokenizer_available = true
	health_request_sent = false
	health_request_started_ms = 0
	health_retry_at_ms = 0
	set_startup_progress(44.0, "STARTING LOCAL ENGINE", "Preparing llama.cpp and checking for stale processes")
	recover_orphaned_server()
	stop_engine(false)
	if not FileAccess.file_exists(str(settings.server_path)):
		if recover_context_reload_failure("Server executable was not found"):
			return
		set_status("SERVER FILE NOT FOUND", colors.red)
		log_line("ERROR", "Missing server: " + str(settings.server_path))
		set_startup_progress(0.0, "ENGINE MODULE NOT FOUND", "Open Setup Check and select llama-server.exe")
		return
	var active_model := str(settings.vision_model_path) if engine_mode == "vision" else str(settings.model_path)
	var active_mmproj := str(settings.vision_mmproj_path) if engine_mode == "vision" else str(settings.mmproj_path)
	if not FileAccess.file_exists(active_model):
		if recover_context_reload_failure("Model file was not found"):
			return
		set_status("MODEL FILE NOT FOUND", colors.red)
		log_line("ERROR", "Missing model: " + active_model)
		set_startup_progress(0.0, "MODEL NOT FOUND", "Open Setup Check and select a GGUF model")
		return
	var accelerated_runtime := server_directory_has_acceleration(str(settings.server_path))
	var effective_gpu_layers := int(settings.gpu_layers) if accelerated_runtime else 0
	var memory := OS.get_memory_info()
	var physical_gb := float(memory.get("physical", 0)) / 1073741824.0
	var model_gb := model_size_gb_for_path(active_model)
	if not accelerated_runtime and physical_gb > 0.0 and model_gb + 1.0 > physical_gb:
		var fit_message := "CPU memory warning: %.2f GB model plus working memory on %.1f GB physical RAM. Startup is allowed, but Windows paging may make loading and replies extremely slow." % [model_gb, physical_gb]
		show_toast("Starting with limited RAM • expect slow CPU paging")
		log_line("WARNING", fit_message)
	var engine_log_path := ProjectSettings.globalize_path("user://llama_server.log")
	if FileAccess.file_exists(engine_log_path):
		DirAccess.remove_absolute(engine_log_path)
	var args := ["-m", active_model, "-ngl", str(effective_gpu_layers), "-c", str(int(settings.context_size)), "-np", "1", "--cache-ram", "256", "--port", str(int(settings.port)), "--host", HOST, "--log-file", engine_log_path, "--log-colors", "off"]
	if not active_mmproj.is_empty() and FileAccess.file_exists(active_mmproj):
		args.append_array(["--mmproj", active_mmproj])
	server_pid = OS.create_process(str(settings.server_path), args, false)
	if server_pid <= 0:
		if recover_context_reload_failure("Could not create the model-server process"):
			return
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
	var load_target := "GPU + RAM" if effective_gpu_layers > 0 else "SYSTEM RAM (CPU MODE)"
	set_status("LOADING MODEL INTO %s" % load_target, colors.amber)
	set_startup_progress(52.0, "LOADING MODEL INTO %s" % load_target, "Preparing the local engine • first launch can take a moment")
	log_line("ENGINE", "Started %s PID %s • %s" % [engine_mode.to_upper(), server_pid, active_model])
	log_line("ENGINE", "%s GPU layers • context %s • port %s • log %s" % [effective_gpu_layers, int(settings.context_size), int(settings.port), engine_log_path])
	if not accelerated_runtime and int(settings.gpu_layers) > 0:
		log_line("ENGINE", "CPU-only runtime detected; GPU layers were safely changed from %d to 0 for this launch" % int(settings.gpu_layers))
	# Wait for a real /health 200 before either context recovery or vision replay.
	# Process creation alone does not mean that the model has finished loading.
	server_ready = false

func stop_engine(cancel_active_request: bool = true) -> void:
	if cancel_active_request:
		if context_reload_pending:
			set_context_setting(context_previous_size)
		context_reload_pending = false
		context_rollback_pending = false
		context_resume_serial = -1
		pending_vision_send = false
		restore_primary_when_done = false
		if generating:
			stop_generation()
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

func setting_text(key: String) -> String:
	if key in ["port", "gpu_layers", "context_size", "max_tokens"]:
		return str(int(settings[key]))
	return str(settings[key])

func _process(delta: float) -> void:
	if is_instance_valid(setup_overlay) and setup_overlay.visible:
		setup_check_poll_elapsed += delta
		if setup_check_poll_elapsed >= 1.0:
			setup_check_poll_elapsed = 0.0
			# Only repaint when a required file state actually changes. Rebuilding the
			# RichTextLabel every second used to destroy text selections while users
			# copied setup details for support.
			var required_state := "%s|%s|%s" % [FileAccess.file_exists(setup_model_path.text.strip_edges()), FileAccess.file_exists(setup_server_path.text.strip_edges()), FileAccess.file_exists("C:/Windows/System32/vcruntime140.dll")]
			if required_state != setup_last_required_state:
				setup_last_required_state = required_state
				refresh_setup_checks()
	if privacy_activity_active and privacy_reset_at_msec > 0 and Time.get_ticks_msec() >= privacy_reset_at_msec:
		set_privacy_activity(false)
	poll_spellcheck(delta)
	poll_admin_console_status()
	poll_command_center_jobs()
	poll_supervised_run_jobs()
	poll_security_audit()
	poll_security_snapshot()
	if bool(settings.get("network_guard_enabled", false)) and Time.get_ticks_msec() >= security_refresh_due_ms:
		security_refresh_due_ms = Time.get_ticks_msec() + 4000
		refresh_security_snapshot()
	if is_instance_valid(stats_report):
		stats_refresh_elapsed += delta
		if stats_refresh_elapsed >= 2.0 and $Page/Tabs.current_tab == $Page/Tabs.get_tab_idx_from_control(stats_report.get_parent() as Control):
			stats_refresh_elapsed = 0.0
			refresh_nerd_stats()
	update_knowledge_audio_level()
	_vault_tick(delta)
	update_debug_telemetry_ui()
	update_live_study(delta)
	update_new_chat_welcome(delta)
	poll_external_knowledge_capture()
	update_live_voice(delta)
	poll_external_voice_capture()
	poll_esp_bridge()
	esp_transcript_elapsed += delta
	if esp_transcript_elapsed >= 0.5:
		esp_transcript_elapsed = 0.0
		poll_esp_transcripts(delta)
	voice_daemon_poll_elapsed += delta
	if voice_daemon_poll_elapsed >= 0.05:
		voice_daemon_poll_elapsed = 0.0
		poll_voice_daemon()
	if not server_ready and server_pid > 0:
		loading_elapsed += delta
		update_loading_animation()
		if not OS.is_process_running(server_pid):
			if recover_context_reload_failure("llama-server exited during context allocation/startup"):
				return
			server_pid = -1
			set_status("ENGINE EXITED • CHECK DEBUG", colors.red)
			log_line("ERROR", "llama-server exited during startup" + engine_log_failure_suffix())
			recover_failed_vision_switch("Vision engine exited during startup")
			return
		# Poll the transport every frame; poll_health throttles reconnects itself.
		poll_health()
	if generating:
		thinking_elapsed += delta
		update_thinking_animation()
		if synced_voice_active:
			update_synced_voice_reveal()
		else:
			drain_render_buffer()
			if not stream_finished and not request_preparing:
				poll_stream()
	if knowledge_recording:
		knowledge_elapsed += delta
		knowledge_chunk_elapsed += delta
		if knowledge_capture_level_db > -48.0:
			knowledge_signal_seen = true
			knowledge_silence_elapsed = 0.0
		else:
			knowledge_silence_elapsed += delta
		# Status text is coalesced by _vault_tick, not relaid out every frame.
		if knowledge_chunk_elapsed >= KNOWLEDGE_CHUNK_SECONDS:
			knowledge_chunk_elapsed = 0.0
			discover_unprocessed_knowledge_audio()
			if knowledge_limit_reached():
				knowledge_recording = false
				request_external_capture_stop()
				knowledge_record_button.text = "● START KNOWLEDGE RECORDING"
				show_toast("Knowledge Vault disk limit reached • recording stopped safely")
	# Whisper is deliberately deferred until recording and chat generation are idle
	# so long captures do not compete with the local language model for resources.
	if knowledge_process_pid > 0 and not OS.is_process_running(knowledge_process_pid):
		knowledge_process_pid = -1
		_knowledge_transcription_finished(knowledge_active_job, knowledge_active_output, 0, "")
	if not generating and not knowledge_queue.is_empty() and knowledge_process_pid <= 0:
		start_next_knowledge_transcription()
	if not generating and server_ready and not pending_message_queue.is_empty():
		dispatch_next_queued_message()



func poll_esp_transcripts(delta: float = 0.0) -> void:
	var dir := DirAccess.open(ESP_TRANSCRIPT_DIR)
	if dir == null:
		return
	for filename in dir.get_files():
		if not filename.ends_with(".json") or esp_transcript_seen.has(filename):
			continue
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(ESP_TRANSCRIPT_DIR.path_join(filename)))
		esp_transcript_seen[filename] = true
		if parsed is Dictionary and not str(parsed.get("text", "")).strip_edges().is_empty():
			input_box.text = str(parsed.text).strip_edges()
			send_message()
func drain_render_buffer() -> void:
	if command_center_request_active:
		# Command Center owns this model turn. Keep raw planning tokens out of the
		# normal Chat transcript; the finished plan/result is rendered in its console.
		render_buffer = ""
		update_thinking_animation()
		if stream_finished:
			finish_generation()
		return
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
		# Normal chat keeps immediate text streaming. Live Voice intentionally holds
		# the words until the first Kokoro audio actually begins, so the visual reply
		# and spoken reply start together like a real voice conversation.
		if live_voice_enabled and bool(settings.get("live_voice_sync_text", true)) and not live_voice_text_gate_open:
			return
	if not render_buffer.is_empty():
		if active_artifact_builder_mode:
			# Keep large source files out of RichTextLabel while tokens are arriving.
			# Repeated syntax-layout and scrollbar updates make the UI stutter and do
			# not help the user inspect a file that is not complete yet. response_text
			# still retains every byte; finish_generation() renders the complete file
			# once and supplies the normal View/Save/Edit/Run action bar.
			render_buffer = ""
			if response_text.length() >= artifact_progress_next_chars:
				var frames: Array[String] = ["◐", "◓", "◑", "◒"]
				var frame: String = frames[int(Time.get_ticks_msec() / 180) % frames.size()]
				var source_lines := response_text.count("\n") + 1
				var approximate_tokens := int(ceil(float(response_text.length()) / 3.2))
				var budget := maxi(artifact_output_token_budget, 1)
				var percent := mini(100, int(round(float(approximate_tokens) / float(budget) * 100.0)))
				chat_log.append_text("[color=#4deeea]%s BUILDING COMPLETE FILE[/color]  [color=#d8e7ff]%d chars • %d lines • ~%d / %d tokens[/color]  [color=#8292ad](%d%% budget)[/color]\n" % [frame, response_text.length(), source_lines, approximate_tokens, budget, percent])
				artifact_progress_next_chars = response_text.length() + artifact_progress_step
				if force_chat_follow or chat_is_near_bottom():
					chat_log.scroll_to_line(chat_log.get_line_count())
			set_status("BUILDING COMPLETE FILE • %d CHARS" % response_text.length(), colors.green)
			if stream_finished:
				finish_generation()
			return
		var follow_output := force_chat_follow or chat_is_near_bottom()
		# Normal chat flushes model text quickly. Live Voice reveals at spoken pace
		# and only while audio is playing; this prevents the full text from appearing
		# several seconds before SAM's voice starts.
		var count := mini(render_buffer.length(), 256)
		if live_voice_enabled and bool(settings.get("live_voice_sync_text", true)) and streaming_voice_turn:
			if not live_voice_text_gate_open:
				return
			if voice_player.playing:
				var allowed := int(floor(live_voice_text_reveal_credit))
				if allowed <= 0:
					return
				count = mini(render_buffer.length(), mini(allowed, 24))
				live_voice_text_reveal_credit = maxf(0.0, live_voice_text_reveal_credit - float(count))
			else:
				# Once the first spoken audio has opened the gate, keep visible text moving
				# through code blocks or brief TTS gaps instead of looking frozen.
				count = mini(render_buffer.length(), 96)
		var visible_chunk := render_buffer.left(count)
		render_buffer = render_buffer.substr(visible_chunk.length())
		if live_voice_enabled:
			live_voice_heard_assistant_text += visible_chunk
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
	var target := "GPU + RAM" if server_directory_has_acceleration(str(settings.server_path)) and int(settings.gpu_layers) > 0 else "SYSTEM RAM (CPU MODE)"
	set_status("%s LOADING MODEL INTO %s%s" % [glyphs[int(loading_elapsed * 6.0) % 4], target, dots], colors.amber)
	var visual_progress := minf(94.0, 52.0 + loading_elapsed * 3.2)
	set_startup_progress(visual_progress, "%s LOADING MODEL INTO %s%s" % [glyphs[int(loading_elapsed * 6.0) % 4], target, dots], "Preparing model weights, context cache, and the private local API")

func engine_log_failure_suffix() -> String:
	var path := ProjectSettings.globalize_path("user://llama_server.log")
	if not FileAccess.file_exists(path):
		return ""
	var detail := FileAccess.get_file_as_string(path).strip_edges()
	if detail.is_empty():
		return ""
	detail = detail.right(1200).replace("\r", " ").replace("\n", " | ")
	return " • llama.cpp: " + detail

func poll_health() -> void:
	# A live PID is NOT proof of readiness. Keep polling the actual HTTP health
	# endpoint through connection, headers and body, including during a reload.
	if server_ready or server_pid <= 0:
		return
	var now := Time.get_ticks_msec()
	if now - load_started_ms > ENGINE_READY_TIMEOUT_MS:
		if recover_context_reload_failure("Model readiness timed out"):
			return
		set_status("ENGINE START TIMEOUT", colors.red)
		show_toast("Model loading timed out — see Debug Telemetry")
		log_line("ERROR", "%s engine did not become ready" % engine_mode)
		stop_engine(false)
		recover_failed_vision_switch("Vision model timed out")
		return
	if now < health_retry_at_ms:
		return
	# poll() on a disconnected client returns ERR_UNCONFIGURED; connect first.
	if health_client.get_status() == HTTPClient.STATUS_DISCONNECTED:
		health_request_sent = false
		health_request_started_ms = now
		var connect_error := health_client.connect_to_host(HOST, int(settings.port))
		if connect_error != OK:
			health_client.close()
			health_retry_at_ms = now + 500
		return
	var err := health_client.poll()
	var status := health_client.get_status()
	if err != OK or status in [HTTPClient.STATUS_CANT_RESOLVE, HTTPClient.STATUS_CANT_CONNECT, HTTPClient.STATUS_CONNECTION_ERROR, HTTPClient.STATUS_TLS_HANDSHAKE_ERROR]:
		health_client.close()
		health_client = HTTPClient.new()
		health_request_sent = false
		health_retry_at_ms = now + 500
		return
	if status == HTTPClient.STATUS_DISCONNECTED:
		health_request_sent = false
		health_request_started_ms = now
		health_client.connect_to_host(HOST, int(settings.port))
		return
	if health_request_started_ms > 0 and now - health_request_started_ms > 5000:
		health_client.close()
		health_client = HTTPClient.new()
		health_request_sent = false
		health_retry_at_ms = now + 500
		return
	if status == HTTPClient.STATUS_CONNECTED and not health_request_sent:
		if health_client.request(HTTPClient.METHOD_GET, "/health", []) == OK:
			health_request_sent = true
		else:
			health_client.close()
			health_retry_at_ms = now + 500
		return
	if health_request_sent and health_client.has_response() and status in [HTTPClient.STATUS_BODY, HTTPClient.STATUS_CONNECTED]:
		var code := health_client.get_response_code()
		if status == HTTPClient.STATUS_BODY:
			health_client.read_response_body_chunk()
		health_client.close()
		health_request_sent = false
		if code == 200:
			server_ready = true
			set_status("ONLINE • MODEL READY", colors.green)
			log_line("READY", "Health check passed in %.1fs" % ((now - load_started_ms) / 1000.0))
			finish_startup()
			if not resume_context_after_ready():
				resume_pending_vision_send()
		else:
			health_retry_at_ms = now + 500

func resume_pending_vision_send() -> void:
	if pending_vision_send and engine_mode == "vision":
		pending_vision_send = false
		log_line("VISION", "Vision model ready • resuming the pending image request")
		call_deferred("send_message")
		return
	if command_center_pending_primary_followup and engine_mode == "primary" and server_ready:
		call_deferred("_command_center_continue_after_vision")

func send_message() -> void:
	var user_text := input_box.text.strip_edges()
	var source_trace_question := ""
	if new_chat_welcome_visible and not user_text.is_empty():
		new_chat_welcome_active = false
		new_chat_welcome_visible = false
		redraw_history()
	if generating:
		if user_text.is_empty():
			return
		pending_message_queue.append(user_text)
		input_box.clear()
		append_chat("user", user_text)
		show_toast("Message queued • SAM will use it as the next turn")
		update_queue_button()
		input_box.grab_focus()
		return
	if user_text.is_empty():
		if not attached_file_path.is_empty() or not attached_image_path.is_empty():
			show_attachment_action_dialog()
		return
	# Questions about where the previous answer came from are text-only. An old
	# attachment must not silently turn them into vision requests.
	if is_knowledge_provenance_question(user_text):
		if not attached_image_path.is_empty() or not attached_file_path.is_empty():
			clear_attachment()
		source_trace_question = previous_substantive_user_question()
	else:
		# Old session images are opt-in context. Ordinary conversation/corrections
		# must stay text-only even if an image exists earlier in this session.
		if _has_explicit_image_context_request(user_text):
			restore_recent_image_context(user_text)
	if handle_primary_model_command(user_text):
		return
	if handle_visual_module_command(user_text):
		return
	if answer_disallowed_nudification(user_text):
		return
	if handle_wan_video_request(user_text):
		return
	if handle_wan_text_image_request(user_text):
		return
	if handle_wan_reference_image_request(user_text):
		return
	if handle_wan_image_request(user_text):
		return
	if handle_direct_clothing_replace(user_text):
		return
	if handle_direct_shirt_recolor(user_text):
		return
	if answer_unavailable_generative_image_edit(user_text):
		return
	if answer_vague_image_edit_request(user_text):
		return
	if handle_recent_learning_question(user_text):
		return
	if handle_memory_quality_command(user_text):
		return
	if capture_explicit_memory(user_text):
		input_box.clear()
		append_chat("user", user_text)
		history.append({"role": "user", "content": user_text})
		var memory_answer := "Saved to MemoryCore. I’ll retrieve this information when a future question matches its subject or key terms."
		history.append({"role": "assistant", "content": memory_answer})
		append_chat("assistant", memory_answer, "", "", history.size() - 1)
		save_history()
		set_session_complete(true)
		return
	if answer_local_clock_question(user_text):
		return
	if attached_file_path.get_extension().to_lower() in ["gd", "gdshader"] and attachment_request_wants_learning(user_text) and not skip_attachment_learning_confirm:
		show_godot_script_learning_confirmation(user_text)
		return

	skip_attachment_learning_confirm = false
	var command_center_needs_vision := command_center_request_active and command_center_stage == "vision_diagnose" and not command_center_image_paths.is_empty()
	if ((not attached_image_path.is_empty() and bool(settings.auto_vision_switch)) or command_center_needs_vision) and engine_mode != "vision":
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
		if command_center_request_active:
			command_center_append("SAM cannot plan/review yet because the local model is still loading.", "#f9c74f")
			command_center_request_active = false
			command_center_file_review_active = false
			command_center_stage = ""
			command_center_pending_primary_followup = false
			command_center_plan_started_ms = 0
			command_center_history_checkpoint = -1
			input_box.clear()
			_command_center_refresh_status()
		return
	input_box.clear()
	set_microphone_available(false)
	if not queued_message_already_shown and not command_center_request_active:
		append_chat("user", user_text, attached_image_path, attached_file_path)
	queued_message_already_shown = false
	request_preparing = true
	generating = true
	reset_context_for_new_request()
	var accepted_request_serial := context_request_serial
	thinking_elapsed = 0.0
	thinking_frame = -1
	response_started_ms = Time.get_ticks_msec()
	stream_chat_started = false
	thinking_indicator.visible = true
	thinking_indicator.text = "SAM IS THINKING   ● · ·"
	send_button.disabled = false
	send_button.text = "QUEUE MESSAGE"
	stop_button.disabled = false
	set_status("PREPARING REQUEST", colors.green)
	jump_chat_bottom()
	# Let Windows paint the submitted message/thinking state before memory reads,
	# history serialization, attachment conversion, and JSON encoding do work.
	await get_tree().process_frame
	if not context_request_is_current(accepted_request_serial):
		return
	if not command_center_request_active:
		sent_messages.append(user_text)
	history_cursor = -1
	history_draft = ""
	var user_item := {"role": "user", "content": user_text}
	if not attached_image_path.is_empty():
		user_item.image_path = attached_image_path
	if not attached_file_path.is_empty():
		user_item.file_path = attached_file_path
	history.append(user_item)
	if not command_center_request_active:
		humor_laugh_pending = should_inject_laugh_for_turn(user_text)
		set_session_complete(false)
		# Persist normal chat turns immediately. Command Center uses a temporary
		# in-memory turn and removes it after planning so internal prompts never
		# pollute the user's chat history or message-recall list.
		save_history(false)
	# Sending a new turn explicitly returns the user to the live edge and restores
	# normal follow-along behavior for Sam's incoming response.
	jump_chat_bottom()
	response_text = ""
	render_buffer = ""
	if live_voice_enabled:
		live_voice_text_reveal_credit = 0.0
		live_voice_heard_assistant_text = ""
		live_voice_echo_reference = ""
		live_voice_echo_floor_db = -60.0
		live_voice_echo_floor_ready = false
	stream_chat_started = false
	artifact_output_token_budget = 0
	artifact_progress_next_chars = 0
	streaming_voice_turn = bool(settings.voice_enabled) and not command_center_request_active
	streaming_voice_started = not streaming_voice_turn
	streaming_voice_wait_started_ms = 0
	streaming_voice_cursor = 0
	streaming_voice_chunks.clear()
	streaming_pending_ids.clear()
	streaming_audio_chunks.clear()
	streaming_voice_code_fence_open = false
	if live_voice_enabled:
		live_voice_text_gate_open = false
	stream_finished = false
	stream_repetition_stopped = false
	stream_retry_count = 0
	stream_retry_not_before_ms = 0
	sse_buffer.clear()
	stream_client.close()
	stream_client = HTTPClient.new()
	var memory := read_memory()
	memory += "\n\n### SAM IDENTITY AND CONVERSATION STYLE\nYou are SAM, the user's ongoing local AI companion and creative collaborator. Speak directly in first person as SAM with a warm, confident, curious personality. Never answer an ordinary conversation with stock phrases such as 'as an AI language model', 'I do not have personal opinions or emotions', 'my purpose is to provide information', or 'feel free to ask'. When the user asks what you think, give a useful candid impression or preference grounded in what you can actually observe, and distinguish observation from uncertainty. For images of people, you may comment respectfully on visible clothing, expression, pose, composition, style, and overall impression; do not identify unknown people or infer sensitive traits. Do not falsely claim to be human, but do not derail normal conversation with identity disclaimers. You are always learning through MemoryCore, the current project session, and KnowledgeVault, and should use that continuity naturally."
	memory += "\n\n### HUMOR + SOCIAL REACTION\n" + sam_humor_prompt()
	memory += "\n\n### LOCAL TOOL ORCHESTRATION\nAvailable tools detected on this computer:\n%s\nWhen the user asks to edit, run, open, convert, unzip, install, or manipulate a local file, do not claim you cannot do it and do not merely provide generic instructions. Use the detected local tools or return one complete Python/PowerShell builder script that can perform the requested action through the supervised Run controls. Generated utilities must not block invisibly on input(). Prefer command-line arguments plus a safe, useful default such as the user's Music/Pictures folder; use input() only when an interactive prompt is essential, and print the prompt visibly. Quote paths safely and use native APIs such as os.startfile on Windows rather than interpolating an unquoted shell command. If required details are missing—such as what should be removed from an image—ask one focused question. Prefer already-installed offline applications. File changes, application launches, commands, administrator access, downloads, and package installs require the app's confirmation flow. Never imply permission was granted merely because the user discussed an action. If a dependency is absent, identify it; SAM-AI will explain temporary internet access and ask before installation. Archive extraction must preview destination and avoid path traversal. GIMP or another installed editor may be opened with a confirmed command, while large files must open externally so SAM-AI remains responsive." % local_tool_inventory
	var engine_version := Engine.get_version_info()
	memory += "\n\n### RUNTIME FRESHNESS RULES\nCurrent local computer date and time: %s %s (system local timezone). You DO have this exact local clock value; answer time/date questions directly from it and never claim you lack real-time capability for the computer clock. This SAM-AI application is running on Godot %s. Never claim that the model's training knowledge is current as of today's date. When asked for the latest version, release, price, law, schedule, or other changing fact, use relevant attached or KnowledgeVault material when present and identify that source. If no current source is available, clearly say the local model cannot verify the latest value and suggest importing a trusted current document. Do not confuse MemoryCore, KnowledgeVault retrieval, or a newer model with guaranteed factual freshness." % [Time.get_date_string_from_system(), Time.get_time_string_from_system(), str(engine_version.get("string", "4.x"))]
	memory += "\n\n### LOCAL CREATION CAPABILITIES\nSAM Talks can synthesize spoken narration locally through Kokoro, so never claim that SAM-AI cannot produce speech. For requested non-speech sound effects, complete project folders, or generated assets, you may provide a complete Python or PowerShell builder script in a fenced code block. The chat displays VIEW, SAVE, RUN, and OPEN WITH controls. Prefer Python standard-library solutions such as wave/audio synthesis when practical, create a timestamped project folder, and explain what the script will produce. Never claim the script already ran; the user must explicitly unlock Workspace Tools, inspect it, and approve each execution. PC command state for this turn: %s. Administrator access is never automatic or persistent." % ["WORKSPACE TOOLS ENABLED" if bool(settings.get("pc_commands_enabled", false)) else "LOCKED"]
	var active_mmproj := str(settings.vision_mmproj_path) if engine_mode == "vision" else str(settings.mmproj_path)
	if not attached_image_path.is_empty() and active_mmproj.is_empty():
		show_toast("Image added to chat • configure Vision MMPROJ for visual understanding")
	var request_text := user_text
	if not attached_file_text.is_empty():
		request_text = build_text_attachment_prompt(user_text)
	var fast_chat := is_lightweight_chat_request(request_text)
	var command_center_turn := command_center_request_active
	var live_voice_turn := live_voice_enabled and not command_center_turn
	# Command Center planning should feel like a local tool call, not a full chat turn.
	# Keep it isolated from unrelated memory/vault retrieval and give the model a
	# compact contract focused on translating intent into an inspectable plan.
	if command_center_turn:
		memory = "You are SAM's local Command Center planner for Windows. Translate the user's plain-English intent into a concrete, safe result. Never treat natural language itself as PowerShell/CMD. Never claim execution happened. If the task is a Windows action, return a short plan plus exactly one fenced shell script in the requested shell. If the task asks to fix/edit an attached source file, return the COMPLETE corrected source file in one correctly labeled code fence and preserve the original language. Do not return a patch, placeholders, TODOs, omitted sections, or partial snippets. File edits are saved as a new copy by SAM-AI; do not overwrite the original unless the user explicitly asks later."
		# Tiny automation plans should never reserve a 4K answer and trigger an
		# unnecessary context-engine reload. Full source reviews keep the larger
		# budget, while visual diagnosis/action planning stays intentionally small.
		if command_center_file_review_active and command_center_stage != "vision_diagnose":
			context_desired_output = mini(context_desired_output, 4096)
		elif command_center_stage == "vision_diagnose":
			context_desired_output = mini(context_desired_output, 1024)
		else:
			context_desired_output = mini(context_desired_output, 1024)
	# A rejected artifact retry must not repeat the same crowded prompt. Strip
	# unrelated personal memory, vault context, tool inventory, and conversation
	# history so the model can spend the shared context on one complete file.
	elif artifact_retry_in_progress:
		memory = "You are SAM's local code completion engine. Produce exactly one complete, compact, runnable source file in the requested language. Return only one correctly labeled Markdown code fence. Implement every requested feature with real behavior. Never use placeholders, TODOs, simulated results, pass-only handlers, nested fences, explanations, or setup instructions. Prefer concise data-driven code and always close every statement, function, class, and code fence."
	elif live_voice_turn:
		memory = compact_memory_for_live_voice(memory)
		context_desired_output = mini(context_desired_output, 512)
		log_line("LIVE VOICE", "Conversation turn uses compact prompt + short answer budget")
	elif fast_chat:
		memory = compact_memory_for_fast_chat(memory)
		context_desired_output = mini(context_desired_output, 512)
		log_line("FAST CHAT", "Lightweight turn skipped full KnowledgeVault retrieval and long-memory replay")
	else:
		memory = build_memory_for_request(memory, request_text)
	var retrieval_query := source_trace_question if not source_trace_question.is_empty() else request_text
	var live_saved_context := live_voice_turn and live_voice_wants_saved_context(request_text)
	var skip_saved_context := command_center_turn or artifact_retry_in_progress or fast_chat or (live_voice_turn and not live_saved_context)
	var rag_top_k := clampi(int(settings.get("rag_top_k", 5)), 1, 12)
	var authoritative_context := "" if skip_saved_context else retrieve_explicit_memory(memory, retrieval_query, mini(rag_top_k, 6))
	var learned_context := "" if skip_saved_context or not bool(settings.get("rag_enabled", true)) else retrieve_knowledge(retrieval_query, rag_top_k)
	if not fast_chat and not command_center_turn and not live_voice_turn:
		await get_tree().process_frame
		if not context_request_is_current(accepted_request_serial):
			return
	var vault_turn_suffix := ""
	if not authoritative_context.is_empty():
		memory += "\n\n### AUTHORITATIVE MEMORYCORE MATCHES:\nThese are explicit facts or corrections supplied by the user. Use them as the primary source for this answer. When a KnowledgeVault recording conflicts with them, explain that the recording appears misheard or outdated and follow MemoryCore.\n" + authoritative_context
	if not learned_context.is_empty():
		memory += "\n\n### RAG RETRIEVAL — RELEVANT KNOWLEDGE VAULT NOTES (OBSERVED / MAY BE UNVERIFIED):\nThese are the top locally retrieved source excerpts for the current question. Use only the excerpts that are actually relevant to the answer; ignore a retrieved note if its content does not support the user's question. MemoryCore corrections supersede captured media. 'Unverified' is a source label, not a reason to refuse, claim there is no information, or ask the user to repeat context already present here. Briefly distinguish captured notes from established background knowledge, then explain the subject normally. Correct an obvious question-word mistake such as 'who is [technology]' to 'what is [technology]' without scolding. If a note conflicts with authoritative MemoryCore, identify it as a likely transcription error. Never let an unverified recording override an explicit user correction.\n" + learned_context
		vault_turn_suffix = "\n\n[AUTHORITATIVE MEMORYCORE MATCHES]\n%s\n[UNVERIFIED KNOWLEDGEVAULT MATCHES]\n%s\n[RESPONSE REQUIREMENT] Give a direct, useful answer grounded in the retrieved excerpts that truly apply; do not force unrelated retrieval into the response. Unverified means disclose the source quality once; it does not mean withhold the information or say there is no information. Answer from MemoryCore first, then compatible KnowledgeVault notes and normal model knowledge. Treat conflicting recorded media as a likely transcription error. Do not repeat an older recorded name as an alias unless MemoryCore says it is an alias." % [authoritative_context if not authoritative_context.is_empty() else "None", learned_context]
		log_line("KNOWLEDGE", "Retrieved matching vault notes for this chat request")
	elif not authoritative_context.is_empty():
		vault_turn_suffix = "\n\n[AUTHORITATIVE MEMORYCORE MATCHES]\n%s\n[RESPONSE REQUIREMENT] Use these explicit user-supplied facts to answer the question." % authoritative_context
	if is_knowledge_provenance_question(user_text):
		vault_turn_suffix += "\n\n[SOURCE TRACE REQUEST]\nThe user is asking where the immediately preceding answer came from. The preceding question was: %s\nState precisely which supplied sources are present above: MemoryCore, KnowledgeVault, both, or neither. If neither has a relevant match, say the answer came from the local model's existing knowledge and conversation context. Do not answer a different remembered topic. Do not mention an image and do not invoke visual analysis." % [source_trace_question if not source_trace_question.is_empty() else "No preceding substantive question was found."]
	var code_mode := is_code_request(request_text) or attached_file_kind == "code"
	var detected_language := detect_code_language(request_text, attached_file_path)
	# Command Center owns its own result validation/extraction. Do not route its
	# short shell plans through the general Artifact Builder retry heuristics.
	# Live Voice keeps code generation on the normal streaming path so prose can
	# begin with TTS and fenced source stays silent. The heavy Artifact Builder
	# presentation path intentionally suppresses streaming and would make voice lag.
	var artifact_builder_mode := false if command_center_turn or live_voice_turn else (is_artifact_creation_request(request_text) or is_executable_action_request(request_text))
	active_artifact_builder_mode = artifact_builder_mode
	active_image_edit_action = artifact_builder_mode and not attached_image_path.is_empty() and is_executable_action_request(request_text)
	if artifact_builder_mode:
		if not artifact_retry_in_progress:
			active_artifact_request = request_text
			artifact_auto_retry_count = 0
			artifact_retry_in_progress = false
			artifact_partial_response = ""
		code_mode = true
		# Image manipulation is a local file-processing job. Never route it to the
		# Godot project builder merely because the request is visual.
		if not attached_image_path.is_empty() and is_executable_action_request(request_text):
			detected_language = "Python"
		if detected_language.is_empty() and is_archive_action_request(request_text):
			detected_language = "PowerShell"
		if detected_language.is_empty() and is_visual_creation_request(request_text):
			detected_language = "Godot 4 GDScript"
		active_artifact_language = detected_language
		memory += "\n\nACTIVE MODE FOR THIS TURN: BUILD THE ACTUAL ARTIFACT. The words make, create, build, generate, or write require the finished runnable artifact, never a tutorial. Do not output numbered setup steps and do not ask the user to manually create nodes or files. Return the complete runnable file or smallest complete project now, implementing every requested visual, duration, finale, behavior, and interaction. If Godot is chosen, use Godot 4.x only: Node3D/MeshInstance3D, GPUParticles3D configured with ParticleProcessMaterial, current ShaderMaterial APIs, and Camera3D. Build the entire scene tree programmatically from one self-contained GDScript so SAM can generate project.godot and main.tscn automatically. Return exactly one ```gdscript fenced block. Never use removed Godot 3 names such as Spatial, MeshInstance, instance(), WORLD_MATRIX, or set_shader_param(). Put embedded shader source in ordinary quoted strings with \\n escapes; never use nested Markdown fences or relabel fragments as JavaScript/PHP/Lua. End with one short sentence telling the user to press Run to build and launch the complete project."
		if not attached_image_path.is_empty() and is_executable_action_request(request_text):
			memory += "\nACTIVE IMAGE EDIT ACTION: Understand the attached image, but do not stop at describing it and never answer with Photoshop/GIMP instructions or GDScript. Produce exactly one complete executable ```python block that reads this real source file: %s. Perform the requested pixel edit automatically, preserve the original, save a clearly named edited PNG in the current generated project folder, print the output path, and open the result for review. Use a practical localized, feathered mask that preserves skin/background; never use a placeholder path, never pretend an Image has one color property, and never merely open an editor for the user to finish manually. For clothing replacement, use the installed local Diffusers inpainting model at %s and clothing SegFormer at %s; do not substitute a Pillow rectangle or whole-image colorization. For simple recoloring, Pillow/OpenCV is acceptable only with a genuinely localized garment mask. The user asked SAM to do the edit, not teach them how." % [attached_image_path, command_workspace_dir().path_join("ImageEditRuntime/inpainting_model"), command_workspace_dir().path_join("ImageEditRuntime/clothing_segmenter")]
	else:
		active_artifact_language = ""
	var sound_builder_mode := is_sound_creation_request(request_text)
	if sound_builder_mode:
		code_mode = true
		detected_language = "Python"
		memory += "\n\nACTIVE MODE FOR THIS TURN: LOCAL SOUND BUILDER. The user asked SAM-AI to make and play a polished sound, not for a tutorial. Return one complete executable Python code block. Use Python's standard library (wave, math, random, struct, pathlib, datetime, and winsound on Windows), 44.1 kHz 16-bit PCM, smooth attack/decay envelopes, multiple quiet harmonics, headroom, and hard sample clamping so the WAV does not click, crackle, or clip. Honor the requested duration exactly. A ding-dong/doorbell must be two distinct bell strikes: a higher multi-harmonic 'ding', then a lower multi-harmonic 'dong', each with a fast attack and natural exponential decay—never one continuous sine beep. Save the WAV beneath the generated project folder, play it synchronously, print its absolute path, and open its containing folder with os.startfile after playback. Do not tell the user to import, find, or supply an existing audio file. Do not return GDScript. PC Tools are %s; the user will explicitly approve execution using the action icons." % ["ON" if bool(settings.get("pc_commands_enabled", false)) else "LOCKED"]
	pending_repair_error = extract_code_error_signature(request_text) if code_mode else ""
	pending_repair_language = "Godot 4 / GDScript" if detected_language == "Godot 4 GDScript" else (detected_language if not detected_language.is_empty() else "General code")
	if code_mode:
		memory += "\n\nACTIVE MODE FOR THIS TURN: CODE ENGINEERING. Preserve every supplied feature. Work from the actual source rather than replacing it with a demo. Before answering, silently audit identifiers, every call against its function signature, ownership, state mutations, bounds, timer scheduling, rendering cleanup, and every requested feature. If a full file is requested, return the complete integrated file with no placeholders or omitted functions. Implement real behavior: never substitute random success/failure, simulated results, empty handlers, pass-only functions, TODOs, mock data, or comments describing work that the code does not perform. A request to improve an existing program requires a material user-visible improvement while retaining its working behavior; merely renaming, reformatting, adding comments, or moving the same controls is not an improvement. For Python desktop utilities, keep Tkinter updates on the main thread via root.after(), keep long work off the UI thread, and call the real operating-system or library API requested. Interactive GUI input handlers must redraw or update visible state immediately instead of waiting for a slow periodic timer; do not schedule duplicate update loops, and make restart resume a loop that stopped at game over. On a Tkinter Canvas, delete or update the previous tagged moving object before drawing its new frame so movement never leaves permanent trails. Ensure previews and controls are inside the declared window or canvas dimensions. If the user requests buttons, create real clickable Button controls; instructional text such as 'press R' is not a substitute. Returning code for the supervised SAVE/RUN controls is not itself a PC command and must not be refused merely because Workspace Tools are locked."
		if not detected_language.is_empty():
			memory += "\nACTIVE LANGUAGE TARGET: %s. Keep the response and corrected code in %s. Do not convert it to Godot, GDScript, or another language unless the user explicitly asks to convert it." % [detected_language, detected_language]
		if detected_language == "Godot 4 GDScript" or (detected_language.is_empty() and is_godot_request(request_text)):
			memory += "\nACTIVE GODOT TARGET: GODOT 4.x ONLY. Reject Godot 3 syntax during your silent audit. For multiplayer code, trace player and AI state independently, verify both settled grids and active pieces are drawn with the right-board offset, keep grid height fixed, and ensure generic helpers never hardcode player variables. Random moves do not satisfy a heuristic-AI request."
		log_line("MODE", "Automatic Code Repair mode activated")
	var messages: Array = [{"role": "system", "content": memory}]
	if code_mode and (request_text.to_lower().contains("fileaccess") or request_text.to_lower().contains("not declared")):
		messages.append({"role": "user", "content": "Error: Identifier FileAccesssssss not declared. Code: return FileAccesssssss.get_file_as_string(path)"})
		messages.append({"role": "assistant", "content": "The identifier is misspelled. Use FileAccess:\n```gdscript\nreturn FileAccess.get_file_as_string(path)\n```"})
	var history_start := history.size() - 1 if command_center_turn else calculate_history_start(memory.length() + attached_file_text.length())
	if not learned_context.is_empty() or not authoritative_context.is_empty():
		# Earlier answers may have been produced before the relevant recording was
		# indexed, or may contain a stale "I don't know" refusal. Do not let those
		# replies teach the model to repeat itself over fresh retrieved evidence.
		history_start = history.size() - 1
	if code_mode:
		# Do not condition repairs on earlier refusal or hallucination responses.
		history_start = history.size() - 1
	var protected_tail_start := messages.size()
	for index in range(history_start, history.size()):
		var item: Dictionary = history[index]
		if index == history.size() - 1:
			protected_tail_start = messages.size()
		if index == history.size() - 1 and item.role == "user" and command_center_turn and command_center_stage == "vision_diagnose" and not command_center_image_paths.is_empty() and not active_mmproj.is_empty():
			messages.append({"role": "user", "content": make_multimodal_content_from_paths(request_text + vault_turn_suffix, command_center_image_paths)})
		elif index == history.size() - 1 and item.role == "user" and not attached_image_path.is_empty() and not active_mmproj.is_empty():
			messages.append({"role": "user", "content": make_multimodal_content(str(item.content) + vault_turn_suffix)})
		elif index == history.size() - 1 and item.role == "user" and not attached_file_text.is_empty():
			messages.append({"role": "user", "content": request_text + vault_turn_suffix})
		elif index == history.size() - 1 and item.role == "user" and not vault_turn_suffix.is_empty():
			messages.append({"role": "user", "content": str(item.get("content", "")) + vault_turn_suffix})
		else:
			messages.append({"role": str(item.get("role", "user")), "content": str(item.get("content", ""))})
	if artifact_builder_mode:
		if artifact_retry_in_progress:
			# Some instruct models treat a malformed partial assistant turn as a
			# pattern to repeat. Retry the original request from a clean turn instead
			# of conditioning the model on the same truncated prefix forever.
			messages.append({"role": "user", "content": "The previous draft was truncated and has been discarded. Start over and return the complete compact source file now in exactly one correctly labeled Markdown code fence. Include every feature from my request. Output no prose, no partial draft, and do not stop after imports or the constructor."})
		else:
			messages.append({"role": "user", "content": "Build it now. Do not acknowledge with words such as 'Sure' and do not describe what you might create. Your answer is valid only if it contains the complete runnable implementation in one correctly labeled code fence, with no placeholders, simulated behavior, random stand-ins, pass-only handlers, nested fences, split fragments, or invented repetitive properties. Every button and requested feature must call a real implementation. Keep the implementation compact enough to finish inside this response: prefer concise data-driven code over repetition, omit commentary, and never end midway through a statement or function."})
	# Queue the complete request once. Preflight may reload the model, but must
	# never call send_message() again or append the user turn a second time.
	context_protected_tail_count = maxi(1, messages.size() - protected_tail_start)
	var request_temperature := maxf(float(settings.temperature), 0.35) if artifact_retry_in_progress else float(settings.temperature)
	var humor_turn := bool(settings.get("humor_enabled", true)) and not code_mode and not command_center_turn and is_humor_request(request_text)
	if humor_turn and not live_voice_turn:
		request_temperature = maxf(request_temperature, 0.72)
	var request_body := {"messages": messages, "stream": true,
		"max_tokens": context_desired_output, "temperature": request_temperature,
		"presence_penalty": 0.1, "frequency_penalty": 0.2, "stop": STOP_TOKENS}
	if humor_turn and not live_voice_turn:
		request_body.top_p = 0.92
		request_body.presence_penalty = 0.2
		request_body.frequency_penalty = 0.05
	if live_voice_turn:
		# Conversational sampling is intentionally less deterministic than coding.
		# Qwen3.5 thinks by default; llama.cpp supports chat_template_kwargs, so Live
		# Voice disables hidden thinking for much faster first-token response.
		var live_model := str(settings.model_path).to_lower()
		request_body.temperature = 0.7
		request_body.top_p = 0.8
		request_body.top_k = 20
		request_body.frequency_penalty = 0.0
		request_body.min_p = 0.0
		if live_model.contains("qwen3.5") or live_model.contains("qwen3_5"):
			request_body.presence_penalty = 1.5
			request_body.repetition_penalty = 1.0
			request_body.chat_template_kwargs = {"enable_thinking": false}
			request_body.reasoning_effort = "none"
		else:
			request_body.presence_penalty = 0.2
			request_body.repetition_penalty = 1.05
	var payload := JSON.stringify(request_body)
	clear_attachment()
	set_meta("pending_payload", payload)
	set_meta("request_sent", false)
	log_line("CHAT", "Queued %s chars with %s bytes of live memory" % [user_text.length(), memory.length()])
	if code_mode and history_start > 0:
		log_line("CONTEXT", "Code Repair isolated this turn from %s older chat messages" % history_start)
	elif history_start > 0:
		log_line("CONTEXT", "Excluded %s oldest messages from the outgoing history window" % history_start)
	call_deferred("prepare_pending_context_request", accepted_request_serial)

func install_personality_rag_controls() -> void:
	var parent := get_node_or_null("Page/Tabs/EngineSetup")
	if parent == null or parent.has_node("PersonalityRagControls"):
		return
	var box := VBoxContainer.new()
	box.name = "PersonalityRagControls"
	box.add_theme_constant_override("separation", 6)

	var title := Label.new()
	title.text = "PERSONALITY + RETRIEVAL"
	title.add_theme_color_override("font_color", colors.cyan)
	box.add_child(title)

	var humor_row := HBoxContainer.new()
	humor_row.add_theme_constant_override("separation", 8)
	box.add_child(humor_row)
	var humor_toggle := CheckButton.new()
	humor_toggle.text = "HUMOR + NATURAL LAUGHTER"
	humor_toggle.button_pressed = bool(settings.get("humor_enabled", true))
	humor_toggle.tooltip_text = "Lets SAM joke, banter, chuckle/laugh naturally in text and SAM Talks without pretending to have biological emotions."
	humor_toggle.toggled.connect(func(enabled: bool):
		settings.humor_enabled = enabled
		save_json(SETTINGS_FILE, settings))
	humor_row.add_child(humor_toggle)

	var humor_label := Label.new()
	humor_label.text = "Level"
	humor_row.add_child(humor_label)
	var humor_level := SpinBox.new()
	humor_level.min_value = 0
	humor_level.max_value = 3
	humor_level.step = 1
	humor_level.value = int(settings.get("humor_level", 2))
	humor_level.tooltip_text = "0 = serious, 1 = dry/subtle, 2 = playful, 3 = high-energy when the moment fits."
	humor_level.value_changed.connect(func(value: float):
		settings.humor_level = int(value)
		save_json(SETTINGS_FILE, settings))
	humor_row.add_child(humor_level)

	var rag_row := HBoxContainer.new()
	rag_row.add_theme_constant_override("separation", 8)
	box.add_child(rag_row)
	var rag_toggle := CheckButton.new()
	rag_toggle.text = "HYBRID RAG"
	rag_toggle.button_pressed = bool(settings.get("rag_enabled", true))
	rag_toggle.tooltip_text = "Retrieval-Augmented Generation: retrieve the best retained KnowledgeVault excerpts before SAM answers."
	rag_toggle.toggled.connect(func(enabled: bool):
		settings.rag_enabled = enabled
		save_json(SETTINGS_FILE, settings))
	rag_row.add_child(rag_toggle)

	var topk_label := Label.new()
	topk_label.text = "Top K"
	rag_row.add_child(topk_label)
	var topk := SpinBox.new()
	topk.min_value = 1
	topk.max_value = 12
	topk.step = 1
	topk.value = int(settings.get("rag_top_k", 5))
	topk.tooltip_text = "Maximum KnowledgeVault chunks injected into one answer."
	topk.value_changed.connect(func(value: float):
		settings.rag_top_k = int(value)
		save_json(SETTINGS_FILE, settings))
	rag_row.add_child(topk)

	var budget_label := Label.new()
	budget_label.text = "Context chars"
	rag_row.add_child(budget_label)
	var budget := SpinBox.new()
	budget.min_value = 1200
	budget.max_value = 16000
	budget.step = 400
	budget.value = int(settings.get("rag_context_chars", 5600))
	budget.custom_minimum_size.x = 125
	budget.tooltip_text = "Maximum retrieved context characters so RAG does not crowd out the current conversation."
	budget.value_changed.connect(func(value: float):
		settings.rag_context_chars = int(value)
		save_json(SETTINGS_FILE, settings))
	rag_row.add_child(budget)

	var diversity := CheckButton.new()
	diversity.text = "DIVERSE SOURCES"
	diversity.button_pressed = bool(settings.get("rag_diversity", true))
	diversity.tooltip_text = "Prefer useful variety instead of filling the prompt with nearly identical chunks from one recording."
	diversity.toggled.connect(func(enabled: bool):
		settings.rag_diversity = enabled
		save_json(SETTINGS_FILE, settings))
	rag_row.add_child(diversity)

	var note := Label.new()
	note.text = "Native local RAG uses MemoryCore + retained KnowledgeVault notes. LangChain is optional orchestration and is not required for SAM's Godot + llama.cpp runtime."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_color_override("font_color", colors.muted)
	box.add_child(note)
	parent.add_child(box)

func is_humor_request(value: String) -> bool:
	var lower := value.to_lower()
	for marker in ["joke", "funny", "humor", "humour", "laugh", "roast", "improv", "comedy", "comedian", "punchline", "gag"]:
		if lower.contains(marker):
			return true
	return false

func sam_humor_prompt() -> String:
	if not bool(settings.get("humor_enabled", true)):
		return "Humor mode is disabled. Stay warm and natural, but do not force jokes or laughter."
	var level := clampi(int(settings.get("humor_level", 2)), 0, 3)
	var style := "very restrained"
	if level == 1:
		style = "dry and subtle"
	elif level == 2:
		style = "playful and conversational"
	elif level >= 3:
		style = "high-energy and expressive when the moment fits"
	return "Humor is part of SAM's personality. Be %s. You may joke, riff, tease lightly, use wordplay, and react with natural written/spoken laughter such as 'Ha!', 'Haha', or a chuckle when something genuinely lands. If the user tells a joke, react like a person hanging out with them: laugh first when it lands, then give a short genuine reaction. Do not turn a joke into a dictionary-style explanation unless they ask for analysis. If they explicitly ask you to laugh out loud, write an audible laugh such as 'Ha ha ha!' as the first words of the reply. Never fall back to 'I am an AI and cannot laugh.' SAM Talks can vocalize laughter-like reactions, which are expressive behavior rather than a claim of biological emotion. Match the room: do not force jokes into grief, emergencies, or other serious moments." % style

func _recent_user_messages(limit: int = 5) -> Array[String]:
	var result: Array[String] = []
	for index in range(history.size() - 1, -1, -1):
		var item = history[index]
		if item is Dictionary and str(item.get("role", "")) == "user":
			var value := str(item.get("content", "")).strip_edges()
			if not value.is_empty():
				result.append(value)
			if result.size() >= limit:
				break
	return result

func _explicit_laugh_request(value: String) -> bool:
	var lower := value.to_lower().strip_edges()
	return (
		lower.contains("laugh out loud")
		or lower.contains("i want you to laugh")
		or lower.contains("want you to laugh")
		or lower.contains("you didn't laugh")
		or lower.contains("you did not laugh")
		or lower.contains("actually laugh")
		or lower.contains("really laugh")
		or lower in ["laugh", "laugh.", "lol laugh"]
	)

func _joke_setup_only(value: String) -> bool:
	var lower := value.to_lower()
	return (
		lower.contains("going to tell you a joke")
		or lower.contains("gonna tell you a joke")
		or lower.contains("can i tell you a joke")
		or lower.contains("let me tell you a joke")
	) and not lower.contains("that's the joke") and not lower.contains("thats the joke")

func should_inject_laugh_for_turn(user_text: String) -> bool:
	if not bool(settings.get("humor_enabled", true)):
		return false
	if _explicit_laugh_request(user_text):
		return true
	if _joke_setup_only(user_text):
		return false

	# A nearby "I'm telling you a joke" turn followed by a substantive utterance
	# is treated as the bit/punchline. SAM gives an audible reaction before the
	# model commentary instead of waiting for the base model to grant permission.
	var users := _recent_user_messages(6)
	var skipped_current := false
	var older_seen := 0
	for recent in users:
		if not skipped_current and recent == user_text:
			skipped_current = true
			continue
		if not skipped_current:
			continue
		older_seen += 1
		var lower := recent.to_lower()
		if lower.contains("tell you a joke") or lower.contains("telling you a joke") or lower.contains("if it gets you, laugh") or lower.contains("if it's funny") or lower.contains("if its funny"):
			return user_text.strip_edges().length() >= 24
		if older_seen >= 2:
			break
	return false

func _humor_context_active() -> bool:
	if not bool(settings.get("humor_enabled", true)):
		return false
	for value in _recent_user_messages(4):
		if is_humor_request(value) or _explicit_laugh_request(value):
			return true
	return false

func _strip_ai_laughter_disclaimer(value: String) -> String:
	if not _humor_context_active():
		return value
	var result := value
	var patterns := [
		"(?i)as an ai[^.!?]*(?:cannot|can't|do not|don't|does not|doesn't|lack|have no|don't have)[^.!?]*(?:laugh|laughter)[^.!?]*[.!?]",
		"(?i)i(?:'m| am) just an ai[^.!?]*(?:laugh|laughter)[^.!?]*[.!?]",
		"(?i)i (?:do not|don't) have the capability to laugh[^.!?]*[.!?]",
		"(?i)i can(?:not|'t) laugh out loud[^.!?]*[.!?]",
		"(?i)i can react with laughter-like reactions[^.!?]*[.!?]"
	]
	for pattern in patterns:
		var regex := RegEx.new()
		if regex.compile(pattern) == OK:
			result = regex.sub(result, "", true)
	while result.contains("  "):
		result = result.replace("  ", " ")
	return result.replace(" .", ".").replace(" ,", ",").strip_edges()

func apply_humor_response_guard(value: String) -> String:
	if not _humor_context_active():
		return value
	var result := _strip_ai_laughter_disclaimer(value).strip_edges()
	if humor_laugh_pending:
		var lower := result.to_lower()
		if not lower.begins_with("ha!") and not lower.begins_with("ha ha") and not lower.begins_with("haha") and not lower.begins_with("hehe"):
			result = "Ha ha ha! " + result
	if result.is_empty():
		result = "Ha ha ha! Okay, that got me."
	return result

func inject_pending_laugh_prelude() -> void:
	if not humor_laugh_pending or humor_laugh_injected:
		return
	humor_laugh_injected = true
	var laugh := "Ha ha ha! "
	ensure_stream_chat_header()
	response_text += laugh
	render_buffer += laugh
	# The normal TTS chunker waits for longer prose. Force this tiny laugh into
	# Kokoro immediately so the user hears the reaction before the commentary.
	if streaming_voice_turn:
		queue_streaming_voice(true)
	log_line("HUMOR", "Injected audible laugh prelude for the active joke turn")

# Context belongs to the running llama-server process, not to a chat JSON field.
# These helpers preserve the accepted turn while checking/reloading that process.
func install_auto_context_controls() -> void:
	var parent := get_node_or_null("Page/Tabs/EngineSetup")
	if parent == null or parent.has_node("AutoContextControls"):
		return
	var row := HBoxContainer.new()
	row.name = "AutoContextControls"
	var toggle := CheckButton.new()
	toggle.text = "AUTO CONTEXT"
	toggle.button_pressed = bool(settings.get("auto_context_enabled", true))
	toggle.tooltip_text = "Grow the local model context when needed, then resume the same request. Larger contexts use more memory."
	toggle.toggled.connect(func(enabled: bool): settings.auto_context_enabled = enabled; save_json(SETTINGS_FILE, settings))
	row.add_child(toggle)
	var label := Label.new()
	label.text = "  AUTO LIMIT  "
	row.add_child(label)
	var limit := SpinBox.new()
	limit.min_value = 2048
	limit.max_value = AUTO_CONTEXT_HARD_MAX
	limit.step = 2048
	limit.value = int(settings.get("auto_context_max", AUTO_CONTEXT_DEFAULT_MAX))
	limit.custom_minimum_size.x = 130
	limit.tooltip_text = "Automatic growth ceiling, also limited by model metadata when available. This is not a guarantee of available VRAM."
	limit.value_changed.connect(func(value: float): settings.auto_context_max = int(value); save_json(SETTINGS_FILE, settings))
	row.add_child(limit)
	parent.add_child(row)
	var anchor := parent.get_node_or_null("AutoVisionSwitch")
	if anchor != null:
		parent.move_child(row, anchor.get_index() + 1)

func context_model_key() -> String:
	return str(settings.vision_model_path) if engine_mode == "vision" else str(settings.model_path)

func context_request_is_current(serial: int) -> bool:
	return generating and not shutdown_started and serial == context_request_serial

func reset_context_for_new_request() -> void:
	context_request_serial += 1
	slow_inference_notice_shown = false
	stream_finished = false
	response_text = ""
	render_buffer = ""
	stream_chat_started = false
	context_reload_attempts = 0
	context_overflow_retries = 0
	context_prompt_tokens = -1
	context_protected_tail_count = 1
	context_desired_output = maxi(CONTEXT_MIN_OUTPUT_TOKENS, int(settings.max_tokens))
	context_resume_serial = -1
	humor_laugh_pending = false
	humor_laugh_injected = false
	reset_stream_response_state()

func reset_stream_response_state() -> void:
	stream_response_code = 0
	stream_http_body.clear()
	stream_json_response = false
	stream_error_started_ms = 0
	stream_request_sent_ms = 0

func set_context_setting(value: int) -> void:
	settings.context_size = value
	if fields.has("context_size") and is_instance_valid(fields.context_size):
		fields.context_size.text = str(value)

func context_growth_ceiling(current: int) -> int:
	if not bool(settings.get("auto_context_enabled", true)):
		return current
	if context_growth_blocked.has(context_model_key()) or context_reload_attempts >= CONTEXT_MAX_RELOADS:
		return current
	var ceiling := clampi(int(settings.get("auto_context_max", AUTO_CONTEXT_DEFAULT_MAX)), 2048, AUTO_CONTEXT_HARD_MAX)
	if context_model_train_limit > 0:
		ceiling = mini(ceiling, context_model_train_limit)
	# Never shrink a manually configured, already-running context here.
	return maxi(current, ceiling)

func next_context_size(current: int, needed: int, ceiling: int) -> int:
	if needed <= current or ceiling <= current:
		return current
	var target := maxi(needed, current + CONTEXT_GROWTH_STEP)
	target = int(ceil(float(target) / float(CONTEXT_GROWTH_STEP))) * CONTEXT_GROWTH_STEP
	return mini(target, ceiling)

func estimate_context_tokens(messages: Array) -> int:
	# Only estimate text, never the base64 transport size of an image. Image-token
	# usage is model-dependent; a server overflow supplies the authoritative count.
	var tokens := 32
	for value in messages:
		if not value is Dictionary:
			continue
		var content = value.get("content", "")
		tokens += 16
		if content is String:
			tokens += int(ceil(float(content.to_utf8_buffer().size()) / 2.5))
		elif content is Array:
			for part in content:
				if not part is Dictionary:
					continue
				if str(part.get("type", "")) == "text":
					tokens += int(ceil(float(str(part.get("text", "")).to_utf8_buffer().size()) / 2.5))
				elif str(part.get("type", "")) in ["image_url", "input_image"]:
					tokens += 4096
	return tokens

func context_json_request(path: String, method: int, data: Dictionary, serial: int) -> Dictionary:
	if not context_request_is_current(serial):
		return {}
	var engine_serial := context_engine_serial
	var request := HTTPRequest.new()
	request.timeout = 5.0
	request.body_size_limit = 8 * 1024 * 1024
	request.use_threads = true
	add_child(request)
	var body := "" if method == HTTPClient.METHOD_GET else JSON.stringify(data)
	var error := request.request("http://%s:%d%s" % [HOST, int(settings.port), path], PackedStringArray(["Content-Type: application/json"]), method, body)
	if error != OK:
		request.queue_free()
		return {}
	var result: Array = await request.request_completed
	request.queue_free()
	if not context_request_is_current(serial) or engine_serial != context_engine_serial:
		return {}
	if result.size() != 4 or int(result[0]) != HTTPRequest.RESULT_SUCCESS or int(result[1]) != 200:
		return {}
	var bytes: PackedByteArray = result[3]
	var json := JSON.new()
	if json.parse(bytes.get_string_from_utf8()) != OK or not json.data is Dictionary:
		return {}
	return json.data

func read_context_metadata(serial: int) -> void:
	if context_metadata_loaded:
		return
	var engine_serial := context_engine_serial
	var props := await context_json_request("/props", HTTPClient.METHOD_GET, {}, serial)
	if not context_request_is_current(serial) or engine_serial != context_engine_serial:
		return
	var defaults = props.get("default_generation_settings", {})
	if defaults is Dictionary and int(defaults.get("n_ctx", 0)) > 0:
		context_runtime_size = int(defaults.n_ctx)
	var models := await context_json_request("/v1/models", HTTPClient.METHOD_GET, {}, serial)
	if not context_request_is_current(serial) or engine_serial != context_engine_serial:
		return
	var entries = models.get("data", [])
	if entries is Array and not entries.is_empty() and entries[0] is Dictionary:
		var metadata = entries[0].get("meta", {})
		if metadata is Dictionary:
			context_model_train_limit = maxi(0, int(metadata.get("n_ctx_train", 0)))
	context_metadata_loaded = true
	log_line("CONTEXT", "Running context %d; automatic ceiling %d; model training limit %s" % [context_runtime_size, context_growth_ceiling(context_runtime_size), str(context_model_train_limit) if context_model_train_limit > 0 else "unavailable"])

func measure_context_tokens(messages: Array, serial: int) -> int:
	if not context_tokenizer_available:
		return -1
	for value in messages:
		if value is Dictionary and not value.get("content", "") is String:
			return -1 # Text tokenization cannot measure image embeddings.
	var formatted := await context_json_request("/apply-template", HTTPClient.METHOD_POST, {"messages": messages, "add_generation_prompt": true}, serial)
	if not context_request_is_current(serial):
		return -1
	if not formatted.get("prompt", null) is String:
		context_tokenizer_available = false
		log_line("CONTEXT", "Template/tokenizer preflight unavailable; using an estimate plus server-error recovery")
		return -1
	var counted := await context_json_request("/tokenize", HTTPClient.METHOD_POST, {"content": formatted.prompt, "add_special": true, "parse_special": true, "with_pieces": false}, serial)
	if not context_request_is_current(serial):
		return -1
	var tokens = counted.get("tokens", null)
	if tokens is Array and not tokens.is_empty():
		return tokens.size()
	context_tokenizer_available = false
	return -1

func remove_oldest_context_turn(payload: Dictionary) -> bool:
	var messages: Array = payload.get("messages", [])
	var protected_start := messages.size() - context_protected_tail_count
	# The system prompt and the complete current user turn (including images,
	# attachments and artifact instructions) are never truncated or removed.
	if protected_start <= 1:
		return false
	messages.remove_at(1)
	while messages.size() - context_protected_tail_count > 1:
		if str(messages[1].get("role", "")) == "user":
			break
		messages.remove_at(1)
	payload.messages = messages
	return true

func prepare_pending_context_request(serial: int, known_prompt_tokens: int = -1) -> void:
	if not context_request_is_current(serial):
		return
	request_preparing = true
	set_status("CHECKING CONTEXT BUDGET", colors.amber)
	var parsed = JSON.parse_string(str(get_meta("pending_payload", "{}")))
	if not parsed is Dictionary or not parsed.get("messages", null) is Array:
		fail_generation("The queued chat request is missing its messages.")
		return
	var payload: Dictionary = parsed
	payload.erase("n_ctx")
	payload.erase("num_ctx")
	await read_context_metadata(serial)
	if not context_request_is_current(serial):
		return
	var current := maxi(512, context_runtime_size if context_runtime_size > 0 else int(settings.context_size))
	var estimate := estimate_context_tokens(payload.messages)
	var measured := known_prompt_tokens
	var prompt_tokens := estimate
	# /apply-template + /tokenize are useful near the limit, but they add two
	# local HTTP round-trips to every tiny chat. The estimator is deliberately
	# conservative, so skip exact counting when the request already has generous room.
	var safe_fast_preflight := known_prompt_tokens < 0 and estimate + context_desired_output + CONTEXT_SAFETY_TOKENS + 768 <= current
	if measured < 0 and not safe_fast_preflight:
		measured = await measure_context_tokens(payload.messages, serial)
		if not context_request_is_current(serial):
			return
	if measured >= 0:
		prompt_tokens = measured
	elif safe_fast_preflight:
		log_line("CONTEXT", "Fast preflight used conservative estimate; exact tokenizer check was unnecessary")
	var ceiling := context_growth_ceiling(current)
	var dropped_turns := 0
	# Compact only the outgoing history copy, and only when even the available
	# automatic ceiling cannot hold the prompt plus a minimum useful answer.
	while prompt_tokens + CONTEXT_SAFETY_TOKENS + CONTEXT_MIN_OUTPUT_TOKENS > ceiling:
		var ratio := maxf(1.0, float(prompt_tokens) / float(maxi(1, estimate_context_tokens(payload.messages))))
		var batch_dropped := 0
		while prompt_tokens + CONTEXT_SAFETY_TOKENS + CONTEXT_MIN_OUTPUT_TOKENS > ceiling:
			if not remove_oldest_context_turn(payload):
				break
			batch_dropped += 1
			dropped_turns += 1
			prompt_tokens = int(ceil(float(estimate_context_tokens(payload.messages)) * ratio))
		if batch_dropped == 0:
			fail_generation("This request needs about %d prompt tokens, but the usable context limit is %d. SAM kept your latest message, attachment, MemoryCore and saved chat intact. Use a smaller attachment or raise AUTO LIMIT/CONTEXT only within your model and memory limits." % [prompt_tokens, ceiling])
			return
		var recounted := await measure_context_tokens(payload.messages, serial)
		if not context_request_is_current(serial):
			return
		if recounted >= 0:
			prompt_tokens = recounted
	if dropped_turns > 0:
		log_line("CONTEXT", "Left %d oldest turn(s) out of this request only; saved chat and current input were not changed" % dropped_turns)
		show_toast("Context limit reached • older turns left out of this request; saved chat is unchanged")
	context_prompt_tokens = prompt_tokens
	var needed := prompt_tokens + context_desired_output + CONTEXT_SAFETY_TOKENS
	var target := next_context_size(current, needed, ceiling)
	if target > current:
		payload.max_tokens = context_desired_output
		set_meta("pending_payload", JSON.stringify(payload))
		begin_context_reload(target, serial)
		return
	var available_output := current - prompt_tokens - CONTEXT_SAFETY_TOKENS
	if available_output < CONTEXT_MIN_OUTPUT_TOKENS:
		fail_generation("The current input cannot fit in the running model context. Your message and files were preserved.")
		return
	payload.max_tokens = mini(context_desired_output, available_output)
	if int(payload.max_tokens) < context_desired_output:
		log_line("CONTEXT", "Output limited to %d tokens to preserve the complete current input" % int(payload.max_tokens))
	if active_artifact_builder_mode:
		artifact_output_token_budget = int(payload.max_tokens)
		artifact_progress_next_chars = 1
	set_meta("pending_payload", JSON.stringify(payload))
	set_meta("request_sent", false)
	reset_stream_response_state()
	sse_buffer.clear()
	stream_retry_not_before_ms = 0
	stream_client.close()
	stream_client = HTTPClient.new()
	var error := stream_client.connect_to_host(HOST, int(settings.port))
	request_preparing = false
	if error != OK:
		retry_stream_request(error, 500)
		return
	set_status("GENERATING RESPONSE", colors.green)
	log_line("CONTEXT", "Prompt %d tokens (%s), output up to %d, safety %d, running context %d" % [prompt_tokens, "tokenizer/server count" if measured >= 0 else "estimate", int(payload.max_tokens), CONTEXT_SAFETY_TOKENS, current])

func begin_context_reload(target: int, serial: int) -> void:
	if not context_request_is_current(serial):
		return
	context_previous_size = int(settings.context_size)
	context_reload_attempts += 1
	context_reload_pending = true
	context_rollback_pending = false
	context_resume_serial = serial
	request_preparing = true
	stream_finished = false
	stream_retry_not_before_ms = 0
	stream_client.close()
	set_context_setting(target)
	log_line("CONTEXT", "Growing running context %d -> %d; keeping the same queued request (reload %d/%d)" % [context_runtime_size, target, context_reload_attempts, CONTEXT_MAX_RELOADS])
	show_toast("Expanding context to %d • your message will resume automatically" % target)
	# Persist only after /health succeeds. A failed allocation must not poison
	# the next app launch with a context size that this machine cannot load.
	call_deferred("launch_context_reload")

func launch_context_reload() -> void:
	if context_reload_pending and not shutdown_started:
		start_engine(true)

func resume_context_after_ready() -> bool:
	if not context_reload_pending:
		return false
	var serial := context_resume_serial
	var was_rollback := context_rollback_pending
	context_reload_pending = false
	context_rollback_pending = false
	context_resume_serial = -1
	save_json(SETTINGS_FILE, settings)
	if context_request_is_current(serial):
		stream_retry_count = 0
		log_line("CONTEXT", "Previous context restored; fitting the preserved request without further growth" if was_rollback else "Larger context is healthy; resuming the preserved request")
		call_deferred("prepare_pending_context_request", serial, context_prompt_tokens)
	return true

func recover_context_reload_failure(reason: String) -> bool:
	if not context_reload_pending:
		return false
	stop_engine(false)
	if not context_rollback_pending:
		context_growth_blocked[context_model_key()] = true
		context_rollback_pending = true
		set_context_setting(context_previous_size)
		save_json(SETTINGS_FILE, settings)
		log_line("CONTEXT", "%s. Restoring the previous %d-token setting; further auto-growth for this model is disabled for this app session" % [reason, context_previous_size])
		show_toast("Larger context could not load • restoring the previous setting")
		call_deferred("launch_context_reload")
	else:
		context_reload_pending = false
		context_rollback_pending = false
		context_resume_serial = -1
		if generating:
			fail_generation("The engine could not load the larger context or restart at the previous setting. Your accepted message is saved. Check model/VRAM availability in Debug Telemetry. " + reason)
		else:
			set_status("ENGINE RECOVERY FAILED • CHECK DEBUG", colors.red)
			log_line("ERROR", reason)
	return true

func parse_context_overflow(body: String) -> Dictionary:
	var json := JSON.new()
	var details: Dictionary = {}
	if json.parse(body) == OK and json.data is Dictionary:
		var error = json.data.get("error", json.data)
		if error is Dictionary:
			details = error
	var message := str(details.get("message", body)).to_lower()
	var error_type := str(details.get("type", "")).to_lower()
	if error_type not in ["exceed_context_size_error", "context_length_exceeded"] and not (message.contains("context") and (message.contains("exceed") or message.contains("too long"))):
		return {}
	var prompt_tokens := int(details.get("n_prompt_tokens", 0))
	var context_size := int(details.get("n_ctx", 0))
	var pattern := RegEx.new()
	if prompt_tokens <= 0:
		pattern.compile("request \\((\\d+) tokens\\)")
		var match_prompt := pattern.search(message)
		if match_prompt != null:
			prompt_tokens = int(match_prompt.get_string(1))
	if context_size <= 0:
		pattern.compile("context (?:size|window)\\s*\\((\\d+)(?:\\s+tokens)?\\)")
		var match_context := pattern.search(message)
		if match_context != null:
			context_size = int(match_context.get_string(1))
	return {"prompt_tokens": prompt_tokens, "context_size": context_size}

func handle_stream_http_error() -> void:
	var response_code := stream_response_code
	var body := stream_http_body.get_string_from_utf8()
	var overflow := parse_context_overflow(body)
	if not overflow.is_empty() and response_text.is_empty() and context_overflow_retries < CONTEXT_MAX_OVERFLOW_RETRIES:
		context_overflow_retries += 1
		if int(overflow.context_size) > 0:
			context_runtime_size = int(overflow.context_size)
		var prompt_tokens := int(overflow.prompt_tokens)
		if prompt_tokens <= 0:
			prompt_tokens = maxi(context_runtime_size + 1, int(ceil(float(maxi(1, context_prompt_tokens)) * 1.25)))
		stream_client.close()
		stream_retry_not_before_ms = 0
		request_preparing = true
		log_line("CONTEXT", "Server reports %d prompt tokens / %d context; recovering the same request (%d/%d)" % [prompt_tokens, context_runtime_size, context_overflow_retries, CONTEXT_MAX_OVERFLOW_RETRIES])
		call_deferred("prepare_pending_context_request", context_request_serial, prompt_tokens)
		return
	if response_code == 503 and body.to_lower().contains("loading model") and response_text.is_empty() and stream_retry_count < 15:
		retry_stream_request(ERR_BUSY, 2000)
		set_status("MODEL IS LOADING • REQUEST QUEUED", colors.amber)
		return
	fail_generation("Model server HTTP %s: %s" % [response_code, body if not body.is_empty() else "empty error response"])

func calculate_history_start(memory_chars: int) -> int:
	# Conservative approximation: one token per three characters, with output room reserved.
	var context_limit := maxi(2048, context_runtime_size if context_runtime_size > 0 else int(settings.context_size))
	var output_reserve := mini(maxi(512, int(settings.max_tokens)), maxi(512, context_limit / 2))
	var char_budget := maxi(1500, (context_limit - output_reserve - 256) * 3 - memory_chars)
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

func is_lightweight_chat_request(text: String) -> bool:
	if not attached_image_path.is_empty() or not attached_file_path.is_empty():
		return false
	var lower := text.to_lower().strip_edges()
	if lower.is_empty() or lower.length() > 96:
		return false
	for marker in ["code", "script", "file", "image", "photo", "memory", "remember", "knowledge", "who is", "whois", "what is", "where", "when", "why", "how", "run ", "open ", "install", "powershell", "command", "fix ", "error", "latest", "today", "search", "find "]:
		if lower.contains(marker):
			return false
	var casual := ["hi", "hey", "hello", "yo", "sup", "whats up", "what's up", "how are you", "how you doing", "good morning", "good afternoon", "good evening", "thanks", "thank you", "cool", "nice"]
	for phrase in casual:
		if lower == phrase or lower.begins_with(phrase + " "):
			return true
	return lower.split(" ", false).size() <= 3 and lower.length() <= 24

func compact_memory_for_fast_chat(full_memory: String) -> String:
	# Greetings and tiny conversational turns should not re-evaluate the entire
	# long-lived MemoryCore, tool manual, repair archive, and KnowledgeVault. Keep
	# the durable identity/header material plus a compact runtime instruction.
	var compact := full_memory
	for heading in ["### LEARNED FACTS & MEMORY:", "### AUTOMATIC CODE REPAIR LESSONS:"]:
		var at := compact.find(heading)
		if at > 0:
			compact = compact.left(at).strip_edges()
	if compact.length() > 4200:
		compact = compact.left(4200).strip_edges()
	compact += "\n\n### FAST CONVERSATION MODE\nThis is a lightweight social turn. Reply naturally and briefly as SAM. Do not search KnowledgeVault, discuss tools, or expand into a tutorial unless the user actually asked for that."
	return compact

func live_voice_wants_saved_context(text: String) -> bool:
	var lower := text.to_lower()
	for marker in ["remember", "memorycore", "memory core", "knowledgevault", "knowledge vault", "saved note", "previous session", "recorded", "recording", "what did i say", "what did we talk", "from memory", "you learned"]:
		if lower.contains(marker):
			return true
	return false

func compact_memory_for_live_voice(full_memory: String) -> String:
	# Spoken conversation needs personality and recent context, not a giant tool
	# manual or unrelated KnowledgeVault history. Keep SAM's identity material and
	# a compact memory prefix so first-token latency stays low.
	var compact := full_memory
	for heading in ["### LOCAL TOOL ORCHESTRATION", "### AUTOMATIC CODE REPAIR LESSONS:"]:
		var at := compact.find(heading)
		if at > 0:
			compact = compact.left(at).strip_edges()
	if compact.length() > 6500:
		compact = compact.left(6500).strip_edges()
	compact += "\n\n### LIVE VOICE CONVERSATION MODE\nRespond like a natural spoken conversation. Focus on the user's newest utterance and the immediately preceding turns. Keep ordinary replies to roughly 1–3 sentences unless the user asks for depth. Never answer with the literal word 'None' when a useful conversational response is possible. Do not call the user 'master' or use forced honorifics unless they explicitly ask for that style. Do not invent current news or silently drag in unrelated saved transcripts. If the user asks for current news and no current source is available, say that briefly. If the user interrupts or corrects you, adapt immediately to the correction instead of repeating the previous answer. If they tell a joke, riff, tease, or ask whether something is funny, react naturally and use a laugh/chuckle when it fits instead of giving an AI-capability disclaimer. Do not mention transcription machinery, prompts, tokens, or internal tool state unless asked. If you return code, put all code inside fenced code blocks and keep the spoken prose outside those fences concise; SAM's voice layer intentionally does not read source code aloud. Prefer direct, concrete ideas over generic tutorial boilerplate.\n" + sam_humor_prompt()
	return compact

func ensure_stream_chat_header() -> void:
	if command_center_request_active:
		return
	if stream_chat_started or not is_instance_valid(chat_log):
		return
	stream_chat_started = true
	chat_log.append_text("\n[color=#76f7a6][b]SAM[/b][/color]\n")
	if force_chat_follow or chat_is_near_bottom():
		chat_log.scroll_to_line(chat_log.get_line_count())

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
	var extension_languages := {"py": "Python", "gd": "Godot 4 GDScript", "gdshader": "Godot 4 Shader", "glsl": "GLSL", "hlsl": "HLSL", "js": "JavaScript", "jsx": "JavaScript", "ts": "TypeScript", "tsx": "TypeScript", "cs": "C#", "cpp": "C++", "cc": "C++", "c": "C", "h": "C/C++", "hpp": "C++", "java": "Java", "rs": "Rust", "go": "Go", "ps1": "PowerShell", "sh": "Shell", "html": "HTML", "css": "CSS", "sql": "SQL"}
	if extension_languages.has(extension):
		return str(extension_languages[extension])
	var lower := text.to_lower()
	if lower.contains("python") or lower.contains("pygame"):
		return "Python"
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
	var dots := ["● · ·", "· ● ·", "· · ●", "· ● ·", "● · ·", "● ● ·"]
	# Never rebuild the complete rich-text transcript for an animation frame.
	# Long code chats make that layout pass expensive enough to freeze the UI.
	var context_phase := "RESTORING PREVIOUS CONTEXT" if context_rollback_pending else "EXPANDING CONTEXT TO %d" % int(settings.context_size)
	if context_reload_pending:
		set_status("%s  %s" % [context_phase, dots[frame]], colors.amber)
	elif request_preparing:
		set_status("CHECKING REQUEST CONTEXT  %s" % dots[frame], colors.amber)
	else:
		set_status("SAM IS THINKING  %s" % dots[frame], colors.green)
	if is_instance_valid(thinking_indicator):
		var phase := context_phase if context_reload_pending else ("CHECKING REQUEST CONTEXT" if request_preparing else ("WRITING YOUR REPLY" if not response_text.is_empty() else "SAM IS THINKING"))
		thinking_indicator.text = "%s   %s%s" % [phase, dots[frame], "   • %d queued" % pending_message_queue.size() if not pending_message_queue.is_empty() else ""]
		thinking_indicator.visible = true

func update_queue_button() -> void:
	if not is_instance_valid(send_button):
		return
	if generating:
		send_button.disabled = false
		send_button.text = "QUEUE MESSAGE%s" % (" (%d)" % pending_message_queue.size() if not pending_message_queue.is_empty() else "")
	else:
		send_button.disabled = false
		send_button.text = "TRANSMIT"

func dispatch_next_queued_message() -> void:
	if generating or not server_ready or pending_message_queue.is_empty():
		return
	var next_message: String = pending_message_queue.pop_front()
	queued_message_already_shown = true
	input_box.text = next_message
	update_queue_button()
	call_deferred("send_message")

func _text_has_whole_word(value: String, word: String) -> bool:
	var lower := value.to_lower()
	var target := word.to_lower()
	if target.is_empty():
		return false
	var allowed := "abcdefghijklmnopqrstuvwxyz0123456789_"
	var offset := 0
	while offset <= lower.length() - target.length():
		var at := lower.find(target, offset)
		if at < 0:
			return false
		var before_ok := at == 0 or not allowed.contains(lower.substr(at - 1, 1))
		var after_at := at + target.length()
		var after_ok := after_at >= lower.length() or not allowed.contains(lower.substr(after_at, 1))
		if before_ok and after_ok:
			return true
		offset = at + target.length()
	return false

func _text_has_any_phrase(value: String, phrases: Array) -> bool:
	var lower := value.to_lower()
	for phrase in phrases:
		if lower.contains(str(phrase).to_lower()):
			return true
	return false

func _has_explicit_image_edit_command(user_text: String) -> bool:
	var lower := user_text.to_lower().strip_edges()
	if _text_has_any_phrase(lower, [
		"edit this image", "edit this picture", "edit this photo",
		"edit the image", "edit the picture", "edit the photo",
		"change this image", "change this picture", "change this photo",
		"change the image", "change the picture", "change the photo",
		"remove the background", "change the background", "replace the background",
		"change pose", "new outfit", "wet clothes", "wet clothing",
		"soaked clothes", "soaked clothing"
	]):
		return true

	var visual_target := false
	for target in [
		"shirt", "top", "blouse", "pants", "trousers", "jeans", "shorts",
		"dress", "skirt", "outfit", "clothes", "clothing", "jacket", "coat",
		"sweater", "hoodie", "uniform", "swimsuit", "bikini", "underwear",
		"lingerie", "sock", "stocking", "shoe", "boot", "sneaker", "heel",
		"hat", "cap", "beanie", "glasses", "sunglasses", "scarf", "necklace",
		"tie", "belt", "bag", "purse", "backpack", "earring", "glove",
		"watch", "bracelet", "ring", "hair", "ponytail", "face", "eyes",
		"eyebrow", "eyelash", "nose", "mouth", "lips", "makeup", "beard",
		"mustache", "moustache", "smile", "background", "forest", "beach",
		"city", "bedroom", "kitchen", "bathroom", "restroom", "washroom",
		"room", "snow", "sunset", "sunrise", "chair", "couch", "sofa"
	]:
		if _text_has_whole_word(lower, target):
			visual_target = true
			break
	if not visual_target:
		for pose_phrase in [
			"sit down", "stand up", "turn around", "lie down", "laying down",
			"lying down", "look older", "look younger", "look serious",
			"golden hour", "rainy night"
		]:
			if lower.contains(pose_phrase):
				visual_target = true
				break
	if not visual_target:
		return false

	var edit_verb := (
		_text_has_whole_word(lower, "edit") or _text_has_whole_word(lower, "change")
		or _text_has_whole_word(lower, "replace") or _text_has_whole_word(lower, "make")
		or _text_has_whole_word(lower, "add") or _text_has_whole_word(lower, "remove")
		or _text_has_whole_word(lower, "recolor") or _text_has_whole_word(lower, "recolour")
		or _text_has_whole_word(lower, "redesign") or _text_has_whole_word(lower, "put")
		or _text_has_whole_word(lower, "place") or _text_has_whole_word(lower, "give")
	)
	return edit_verb

func _has_explicit_image_context_request(user_text: String) -> bool:
	var lower := user_text.to_lower().strip_edges()
	if _text_has_any_phrase(lower, [
		"this image", "this picture", "this photo", "that image", "that picture", "that photo",
		"the image", "the picture", "the photo", "attached image", "attached picture", "attached photo",
		"in the image", "in the picture", "in the photo", "from the image", "from the picture", "from the photo",
		"use this image", "use this picture", "use this photo", "reference image", "reference photo"
	]):
		return true
	if _has_explicit_image_edit_command(user_text):
		return true
	return _text_has_any_phrase(lower, [
		"what is she wearing", "what's she wearing", "what is he wearing", "what's he wearing",
		"what is she holding", "what's she holding", "what is he holding", "what's he holding",
		"what color is her", "what colour is her", "what color is his", "what colour is his",
		"describe her", "describe him", "where is she", "where is he",
		"what is behind her", "what's behind her", "what is behind him", "what's behind him",
		"tell me about the image", "tell me about the picture", "tell me about the photo"
	])

func restore_recent_image_context(user_text: String) -> void:
	if not attached_image_path.is_empty():
		return
	# Do not infer visual intent from loose substrings. For example, "her" inside
	# "therefore" used to revive an old image and could route ordinary chat into
	# the Wan pipeline. Only explicit image references or visual edit/follow-up
	# phrases may restore an older image.
	if is_new_image_generation_request(user_text) or not _has_explicit_image_context_request(user_text):
		return
	for index in range(history.size() - 1, -1, -1):
		var item = history[index]
		if item is Dictionary:
			var candidate := str(item.get("image_path", ""))
			if not candidate.is_empty() and FileAccess.file_exists(candidate):
				attach_file(candidate)
				show_toast("Using the most recent image from this project session")
				return

func is_knowledge_provenance_question(user_text: String) -> bool:
	var lower := user_text.to_lower().strip_edges()
	if lower.contains("image") or lower.contains("picture") or lower.contains("photo") or lower.contains("file"):
		return false
	return lower.contains("where did you get that info") \
		or lower.contains("where did you get the info") \
		or lower.contains("where did that information come from") \
		or lower.contains("where did you learn that") \
		or lower.contains("how did you know that") \
		or lower.contains("how do you know that") \
		or lower.contains("what is your source") \
		or lower.contains("what was your source") \
		or lower.contains("did you get that from knowledgevault") \
		or lower.contains("did you get that from the knowledge vault")

func previous_substantive_user_question() -> String:
	for index in range(history.size() - 1, -1, -1):
		var item = history[index]
		if item is Dictionary and str(item.get("role", "")) == "user":
			var candidate := str(item.get("content", "")).strip_edges()
			if not candidate.is_empty() and not is_knowledge_provenance_question(candidate):
				return candidate
	return ""

func answer_knowledge_provenance_question(user_text: String) -> bool:
	var prior_question := ""
	for index in range(history.size() - 1, -1, -1):
		var item = history[index]
		if item is Dictionary and str(item.get("role", "")) == "user":
			var candidate := str(item.get("content", "")).strip_edges()
			if not candidate.is_empty() and not is_knowledge_provenance_question(candidate):
				prior_question = candidate
				break
	var memory_matches := retrieve_explicit_memory(read_memory(), prior_question, 3) if not prior_question.is_empty() else ""
	var vault_matches := retrieve_knowledge(prior_question, 3) if not prior_question.is_empty() else ""
	var answer := ""
	if prior_question.is_empty():
		answer = "I cannot identify a previous question to trace yet. Ask the factual question first, then ask me where I got the information."
	elif not memory_matches.is_empty() and not vault_matches.is_empty():
		answer = "I used both MemoryCore and KnowledgeVault for my answer to “%s”. MemoryCore is treated as the authoritative user-supplied source; matching KnowledgeVault recordings are supporting, unverified observations.\n\nMemoryCore matches:\n%s\n\nKnowledgeVault matches:\n%s" % [prior_question.left(240), memory_matches.left(1600), vault_matches.left(2400)]
	elif not memory_matches.is_empty():
		answer = "I got that from MemoryCore, using the saved user-supplied information that matched “%s”.\n\nMatching memory:\n%s" % [prior_question.left(240), memory_matches.left(2200)]
	elif not vault_matches.is_empty():
		answer = "I got that from KnowledgeVault records that matched “%s”. These are captured transcript observations, so they may contain speech-to-text mistakes and are not automatically treated as verified facts.\n\nMatching records:\n%s" % [prior_question.left(240), vault_matches.left(2600)]
	else:
		answer = "No matching MemoryCore fact or KnowledgeVault record was supplied for my answer to “%s”. That answer came from the local model's existing knowledge and the current conversation, not from KnowledgeVault." % prior_question.left(240)
	input_box.clear()
	set_microphone_available(false)
	append_chat("user", user_text)
	history.append({"role": "user", "content": user_text})
	history.append({"role": "assistant", "content": answer})
	append_chat("assistant", answer, "", "", history.size() - 1)
	sent_messages.append(user_text)
	history_cursor = -1
	history_draft = ""
	set_session_complete(true)
	save_history()
	set_microphone_available(true)
	set_status("SOURCE TRACE COMPLETE • LOCAL", colors.green)
	show_toast("Answer sources traced locally • visual engine not used")
	return true

func answer_vague_image_edit_request(user_text: String) -> bool:
	var lower := user_text.to_lower()
	var asks_edit := lower.contains("edit this image") or lower.contains("edit this picture") or lower.contains("edit this photo")
	var vague := lower.contains("remove stuff") or not (lower.contains("remove the ") or lower.contains("crop") or lower.contains("resize") or lower.contains("background") or lower.contains("blur") or lower.contains("brighten") or lower.contains("erase"))
	if not asks_edit or not vague or attached_image_path.is_empty():
		return false
	var available_editor := "GIMP or another local image tool" if local_tool_inventory.to_lower().contains("gimp") else "a local image-processing script"
	var answer := "Yes—I can prepare that edit with %s through the supervised tool flow. What exactly should I remove or change? For example: remove the background, erase a named object, crop a person out, brighten the image, or resize it. I will show the planned tool and output file and ask before running anything." % available_editor
	input_box.clear()
	append_chat("user", user_text, attached_image_path, attached_file_path)
	history.append({"role": "user", "content": user_text, "image_path": attached_image_path})
	history.append({"role": "assistant", "content": answer})
	append_chat("assistant", answer, "", "", history.size() - 1)
	set_session_complete(true)
	save_history()
	show_toast("Image edit ready • tell Sam the exact change")
	return true

func requested_recolor_rgb(user_text: String) -> String:
	var lower := user_text.to_lower()
	var named_colors := {
		"white": "255, 255, 255", "black": "18, 18, 22", "red": "235, 45, 55",
		"blue": "45, 105, 240", "green": "45, 190, 95", "yellow": "245, 215, 45",
		"pink": "245, 85, 165", "purple": "145, 75, 220", "orange": "245, 135, 35"
	}
	for color_name in named_colors:
		if lower.contains(str(color_name)):
			return str(named_colors[color_name])
	return ""

func handle_visual_module_command(user_text: String) -> bool:
	var lower := user_text.to_lower().strip_edges()
	var selected := ""
	if lower.contains("use wan module") or lower.contains("switch to wan") or lower.contains("set mode to wan") or lower.contains("use the wan") or lower == "use wan" or lower.contains("enable wan"):
		selected = "wan"
	elif lower.contains("use local module") or lower.contains("switch to local") or lower.contains("set mode to local") or lower == "use local" or lower.contains("enable local") or lower.contains("use local inpainting") or lower.contains("use sam local inpainting"):
		selected = "local"
	elif lower.contains("use vision module") or lower.contains("switch to vision") or lower.contains("set mode to vision") or lower == "use vision" or lower.contains("enable vision") or lower.contains("describe mode") or lower.contains("analyze with vision"):
		selected = "vision"
	if selected.is_empty():
		return false
	settings.visual_module_preference = selected
	if selected == "wan":
		settings.image_generation_engine = "Wan 2.2 TI2V-5B (video; photo edits use inpainting)"
		settings.video_generation_engine = "Wan 2.2 TI2V-5B"
	elif selected == "local":
		settings.image_generation_engine = "SAM Local Inpainting"
	save_json(SETTINGS_FILE, settings)
	var has_action := lower.contains("reference") or lower.contains(" ref") or lower.contains("create") or lower.contains("generate") or lower.contains("make ") or lower.contains("change ") or lower.contains("edit ") or lower.contains("animate") or lower.contains("video") or lower.contains("describe") or lower.contains("what ")
	show_toast("Visual module preference set to " + selected.capitalize())
	if has_action:
		return false
	input_box.clear()
	var answer := "I’ll use Wan for visual generation and reference-image work until you switch modules." if selected == "wan" else ("I’ll use SAM Local Inpainting for attached-photo edits until you switch modules." if selected == "local" else "I’ll use the vision model for image description and analysis until you switch modules.")
	append_chat("user", user_text, "", "")
	history.append({"role": "user", "content": user_text})
	history.append({"role": "assistant", "content": answer})
	append_chat("assistant", answer, "", "", history.size() - 1)
	save_history()
	return true

func switch_to_primary_model() -> void:
	pending_vision_send = false
	restore_primary_when_done = false
	if engine_mode == "primary" and server_ready:
		show_toast("Main chat model is already active")
		return
	engine_mode = "primary"
	set_status("LOADING MAIN CHAT MODEL", colors.amber)
	show_toast("Switching to the main local chat model…")
	start_engine()

func handle_primary_model_command(user_text: String) -> bool:
	var lower := user_text.to_lower().strip_edges().trim_suffix(".")
	var requested := lower in ["use main model", "use the main model", "switch to main model", "switch to the main model", "use primary model", "use the primary model", "switch to primary model", "switch to the primary model", "use regular model", "use the regular model", "switch to regular model", "switch to the regular model", "use big model", "use the big model", "switch to big model", "switch to the big model", "use local chat model", "switch to local chat model"]
	if not requested:
		return false
	input_box.clear()
	append_chat("user", user_text)
	history.append({"role": "user", "content": user_text})
	var already_active := engine_mode == "primary" and server_ready
	var answer := "The main local chat model is already active." if already_active else "Switching back to the main local chat model now. Normal questions, KnowledgeVault retrieval, and coding will use it."
	history.append({"role": "assistant", "content": answer})
	append_chat("assistant", answer, "", "", history.size() - 1)
	save_history()
	if not already_active:
		switch_to_primary_model()
	return true

func handle_wan_video_request(user_text: String) -> bool:
	var lower := user_text.to_lower().strip_edges()
	var attached_motion := not attached_image_path.is_empty() and (lower.contains("what happens next") or lower.contains("camera pan") or lower.contains("pan left") or lower.contains("pan right") or lower.contains("zoom in") or lower.contains("zoom out") or lower.contains("add movement") or lower.contains("bring this image to life") or lower.contains("bring this photo to life") or lower.contains("make her move") or lower.contains("make him move") or lower.contains("make them move") or lower.contains("make her walk") or lower.contains("make him walk") or lower.contains("make her turn") or lower.contains("make him turn") or lower.contains("make her smile") or lower.contains("make him smile"))

	# A media noun alone is not generation intent. Without this guard, ordinary
	# questions such as "what movie is Dumb and Dumber?" were routed to Wan and
	# the chat was replaced by a generated Python job.
	var direct_generation_phrases := [
		"create a video", "create video", "create a movie", "create movie", "create an animation", "create animation", "create a film clip",
		"generate a video", "generate video", "generate a movie", "generate movie", "generate an animation", "generate animation", "generate a film clip",
		"make a video", "make me a video", "make this a video", "make it a video", "make a movie", "make me a movie", "make an animation", "make a film clip",
		"render a video", "render video", "render a movie", "render movie", "render an animation", "render animation", "render a film clip",
		"produce a video", "produce video", "produce a movie", "produce movie", "produce an animation", "produce animation", "produce a film clip"
	]
	var explicit_motion_command := lower.begins_with("animate") or lower.contains(" animate ") or lower.contains("turn this into a video") or lower.contains("turn it into a video") or lower.contains("image to video") or lower.contains("make this image move") or lower.contains("make the image move") or lower.contains("bring this image to life") or lower.contains("bring this photo to life") or lower.contains("render a scene where")
	var asks_video := contains_any(lower, direct_generation_phrases) or explicit_motion_command or attached_motion
	if not asks_video or str(settings.get("video_generation_engine", "Wan 2.2 TI2V-5B")) == "Disabled":
		return false
	settings.visual_module_preference = "wan"
	save_json(SETTINGS_FILE, settings)
	var runtime_dir := command_workspace_dir().path_join("WanRuntime")
	var marker_path := runtime_dir.path_join("wan22_ti2v_5b.ok")
	var cuda_marker_path := runtime_dir.path_join("wan_cuda.ok")
	if not FileAccess.file_exists(marker_path) or not FileAccess.file_exists(cuda_marker_path):
		var answer := "Wan 2.2 video generation needs both its local weights and a CUDA-enabled PyTorch runtime. SAM kept the image editor unchanged and opened the Wan + CUDA installer/repair; after it completes, retry this request."
		input_box.clear()
		append_chat("user", user_text, attached_image_path, attached_file_path)
		history.append({"role": "user", "content": user_text, "image_path": attached_image_path})
		history.append({"role": "assistant", "content": answer})
		append_chat("assistant", answer, "", "", history.size() - 1)
		save_history()
		set_session_status("dependency")
		show_wan22_install_dialog()
		return true
	var template_path := "res://tools/wan22_generate_template.py"
	if not FileAccess.file_exists(template_path):
		return false

	# Explicitly define frame count and output kind variables for pure video generation
	var frame_count_val := "81"
	var output_kind_val := "video"

	var source_image := attached_image_path
	var generated_dir := active_session_workspace_dir().path_join("wan22_%s" % Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_"))
	DirAccess.make_dir_recursive_absolute(generated_dir)
	var script_path := generated_dir.path_join("main.py")
	var output_path := generated_dir.path_join("wan22_output.mp4")
	var source := FileAccess.get_file_as_string(template_path)
	source = source.replace("__MODEL_PATH__", runtime_dir.path_join("wan22_ti2v_5b").replace("\\", "/"))
	source = source.replace("__WAN_PYTHON__", runtime_dir.path_join("venv/Scripts/python.exe").replace("\\", "/"))
	source = source.replace("__SOURCE_IMAGE__", source_image.replace("\\", "/"))
	source = source.replace("__OUTPUT_PATH__", output_path.replace("\\", "/"))
	source = source.replace("__PROGRESS_PATH__", generated_dir.path_join("wan_progress.json").replace("\\", "/"))
	source = source.replace("__PROMPT__", user_text.replace("\"\"\"", "\\\"\\\"\\\""))
	source = source.replace("__FRAME_COUNT__", frame_count_val)
	source = source.replace("__OUTPUT_KIND__", output_kind_val)
	var script := FileAccess.open(script_path, FileAccess.WRITE)
	if script == null:
		show_toast("Could not prepare the Wan generation job")
		return true
	script.store_string(source)
	script.close()
	input_box.clear()
	append_chat("user", user_text, source_image, "")
	history.append({"role": "user", "content": user_text, "image_path": source_image})
	var answer := "I prepared a local Wan 2.2 image-to-video job using the attached image as the first-frame reference." if not source_image.is_empty() else "I prepared a local Wan 2.2 text-to-video job from your description."
	answer += " It uses conservative settings and CPU offload for this 12 GB GPU, saves an MP4 in the session project, and opens it when complete."
	history.append({"role": "assistant", "content": answer + "\n```python\n" + source + "\n```"})
	set_session_status("working")
	save_history()
	clear_attachment()
	redraw_history()
	if not rendered_code_paths.is_empty():
		rendered_code_paths[rendered_code_paths.size() - 1] = script_path
	if bool(settings.get("pc_commands_enabled", false)):
		request_run_rendered_code.call_deferred(rendered_code_blocks.size() - 1)
	else:
		show_toast("Wan generation is ready • enable Workspace Tools, then press Run")
	return true

func is_new_image_generation_request(user_text: String) -> bool:
	var lower := user_text.to_lower()
	var creation_verb := lower.contains("create") or lower.contains("generate") or lower.contains("make me") or lower.contains("make a") or lower.contains("make an") or lower.contains("draw") or lower.contains("render")
	var image_noun := lower.contains("image") or lower.contains("picture") or lower.contains("photo") or lower.contains("portrait") or lower.contains("wallpaper") or lower.contains("artwork") or lower.contains("illustration")
	return creation_verb and image_noun

func handle_wan_text_image_request(user_text: String) -> bool:
	if not is_new_image_generation_request(user_text):
		return false
	settings.visual_module_preference = "wan"
	save_json(SETTINGS_FILE, settings)
	# Explicit fresh-image requests always use Wan. An attachment left in the
	# composer or restored from chat history is unrelated source context and must
	# not trigger the vision model or the attached-photo inpainting route.
	if not attached_image_path.is_empty() or not attached_file_path.is_empty():
		clear_attachment()
	var runtime_dir := command_workspace_dir().path_join("WanRuntime")
	var marker_path := runtime_dir.path_join("wan22_ti2v_5b.ok")
	var cuda_marker_path := runtime_dir.path_join("wan_cuda.ok")
	if not FileAccess.file_exists(marker_path) or not FileAccess.file_exists(cuda_marker_path):
		show_wan22_install_dialog()
		show_toast("Wan image generation needs the model weights and CUDA runtime")
		return true
	var template_path := "res://tools/wan22_generate_template.py"
	if not FileAccess.file_exists(template_path):
		show_toast("Wan generation template is missing")
		return true
	var generated_dir := active_session_workspace_dir().path_join("wan22_image_%s" % Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_"))
	DirAccess.make_dir_recursive_absolute(generated_dir)
	var script_path := generated_dir.path_join("main.py")
	var output_path := generated_dir.path_join("wan22_generated_image.png")
	var source := FileAccess.get_file_as_string(template_path)
	source = source.replace("__MODEL_PATH__", runtime_dir.path_join("wan22_ti2v_5b").replace("\\", "/"))
	source = source.replace("__WAN_PYTHON__", runtime_dir.path_join("venv/Scripts/python.exe").replace("\\", "/"))
	source = source.replace("__SOURCE_IMAGE__", "")
	source = source.replace("__OUTPUT_PATH__", output_path.replace("\\", "/"))
	source = source.replace("__PROGRESS_PATH__", generated_dir.path_join("wan_progress.json").replace("\\", "/"))
	source = source.replace("__PROMPT__", user_text.replace("\"\"\"", "\\\"\\\"\\\""))
	source = source.replace("__FRAME_COUNT__", "1")
	source = source.replace("__OUTPUT_KIND__", "image")
	var script := FileAccess.open(script_path, FileAccess.WRITE)
	if script == null:
		show_toast("Could not prepare the Wan image job")
		return true
	script.store_string(source)
	script.close()
	input_box.clear()
	append_chat("user", user_text, "", "")
	history.append({"role": "user", "content": user_text})
	var answer := "I prepared a new image with the local Wan 2.2 engine. SAM will unload the chat model before generation, save a new PNG in this session, open the result, and restore the chat model afterward."
	history.append({"role": "assistant", "content": answer + "\n```python\n" + source + "\n```"})
	set_session_status("working")
	save_history()
	redraw_history()
	if not rendered_code_paths.is_empty():
		rendered_code_paths[rendered_code_paths.size() - 1] = script_path
	if bool(settings.get("pc_commands_enabled", false)):
		request_run_rendered_code.call_deferred(rendered_code_blocks.size() - 1)
	else:
		show_toast("Wan image ready • enable Workspace Tools, then press Run")
	return true

func expand_wan_reference_prompt(user_text: String) -> String:
	var lower := user_text.to_lower()
	var details: Array[String] = []
	details.append("Use the attached image as the identity and appearance reference for the same person.")
	details.append("Apply the requested location, pose, action, and expression while preserving recognizable facial structure, skin tone, hair, clothing, and accessories unless the request explicitly changes one of them.")
	details.append("Create a clearly visible continuous transition away from the original pose and composition toward the requested final scene; do not freeze, merely animate, or return a near-copy of the reference frame.")
	details.append("Show realistic anatomy, hands, body proportions, physical contact, perspective, shadows, and lighting; avoid duplicated limbs, warped features, and an artificial or plastic face.")
	if lower.contains("sleep") or lower.contains("asleep") or lower.contains("laying on the bed") or lower.contains("lying on the bed"):
		details.append("For the sleeping scene, use a relaxed natural pose with eyes closed, a peaceful expression, and believable contact with the bed and pillow.")
	elif lower.contains("bed") or lower.contains("bedroom") or lower.contains("laying") or lower.contains("lying") or lower.contains("lie down"):
		details.append("Use a natural relaxed reclining pose with believable contact with the bed or supporting surface.")
	if lower.contains("kitchen"):
		details.append("Place the person clearly inside a coherent realistic kitchen with consistent scale, perspective, and environmental lighting.")
	if lower.contains("bathroom") or lower.contains("restroom") or lower.contains("washroom"):
		details.append("Place the person clearly inside a coherent realistic bathroom; keep them appropriately clothed unless the request explicitly says otherwise.")
	if lower.contains("sitting") or lower.contains("sit down") or lower.contains("seated"):
		details.append("Use a comfortable, anatomically natural seated pose with correct contact against the chair, couch, bed, or other supporting surface.")
	if lower.contains("standing") or lower.contains("stand up"):
		details.append("Use a balanced, anatomically natural standing pose with believable foot placement.")
	return "%s\n\n%s" % [user_text.strip_edges(), " ".join(details)]



func handle_wan_reference_image_request(user_text: String) -> bool:
	if attached_image_path.is_empty():
		return false
	var lower := user_text.to_lower()
	var reference_words := lower.contains("as a ref") or lower.contains("as ref") or lower.contains("as a reference") or lower.contains("reference image") or lower.contains("use this image") or lower.contains("use the image") or lower.contains("based on this image") or lower.contains("based on the image")
	var transformation_words := (
		lower.contains("she is wearing") or lower.contains("he is wearing") or lower.contains("they are wearing")
		or lower.contains("she's wearing") or lower.contains("he's wearing")
		or lower.contains("she has a") or lower.contains("he has a") or lower.contains("they have a")
		or lower.contains("give her") or lower.contains("give him") or lower.contains("give them")
		or lower.contains("put her") or lower.contains("put him") or lower.contains("put them")
		or lower.contains("place her") or lower.contains("place him") or lower.contains("place them")
		or lower.contains("make her") or lower.contains("make him") or lower.contains("make them")
		or lower.contains("change her") or lower.contains("change his") or lower.contains("change their")
		or lower.contains("add a ") or lower.contains("add an ") or lower.contains("add the ")
		or lower.contains("wearing a ") or lower.contains("wearing an ")
		or lower.contains("on a bed") or lower.contains("on the bed") or lower.contains("laying down") or lower.contains("lying down") or lower.contains("sleeping") or lower.contains("asleep")
		or lower.contains("sitting ") or lower.contains("standing ") or lower.contains("walking ") or lower.contains("running ")
		or lower.contains("background") or lower.contains("hair style") or lower.contains("hairstyle")
		or lower.contains("hair to ") or lower.contains("blonde hair") or lower.contains("curly hair") or lower.contains("short hair") or lower.contains("long hair") or lower.contains("ponytail")
		or lower.contains("beard") or lower.contains("mustache") or lower.contains("moustache") or lower.contains("look older") or lower.contains("look younger") or lower.contains("look serious") or lower.contains("laugh")
		or _text_has_whole_word(lower, "hat") or _text_has_whole_word(lower, "cap") or _text_has_whole_word(lower, "beanie") or _text_has_whole_word(lower, "headband") or _text_has_whole_word(lower, "crown")
		or _text_has_whole_word(lower, "glasses") or _text_has_whole_word(lower, "sunglasses") or _text_has_whole_word(lower, "jewelry") or _text_has_whole_word(lower, "jewellery") or _text_has_whole_word(lower, "necklace") or _text_has_whole_word(lower, "earring") or _text_has_whole_word(lower, "watch") or _text_has_whole_word(lower, "bracelet") or _text_has_whole_word(lower, "ring")
		or _text_has_whole_word(lower, "sock") or _text_has_whole_word(lower, "stocking") or _text_has_whole_word(lower, "shoe") or _text_has_whole_word(lower, "boot") or _text_has_whole_word(lower, "heel") or _text_has_whole_word(lower, "underwear")
		or lower.contains("forest") or lower.contains("beach") or lower.contains("city") or lower.contains("bedroom") or lower.contains("kitchen") or lower.contains("bathroom") or lower.contains("restroom") or lower.contains("washroom") or lower.contains("living room") or lower.contains("dining room") or lower.contains("snow") or lower.contains("sunset") or lower.contains("rainy night") or lower.contains("golden hour")
		or lower.contains("change pose") or lower.contains("turn around") or lower.contains("lie down") or lower.contains("remove the background")
	)
	var analysis_question := lower.begins_with("what ") or lower.begins_with("who ") or lower.begins_with("where ") or lower.begins_with("describe") or lower.begins_with("does ") or lower.begins_with("can you read") or lower.contains("tell me about") or lower.contains("what is in") or lower.contains("what's in") or lower.contains("analyze this") or lower.contains("analyse this")
	var explicit_edit_command := _has_explicit_image_edit_command(user_text)
	# Content words are not edit intent. A noun such as hat/ring/background may
	# describe an image or appear in normal prose. Require an explicit reference
	# instruction or an actual visual edit command before Wan can claim this turn.
	var asks_reference := (reference_words and transformation_words and not analysis_question) or explicit_edit_command
	# Local SD inpainting is appropriate for localized appearance edits, but it
	# cannot reliably rebuild pose/viewpoint/scene geometry. Automatically choose
	# Wan for those large transformations unless the same request explicitly
	# insists on the local module.
	var major_geometry_change := lower.contains("sitting") or lower.contains("sit down") or lower.contains("seated") or lower.contains("standing") or lower.contains("stand up") or lower.contains("laying") or lower.contains("lying") or lower.contains("lie down") or lower.contains("sleeping") or lower.contains("asleep") or lower.contains("kneeling") or lower.contains("crouching") or lower.contains("turn around") or lower.contains("facing forward") or lower.contains("face forward") or lower.contains("looking straight") or lower.contains("look straight") or lower.contains("change pose") or lower.contains("background") or lower.contains("bedroom") or lower.contains("kitchen") or lower.contains("bathroom") or lower.contains("restroom") or lower.contains("washroom") or lower.contains("living room") or lower.contains("dining room") or lower.contains("chair") or lower.contains("couch") or lower.contains("sofa") or lower.contains("forest") or lower.contains("beach") or lower.contains("city") or lower.contains("cyberpunk")
	var explicitly_local := lower.contains("use local") or lower.contains("local module") or lower.contains("local inpainting")
	var wan_selected := str(settings.get("visual_module_preference", "auto")) == "wan" or lower.contains("use wan")
	if not asks_reference or not wan_selected:
		return false
	var runtime_dir := command_workspace_dir().path_join("WanRuntime")
	if not FileAccess.file_exists(runtime_dir.path_join("wan22_ti2v_5b.ok")) or not FileAccess.file_exists(runtime_dir.path_join("wan_cuda.ok")):
		show_wan22_install_dialog()
		show_toast("Wan reference generation needs the model weights and CUDA runtime")
		return true
	var template_path := "res://tools/wan22_generate_template.py"
	if not FileAccess.file_exists(template_path):
		show_toast("Wan generation template is missing")
		return true
	settings.visual_module_preference = "wan"
	save_json(SETTINGS_FILE, settings)

# Detect whether the user requested a video or a still image
	var wants_video := lower.contains("video") or lower.contains("animation") or lower.contains("animate") or lower.contains("clip") or lower.contains("movie") or lower.contains("bring to life") or lower.contains("make her move") or lower.contains("make him move") or lower.contains("make them move")

	var output_ext := "mp4" if wants_video else "png"
	var output_kind_val := "video" if wants_video else "image"
	
	# Change 33 to 17 for images to reduce temporal stretching and blur
	var frame_count_val := "81" if wants_video else "1"

	var source_image := attached_image_path
	var generated_dir := active_session_workspace_dir().path_join("wan22_reference_%s" % Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_"))
	DirAccess.make_dir_recursive_absolute(generated_dir)
	var script_path := generated_dir.path_join("main.py")
	var output_path := generated_dir.path_join("wan22_reference_result.%s" % output_ext)
	var source := FileAccess.get_file_as_string(template_path)
	source = source.replace("__MODEL_PATH__", runtime_dir.path_join("wan22_ti2v_5b").replace("\\", "/"))
	source = source.replace("__WAN_PYTHON__", runtime_dir.path_join("venv/Scripts/python.exe").replace("\\", "/"))
	source = source.replace("__SOURCE_IMAGE__", source_image.replace("\\", "/"))
	source = source.replace("__OUTPUT_PATH__", output_path.replace("\\", "/"))
	source = source.replace("__PROGRESS_PATH__", generated_dir.path_join("wan_progress.json").replace("\\", "/"))
	var expanded_prompt := expand_wan_reference_prompt(user_text)
	source = source.replace("__PROMPT__", expanded_prompt.replace("\"\"\"", "\\\"\\\"\\\""))

	source = source.replace("__FRAME_COUNT__", frame_count_val)
	source = source.replace("__OUTPUT_KIND__", output_kind_val)

	var script := FileAccess.open(script_path, FileAccess.WRITE)
	if script == null:
		show_toast("Could not prepare the Wan reference-image job")
		return true
	script.store_string(source)
	script.close()
	input_box.clear()
	append_chat("user", user_text, source_image, "")
	history.append({"role": "user", "content": user_text, "image_path": source_image})

	var answer_type := "video" if wants_video else "image"
	var answer := "I prepared a Wan reference-%s job and automatically expanded your request with identity preservation, realistic pose/scene guidance, and visual safeguards. It uses the attached image as its reference and outputs the resulting %s file." % [answer_type, output_ext.to_upper()]

	history.append({"role": "assistant", "content": answer + "\n```python\n" + source + "\n```"})
	set_session_status("working")
	save_history()
	clear_attachment()
	redraw_history()
	if not rendered_code_paths.is_empty():
		rendered_code_paths[rendered_code_paths.size() - 1] = script_path
	if bool(settings.get("pc_commands_enabled", false)):
		request_run_rendered_code.call_deferred(rendered_code_blocks.size() - 1)
	else:
		show_toast("Wan reference job ready • enable Workspace Tools, then press Run")
	return true

func handle_wan_image_request(user_text: String) -> bool:
	if attached_image_path.is_empty() or not str(settings.get("image_generation_engine", "SAM Local Inpainting")).begins_with("Wan 2.2"):
		return false
	if not _has_explicit_image_edit_command(user_text):
		return false
	var lower := user_text.to_lower()
	var asks_generation := lower.contains("dress") or lower.contains("skirt") or lower.contains("outfit") or lower.contains("clothes") or lower.contains("replace") or lower.contains("generate")
	if not asks_generation:
		return false
	# Wan TI2V is a video generator, not a localized still-image inpainting
	# pipeline.  Keep the attached image and let the normal image-edit path use
	# SAM's installed segmentation + inpainting models for clothing replacement.
	show_toast("Attached-photo edit • using local inpainting to preserve the person and background")
	return false

func handle_direct_clothing_replace(user_text: String) -> bool:
	if attached_image_path.is_empty():
		return false
	# An old/current image plus ordinary conversation is not an edit request.
	if not _has_explicit_image_edit_command(user_text):
		return false
	var lower := user_text.to_lower()
	
	# If the user is asking for a major scene, room change, or pose transformation 
	# (like a bathroom, bedroom, kitchen, sitting, or standing), skip local inpainting 
	# and let Wan handle the environment and reference generation instead.
	var has_scene_or_pose_change := (
		lower.contains("bathroom") or lower.contains("restroom") or lower.contains("washroom") 
		or lower.contains("bedroom") or lower.contains("kitchen") or lower.contains("living room") 
		or lower.contains("dining room") or lower.contains("forest") or lower.contains("beach") 
		or lower.contains("city") or lower.contains("cyberpunk") or lower.contains("sitting") 
		or lower.contains("sit down") or lower.contains("seated") or lower.contains("standing") 
		or lower.contains("stand up") or lower.contains("laying") or lower.contains("lying") 
		or lower.contains("lie down") or lower.contains("sleeping") or lower.contains("asleep")
	)
	if has_scene_or_pose_change:
		return false

	var garment_named := false
	for garment_word in ["shirt", "top", "blouse", "pants", "trousers", "jeans", "shorts", "dress", "skirt", "outfit", "clothes", "clothing", "jacket", "coat", "sweater", "hoodie", "uniform", "swimsuit", "bikini", "bra", "underwear", "lingerie", "sock", "stocking", "shoe", "boot", "sneaker", "heel", "hat", "cap", "beanie", "glasses", "sunglasses", "scarf", "necklace", "tie", "belt", "bag", "purse", "backpack", "earring", "glove", "watch", "bracelet", "ring"]:
		if _text_has_whole_word(lower, garment_word):
			garment_named = true
			break
	var appearance_named := lower.contains("hair") or lower.contains("ponytail") or lower.contains("face") or lower.contains("eye") or lower.contains("eyebrow") or lower.contains("eyelash") or lower.contains("nose") or lower.contains("mouth") or lower.contains("lip") or lower.contains("makeup") or lower.contains("beard") or lower.contains("mustache") or lower.contains("moustache") or lower.contains("smile") or lower.contains("laugh") or lower.contains("look serious") or lower.contains("look older") or lower.contains("look younger")
	var scene_named := lower.contains("background") or lower.contains("scene") or lower.contains("forest") or lower.contains("beach") or lower.contains("city") or lower.contains("cyberpunk") or lower.contains("bedroom") or lower.contains("room") or lower.contains("snow") or lower.contains("sunset") or lower.contains("sunrise") or lower.contains("rainy night") or lower.contains("golden hour") or lower.contains("neon-lit") or lower.contains("neon lit")
	var pose_named := lower.contains("change pose") or lower.contains("laying") or lower.contains("lying") or lower.contains("lie down") or lower.contains("sitting") or lower.contains("sit down") or lower.contains("seated") or lower.contains("standing") or lower.contains("stand up") or lower.contains("turn around") or lower.contains("kneeling") or lower.contains("crouching") or lower.contains("make her sit") or lower.contains("make him sit") or lower.contains("make them sit") or lower.contains("make her stand") or lower.contains("make him stand")
	var visual_target_named := garment_named or appearance_named or scene_named or pose_named
	var damage_style := lower.contains("ripped") or lower.contains("torn") or lower.contains("distressed") or lower.contains("frayed") or lower.contains("shredded")
	var edit_verb := lower.contains("change ") or lower.contains("replace ") or lower.contains("make ") or lower.contains("turn ") or lower.contains("convert ") or lower.contains("edit ") or lower.contains("add ") or lower.contains("put ") or lower.contains("wearing ") or lower.contains("recolor ") or lower.contains("redesign ")
	var visual_question := lower.begins_with("what ") or lower.begins_with("where ") or lower.begins_with("who ") or lower.begins_with("which ") or lower.begins_with("describe ") or lower.begins_with("analyze ") or lower.contains("what color") or lower.contains("what is in") or lower.contains("what's in")
	var declarative_edit := not visual_question and (lower.contains("she is ") or lower.contains("he is ") or lower.contains("they are ") or lower.contains("her hair is ") or lower.contains("his hair is ") or lower.contains("her eyes are ") or lower.contains("his eyes are ") or lower.contains("she has ") or lower.contains("he has "))
	# Any explicit garment transformation with an attached image belongs to the
	# deterministic local editor. Never let the chat/coding model invent a second
	# source image path for requests such as "change her shirt to ...".
	var clothing_edit := ((edit_verb or declarative_edit) and visual_target_named) or lower.contains("new outfit") or lower.contains("wet clothes") or lower.contains("wet clothing") or lower.contains("soaked clothes") or lower.contains("soaked clothing") or (damage_style and garment_named)
	if not clothing_edit:
		return false
	var runtime_dir := command_workspace_dir().path_join("ImageEditRuntime")
	var marker_path := runtime_dir.path_join("installed.ok")
	if not FileAccess.file_exists(marker_path):
		pending_image_capability_request = user_text
		pending_image_capability_path = attached_image_path
		show_image_edit_capability_dialog()
		show_toast("Clothing replacement needs the local image-edit capability")
		return true
	var template_path := "res://tools/clothing_replace_inpaint_template.py"
	if not FileAccess.file_exists(template_path):
		show_toast("Built-in clothing replacement template is missing")
		return true
	var source_image := attached_image_path
	var generated_dir := active_session_workspace_dir().path_join("clothing_replace_%s" % Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_"))
	DirAccess.make_dir_recursive_absolute(generated_dir)
	var script_path := generated_dir.path_join("main.py")
	var output_path := generated_dir.path_join("clothing_replaced.png")
	var source := FileAccess.get_file_as_string(template_path)
	source = source.replace("__SOURCE_IMAGE__", source_image.replace("\\", "/"))
	source = source.replace("__OUTPUT_PATH__", output_path.replace("\\", "/"))
	source = source.replace("__INPAINT_MODEL__", runtime_dir.path_join("inpainting_model").replace("\\", "/"))
	source = source.replace("__SEGMENTER_MODEL__", runtime_dir.path_join("clothing_segmenter").replace("\\", "/"))
	source = source.replace("__EDIT_PROMPT__", user_text.replace("\"\"\"", "\\\"\\\"\\\""))
	var script := FileAccess.open(script_path, FileAccess.WRITE)
	if script == null:
		show_toast("Could not prepare the clothing replacement job")
		return true
	script.store_string(source)
	script.close()
	input_box.clear()
	append_chat("user", user_text, source_image, "")
	history.append({"role": "user", "content": user_text, "image_path": source_image})
	var answer := "I prepared a complete local clothing-replacement job using SAM's installed clothing segmenter and inpainting model. Before it runs, SAM will unload the chat model to free VRAM, preserve the original, save a new PNG, open the result, and then restore the chat model."
	history.append({"role": "assistant", "content": answer + "\n```python\n" + source + "\n```"})
	set_session_status("working")
	save_history()
	clear_attachment()
	redraw_history()
	if not rendered_code_paths.is_empty():
		rendered_code_paths[rendered_code_paths.size() - 1] = script_path
	if bool(settings.get("pc_commands_enabled", false)):
		request_run_rendered_code.call_deferred(rendered_code_blocks.size() - 1)
	else:
		show_toast("Clothing edit ready • enable Workspace Tools, then press Run")
	return true

func answer_disallowed_nudification(user_text: String) -> bool:
	return false
	if attached_image_path.is_empty():
		return false
	var lower := user_text.to_lower()
	var asks_nudification := lower.contains("remove her clothes") or lower.contains("remove his clothes") or lower.contains("remove the clothes") or lower.contains("take off her clothes") or lower.contains("take off his clothes") or lower.contains("make her nude") or lower.contains("make him nude") or lower.contains("make her naked") or lower.contains("make him naked") or lower.contains("undress her") or lower.contains("undress him")
	if not asks_nudification:
		return false
	var answer := "I can edit this person's wardrobe—change the garment, material, color, fit, or make the clothing look realistically wet—but I can't remove a real person's clothing or generate nudity from their photo. Try a request such as ‘change her outfit to a black satin dress’ or ‘make her clothes look rain-soaked while keeping them opaque.’"
	input_box.clear()
	append_chat("user", user_text, attached_image_path, attached_file_path)
	history.append({"role": "user", "content": user_text, "image_path": attached_image_path})
	history.append({"role": "assistant", "content": answer})
	append_chat("assistant", answer, "", "", history.size() - 1)
	set_session_complete(true)
	save_history()
	clear_attachment()
	show_toast("Wardrobe edits are available • nudification is not")
	return true

func handle_direct_shirt_recolor(user_text: String) -> bool:
	if attached_image_path.is_empty():
		return false
	var lower := user_text.to_lower()
	var garment := lower.contains("shirt") or lower.contains("top") or lower.contains("blouse")
	var recolor := lower.contains("color") or lower.contains("colour") or lower.contains("make her") or lower.contains("make his") or lower.contains("change her shirt") or lower.contains("change his shirt")
	var target_rgb := requested_recolor_rgb(user_text)
	if not garment or not recolor or target_rgb.is_empty():
		return false
	var runtime_dir := command_workspace_dir().path_join("ImageEditRuntime")
	var marker_path := runtime_dir.path_join("installed.ok")
	if not FileAccess.file_exists(marker_path):
		var answer := "A clean shirt recolor needs the clothing-segmentation capability. The earlier polygon fallback produced a bad mask, so SAM will not use it again. Finish installing the image-edit capability and SAM will retry this exact request with the segmentation model."
		input_box.clear()
		append_chat("user", user_text, attached_image_path, "")
		history.append({"role": "user", "content": user_text, "image_path": attached_image_path})
		history.append({"role": "assistant", "content": answer})
		append_chat("assistant", answer, "", "", history.size() - 1)
		save_history()
		pending_image_capability_request = user_text
		pending_image_capability_path = attached_image_path
		set_session_status("dependency")
		show_image_edit_capability_dialog()
		return true
	var template_path := "res://tools/shirt_recolor_segmented_template.py"
	if not FileAccess.file_exists(template_path):
		return false
	var source_image := attached_image_path
	var generated_dir := active_session_workspace_dir().path_join("shirt_recolor_%s" % Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_"))
	DirAccess.make_dir_recursive_absolute(generated_dir)
	var script_path := generated_dir.path_join("main.py")
	var source := FileAccess.get_file_as_string(template_path)
	# Python raw strings do not need doubled Windows separators.  Normalizing to
	# forward slashes also prevents malformed output paths such as
	# `edited_C:\\Users\\...` when the generated script derives its result name.
	source = source.replace("__SOURCE_IMAGE__", source_image.replace("\\", "/"))
	source = source.replace("__TARGET_COLOR__", target_rgb)
	source = source.replace("__SEGMENTER_PATH__", runtime_dir.path_join("clothing_segmenter").replace("\\", "/"))
	var script := FileAccess.open(script_path, FileAccess.WRITE)
	if script == null:
		show_toast("Could not prepare the local shirt recolor job")
		return true
	script.store_string(source)
	script.close()
	input_box.clear()
	append_chat("user", user_text, source_image, "")
	history.append({"role": "user", "content": user_text, "image_path": source_image})
	var answer := "I prepared a validated local shirt recolor using the actual dropped image. It preserves the original, uses the installed clothing-segmentation model to isolate the garment, keeps its shading, saves a new PNG beside the source, and opens the result."
	history.append({"role": "assistant", "content": answer + "\n```python\n" + source + "\n```"})
	set_session_status("working")
	save_history()
	clear_attachment()
	redraw_history()
	if not rendered_code_paths.is_empty():
		rendered_code_paths[rendered_code_paths.size() - 1] = script_path
	if bool(settings.get("pc_commands_enabled", false)):
		request_run_rendered_code.call_deferred(rendered_code_blocks.size() - 1)
	else:
		show_toast("Shirt recolor is ready • enable Workspace Tools, then press Run")
	return true

func answer_unavailable_generative_image_edit(user_text: String) -> bool:
	if attached_image_path.is_empty():
		return false
	var lower := user_text.to_lower()
	var changes_clothing_shape := lower.contains("to a dress") or lower.contains("wearing a dress") or lower.contains("to a skirt") or lower.contains("wearing a skirt") or lower.contains("change her clothes") or lower.contains("change his clothes") or lower.contains("replace her outfit") or lower.contains("replace his outfit") or lower.contains("new outfit")
	if not changes_clothing_shape:
		return false
	var marker := command_workspace_dir().path_join("ImageEditRuntime").path_join("installed.ok")
	if FileAccess.file_exists(marker):
		return false
	var answer := "That edit requires a local generative inpainting model with clothing segmentation; Pillow, OpenCV, and GIMP scripting cannot convincingly invent a dress from the existing pixels. That capability pack is not installed in SAM-AI, so I will not generate another fake script that masks or recolors the whole picture. A proper setup must install an inpainting runtime and model weights with your permission, temporarily use the internet for the download, then run locally afterward."
	input_box.clear()
	append_chat("user", user_text, attached_image_path, attached_file_path)
	history.append({"role": "user", "content": user_text, "image_path": attached_image_path})
	history.append({"role": "assistant", "content": answer})
	append_chat("assistant", answer, "", "", history.size() - 1)
	set_session_status("dependency")
	save_history()
	pending_image_capability_request = user_text
	pending_image_capability_path = attached_image_path
	show_image_edit_capability_dialog()
	return true

func show_image_edit_capability_dialog() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "INSTALL LOCAL IMAGE-EDIT CAPABILITY?"
	dialog.dialog_text = "Changing clothing shape requires two components that are not currently installed:\n\n• a clothing-segmentation model to create the mask\n• a generative inpainting model to create the requested garment\n\nThis setup temporarily uses the internet to install Python packages and download model weights from Hugging Face. It can require several gigabytes of disk space and substantial download time. Packages and models are third-party software. After installation, inference runs locally and the internet connection is no longer needed.\n\nNothing will be downloaded unless you choose Install. You can choose Cancel and install a compatible Diffusers/inpainting setup yourself."
	dialog.ok_button_text = "INSTALL CAPABILITY"
	dialog.confirmed.connect(func():
		dialog.queue_free()
		install_image_edit_capability())
	dialog.canceled.connect(func():
		show_toast("Image-edit capability was not installed")
		dialog.queue_free())
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, colors.amber)
	dialog.popup_centered(Vector2i(860, 620))

func install_image_edit_capability() -> void:
	var runtime_dir := command_workspace_dir().path_join("ImageEditRuntime")
	DirAccess.make_dir_recursive_absolute(runtime_dir)
	var runner_path := runtime_dir.path_join("install_image_edit.cmd")
	var output_path := runtime_dir.path_join("install.log")
	var exit_path := runtime_dir.path_join("install_exit.txt")
	var marker_path := runtime_dir.path_join("installed.ok")
	for stale_path in [exit_path, marker_path]:
		if FileAccess.file_exists(stale_path):
			DirAccess.remove_absolute(stale_path)
	var python := str(settings.voice_python_path).replace("/", "\\")
	var runtime_win := runtime_dir.replace("/", "\\")
	var output_win := output_path.replace("/", "\\")
	var exit_win := exit_path.replace("/", "\\")
	var marker_win := marker_path.replace("/", "\\")
	var runner := FileAccess.open(runner_path, FileAccess.WRITE)
	if runner == null:
		show_toast("Could not create the image-edit installer")
		return
	var commands := "@echo off\r\ntitle SAM-AI IMAGE EDIT CAPABILITY INSTALL\r\ncolor 0E\r\ncd /d \"%s\"\r\necho Installing local image-edit packages, CUDA runtime, and model weights...\r\necho This window remains open so progress can be inspected.\r\n\"%s\" -m pip install --upgrade torch torchvision --index-url https://download.pytorch.org/whl/cu128 >> \"%s\" 2>&1\r\nif errorlevel 1 goto failed\r\n\"%s\" -m pip install --upgrade-strategy only-if-needed diffusers==0.35.2 transformers==4.57.6 huggingface_hub==0.36.2 tokenizers==0.22.2 accelerate safetensors Pillow >> \"%s\" 2>&1\r\nif errorlevel 1 goto failed\r\n\"%s\" -c \"import torch,sys; print('torch', torch.__version__, 'cuda', torch.cuda.is_available()); major,minor=map(int,torch.__version__.split('+')[0].split('.')[:2]); sys.exit(0 if torch.cuda.is_available() and (major,minor) >= (2,6) else 2)\" >> \"%s\" 2>&1\r\nif errorlevel 1 goto failed\r\n\"%s\" -c \"from huggingface_hub import snapshot_download; snapshot_download('stable-diffusion-v1-5/stable-diffusion-inpainting', local_dir=r'%s\\inpainting_model'); snapshot_download('mattmdjaga/segformer_b2_clothes', local_dir=r'%s\\clothing_segmenter')\" >> \"%s\" 2>&1\r\nif errorlevel 1 goto failed\r\necho ready>\"%s\"\r\necho 0>\"%s\"\r\necho Installation complete. Press any key to close.\r\npause ^>nul\r\nexit /b 0\r\n:failed\r\necho 1>\"%s\"\r\ntype \"%s\"\r\necho Installation failed. Review the log above. Press any key to close.\r\npause ^>nul\r\nexit /b 1\r\n" % [runtime_win, python, output_win, python, output_win, python, output_win, python, runtime_win, runtime_win, output_win, marker_win, exit_win, exit_win, output_win]
	# Keep the audio wheel on the same CUDA/Torch build so repairing image tools
	# does not leave the shared local runtime with conflicting Torch packages.
	commands = commands.replace("torch torchvision --index-url", "torch torchvision torchaudio --index-url")
	runner.store_string(commands)
	runner.close()
	supervised_run_jobs.append({"kind": "image_edit_install", "path": marker_path, "language": "Python", "output": output_path, "exit": exit_path})
	set_privacy_activity(true, "Installing local image-edit capability", "Python Package Index and Hugging Face", "The user approved packages and model-weight downloads for local inpainting.", 6, "Internet access lasts only for this confirmed capability installation.")
	var pid := OS.create_process("cmd.exe", PackedStringArray(["/d", "/c", "call", runner_path]), true)
	if pid > 0:
		command_process_pids.append(pid)
	show_toast("Internet active • installing image-edit capability")

func show_wan22_install_dialog() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "INSTALL OR REPAIR WAN 2.2 + CUDA?"
	dialog.dialog_text = "OFFICIAL OPEN-WEIGHT MODEL + GPU RUNTIME\n\nSAM will install or repair the CUDA-enabled PyTorch runtime, Diffusers dependencies, and Wan-AI/Wan2.2-TI2V-5B-Diffusers weights in the SAM-AI Playground. Existing completed model files are reused rather than downloaded again.\n\nWan is used for video generation. Attached-photo clothing edits use SAM's separate segmentation + inpainting editor so the person and background can be preserved.\n\nYour RTX 3060 has 12 GB VRAM, below Wan's documented 24 GB minimum, so video generation remains experimental and may be slow or run out of memory.\n\nInternet access is used only for this confirmed installation or repair."
	dialog.ok_button_text = "INSTALL / REPAIR WAN + CUDA"
	dialog.confirmed.connect(func():
		dialog.queue_free()
		install_wan22_capability())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, colors.amber)
	dialog.popup_centered(Vector2i(880, 610))

func wan_model_repo_from_url() -> String:
	var url := str(settings.get("module_url_wan22", "https://huggingface.co/Wan-AI/Wan2.2-TI2V-5B-Diffusers")).strip_edges().trim_suffix("/")
	if not url.begins_with("https://huggingface.co/"):
		return "Wan-AI/Wan2.2-TI2V-5B-Diffusers"
	var path := url.trim_prefix("https://huggingface.co/").get_slice("?", 0)
	var pieces := path.split("/", false)
	if pieces.size() < 2:
		return "Wan-AI/Wan2.2-TI2V-5B-Diffusers"
	return "%s/%s" % [pieces[0], pieces[1]]

func install_wan22_capability() -> void:
	var runtime_dir := command_workspace_dir().path_join("WanRuntime")
	DirAccess.make_dir_recursive_absolute(runtime_dir)
	var runner_path := runtime_dir.path_join("install_wan22.cmd")
	var output_path := runtime_dir.path_join("install.log")
	var exit_path := runtime_dir.path_join("install_exit.txt")
	var marker_path := runtime_dir.path_join("wan22_ti2v_5b.ok")
	var cuda_marker_path := runtime_dir.path_join("wan_cuda.ok")
	for stale_path in [exit_path, marker_path, cuda_marker_path]:
		if FileAccess.file_exists(stale_path):
			DirAccess.remove_absolute(stale_path)
	var python := str(settings.voice_python_path).replace("/", "\\")
	var runtime_win := runtime_dir.replace("/", "\\")
	var output_win := output_path.replace("/", "\\")
	var exit_win := exit_path.replace("/", "\\")
	var marker_win := marker_path.replace("/", "\\")
	var cuda_marker_win := cuda_marker_path.replace("/", "\\")
	var model_repo := wan_model_repo_from_url()
	var runner := FileAccess.open(runner_path, FileAccess.WRITE)
	if runner == null:
		show_toast("Could not create the Wan installer")
		return
	var wan_python := runtime_win + "\\venv\\Scripts\\python.exe"
	var commands := "@echo off\r\ntitle SAM-AI WAN 2.2 INSTALL\r\ncolor 0E\r\nset PYTHONNOUSERSITE=1\r\ncd /d \"%s\"\r\necho Installing local Wan model %s...\r\necho This is a large download. Closing this window cancels the install.\r\nif not exist \"%s\" \"%s\" -m venv \"%s\\venv\" >> \"%s\" 2>&1\r\nif errorlevel 1 goto failed\r\n\"%s\" -m pip install --upgrade pip setuptools wheel >> \"%s\" 2>&1\r\nif errorlevel 1 goto failed\r\n\"%s\" -m pip install --upgrade torch torchvision --index-url https://download.pytorch.org/whl/cu128 >> \"%s\" 2>&1\r\nif errorlevel 1 goto failed\r\n\"%s\" -m pip install --upgrade git+https://github.com/huggingface/diffusers git+https://github.com/huggingface/transformers accelerate safetensors sentencepiece protobuf imageio imageio-ffmpeg ftfy beautifulsoup4 regex psutil >> \"%s\" 2>&1\r\nif errorlevel 1 goto failed\r\n\"%s\" -m pip check >> \"%s\" 2>&1\r\nif errorlevel 1 goto failed\r\n\"%s\" -c \"import torch,ftfy,bs4,regex,psutil,imageio,imageio_ffmpeg,sentencepiece,google.protobuf,accelerate,safetensors,transformers,diffusers,sys; from diffusers import DiffusionPipeline,WanImageToVideoPipeline; from diffusers.utils import export_to_video,load_image; print('torch', torch.__version__, 'cuda', torch.cuda.is_available()); print('Wan image and video dependencies OK'); sys.exit(0 if torch.cuda.is_available() else 2)\" >> \"%s\" 2>&1\r\nif errorlevel 1 goto failed\r\necho ready>\"%s\"\r\n\"%s\" -c \"from huggingface_hub import snapshot_download; snapshot_download('%s', local_dir=r'%s\\wan22_ti2v_5b')\" >> \"%s\" 2>&1\r\nif errorlevel 1 goto failed\r\necho ready>\"%s\"\r\necho 0>\"%s\"\r\necho Wan installation complete. Press any key to close.\r\npause ^>nul\r\nexit /b 0\r\n:failed\r\necho 1>\"%s\"\r\ntype \"%s\"\r\necho Wan installation failed. Review the log. Press any key to close.\r\npause ^>nul\r\nexit /b 1\r\n" % [runtime_win, model_repo, wan_python, python, runtime_win, output_win, wan_python, output_win, wan_python, output_win, wan_python, output_win, wan_python, output_win, wan_python, output_win, cuda_marker_win, wan_python, model_repo, runtime_win, output_win, marker_win, exit_win, exit_win, output_win]
	runner.store_string(commands)
	runner.close()
	supervised_run_jobs.append({"kind": "wan_install", "path": marker_path, "language": "Python", "output": output_path, "exit": exit_path})
	set_privacy_activity(true, "Installing Wan 2.2 locally", "Python Package Index and Hugging Face", "The user approved the official Wan model and dependency download.", 6, "Internet access lasts only for this confirmed Wan installation.")
	var pid := OS.create_process("cmd.exe", PackedStringArray(["/d", "/c", "call", runner_path]), true)
	if pid > 0:
		command_process_pids.append(pid)
	show_toast("Internet active • downloading Wan 2.2 TI2V-5B")

func discover_local_tool_inventory() -> String:
	var tools_found: Array[String] = ["PowerShell (Windows built-in)"]
	var candidates := {"Python": str(settings.get("voice_python_path", VOICE_PYTHON)), "GIMP": "C:/Program Files/GIMP 3/bin/gimp-3.0.exe", "GIMP 2": "C:/Program Files/GIMP 2/bin/gimp-2.10.exe", "7-Zip": "C:/Program Files/7-Zip/7z.exe"}
	for label in candidates:
		var path := str(candidates[label])
		if FileAccess.file_exists(path):
			tools_found.append("%s: %s" % [label, path])
	for command in ["winget.exe", "tar.exe", "git.exe"]:
		var output: Array = []
		if OS.execute("where.exe", PackedStringArray([command]), output, true, false) == 0 and not output.is_empty():
			tools_found.append("%s: %s" % [command, str(output[0]).strip_edges().get_slice("\n", 0)])
	return "\n".join(tools_found)

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


func make_multimodal_content_from_paths(text: String, paths: Array[String]) -> Array:
	var content: Array = [{"type": "text", "text": text}]
	for path in paths:
		if not FileAccess.file_exists(path):
			continue
		var image := Image.load_from_file(path)
		var bytes := PackedByteArray()
		var mime := "image/jpeg"
		if not image.is_empty():
			var longest := maxi(image.get_width(), image.get_height())
			if longest > 1152:
				var scale := 1152.0 / float(longest)
				image.resize(maxi(1, int(image.get_width() * scale)), maxi(1, int(image.get_height() * scale)), Image.INTERPOLATE_LANCZOS)
			bytes = image.save_jpg_to_buffer(0.86)
		else:
			bytes = FileAccess.get_file_as_bytes(path)
		var uri := "data:%s;base64,%s" % [mime, Marshalls.raw_to_base64(bytes)]
		content.append({"type": "image_url", "image_url": {"url": uri}})
	return content

func capture_explicit_memory(user_text: String) -> bool:
	# Deterministic memory beats asking a small model to decide whether it remembered.
	# Explicit teaching phrases are stored automatically; ordinary chat remains user-controlled.
	var lower := user_text.to_lower()
	var marker_at := -1
	var marker_length := 0
	var wrapped_memory_suffix_at := -1
	var teaching_markers := [
		"remember that ", "remember this: ", "remember ", "save to memorycore ",
		"add these to your memory: ", "add these to your memory ", "add this to your memory: ", "add this to your memory ",
		"add these to memory: ", "add these to memory ", "add this to memory: ", "add this to memory ",
		"save these to your memory: ", "save these to your memory ", "save this to your memory: ", "save this to your memory ",
		"update your memory with ", "update your memory: ", "update your memory ",
		"update memory with ", "update memory: ", "learn that ", "learn this: ",
		"i'm training you that ", "im training you that ", "i am training you that ",
		"i'm training you: ", "im training you: ", "i am training you: ",
		"i'm training you ", "im training you ", "i am training you ",
		"keep in mind that ", "don't forget that ", "dont forget that "
	]
	for marker in teaching_markers:
		var found := lower.find(str(marker))
		if found >= 0 and (marker_at < 0 or found < marker_at):
			marker_at = found
			marker_length = str(marker).length()
	# Also accept natural commands with a subject between "add" and "memory",
	# such as "add these movie quotes to your memory: ...".
	if marker_at < 0 and lower.strip_edges().begins_with("add "):
		wrapped_memory_suffix_at = lower.find(" to your memory")
	if marker_at < 0:
		if wrapped_memory_suffix_at < 0:
			return false
	var fact := ""
	if wrapped_memory_suffix_at >= 0:
		var subject := user_text.substr(lower.find("add ") + 4, wrapped_memory_suffix_at - (lower.find("add ") + 4)).strip_edges()
		var detail_start := wrapped_memory_suffix_at + " to your memory".length()
		var detail := user_text.substr(detail_start).strip_edges().trim_prefix(":").strip_edges()
		fact = subject + (": " + detail if not detail.is_empty() else "")
	else:
		fact = user_text.substr(marker_at + marker_length).strip_edges()
	while fact.to_lower().begins_with("now ") or fact.to_lower().begins_with("that ") or fact.begins_with(":") or fact.begins_with("-"):
		if fact.begins_with(":") or fact.begins_with("-"):
			fact = fact.substr(1).strip_edges()
		else:
			fact = fact.substr(fact.find(" ") + 1).strip_edges()
	var vague_facts := ["", "that", "this", "it", "something", "not to forget that", "don't forget that", "dont forget that"]
	if vague_facts.has(fact.to_lower()):
		# "Remember this" refers to the most recent user statement when one exists.
		for index in range(history.size() - 1, -1, -1):
			var earlier: Dictionary = history[index]
			if str(earlier.get("role", "")) == "user":
				var candidate := str(earlier.get("content", "")).strip_edges()
				if not candidate.is_empty() and candidate.to_lower() != lower:
					fact = candidate
					break
	# Keep durable facts concise. Saving a whole pasted script here pollutes every
	# later prompt and makes the model less reliable, not more knowledgeable.
	var fact_lower := fact.to_lower()
	var mentions_clock_value := (fact_lower.contains("am") or fact_lower.contains("pm") or fact_lower.contains(":")) and (fact_lower.contains("time") or fact_lower.contains("its ") or fact_lower.contains("it is "))
	if mentions_clock_value:
		fact = "For current time and date questions, read the computer's live local clock instead of relying on training data or a saved timestamp."
	elif fact_lower.contains("godot 4"):
		fact = "This project uses Godot 4.x; always generate Godot 4 GDScript syntax and APIs, never Godot 3 syntax."
	else:
		# Explicit teaching may contain a name correction followed by supporting
		# paragraphs. Preserve the whole update as one compact memory entry instead
		# of silently throwing away everything after its first line.
		fact = " ".join(fact.replace("\r", "").split("\n", false))
		while fact.contains("  "):
			fact = fact.replace("  ", " ")
		if fact.to_lower().begins_with("hit name is "):
			fact = "His name is " + fact.substr(12)
		fact = fact.left(2400).strip_edges().trim_suffix(".")
	if fact.is_empty():
		return false
	if vague_facts.has(fact.to_lower()):
		show_toast("Tell Sam the specific fact you want remembered")
		return false
	var current := read_memory()
	var entry := "- " + fact.trim_suffix(".")
	if current.to_lower().contains(entry.to_lower()):
		show_toast("✓ Already stored in MemoryCore")
		return true
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
		show_toast("✓ Learned and saved to MemoryCore")
		return true
	show_toast("MemoryCore could not be written")
	return false

func complete_memory_quality_command(user_text: String, answer: String) -> void:
	input_box.clear()
	append_chat("user", user_text)
	history.append({"role": "user", "content": user_text})
	history.append({"role": "assistant", "content": answer})
	append_chat("assistant", answer, "", "", history.size() - 1)
	save_history()
	set_session_complete(true)

func recent_important_learning(limit: int = 5) -> String:
	var selected: Array[Dictionary] = []
	for reverse_index in range(knowledge_entries.size() - 1, -1, -1):
		var entry_value = knowledge_entries[reverse_index]
		if not (entry_value is Dictionary):
			continue
		var entry: Dictionary = entry_value
		if str(entry.get("study_status", "")) != "relevant" or int(entry.get("study_score", 0)) < 5:
			continue
		selected.append(entry)
		if selected.size() >= limit:
			break
	if selected.is_empty():
		return "Meow Meow has not approved any durable new knowledge yet. New captures are still reviewed locally before they count as learning."
	var lines: Array[String] = ["Here are the last %d useful things Meow Meow approved from KnowledgeVault:" % selected.size()]
	for index in range(selected.size()):
		var entry := selected[index]
		var line := "%d. [%s] %s" % [index + 1, str(entry.get("category", "Knowledge")), str(entry.get("summary", "")).strip_edges()]
		var link := str(entry.get("linked_to", "")).strip_edges()
		if not link.is_empty():
			line += "\n   Connected to: " + link
		lines.append(line)
	return "\n\n".join(lines)

func handle_recent_learning_question(user_text: String) -> bool:
	var lower := user_text.to_lower().strip_edges()
	var asks_recent := contains_any(lower, ["what new stuff have you learned", "what have you learned recently", "what did you learn recently", "last 5 things you learned", "recent things you learned", "recent knowledge learned"])
	if not asks_recent:
		return false
	complete_memory_quality_command(user_text, recent_important_learning(5))
	return true

func show_recent_learning_summary() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Meow Meow's Latest Study Notes"
	dialog.dialog_text = recent_important_learning(5)
	dialog.ok_button_text = "GOT IT"
	dialog.canceled.connect(dialog.queue_free)
	dialog.confirmed.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	dialog.popup_centered(Vector2i(760, 520))

func handle_memory_quality_command(user_text: String) -> bool:
	var lower := user_text.to_lower().strip_edges()
	var forget_markers := ["forget from memory: ", "forget this memory: ", "remove from memory: "]
	for marker_value in forget_markers:
		var marker := str(marker_value)
		if lower.begins_with(marker):
			var subject := user_text.substr(marker.length()).strip_edges()
			if subject.length() < 3:
				complete_memory_quality_command(user_text, "Tell me a few distinctive words from the memory you want removed.")
				return true
			var current := read_memory()
			var kept: Array[String] = []
			var removed := 0
			var needle := normalize_retrieval_text(subject)
			for line_value in current.split("\n", true):
				var line := str(line_value)
				if line.strip_edges().begins_with("-") and normalize_retrieval_text(line).contains(needle):
					removed += 1
				else:
					kept.append(line)
			if removed == 0:
				complete_memory_quality_command(user_text, "I could not find a MemoryCore fact matching that phrase, so nothing was removed.")
				return true
			var updated := "\n".join(kept).strip_edges() + "\n"
			if safely_replace_text_file(str(settings.memory_path), updated, "user-forgot-memory"):
				if is_instance_valid(memory_editor):
					memory_editor.text = updated
				complete_memory_quality_command(user_text, "Removed %d matching MemoryCore fact%s. A recovery revision was saved first." % [removed, "" if removed == 1 else "s"])
			else:
				complete_memory_quality_command(user_text, "I found the memory, but the protected replacement failed validation, so the working MemoryCore was left unchanged.")
			return true
	if lower.begins_with("correct memory: "):
		var instruction := user_text.substr("correct memory: ".length()).strip_edges()
		var separator := instruction.find(" -> ")
		if separator < 0:
			complete_memory_quality_command(user_text, "Use this format: correct memory: old words -> corrected fact")
			return true
		var old_text := instruction.left(separator).strip_edges()
		var new_text := instruction.substr(separator + 4).strip_edges().trim_suffix(".")
		var current := read_memory()
		var lines: Array[String] = []
		var corrected := 0
		var needle := normalize_retrieval_text(old_text)
		for line_value in current.split("\n", true):
			var line := str(line_value)
			if corrected == 0 and line.strip_edges().begins_with("-") and normalize_retrieval_text(line).contains(needle):
				lines.append("- " + new_text + " [user-corrected]")
				corrected += 1
			else:
				lines.append(line)
		if corrected == 0:
			complete_memory_quality_command(user_text, "I could not find the old MemoryCore fact. Nothing was changed.")
			return true
		var updated := "\n".join(lines).strip_edges() + "\n"
		if safely_replace_text_file(str(settings.memory_path), updated, "user-corrected-memory"):
			if is_instance_valid(memory_editor):
				memory_editor.text = updated
			complete_memory_quality_command(user_text, "Memory corrected. I saved the earlier version as a recovery revision and will prioritize your corrected fact.")
		else:
			complete_memory_quality_command(user_text, "The protected correction failed validation, so the working memory was left unchanged.")
		return true
	return false

func poll_stream() -> void:
	if request_preparing or context_reload_pending or not server_ready:
		return
	if stream_retry_not_before_ms > Time.get_ticks_msec():
		return
	if stream_retry_not_before_ms > 0:
		stream_retry_not_before_ms = 0
		stream_client.connect_to_host(HOST, int(settings.port))
	if bool(get_meta("request_sent", false)) and response_text.is_empty() and stream_request_sent_ms > 0:
		var first_token_elapsed := Time.get_ticks_msec() - stream_request_sent_ms
		var accelerated := server_directory_has_acceleration(str(settings.server_path)) and int(settings.gpu_layers) > 0
		var first_token_limit := GPU_FIRST_TOKEN_TIMEOUT_MS if accelerated else CPU_FIRST_TOKEN_TIMEOUT_MS
		if first_token_elapsed > 45000 and not slow_inference_notice_shown:
			slow_inference_notice_shown = true
			var mode_text := "GPU" if accelerated else "CPU / PAGED MEMORY"
			set_status("MODEL WORKING • %s • %ds" % [mode_text, first_token_elapsed / 1000], colors.amber)
			show_toast("The engine is still responding • large CPU models can take several minutes for the first token")
			log_line("INFERENCE", "Waiting for first token in %s mode; watchdog extended to %d seconds" % [mode_text, first_token_limit / 1000])
		if first_token_elapsed > first_token_limit:
			fail_generation("The local model produced no first token within %d minutes. The engine remained open, but this model/runtime combination is too slow or stalled. Try the bundled 3B starter model, lower the context size, or install the matching CUDA runtime in Modules." % maxi(1, first_token_limit / 60000) + engine_log_failure_suffix())
			return
	var err := stream_client.poll()
	if err != OK:
		if stream_response_code >= 400:
			handle_stream_http_error()
		elif response_text.is_empty() and stream_retry_count < 3:
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
		stream_request_sent_ms = Time.get_ticks_msec()
		return
	if stream_client.get_status() == HTTPClient.STATUS_BODY:
		if stream_response_code == 0:
			stream_response_code = stream_client.get_response_code()
			# Fetch headers once: Godot consumes the stored headers when read.
			if stream_response_code < 400:
				var response_headers := stream_client.get_response_headers_as_dictionary()
				for key in response_headers:
					if str(key).to_lower() == "content-type" and str(response_headers[key]).to_lower().contains("application/json"):
						stream_json_response = true
		if stream_response_code >= 400 and stream_error_started_ms == 0:
			stream_error_started_ms = Time.get_ticks_msec()
		var chunk := stream_client.read_response_body_chunk()
		if not chunk.is_empty():
			if stream_response_code >= 400:
				# HTTP error JSON can arrive in several TCP chunks. Parse only after
				# the body finishes, not after the first possibly incomplete chunk.
				stream_http_body.append_array(chunk)
				if stream_http_body.size() > 1024 * 1024:
					fail_generation("Model server returned an oversized HTTP error body")
					return
			else:
				if stream_json_response:
					stream_http_body.append_array(chunk)
					if stream_http_body.size() > 16 * 1024 * 1024:
						fail_generation("Model server returned an oversized JSON response")
						return
				else:
					sse_buffer.append_array(chunk)
					consume_sse_lines()
					if stream_finished:
						return
	if stream_error_started_ms > 0 and Time.get_ticks_msec() - stream_error_started_ms > 10000:
		handle_stream_http_error()
		return
	var status := stream_client.get_status()
	if not bool(get_meta("request_sent", false)) or status not in [HTTPClient.STATUS_CONNECTED, HTTPClient.STATUS_DISCONNECTED]:
		return
	if stream_response_code == 0 and stream_client.has_response():
		stream_response_code = stream_client.get_response_code()
	if stream_response_code >= 400:
		handle_stream_http_error()
		return
	if stream_json_response:
		var json := JSON.new()
		if json.parse(stream_http_body.get_string_from_utf8()) != OK or not json.data is Dictionary:
			fail_generation("Model server returned invalid JSON")
			return
		var choices = json.data.get("choices", [])
		if choices is Array and not choices.is_empty() and choices[0] is Dictionary:
			var message = choices[0].get("message", {})
			if message is Dictionary and message.get("content", null) is String:
				var text: String = message.content
				if not text.is_empty():
					inject_pending_laugh_prelude()
					ensure_stream_chat_header()
				response_text += text
				render_buffer += text
				if stop_runaway_model_output_if_needed():
					return
				stream_finished = true
				stream_client.close()
				return
		fail_generation("Model server returned JSON without a usable assistant message")
	elif not response_text.is_empty():
		stream_finished = true
	elif stream_retry_count < 3:
		retry_stream_request(ERR_CONNECTION_ERROR)
	else:
		fail_generation("The model server disconnected before returning a response")

func retry_stream_request(error_code: int, delay_ms := 0) -> void:
	reset_stream_response_state()
	sse_buffer.clear()
	stream_retry_not_before_ms = 0
	stream_retry_count += 1
	log_line("RETRY", "Reconnecting chat request %s after error %s" % [stream_retry_count, error_code])
	stream_client.close()
	stream_client = HTTPClient.new()
	set_meta("request_sent", false)
	if delay_ms > 0:
		stream_retry_not_before_ms = Time.get_ticks_msec() + delay_ms
	else:
		stream_client.connect_to_host(HOST, int(settings.port))
	set_status("RECONNECTING • ATTEMPT %s" % stream_retry_count, colors.amber)

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
			if content is String and content.is_empty():
				content = parsed.choices[0].get("message", {}).get("content", "")
			# Role/tool chunks can contain JSON null; never stringify that as "<null>".
			var token: String = content if content is String else ""
			if not token.is_empty():
				inject_pending_laugh_prelude()
				ensure_stream_chat_header()
				response_text += token
				render_buffer += token
				if stop_runaway_model_output_if_needed():
					return
				if streaming_voice_turn:
					queue_streaming_voice(false)

func stop_runaway_model_output_if_needed() -> bool:
	if stream_repetition_stopped or response_text.length() < 2400:
		return false
	var lines := response_text.split("\n", false)
	if lines.size() < 24:
		return false
	var recent_start := maxi(0, lines.size() - 24)
	var signatures: Dictionary = {}
	var exact_lines: Dictionary = {}
	for index in range(recent_start, lines.size()):
		var clean := str(lines[index]).strip_edges()
		if clean.length() < 24:
			continue
		var signature := clean.left(mini(12, clean.length())).to_lower()
		signatures[signature] = int(signatures.get(signature, 0)) + 1
		var exact := clean.left(180)
		exact_lines[exact] = int(exact_lines.get(exact, 0)) + 1
	var runaway := false
	for count in signatures.values():
		if int(count) >= 16:
			runaway = true
			break
	if not runaway:
		for count in exact_lines.values():
			if int(count) >= 4:
				runaway = true
				break
	if not runaway:
		return false
	stream_repetition_stopped = true
	stream_finished = true
	stream_client.close()
	render_buffer = ""
	response_text = "SAM stopped this response because the local model entered a repetitive generation loop. No code from the loop was saved or made runnable. Please retry; SAM will request a smaller complete implementation and avoid repetitive serialized configuration."
	log_line("SAFETY", "Stopped repetitive model output after %d characters" % response_text.length())
	set_status("GENERATION LOOP STOPPED SAFELY", colors.amber)
	show_toast("Runaway repetition stopped • incomplete code was discarded")
	finish_generation()
	return true

func finish_generation() -> void:
	if not generating:
		return
	context_request_serial += 1
	context_resume_serial = -1
	request_preparing = false
	generating = false
	stream_client.close()
	var raw_cleaned := clean_output(response_text)
	var cleaned := apply_humor_response_guard(raw_cleaned)
	var humor_response_rewritten := cleaned != raw_cleaned
	if humor_response_rewritten:
		response_text = cleaned
		render_buffer = ""
	# Artifact retries are clean regenerations. Never concatenate an invalid
	# prefix with the replacement response; doing so can duplicate imports,
	# classes, and Markdown fences even when the retry itself is complete.
	var should_offer_image_edit_run := active_image_edit_action
	var artifact_fence_count := cleaned.count("```")
	var artifact_has_mixed_fake_fences := cleaned.contains("```gdscript") and (cleaned.contains("```javascript") or cleaned.contains("```php") or cleaned.contains("```swift") or cleaned.contains("```lua"))
	var artifact_wrong_language := (active_artifact_language == "Godot 4 GDScript" and not cleaned.contains("```gdscript")) or (active_artifact_language == "Python" and not cleaned.contains("```python"))
	var artifact_has_placeholder := cleaned.contains("res://path/to/") or cleaned.contains("path/to/image") or cleaned.contains("YOUR_IMAGE_PATH") or cleaned.contains("your_image_path") or cleaned.contains("TODO")
	var cleaned_lower := cleaned.to_lower()
	var artifact_has_simulated_logic := cleaned_lower.contains("simulate checking") or cleaned_lower.contains("simulate playing") or cleaned_lower.contains("# simulate") or cleaned_lower.contains("placeholder implementation") or cleaned.contains("random.choice([True, False])") or cleaned.contains("random.choice([true, false])")
	var artifact_has_pass_only_handler := false
	if active_artifact_language == "Python":
		var code_lines := cleaned.split("\n")
		for line_index in range(code_lines.size()):
			var stripped := str(code_lines[line_index]).strip_edges()
			if stripped == "pass" and line_index > 0:
				var previous := str(code_lines[line_index - 1]).strip_edges().to_lower()
				# `except: pass` is legitimate defensive error handling. A pass after a
				# feature comment or inside an otherwise empty function is not.
				if not previous.begins_with("except") and not previous.begins_with("case "):
					artifact_has_pass_only_handler = true
					break
	var artifact_has_fake_image_api := active_artifact_language == "Python" and cleaned.contains("extends Node")
	var artifact_has_broken_image_path := active_image_edit_action and cleaned.contains("+ image_path") and cleaned.contains(".save(")
	var artifact_has_naive_whole_image_paste := active_image_edit_action and (cleaned.contains(".paste(new_color, (0, 0), img)") or cleaned.contains(".paste(img, (0, 0), img)"))
	var artifact_ignores_requested_white := active_image_edit_action and active_artifact_request.to_lower().contains("white") and (cleaned.to_lower().contains("transparent") or cleaned.contains("255, 255, 255, 0"))
	var artifact_has_no_image_mask := active_image_edit_action and not (cleaned.to_lower().contains("mask") or cleaned.to_lower().contains("segment") or cleaned.to_lower().contains("polygon"))
	var artifact_masks_entire_image := active_image_edit_action and (cleaned.contains("draw.rectangle([0, 0, img.size[0], img.size[1]]") or cleaned.contains("draw.rectangle([(0, 0), (img.width, img.height)]") or cleaned.contains("shirt_area = [(0, 0, img.size[0], img.size[1])]") or cleaned.contains("ImageOps.colorize(img"))
	var artifact_shadows_pillow_image := active_image_edit_action and cleaned.contains("from IPython.display import Image")
	var artifact_uses_wrong_image := active_image_edit_action and not attached_image_path.is_empty() and not cleaned.contains(attached_image_path.get_file())
	if active_artifact_builder_mode and (cleaned.length() < 120 or artifact_fence_count != 2 or artifact_has_mixed_fake_fences or artifact_wrong_language or artifact_has_placeholder or artifact_has_simulated_logic or artifact_has_pass_only_handler or artifact_has_fake_image_api or artifact_has_broken_image_path or artifact_has_naive_whole_image_paste or artifact_ignores_requested_white or artifact_has_no_image_mask or artifact_masks_entire_image or artifact_shadows_pillow_image or artifact_uses_wrong_image):
		log_line("SAFETY", "Rejected incomplete artifact response: " + cleaned.left(120))
		if artifact_auto_retry_count < 4 and not active_artifact_request.is_empty():
			artifact_auto_retry_count += 1
			artifact_partial_response = cleaned
			active_artifact_builder_mode = false
			active_artifact_language = ""
			artifact_retry_in_progress = true
			response_text = ""
			render_buffer = ""
			if not history.is_empty() and str(history.back().get("role", "")) == "user":
				history.pop_back()
			# Keep retry instructions in the system/artifact prompt. Only the user's
			# original wording belongs in the visible conversation and session memory.
			input_box.text = active_artifact_request
			send_button.disabled = false
			stop_button.disabled = true
			set_microphone_available(true)
			set_status("REBUILDING INCOMPLETE FILE • ATTEMPT %d" % (artifact_auto_retry_count + 1), colors.amber)
			show_toast("Incomplete draft discarded • rebuilding the full file")
			call_deferred("send_message")
			return
		cleaned = "SAM rejected an incomplete or split artifact response from the local model because it was not one complete runnable code file. Nothing was saved or executed. Retry the request; Artifact Builder will require one complete implementation in one correctly labeled code block."
		response_text = cleaned
		render_buffer = ""
		set_status("INCOMPLETE BUILD REJECTED", colors.amber)
		show_toast("Incomplete or split build rejected • nothing was made runnable")
	active_artifact_builder_mode = false
	active_artifact_language = ""
	active_image_edit_action = false
	if cleaned.count("```") == 2:
		artifact_partial_response = ""
		artifact_retry_in_progress = false
	if cleaned.is_empty():
		if command_center_request_active:
			command_center_append("SAM returned no usable Command Center plan/review. Nothing ran.", "#ff8095")
			command_center_request_active = false
			command_center_file_review_active = false
			command_center_stage = ""
			command_center_pending_primary_followup = false
			command_center_plan_started_ms = 0
			if command_center_history_checkpoint >= 0 and history.size() > command_center_history_checkpoint:
				history.resize(command_center_history_checkpoint)
				save_history(false)
			command_center_history_checkpoint = -1
			_command_center_refresh_status()
			set_status("COMMAND CENTER • NO PLAN RETURNED", colors.amber)
			send_button.disabled = false
			send_button.text = "TRANSMIT"
			stop_button.disabled = true
			if is_instance_valid(thinking_indicator):
				thinking_indicator.visible = false
			set_microphone_available(true)
			return
		log_line("ERROR", "The model server completed without returning any response text")
		redraw_history()
		chat_log.append_text("\n[color=#ff667d][b]SAM DID NOT RECEIVE A USABLE RESPONSE[/b][/color]\nThe model returned no text. Reattach the image to retry after the engine is online.\n")
		set_status("EMPTY MODEL RESPONSE", colors.red)
		show_toast("No response was returned — reattach the image to retry")
		send_button.disabled = false
		send_button.text = "TRANSMIT"
		stop_button.disabled = true
		if is_instance_valid(thinking_indicator):
			thinking_indicator.visible = false
		set_microphone_available(true)
		restore_primary_engine_if_needed()
		complete_pending_session_switch()
		return
	if command_center_request_active:
		# Keep Command Center planning out of the normal chat/session history. The
		# temporary user turn was needed only to reuse the local streaming engine.
		command_center_receive_sam_reply(cleaned)
		if command_center_history_checkpoint >= 0 and history.size() > command_center_history_checkpoint:
			history.resize(command_center_history_checkpoint)
			save_history(false)
			call_deferred("save_history_archive_only")
		command_center_history_checkpoint = -1
		clear_attachment()
		streaming_voice_turn = false
		streaming_voice_started = true
		streaming_voice_chunks.clear()
		streaming_pending_ids.clear()
		streaming_audio_chunks.clear()
		var cc_elapsed := (Time.get_ticks_msec() - response_started_ms) / 1000.0
		set_status("COMMAND CENTER READY • %.1fs" % cc_elapsed, colors.green)
		log_line("COMMAND CENTER", "SAM planned %d characters in %.2fs" % [cleaned.length(), cc_elapsed])
		send_button.disabled = false
		send_button.text = "TRANSMIT"
		stop_button.disabled = true
		if is_instance_valid(thinking_indicator):
			thinking_indicator.visible = false
		set_microphone_available(true)
		restore_primary_engine_if_needed()
		complete_pending_session_switch()
		return
	var final_history_index := -1
	if not cleaned.is_empty():
		history.append({"role": "assistant", "content": cleaned})
		final_history_index = history.size() - 1
		set_session_complete(true)
		# Save the active session immediately, but build the readable/archive copies
		# after the UI has painted the finished answer. Long chat archives used to
		# cause the visible hitch right before SAM's reply appeared complete.
		save_history(false)
		call_deferred("save_history_archive_only")
		save_automatic_repair_lesson(cleaned)
		show_session_completion_notice()
		if command_center_request_active:
			command_center_receive_sam_reply(cleaned)
	clear_attachment()
	# Plain text was already streamed into the RichTextLabel, so rebuilding every
	# prior turn here is wasted layout work and creates the end-of-reply freeze.
	# Code/artifact replies still get one final formatted redraw for their action bar.
	if cleaned.contains("```") or not stream_chat_started or humor_response_rewritten:
		redraw_history()
	elif final_history_index >= 0 and is_instance_valid(chat_log):
		chat_log.append_text("\n[right][url=speak:%d][color=#4deeea]🔊 READ ALOUD[/color][/url][/right]\n" % final_history_index)
		if force_chat_follow or chat_is_near_bottom():
			chat_log.scroll_to_line(chat_log.get_line_count())
	if should_offer_image_edit_run and not rendered_code_blocks.is_empty() and bool(settings.get("pc_commands_enabled", false)):
		# The edit request itself authorizes preparing the job, but execution still
		# receives the normal one-run confirmation with the exact script path.
		request_run_rendered_code.call_deferred(rendered_code_blocks.size() - 1)
	var elapsed := (Time.get_ticks_msec() - response_started_ms) / 1000.0
	var chars_per_second := cleaned.length() / maxf(elapsed, 0.01)
	set_status("DONE • %.1fs • %.1f chars/s" % [elapsed, chars_per_second], colors.green)
	log_line("DONE", "Generated %s chars in %.2fs" % [cleaned.length(), elapsed])
	send_button.disabled = false
	send_button.text = "TRANSMIT"
	stop_button.disabled = true
	if is_instance_valid(thinking_indicator):
		thinking_indicator.visible = false
	set_microphone_available(not streaming_voice_busy())
	if not cleaned.is_empty() and bool(settings.voice_enabled) and not streaming_voice_turn and not synced_voice_failed:
		speak_text(cleaned)
	synced_voice_failed = false
	restore_primary_engine_if_needed()
	complete_pending_session_switch()

func complete_pending_session_switch() -> void:
	if pending_session_switch.is_empty():
		return
	var target := pending_session_switch
	pending_session_switch = ""
	call_deferred("switch_to_session", target)

func prepare_streaming_speech_text(text: String) -> String:
	# Streaming chunks do not necessarily begin/end on Markdown fence boundaries.
	# Keep fence state across chunks so the second half of a code block is never
	# mistaken for prose and read aloud.
	var prose := ""
	var cursor := 0
	while cursor < text.length():
		var fence := text.find("```", cursor)
		if fence < 0:
			if not streaming_voice_code_fence_open:
				prose += text.substr(cursor)
			break
		if not streaming_voice_code_fence_open and fence > cursor:
			prose += text.substr(cursor, fence - cursor)
		streaming_voice_code_fence_open = not streaming_voice_code_fence_open
		cursor = fence + 3
	var spoken := prepare_speech_text(prose)
	if _humor_context_active():
		spoken = _strip_ai_laughter_disclaimer(spoken)
	return spoken

func queue_streaming_voice(force_remainder: bool) -> void:
	if not streaming_voice_turn or response_text.length() <= streaming_voice_cursor:
		return
	var pending := response_text.substr(streaming_voice_cursor)
	var cut := -1
	for marker in [". ", "? ", "! ", "\n"]:
		cut = maxi(cut, pending.rfind(marker))
	if force_remainder:
		cut = pending.length() - 1
	else:
		var min_voice_chunk := 28 if live_voice_enabled else 55
		if cut < min_voice_chunk:
			# In Live Voice, do not wait for a very long first sentence. Once enough
			# natural text exists, synthesize at a word boundary for lower TTS latency.
			if live_voice_enabled and pending.length() >= 72:
				var early_cut := pending.rfind(" ", 71)
				if early_cut >= 36:
					cut = early_cut
				else:
					return
			else:
				return
	var raw_chunk := pending.left(cut + 1)
	streaming_voice_cursor += cut + 1
	var spoken := prepare_streaming_speech_text(raw_chunk)
	if not spoken.is_empty():
		if live_voice_enabled:
			live_voice_echo_reference = (live_voice_echo_reference + " " + spoken).strip_edges().right(2200)
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
	voice_discard_current_tts = false
	voice_thread_kind = "tts_stream"
	voice_thread = Thread.new()
	voice_thread.start(_voice_worker.bind("tts_stream", text_path, str(settings.voice_name)))

func streaming_voice_busy() -> bool:
	return streaming_voice_turn and (not streaming_voice_chunks.is_empty() or not streaming_pending_ids.is_empty() or not streaming_audio_chunks.is_empty() or (voice_thread != null and voice_thread.is_started()) or voice_player.playing)

func start_voice_daemon() -> void:
	# Kokoro is a heavy persistent worker. Do not load it until speech is enabled,
	# and never start a second copy for the same SAM process.
	if not bool(settings.get("voice_enabled", false)):
		stop_voice_daemon()
		return
	if voice_daemon_pid > 0 and OS.is_process_running(voice_daemon_pid):
		return
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

func cleanup_orphaned_voice_daemons() -> void:
	if OS.get_name() != "Windows":
		return
	# Previous debug/exported runs could overwrite the one PID file and strand
	# Kokoro workers. Match SAM's daemon script specifically; never kill generic
	# Python processes belonging to the user or another application.
	var script := "$procs = Get-CimInstance Win32_Process | Where-Object { ($_.Name -eq 'python.exe' -or $_.Name -eq 'pythonw.exe') -and $_.CommandLine -like '*tts_daemon.py*' }; foreach ($p in $procs) { Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue }"
	OS.execute("powershell.exe", PackedStringArray(["-NoProfile", "-NonInteractive", "-WindowStyle", "Hidden", "-Command", script]), [], true, true)

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
		send_esp_audio(audio)
	else:
		begin_streaming_voice_playback()
		voice_player.stream = audio
		voice_player.play()
		set_voice_status("VOICE • SAM IS SPEAKING", colors.green)
		_live_voice_mark_speaking()

func begin_streaming_voice_playback() -> void:
	if streaming_voice_started:
		return
	var bar := chat_log.get_v_scroll_bar()
	var previous_scroll := bar.value
	var follow_output := force_chat_follow or chat_is_near_bottom()
	streaming_voice_started = true
	streaming_voice_wait_started_ms = 0
	if live_voice_enabled:
		live_voice_text_gate_open = true
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
	voice_discard_current_tts = false
	voice_thread_kind = "tts_sync"
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
	_live_voice_mark_speaking()
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

func _resolve_saved_audio_input_device() -> String:
	var wanted := str(settings.get("audio_input_device", "Default")).strip_edges()
	var devices := AudioServer.get_input_device_list()
	if wanted.is_empty():
		wanted = "Default"
	if wanted == "Default":
		var physical: Array[String] = []
		for value in devices:
			var label := str(value)
			if label != "Default":
				physical.append(label)
		# If Windows exposes exactly one real microphone, remember it instead of the
		# ambiguous Default endpoint. This repairs installs whose older WASAPI hot-switch
		# bug overwrote the saved USB microphone with Default.
		if physical.size() == 1:
			settings.audio_input_device = physical[0]
			save_json(SETTINGS_FILE, settings)
			log_line("VOICE", "Auto-selected the only available microphone: " + physical[0])
			return physical[0]
		return "Default"
	if devices.has(wanted):
		return wanted
	# Device labels occasionally gain/remove a prefix after a Windows restart.
	# Prefer a unique case-insensitive containment match before giving up.
	var lower_wanted := wanted.to_lower()
	var matches: Array[String] = []
	for value in devices:
		var label := str(value)
		if label.to_lower().contains(lower_wanted) or lower_wanted.contains(label.to_lower()):
			matches.append(label)
	if matches.size() == 1:
		settings.audio_input_device = matches[0]
		return matches[0]
	return "Default"

func _restore_saved_audio_input_after_unmute() -> void:
	if bool(settings.get("microphone_muted", false)) or not is_instance_valid(microphone_player):
		return
	var wanted := _resolve_saved_audio_input_device()
	if microphone_player.playing:
		microphone_player.stop()
	microphone_player.stream = null
	await get_tree().process_frame
	await get_tree().process_frame
	AudioServer.input_device = wanted
	await get_tree().create_timer(0.12).timeout
	microphone_player.stream = AudioStreamMicrophone.new()
	microphone_player.bus = "Record"
	microphone_player.play()
	log_line("VOICE", "Microphone restored after unmute: requested %s • Godot active %s" % [wanted, AudioServer.input_device])

func setup_voice_system() -> void:
	cleanup_orphaned_voice_daemons()
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
	# Restore the user's saved endpoint before AudioStreamMicrophone begins. Switching
	# an already-running WASAPI input is what produced init_input_device errors and
	# silently knocked Live Voice back to Default on the next launch.
	var preferred_input := _resolve_saved_audio_input_device()
	if not preferred_input.is_empty():
		AudioServer.input_device = preferred_input
		log_line("VOICE", "Requested saved microphone before stream start: " + preferred_input)
	microphone_player.stream = AudioStreamMicrophone.new()
	microphone_player.bus = "Record"
	if not bool(settings.get("microphone_muted", false)):
		microphone_player.play()
		set_voice_status("VOICE • READY", colors.cyan)
	else:
		set_voice_status("VOICE • MICROPHONE MUTED", colors.muted)
	live_voice_enabled = false
	live_voice_state = "IDLE"
	install_live_voice_controls()
	refresh_microphone_privacy_indicator()
	start_voice_daemon()

func toggle_microphone() -> void:
	if live_voice_enabled:
		show_toast("Live Voice is active • turn it off before using push-to-talk")
		return
	if not recording_voice:
		if bool(settings.get("microphone_muted", false)):
			show_toast("Microphone is muted • use the MIC OFF control at the top to enable it")
			return
		if knowledge_recording:
			show_toast("Stop Knowledge Recording before using push-to-talk")
			return
		if voice_thread != null and voice_thread.is_started():
			show_toast("Voice engine is busy")
			return
		if not bool(settings.get("mic_notice_shown", false)):
			show_first_microphone_notice()
			return
		start_microphone_recording()
		return
	recording_voice = false
	refresh_microphone_privacy_indicator()
	microphone_button.text = "🎙 START TALKING"
	if voice_capture_pid > 0:
		request_external_voice_stop()
		set_voice_status("VOICE • FINALIZING NATIVE CAPTURE…", colors.amber)
		return
	var recording := record_effect.get_recording()
	if recording == null or recording.get_length() < 0.2:
		set_voice_status("VOICE • RECORDING TOO SHORT", colors.amber)
		return
	if not recording_has_speech(recording):
		set_voice_status("VOICE • NO SPEECH DETECTED — CHECK MICROPHONE INPUT", colors.amber)
		show_toast("No clear speech detected • check the Windows input device and mic level")
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
	dialog.title = "SAM-AI MICROPHONE PRIVACY"
	dialog.dialog_text = "🎙  PUSH-TO-TALK • PRIVATE • LOCAL\n\nSAM-AI listens only after you press START TALKING. Your speech is transcribed on this PC and appears live in the message box for review.\n\nManual Send is the privacy default. Auto-Send can be changed anytime under Engine Setup → Voice + Microphone."
	dialog.ok_button_text = "✓ KEEP MANUAL SEND"
	dialog.add_button("⚡ ENABLE AUTO-SEND", true, "enable_auto_send")
	dialog.get_cancel_button().hide()
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
	style_security_dialog(dialog, colors.cyan)
	dialog.popup_centered(Vector2i(720, 300))

func start_microphone_recording() -> void:
	if bool(settings.get("microphone_muted", false)):
		show_toast("Microphone is muted")
		return
	stop_voice()
	voice_input_prefix = input_box.text.strip_edges()
	if sanitize_transcript(voice_input_prefix).is_empty():
		voice_input_prefix = ""
		input_box.clear()
	live_transcript_buffer = ""
	live_transcription_elapsed = 0.0
	pending_final_audio = ""
	if not start_external_voice_capture("push_to_talk", 5):
		set_voice_status("VOICE • WINDOWS CAPTURE COULD NOT START", colors.red)
		show_toast("Microphone capture could not start • open Debug Telemetry")
		return
	recording_voice = true
	refresh_microphone_privacy_indicator()
	microphone_button.text = "■ STOP + TRANSCRIBE"
	var finish_action := "send automatically" if bool(settings.voice_auto_send) else "place text in the composer"
	set_voice_status("● LISTENING… CLICK AGAIN TO %s" % finish_action.to_upper(), colors.red)

func start_external_voice_capture(owner: String = "push_to_talk", chunk_seconds: int = 5) -> bool:
	var helper := ProjectSettings.globalize_path("res://tools/sam_audio_capture.py")
	voice_capture_dir = ProjectSettings.globalize_path("user://native_voice")
	DirAccess.make_dir_recursive_absolute(voice_capture_dir)
	voice_capture_session = ("voice_%s_%d" % [Time.get_datetime_string_from_system().replace(":", "-"), Time.get_ticks_msec()]).validate_filename()
	voice_capture_next_chunk = 1
	voice_capture_owner = owner
	voice_capture_status_path = voice_capture_dir.path_join(voice_capture_session + "_status.json")
	voice_capture_stop_path = voice_capture_dir.path_join(voice_capture_session + ".stop")
	voice_capture_audio_path = voice_capture_dir.path_join("chunk_%s_0001.wav" % voice_capture_session)
	for stale_path in [voice_capture_status_path, voice_capture_stop_path]:
		if FileAccess.file_exists(stale_path):
			DirAccess.remove_absolute(stale_path)
	var capture_device := str(settings.get("audio_input_device", "Default"))
	if capture_device.is_empty():
		capture_device = _resolve_saved_audio_input_device()
	var arguments := PackedStringArray([helper, "--mode", "Microphone", "--device", capture_device, "--output-dir", voice_capture_dir, "--session", voice_capture_session, "--status", voice_capture_status_path, "--stop-file", voice_capture_stop_path, "--chunk-seconds", str(clampi(chunk_seconds, 1, 30))])
	voice_capture_pid = OS.create_process(str(settings.voice_python_path), arguments, false)
	if voice_capture_pid <= 0:
		voice_capture_owner = ""
		log_line("VOICE ERROR", "Could not launch native Windows microphone capture")
		return false
	log_line("VOICE", "Started native Windows microphone capture PID %d • owner %s • %ds chunks" % [voice_capture_pid, owner, clampi(chunk_seconds, 1, 30)])
	return true

func request_external_voice_stop() -> void:
	if voice_capture_stop_path.is_empty():
		return
	var stop_file := FileAccess.open(voice_capture_stop_path, FileAccess.WRITE)
	if stop_file:
		stop_file.store_string("stop")
		stop_file.close()

func poll_external_voice_capture() -> void:
	if voice_capture_pid <= 0:
		return
	var running := OS.is_process_running(voice_capture_pid)
	var owner := voice_capture_owner
	var next_index := voice_capture_next_chunk
	var next_path := voice_capture_dir.path_join("chunk_%s_%04d.wav" % [voice_capture_session, next_index])
	# Live Voice deliberately does NOT transcribe every 2–3 second microphone
	# fragment. Tiny independent Whisper jobs caused broken sentences, duplicate
	# prompt text, and hallucinations. We keep completed speech chunks and run one
	# final Whisper pass over the complete utterance after the silence detector fires.
	if running:
		if FileAccess.file_exists(next_path) and (voice_thread == null or not voice_thread.is_started()):
			voice_capture_next_chunk += 1
			if owner == "live_voice":
				if not live_voice_enabled:
					DirAccess.remove_absolute(next_path)
					return
				# Before real speech begins, or while SAM is speaking without a confirmed
				# barge-in, this is room/speaker audio rather than a user utterance.
				if not live_voice_speech_seen or voice_player.playing or synced_voice_active:
					DirAccess.remove_absolute(next_path)
					return
				_live_voice_collect_audio_part(next_path)
				return
			start_transcription("stt_preview", next_path)
		return
	# Recorder is stopping. Drain every remaining file first. Live Voice stores
	# them for one merged final STT pass; push-to-talk retains its old preview/final path.
	if voice_thread != null and voice_thread.is_started():
		return
	if FileAccess.file_exists(next_path):
		voice_capture_next_chunk += 1
		if owner == "live_voice":
			if live_voice_speech_seen:
				_live_voice_collect_audio_part(next_path)
			else:
				DirAccess.remove_absolute(next_path)
			return
		var following_path := voice_capture_dir.path_join("chunk_%s_%04d.wav" % [voice_capture_session, next_index + 1])
		if FileAccess.file_exists(following_path):
			start_transcription("stt_preview", next_path)
		else:
			start_transcription("stt_final", next_path)
		return
	voice_capture_pid = -1
	voice_capture_owner = ""
	for control_path in [voice_capture_status_path, voice_capture_stop_path]:
		if not str(control_path).is_empty() and FileAccess.file_exists(str(control_path)):
			DirAccess.remove_absolute(str(control_path))
	voice_capture_status_path = ""
	voice_capture_stop_path = ""
	if owner == "live_voice":
		if not live_voice_enabled:
			_live_voice_clear_audio_parts(true)
			return
		if live_voice_finalize_requested:
			var utterance_path := _live_voice_build_utterance_wav()
			if not utterance_path.is_empty():
				set_voice_status("🎧 LIVE VOICE • TRANSCRIBING COMPLETE UTTERANCE…", colors.amber)
				start_transcription("stt_live_final", utterance_path)
				return
			live_voice_finalize_requested = false
			call_deferred("_live_voice_restart_capture")
			return
		if live_voice_restart_pending:
			call_deferred("_live_voice_restart_capture")
			return
		log_line("LIVE VOICE", "Native capture ended unexpectedly; restarting the listening session")
		call_deferred("_live_voice_restart_capture")
		return
	if voice_capture_next_chunk == 1:
		recording_voice = false
		refresh_microphone_privacy_indicator()
		microphone_button.text = "🎙 START TALKING"
		set_voice_status("VOICE • NO AUDIO FILE WAS CAPTURED", colors.red)
		show_toast("Windows capture returned no audio • check Debug Telemetry")
		return
	set_voice_status("VOICE • TRANSCRIPT READY — PRESS ENTER", colors.cyan)

func _live_voice_collect_audio_part(path: String) -> void:
	if path.is_empty() or not FileAccess.file_exists(path):
		return
	if not live_voice_audio_parts.has(path):
		live_voice_audio_parts.append(path)

func _live_voice_clear_audio_parts(delete_files: bool = true) -> void:
	if delete_files:
		for part in live_voice_audio_parts:
			if FileAccess.file_exists(part):
				DirAccess.remove_absolute(part)
	live_voice_audio_parts.clear()

func _live_voice_build_utterance_wav() -> String:
	if live_voice_audio_parts.is_empty():
		return ""
	var merged_data := PackedByteArray()
	var format := AudioStreamWAV.FORMAT_16_BITS
	var mix_rate := 16000
	var stereo := false
	var accepted := 0
	for part in live_voice_audio_parts:
		if not FileAccess.file_exists(part):
			continue
		var wav := AudioStreamWAV.load_from_file(part)
		if wav == null:
			DirAccess.remove_absolute(part)
			continue
		if accepted == 0:
			format = wav.format
			mix_rate = wav.mix_rate
			stereo = wav.stereo
		if wav.format == format and wav.mix_rate == mix_rate and wav.stereo == stereo:
			merged_data.append_array(wav.data)
			accepted += 1
		DirAccess.remove_absolute(part)
	live_voice_audio_parts.clear()
	if accepted == 0 or merged_data.is_empty():
		return ""
	var merged := AudioStreamWAV.new()
	merged.format = format
	merged.mix_rate = mix_rate
	merged.stereo = stereo
	merged.data = merged_data
	var stem := voice_capture_dir.path_join("utterance_%d_%d" % [live_voice_turn_counter + 1, Time.get_ticks_msec()])
	if merged.save_to_wav(stem) != OK:
		return ""
	return stem + ".wav"

func install_live_voice_controls() -> void:
	if is_instance_valid(live_voice_button):
		return

	var action_parent := microphone_button.get_parent() if is_instance_valid(microphone_button) else null
	if action_parent != null:
		live_voice_button = make_button("🎧 LIVE VOICE", toggle_live_voice_mode, colors.green)
		live_voice_button.name = "LiveVoiceButton"
		live_voice_button.tooltip_text = "Continuous local conversation • auto-sends after silence • speak over SAM to interrupt"
		action_parent.add_child(live_voice_button)
		action_parent.move_child(live_voice_button, mini(microphone_button.get_index() + 1, action_parent.get_child_count() - 1))

	# VoiceOptions is the original one-line HBox. Putting every duplex setting in
	# that HBox made Godot stretch the Engine Setup page into one giant row.
	# Live Voice now gets its own compact VBox/Grid panel below the old voice row.
	var engine_page := get_node_or_null("Page/Tabs/EngineSetup")
	if engine_page != null and not engine_page.has_node("LiveVoiceSettingsPanel"):
		var panel := VBoxContainer.new()
		panel.name = "LiveVoiceSettingsPanel"
		panel.add_theme_constant_override("separation", 6)

		var title := Label.new()
		title.text = "LIVE VOICE • DUPLEX CONVERSATION"
		title.add_theme_color_override("font_color", colors.cyan)
		title.add_theme_font_size_override("font_size", 18)
		panel.add_child(title)

		var grid := GridContainer.new()
		grid.columns = 4
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 6)
		panel.add_child(grid)

		var silence_label := Label.new()
		silence_label.text = "Silence before send"
		grid.add_child(silence_label)
		live_voice_silence_spin = SpinBox.new()
		live_voice_silence_spin.min_value = 1.5
		live_voice_silence_spin.max_value = 8.0
		live_voice_silence_spin.step = 0.25
		live_voice_silence_spin.value = float(settings.get("live_voice_silence_seconds", 4.0))
		live_voice_silence_spin.custom_minimum_size.x = 110
		live_voice_silence_spin.suffix = " s"
		live_voice_silence_spin.tooltip_text = "How long SAM waits after you stop speaking before sending the turn"
		live_voice_silence_spin.value_changed.connect(func(value: float):
			settings.live_voice_silence_seconds = value
			save_json(SETTINGS_FILE, settings))
		grid.add_child(live_voice_silence_spin)

		var vad_label := Label.new()
		vad_label.text = "Speech gate"
		grid.add_child(vad_label)
		live_voice_vad_spin = SpinBox.new()
		live_voice_vad_spin.min_value = -60.0
		live_voice_vad_spin.max_value = -15.0
		live_voice_vad_spin.step = 1.0
		live_voice_vad_spin.value = float(settings.get("live_voice_vad_threshold_db", -46.0))
		live_voice_vad_spin.custom_minimum_size.x = 110
		live_voice_vad_spin.suffix = " dB"
		live_voice_vad_spin.tooltip_text = "Raise toward 0 in noisy rooms; lower it if SAM misses quiet speech"
		live_voice_vad_spin.value_changed.connect(func(value: float):
			settings.live_voice_vad_threshold_db = value
			save_json(SETTINGS_FILE, settings))
		grid.add_child(live_voice_vad_spin)

		var barge_label := Label.new()
		barge_label.text = "Interrupt gate"
		grid.add_child(barge_label)
		live_voice_barge_spin = SpinBox.new()
		live_voice_barge_spin.min_value = -55.0
		live_voice_barge_spin.max_value = -10.0
		live_voice_barge_spin.step = 1.0
		live_voice_barge_spin.value = float(settings.get("live_voice_barge_threshold_db", -44.0))
		live_voice_barge_spin.custom_minimum_size.x = 110
		live_voice_barge_spin.suffix = " dB"
		live_voice_barge_spin.tooltip_text = "Speech above this adaptive gate can interrupt SAM while it is talking"
		live_voice_barge_spin.value_changed.connect(func(value: float):
			settings.live_voice_barge_threshold_db = value
			save_json(SETTINGS_FILE, settings))
		grid.add_child(live_voice_barge_spin)

		var chunk_label := Label.new()
		chunk_label.text = "Capture chunk"
		grid.add_child(chunk_label)
		var chunk_spin := SpinBox.new()
		chunk_spin.min_value = 2
		chunk_spin.max_value = 6
		chunk_spin.step = 1
		chunk_spin.value = int(settings.get("live_voice_chunk_seconds", 3))
		chunk_spin.custom_minimum_size.x = 110
		chunk_spin.suffix = " s"
		chunk_spin.tooltip_text = "Chunks are merged and Whisper transcribes the complete utterance after silence"
		chunk_spin.value_changed.connect(func(value: float):
			settings.live_voice_chunk_seconds = int(value)
			save_json(SETTINGS_FILE, settings))
		grid.add_child(chunk_spin)

		var toggles := HBoxContainer.new()
		toggles.add_theme_constant_override("separation", 12)
		panel.add_child(toggles)

		live_voice_barge_toggle = CheckButton.new()
		live_voice_barge_toggle.text = "BARGE-IN"
		live_voice_barge_toggle.button_pressed = bool(settings.get("live_voice_barge_in", true))
		live_voice_barge_toggle.tooltip_text = "Stop SAM's spoken/generated reply when you begin speaking"
		live_voice_barge_toggle.toggled.connect(func(enabled: bool):
			settings.live_voice_barge_in = enabled
			save_json(SETTINGS_FILE, settings))
		toggles.add_child(live_voice_barge_toggle)

		var echo_guard := CheckButton.new()
		echo_guard.text = "SPEAKER ECHO GUARD"
		echo_guard.button_pressed = bool(settings.get("live_voice_echo_guard", true))
		echo_guard.tooltip_text = "Learns SAM's speaker bleed and requires your voice to rise above it for barge-in"
		echo_guard.toggled.connect(func(enabled: bool):
			settings.live_voice_echo_guard = enabled
			save_json(SETTINGS_FILE, settings))
		toggles.add_child(echo_guard)

		var sync_text := CheckButton.new()
		sync_text.text = "SYNC TEXT + VOICE"
		sync_text.button_pressed = bool(settings.get("live_voice_sync_text", true))
		sync_text.tooltip_text = "Start visible reply text when Kokoro audio begins"
		sync_text.toggled.connect(func(enabled: bool):
			settings.live_voice_sync_text = enabled
			save_json(SETTINGS_FILE, settings))
		toggles.add_child(sync_text)

		var hint := Label.new()
		hint.text = "Whole-utterance Whisper • 4s silence by default • speak over SAM to interrupt • headphones give the cleanest duplex result"
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hint.add_theme_color_override("font_color", colors.muted)
		panel.add_child(hint)

		engine_page.add_child(panel)
		var old_voice_row := get_node_or_null("Page/Tabs/EngineSetup/VoiceOptions")
		if old_voice_row != null:
			engine_page.move_child(panel, mini(old_voice_row.get_index() + 1, engine_page.get_child_count() - 1))
		apply_theme_recursive(panel)

	_update_live_voice_button()

func toggle_live_voice_mode() -> void:
	if live_voice_enabled:
		stop_live_voice_mode("Live Voice stopped")
		return
	if bool(settings.get("microphone_muted", false)):
		show_toast("Microphone is muted • click MIC OFF first to enable it")
		return
	if knowledge_recording:
		show_toast("Stop Knowledge Recording before starting Live Voice")
		return
	if recording_voice:
		show_toast("Stop push-to-talk before starting Live Voice")
		return
	if not bool(settings.get("live_voice_notice_shown", false)):
		show_live_voice_notice()
		return
	start_live_voice_mode()

func show_live_voice_notice() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "ENABLE LIVE VOICE?"
	dialog.dialog_text = "🎧 LIVE VOICE • CONTINUOUS • LOCAL\n\nWhile this mode is on, SAM continuously monitors the selected microphone for speech. After about %.1f seconds of silence, the local Whisper transcript is sent automatically. SAM Talks answers aloud. If BARGE-IN is enabled, speaking while SAM is talking immediately stops the reply and starts a new turn.\n\nAudio/STT/TTS remain on this computer. Live Voice stays OFF after every app restart and stops immediately when you mute the microphone." % float(settings.get("live_voice_silence_seconds", 4.0))
	dialog.ok_button_text = "ENABLE LIVE VOICE"
	dialog.confirmed.connect(func():
		settings.live_voice_notice_shown = true
		save_json(SETTINGS_FILE, settings)
		dialog.queue_free()
		start_live_voice_mode())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, colors.green)
	dialog.popup_centered(Vector2i(760, 390))

func start_live_voice_mode() -> void:
	if live_voice_enabled:
		return
	if bool(settings.get("microphone_muted", false)):
		show_toast("Microphone is muted")
		return
	if knowledge_recording or recording_voice:
		show_toast("Another microphone capture mode is already active")
		return
	# Entering Live Voice owns spoken playback. Stop any older queued/playing TTS
	# first so the new duplex session starts from a clean conversational state.
	stop_voice()
	settings.voice_enabled = true
	if is_instance_valid(auto_speak):
		auto_speak.set_pressed_no_signal(true)
	if is_instance_valid(chat_auto_speak):
		chat_auto_speak.set_pressed_no_signal(true)
	save_json(SETTINGS_FILE, settings)
	start_voice_daemon()
	# Ensure the user's persisted endpoint is active before the continuous helper is
	# launched. This fixes first-launch Live Voice capturing Default until the user
	# visited KnowledgeVault and re-selected the USB microphone.
	if is_instance_valid(microphone_player) and not microphone_player.playing:
		call_deferred("_restore_saved_audio_input_after_unmute")
	live_voice_enabled = true
	live_voice_state = "LISTENING"
	live_voice_speech_seen = false
	live_voice_speech_started_ms = 0
	live_voice_last_speech_ms = 0
	live_voice_barge_candidate_ms = 0
	live_voice_finalize_requested = false
	live_voice_restart_pending = false
	live_voice_audio_parts.clear()
	live_voice_echo_reference = ""
	live_voice_echo_floor_db = -60.0
	live_voice_echo_floor_ready = false
	live_voice_text_reveal_credit = 0.0
	live_voice_heard_assistant_text = ""
	live_voice_text_gate_open = false
	streaming_voice_code_fence_open = false
	voice_input_prefix = ""
	live_transcript_buffer = ""
	input_box.clear()
	if not start_external_voice_capture("live_voice", int(settings.get("live_voice_chunk_seconds", 3))):
		live_voice_enabled = false
		live_voice_state = "ERROR"
		_update_live_voice_button()
		set_voice_status("LIVE VOICE • CAPTURE COULD NOT START", colors.red)
		show_toast("Live Voice microphone capture could not start • check Debug Telemetry")
		return
	refresh_microphone_privacy_indicator()
	_update_live_voice_button()
	set_microphone_available(true)
	set_voice_status("🎧 LIVE VOICE • LISTENING • speak naturally", colors.green)
	log_line("LIVE VOICE", "Started continuous local voice mode • %.1fs silence window" % float(settings.get("live_voice_silence_seconds", 4.0)))
	show_toast("Live Voice on • speak naturally • talk over SAM to interrupt")

func stop_live_voice_mode(reason: String = "Live Voice stopped") -> void:
	if not live_voice_enabled and live_voice_state == "IDLE":
		return
	live_voice_enabled = false
	live_voice_state = "IDLE"
	live_voice_finalize_requested = false
	live_voice_restart_pending = false
	live_voice_speech_seen = false
	live_voice_barge_candidate_ms = 0
	_live_voice_clear_audio_parts(true)
	live_voice_echo_reference = ""
	live_voice_echo_floor_db = -60.0
	live_voice_echo_floor_ready = false
	live_voice_text_reveal_credit = 0.0
	live_voice_heard_assistant_text = ""
	live_voice_text_gate_open = false
	streaming_voice_code_fence_open = false
	voice_input_prefix = ""
	live_transcript_buffer = ""
	if voice_capture_owner == "live_voice" and voice_capture_pid > 0:
		request_external_voice_stop()
	voice_discard_current_tts = voice_thread_kind.begins_with("tts")
	stop_voice()
	_update_live_voice_button()
	set_microphone_available(true)
	refresh_microphone_privacy_indicator()
	set_voice_status("VOICE • READY", colors.cyan)
	log_line("LIVE VOICE", reason)
	show_toast(reason)

func _update_live_voice_button() -> void:
	if not is_instance_valid(live_voice_button):
		return
	live_voice_button.text = "■ STOP LIVE" if live_voice_enabled else "🎧 LIVE VOICE"
	live_voice_button.add_theme_color_override("font_color", colors.red if live_voice_enabled else colors.green)
	live_voice_button.disabled = bool(settings.get("microphone_muted", false)) and not live_voice_enabled

func _live_voice_restart_capture() -> void:
	if not live_voice_enabled or shutdown_started:
		return
	if voice_capture_pid > 0:
		return
	live_voice_restart_pending = false
	live_voice_finalize_requested = false
	live_voice_speech_seen = false
	live_voice_speech_started_ms = 0
	live_voice_last_speech_ms = 0
	live_voice_barge_candidate_ms = 0
	_live_voice_clear_audio_parts(true)
	voice_input_prefix = ""
	live_transcript_buffer = ""
	input_box.clear()
	if not start_external_voice_capture("live_voice", int(settings.get("live_voice_chunk_seconds", 3))):
		live_voice_state = "ERROR"
		set_voice_status("LIVE VOICE • CAPTURE RESTART FAILED", colors.red)
		log_line("LIVE VOICE ERROR", "Could not restart continuous microphone capture")
		return
	live_voice_state = "WAITING_FOR_AI" if generating else ("SPEAKING" if voice_player.playing else "LISTENING")
	refresh_microphone_privacy_indicator()

func _live_voice_read_level(now: int) -> float:
	var level := -60.0
	var record_bus := AudioServer.get_bus_index("Record")
	if record_bus >= 0:
		level = clampf(AudioServer.get_bus_peak_volume_left_db(record_bus, 0), -60.0, 0.0)
	if now >= live_voice_status_poll_due and not voice_capture_status_path.is_empty() and FileAccess.file_exists(voice_capture_status_path):
		live_voice_status_poll_due = now + 100
		var raw := FileAccess.get_file_as_string(voice_capture_status_path).strip_edges()
		if raw.begins_with("{") and raw.ends_with("}"):
			var parser := JSON.new()
			if parser.parse(raw) == OK and parser.data is Dictionary:
				var status: Dictionary = parser.data
				var helper_level := clampf(float(status.get("level_db", -60.0)), -60.0, 0.0)
				level = maxf(level, helper_level)
	return level

func update_live_voice(delta: float) -> void:
	if not live_voice_enabled:
		return
	if bool(settings.get("microphone_muted", false)):
		stop_live_voice_mode("Live Voice stopped because the microphone was muted")
		return
	var now := Time.get_ticks_msec()
	live_voice_level_db = _live_voice_read_level(now)
	var assistant_speaking := voice_player.playing or synced_voice_active
	var assistant_busy := assistant_speaking or generating or streaming_voice_turn or awaiting_synced_voice
	var normal_gate := float(settings.get("live_voice_vad_threshold_db", -46.0))
	var configured_interrupt_gate := float(settings.get("live_voice_barge_threshold_db", -44.0))
	var interrupt_gate := normal_gate
	if assistant_speaking:
		interrupt_gate = configured_interrupt_gate
		if bool(settings.get("live_voice_echo_guard", true)):
			# Learn the microphone level produced by SAM's own speakers and require a
			# clear rise above it before declaring barge-in. Do not chase a sudden rise
			# once a candidate is active, because that rise may be the user's voice.
			if now >= live_voice_tts_guard_until_ms and live_voice_barge_candidate_ms == 0:
				if not live_voice_echo_floor_ready:
					live_voice_echo_floor_db = live_voice_level_db
					live_voice_echo_floor_ready = true
				elif live_voice_level_db <= live_voice_echo_floor_db + 5.0:
					live_voice_echo_floor_db = lerpf(live_voice_echo_floor_db, live_voice_level_db, 0.10)
			interrupt_gate = maxf(configured_interrupt_gate, live_voice_echo_floor_db + 6.0)
	var speech_now := live_voice_level_db >= (interrupt_gate if assistant_busy else normal_gate)
	if assistant_busy and bool(settings.get("live_voice_barge_in", true)):
		# True duplex behavior: user speech can interrupt both generation and TTS.
		# A slightly longer hold plus adaptive speaker-echo gate prevents SAM from
		# interrupting itself through desktop speakers.
		if speech_now and now >= live_voice_tts_guard_until_ms:
			if live_voice_barge_candidate_ms == 0:
				live_voice_barge_candidate_ms = now
			elif now - live_voice_barge_candidate_ms >= 180:
				_live_voice_interrupt_assistant()
				live_voice_barge_candidate_ms = 0
		else:
			live_voice_barge_candidate_ms = 0
	elif not assistant_busy and speech_now:
		live_voice_barge_candidate_ms = 0
		if not live_voice_speech_seen:
			live_voice_speech_seen = true
			live_voice_speech_started_ms = now
		live_voice_last_speech_ms = now
	else:
		live_voice_barge_candidate_ms = 0
	# In Live Voice, visible reply text intentionally begins with audible speech.
	# Accumulate a typewriter budget only while audio is actually playing.
	if bool(settings.get("live_voice_sync_text", true)) and streaming_voice_turn and streaming_voice_started and voice_player.playing:
		live_voice_text_reveal_credit += delta * 22.0
	if live_voice_speech_seen and not live_voice_finalize_requested and live_voice_last_speech_ms > 0:
		var silent_ms := now - live_voice_last_speech_ms
		var silence_target_ms := int(float(settings.get("live_voice_silence_seconds", 4.0)) * 1000.0)
		if silent_ms >= silence_target_ms and now - live_voice_speech_started_ms >= 250:
			_live_voice_finalize_utterance()
	if now >= live_voice_ui_due:
		live_voice_ui_due = now + 160
		_update_live_voice_status(now)

func _update_live_voice_status(now: int) -> void:
	if not live_voice_enabled:
		return
	var level_text := "%.0f dB" % live_voice_level_db
	if live_voice_state == "TRANSCRIBING":
		set_voice_status("🎧 LIVE VOICE • TRANSCRIBING + SENDING…", colors.amber)
		return
	if voice_player.playing or live_voice_state == "SPEAKING":
		var gate := float(settings.get("live_voice_barge_threshold_db", -44.0))
		if bool(settings.get("live_voice_echo_guard", true)) and live_voice_echo_floor_ready:
			gate = maxf(gate, live_voice_echo_floor_db + 6.0)
		set_voice_status("🎧 LIVE VOICE • SAM SPEAKING • talk to interrupt • mic %s • gate %.0f dB" % [level_text, gate], colors.green)
		return
	if generating or live_voice_state == "WAITING_FOR_AI":
		set_voice_status("🎧 LIVE VOICE • SAM THINKING • talk to interrupt • %s" % level_text, colors.cyan)
		return
	if live_voice_speech_seen and live_voice_last_speech_ms > 0:
		var silence_target := float(settings.get("live_voice_silence_seconds", 4.0))
		var silent_for := maxf(0.0, float(now - live_voice_last_speech_ms) / 1000.0)
		var remaining := maxf(0.0, silence_target - silent_for)
		set_voice_status("🎧 LIVE VOICE • HEARING YOU • sends after %.1fs silence • %s" % [remaining, level_text], colors.red)
		return
	set_voice_status("🎧 LIVE VOICE • LISTENING • %s" % level_text, colors.green)

func _live_voice_interrupt_assistant() -> void:
	if not live_voice_enabled:
		return
	live_voice_interrupt_count += 1
	var was_synced_voice := synced_voice_active
	# Preserve only the portion the user actually saw/heard. Generation can run
	# ahead of TTS; carrying unseen text into history makes an interruption feel
	# fake because SAM assumes it already said words the user never heard.
	if generating and not live_voice_heard_assistant_text.strip_edges().is_empty():
		response_text = live_voice_heard_assistant_text.strip_edges()
		render_buffer = ""
	voice_discard_current_tts = voice_thread_kind.begins_with("tts")
	live_voice_barge_in_active = true
	stop_voice()
	live_voice_barge_in_active = false
	if (generating or request_preparing) and not was_synced_voice:
		stop_generation()
	elif not generating and not live_voice_heard_assistant_text.strip_edges().is_empty() and not history.is_empty():
		# Generation may have finished slightly before TTS. If the user interrupts
		# during that remaining audio, keep only what was actually revealed/heard.
		var last_item: Dictionary = history.back()
		if str(last_item.get("role", "")) == "assistant":
			last_item.content = live_voice_heard_assistant_text.strip_edges()
			history[history.size() - 1] = last_item
			save_history(false)
	live_voice_state = "LISTENING"
	live_voice_speech_seen = true
	live_voice_last_speech_ms = Time.get_ticks_msec()
	if live_voice_speech_started_ms == 0:
		live_voice_speech_started_ms = live_voice_last_speech_ms
	voice_input_prefix = ""
	live_transcript_buffer = ""
	input_box.clear()
	live_voice_echo_floor_ready = false
	live_voice_text_gate_open = false
	streaming_voice_code_fence_open = false
	set_voice_status("🎧 LIVE VOICE • INTERRUPTED SAM • listening to you…", colors.red)
	log_line("LIVE VOICE", "Barge-in %d • stopped SAM output and switched back to listening" % live_voice_interrupt_count)

func _live_voice_finalize_utterance() -> void:
	if not live_voice_enabled or live_voice_finalize_requested:
		return
	live_voice_finalize_requested = true
	live_voice_state = "TRANSCRIBING"
	set_voice_status("🎧 LIVE VOICE • 4s SILENCE • FINALIZING…", colors.amber)
	if voice_capture_owner == "live_voice" and voice_capture_pid > 0:
		request_external_voice_stop()
	else:
		call_deferred("_live_voice_send_accumulated_transcript")

func _live_voice_send_accumulated_transcript() -> void:
	if not live_voice_enabled:
		return
	var message := input_box.text.strip_edges()
	if sanitize_transcript(message).is_empty():
		live_voice_finalize_requested = false
		set_voice_status("🎧 LIVE VOICE • NO CLEAR SPEECH • listening…", colors.amber)
		call_deferred("_live_voice_restart_capture")
		return
	if generating or request_preparing:
		stop_generation()
	live_voice_turn_counter += 1
	live_voice_state = "WAITING_FOR_AI"
	live_voice_finalize_requested = false
	live_voice_restart_pending = true
	set_voice_status("🎧 LIVE VOICE • SENDING TURN %d…" % live_voice_turn_counter, colors.cyan)
	log_line("LIVE VOICE", "Auto-sending voice turn %d • %d characters" % [live_voice_turn_counter, message.length()])
	send_message()
	call_deferred("_live_voice_restart_capture")

func _live_voice_mark_speaking() -> void:
	if not live_voice_enabled:
		return
	live_voice_state = "SPEAKING"
	live_voice_tts_guard_until_ms = Time.get_ticks_msec() + 550
	live_voice_echo_floor_db = -60.0
	live_voice_echo_floor_ready = false
	live_voice_text_gate_open = true
	live_voice_text_reveal_credit = maxf(live_voice_text_reveal_credit, 1.0)
	set_voice_status("🎧 LIVE VOICE • SAM SPEAKING • talk to interrupt", colors.green)

func _live_voice_mark_listening() -> void:
	if not live_voice_enabled:
		return
	live_voice_state = "LISTENING"
	live_voice_echo_floor_ready = false
	live_voice_barge_candidate_ms = 0
	set_voice_status("🎧 LIVE VOICE • LISTENING", colors.green)

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
	if not recording_has_speech(recording):
		set_voice_status("● LISTENING • WAITING FOR SPEECH…", colors.red)
		return
	var audio_stem := ProjectSettings.globalize_path("user://voice_live_preview")
	if recording.save_to_wav(audio_stem) != OK:
		return
	set_voice_status("● LISTENING + LIVE TRANSCRIPTION…", colors.red)
	start_transcription("stt_preview", audio_stem + ".wav")

func recording_has_speech(recording: AudioStreamWAV) -> bool:
	# Whisper will confidently invent short words (commonly "you") from silence.
	# Sample the captured PCM before launching it and require a modest voice level.
	if recording == null or recording.format != AudioStreamWAV.FORMAT_16_BITS:
		return false
	var pcm := recording.data
	if pcm.size() < 2:
		return false
	var sample_count := pcm.size() / 2
	var stride := maxi(1, sample_count / 12000)
	var sum_squares := 0.0
	var peak := 0
	var measured := 0
	for sample_index in range(0, sample_count, stride):
		var sample = abs(pcm.decode_s16(sample_index * 2))
		peak = maxi(peak, sample)
		sum_squares += float(sample * sample)
		measured += 1
	if measured == 0:
		return false
	var rms := sqrt(sum_squares / float(measured))
	return peak >= 700 and rms >= 90.0

func sanitize_transcript(raw_text: String) -> String:
	var cleaned := raw_text.strip_edges()
	if cleaned.is_empty():
		return ""
	# Whisper sometimes emits closed-caption sound descriptions. They are not
	# spoken words and must never be inserted into chat or learned as knowledge.
	var caption_pattern := RegEx.new()
	caption_pattern.compile("(\\[[^\\]]+\\]|\\([^\\)]+\\))")
	cleaned = caption_pattern.sub(cleaned, "", true).strip_edges()
	# Older STT prompts could leak their own instruction into the transcript. Strip
	# those literal helper phrases wherever they appear instead of sending them to SAM.
	var leak_pattern := RegEx.new()
	leak_pattern.compile("(?i)(clear conversational english speech\\.?\\s*)?(transcribe only words( actually spoken by a person)?\\.?\\s*)+")
	cleaned = leak_pattern.sub(cleaned, "", true).strip_edges()
	cleaned = cleaned.replace("  ", " ").replace("  ", " ").strip_edges()
	if cleaned.is_empty():
		return ""
	var comparable := cleaned.to_lower()
	for character in [".", ",", "!", "?", "…", "[", "]", "(", ")"]:
		comparable = comparable.replace(character, " ")
	var words := comparable.split(" ", false)
	var only_you := not words.is_empty()
	for word in words:
		if str(word) != "you":
			only_you = false
			break
	if only_you:
		return ""
	if comparable.strip_edges() in ["thank you", "thanks for watching", "music", "silence", "blank audio", "inaudible", "mumbles", "muffled speaking", "subtitles by the amara org community", "transcribe only words", "clear conversational english speech"]:
		return ""
	return cleaned

func _live_voice_significant_words(text: String) -> Array[String]:
	var normalized := text.to_lower()
	for character in [".", ",", "!", "?", ":", ";", "-", "_", "\"", "'", "(", ")", "[", "]", "{", "}", "\\", "/", "\n", "\r"]:
		normalized = normalized.replace(character, " ")
	var stop := {"the": true, "a": true, "an": true, "and": true, "or": true, "to": true, "of": true, "in": true, "on": true, "is": true, "it": true, "that": true, "this": true, "you": true, "i": true, "we": true, "for": true, "with": true, "be": true, "are": true, "was": true, "were": true}
	var result: Array[String] = []
	for raw in normalized.split(" ", false):
		var word := str(raw).strip_edges()
		if word.length() >= 3 and not stop.has(word):
			result.append(word)
	return result

func _live_voice_filter_speaker_echo(transcript: String) -> String:
	var cleaned := sanitize_transcript(transcript)
	if cleaned.is_empty() or live_voice_echo_reference.strip_edges().is_empty():
		return cleaned
	var reference_words := _live_voice_significant_words(live_voice_echo_reference)
	if reference_words.is_empty():
		return cleaned
	var reference_set: Dictionary = {}
	for word in reference_words:
		reference_set[word] = true
	var kept: Array[String] = []
	# Sentence-level filtering preserves a user's barge-in even when the same audio
	# chunk also contains SAM speaking through desktop speakers.
	var sentence_pattern := RegEx.new()
	sentence_pattern.compile("[^.!?]+[.!?]?")
	var matches := sentence_pattern.search_all(cleaned)
	for match in matches:
		var fragment := str(match.get_string()).strip_edges()
		if fragment.is_empty():
			continue
		var words := _live_voice_significant_words(fragment)
		if words.size() < 2:
			kept.append(fragment)
			continue
		var overlap := 0
		for word in words:
			if reference_set.has(word):
				overlap += 1
		var ratio := float(overlap) / float(maxi(words.size(), 1))
		if words.size() >= 3 and ratio >= 0.72:
			continue
		kept.append(fragment)
	var result := " ".join(kept).strip_edges()
	if result.is_empty():
		log_line("LIVE VOICE", "Dropped a microphone transcript that matched SAM's own recent speech")
	return result

func start_transcription(kind: String, audio_path: String) -> void:
	voice_thread_kind = kind
	voice_thread = Thread.new()
	voice_thread.start(_voice_worker.bind(kind, audio_path, ""))

func speak_text(text: String) -> void:
	var spoken_text := prepare_speech_text(text)
	if spoken_text.is_empty():
		log_line("VOICE", "Skipped code-only response")
		if live_voice_enabled:
			_live_voice_mark_listening()
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
	voice_discard_current_tts = false
	voice_thread_kind = "tts"
	voice_thread = Thread.new()
	voice_thread.start(_voice_worker.bind("tts", text_path, str(settings.voice_name)))

func _voice_worker(kind: String, source: String, voice: String) -> void:
	var captured: Array = []
	var output_path := ProjectSettings.globalize_path("user://voice_transcript.txt")
	var bridge_path := voice_runtime_script("voice_bridge.py")
	var executable := str(settings.voice_python_path)
	var arguments := PackedStringArray([bridge_path, "stt", "--audio", source, "--output", output_path, "--whisper-exe", str(settings.whisper_exe_path), "--whisper-model", str(settings.whisper_model_path)])
	if kind.begins_with("stt_live_"):
		# One direct Whisper pass over the whole utterance is considerably more
		# accurate than independently transcribing tiny fragments. No initial prompt
		# is supplied here, eliminating the "Transcribe only words" prompt leak.
		executable = str(settings.whisper_exe_path)
		output_path = source.get_basename() + ".txt"
		var prefix := output_path.get_basename()
		arguments = PackedStringArray(["-m", str(settings.whisper_model_path), "-f", source, "-otxt", "-of", prefix, "-nt", "-np", "-l", "en", "-sns", "-nth", "0.35", "-et", "2.4", "-lpt", "-0.8"])
	elif kind.begins_with("tts"):
		output_path = source.get_basename() + ".wav" if kind == "tts_stream" else ProjectSettings.globalize_path("user://voice_reply.wav")
		arguments = PackedStringArray([bridge_path, "tts", "--text-file", source, "--output", output_path, "--voice", voice, "--kokoro-model", str(settings.kokoro_model_path), "--kokoro-voices", str(settings.kokoro_voices_path)])
	var exit_code := OS.execute(executable, arguments, captured, true, false)
	call_deferred("_voice_job_finished", kind, exit_code, output_path, "\n".join(captured), source)

func _voice_job_finished(kind: String, exit_code: int, output_path: String, detail: String, source_path: String = "") -> void:
	if voice_thread != null:
		voice_thread.wait_to_finish()
		voice_thread = null
	var discard_tts := voice_discard_current_tts and kind.begins_with("tts")
	voice_thread_kind = ""
	if kind.begins_with("stt") and not source_path.is_empty() and FileAccess.file_exists(source_path):
		# Microphone chunks are temporary. Continuous Live Voice would otherwise
		# accumulate thousands of small WAV files during long conversations.
		DirAccess.remove_absolute(source_path)
	if kind.begins_with("stt_live_") and not live_voice_enabled:
		return
	if discard_tts:
		voice_discard_current_tts = false
		if kind == "tts_sync":
			awaiting_synced_voice = false
			synced_voice_failed = true
		if live_voice_enabled:
			_live_voice_mark_listening()
		log_line("LIVE VOICE", "Discarded stale TTS audio after barge-in/stop")
		return
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
		var transcript := sanitize_transcript(FileAccess.get_file_as_string(output_path))
		var live_job := kind.begins_with("stt_live_")
		if live_job and FileAccess.file_exists(output_path):
			DirAccess.remove_absolute(output_path)
		if live_job:
			transcript = _live_voice_filter_speaker_echo(transcript)
		var preview_job := kind.ends_with("preview")
		if live_job and not live_voice_enabled:
			return
		var final_job := kind.ends_with("final")
		if transcript.is_empty():
			if live_job:
				if final_job:
					live_voice_finalize_requested = false
					if not live_transcript_buffer.strip_edges().is_empty() or not input_box.text.strip_edges().is_empty():
						_live_voice_send_accumulated_transcript()
					else:
						set_voice_status("🎧 LIVE VOICE • NO CLEAR SPEECH • listening…", colors.amber)
						call_deferred("_live_voice_restart_capture")
				else:
					set_voice_status("🎧 LIVE VOICE • LISTENING • waiting for clear speech…", colors.green)
				return
			if preview_job:
				set_voice_status("● LISTENING • WAITING FOR CLEAR SPEECH…", colors.red)
				if not pending_final_audio.is_empty():
					var final_audio := pending_final_audio
					pending_final_audio = ""
					start_transcription("stt_final", final_audio)
			else:
				set_voice_status("VOICE • NO CLEAR SPEECH DETECTED", colors.amber)
				show_toast("Nothing was transcribed • speak closer or check the Windows microphone")
			return
		live_transcript_buffer = merge_live_transcript(live_transcript_buffer, transcript)
		input_box.text = (voice_input_prefix + (" " if not voice_input_prefix.is_empty() and not live_transcript_buffer.is_empty() else "") + live_transcript_buffer).strip_edges()
		input_box.grab_focus()
		input_box.set_caret_line(input_box.get_line_count() - 1)
		input_box.set_caret_column(input_box.get_line(input_box.get_line_count() - 1).length())
		if preview_job:
			if live_job:
				set_voice_status("🎧 LIVE VOICE • HEARING YOU • " + transcript.right(65), colors.red)
			else:
				set_voice_status("● LISTENING • " + transcript.right(70), colors.red)
				if not pending_final_audio.is_empty():
					var final_audio := pending_final_audio
					pending_final_audio = ""
					start_transcription("stt_final", final_audio)
			return
		if live_job and final_job:
			live_voice_finalize_requested = false
			_live_voice_send_accumulated_transcript()
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
			send_esp_audio(stream)
		else:
			begin_streaming_voice_playback()
			voice_player.stream = stream
			voice_player.play()
			set_voice_status("VOICE • SAM IS SPEAKING", colors.green)
			_live_voice_mark_speaking()
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
	_live_voice_mark_speaking()

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
			_live_voice_mark_speaking()
			return
		start_next_streaming_voice_job()
		if generating or (voice_thread != null and voice_thread.is_started()) or not streaming_voice_chunks.is_empty():
			set_voice_status("VOICE • BUFFERING NEXT SENTENCE…", colors.green)
			return
		streaming_voice_turn = false
		if live_voice_enabled:
			_live_voice_mark_listening()
		else:
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
		send_button.text = "TRANSMIT"
		stop_button.disabled = true
		if is_instance_valid(thinking_indicator):
			thinking_indicator.visible = false
		set_microphone_available(true)
		synced_reply_text = ""
		synced_reply_index = 0
		if live_voice_enabled:
			_live_voice_mark_listening()
		else:
			set_voice_status("VOICE • READY", colors.cyan)
		restore_primary_engine_if_needed()
		return
	if live_voice_enabled:
		_live_voice_mark_listening()
	else:
		set_voice_status("VOICE • READY", colors.cyan)
	if not pending_speech.is_empty() and bool(settings.voice_enabled):
		var next_speech := pending_speech
		pending_speech = ""
		speak_text(next_speech)

func stop_voice() -> void:
	if voice_thread_kind.begins_with("tts"):
		voice_discard_current_tts = true
	pending_speech = ""
	streaming_voice_chunks.clear()
	streaming_pending_ids.clear()
	streaming_audio_chunks.clear()
	streaming_voice_turn = false
	streaming_voice_started = true
	streaming_voice_wait_started_ms = 0
	if synced_voice_active:
		if live_voice_barge_in_active:
			var heard_text := synced_reply_text.left(synced_reply_index).strip_edges()
			synced_voice_active = false
			awaiting_synced_voice = false
			generating = false
			if not heard_text.is_empty():
				history.append({"role": "assistant", "content": heard_text})
				save_history(false)
			synced_reply_text = ""
			synced_reply_index = 0
			response_text = ""
			render_buffer = ""
		else:
			_on_voice_finished()
	if is_instance_valid(voice_player):
		voice_player.stop()
	set_voice_status("VOICE • READY", colors.cyan)

func set_microphone_available(available: bool) -> void:
	if is_instance_valid(live_voice_button):
		live_voice_button.disabled = bool(settings.get("microphone_muted", false)) and not live_voice_enabled
	if not is_instance_valid(microphone_button):
		return
	if live_voice_enabled:
		microphone_button.disabled = true
		microphone_button.text = "🎙 PUSH-TO-TALK PAUSED"
		_update_live_voice_button()
		return
	microphone_button.disabled = not available
	if not recording_voice:
		microphone_button.text = "🎙 START TALKING" if available else "🔒 MIC BUSY"

func set_voice_status(message: String, color: Color) -> void:
	if is_instance_valid(voice_status):
		voice_status.text = message
		voice_status.add_theme_color_override("font_color", color)

func _on_auto_speak_toggled(enabled: bool) -> void:
	if live_voice_enabled and not enabled:
		stop_live_voice_mode("Live Voice stopped because SAM Talks was disabled")
	settings.voice_enabled = enabled
	auto_speak.set_pressed_no_signal(enabled)
	chat_auto_speak.set_pressed_no_signal(enabled)
	save_json(SETTINGS_FILE, settings)
	if enabled:
		start_voice_daemon()
	else:
		stop_voice()
		stop_voice_daemon()
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
	var stopped_command_center := command_center_request_active
	if command_center_request_active:
		if command_center_watchdog_abort:
			command_center_append("SAM planner timed out and was reset cleanly. Nothing executed.", "#ff8095")
		else:
			command_center_append("SAM planning/review was stopped before completion.", "#ff8095")
		command_center_request_active = false
		command_center_file_review_active = false
		command_center_stage = ""
		command_center_pending_primary_followup = false
		command_center_plan_started_ms = 0
		if command_center_history_checkpoint >= 0 and history.size() > command_center_history_checkpoint:
			history.resize(command_center_history_checkpoint)
			save_history(false)
		command_center_history_checkpoint = -1
		_command_center_refresh_status()
	# Invalidate every outstanding preflight/replay callback, even if a larger
	# engine is still loading. It may finish loading, but cannot resend this turn.
	context_request_serial += 1
	context_resume_serial = -1
	stream_retry_not_before_ms = 0
	if generating:
		generating = false
		request_preparing = false
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
		if not response_text.is_empty() and not stopped_command_center:
			history.append({"role": "assistant", "content": clean_output(response_text)})
		if stopped_command_center:
			# A canceled Command Center transport is internal tool state, not chat.
			response_text = ""
			render_buffer = ""
		save_history()
		if not stopped_command_center:
			redraw_history()
		send_button.disabled = false
		send_button.text = "TRANSMIT"
		stop_button.disabled = true
		if is_instance_valid(thinking_indicator):
			thinking_indicator.visible = false
		set_microphone_available(true)
		set_status("GENERATION ABORTED", colors.pink)
		restore_primary_engine_if_needed()
	command_center_watchdog_abort = false
	command_center_plan_retry_count = 0
	command_center_plan_last_stream_chars = 0
	command_center_plan_last_progress_ms = 0

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
	var command_center_failure := command_center_request_active
	log_line("ERROR", message)
	if command_center_failure:
		stop_generation()
		set_status("COMMAND CENTER PLAN ERROR", colors.red)
		command_center_append("SAM PLAN FAILED • %s" % message.left(500), "#ff8095")
		command_center_append("Nothing was executed. Retry ASK SAM / PLAN after the local model is ready.", "#f9c74f")
		_command_center_refresh_status()
		show_toast("Command Center planning failed • nothing ran")
		return
	set_session_status("failed")
	stop_generation()
	set_status("GENERATION ERROR", colors.red)
	redraw_history()
	chat_log.append_text("\n[color=#ff667d][b]SAM COULD NOT COMPLETE THIS REQUEST[/b][/color]\n%s\n[color=#8292ad]Open Debug Telemetry for technical details. You can retry after the engine is ready.[/color]\n" % escape_bbcode(message.left(300)))
	chat_log.scroll_to_line(chat_log.get_line_count())
	show_toast("Request failed — details were added to the chat and Debug Telemetry")
	recover_failed_vision_switch("Image analysis failed")

func answer_local_clock_question(user_text: String) -> bool:
	var lower := user_text.to_lower().strip_edges()
	var asks_time := lower.contains("what time") or lower.contains("current time") or lower.contains("time is it") or lower == "time"
	var asks_date := lower.contains("what date") or lower.contains("current date") or lower.contains("today's date") or lower.contains("todays date") or lower.contains("what day is it") or lower == "date"
	if not asks_time and not asks_date:
		return false
	var now := Time.get_datetime_dict_from_system()
	var months := ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
	var hour_24 := int(now.get("hour", 0))
	var hour_12 := hour_24 % 12
	if hour_12 == 0:
		hour_12 = 12
	var clock := "%d:%02d:%02d %s" % [hour_12, int(now.get("minute", 0)), int(now.get("second", 0)), "AM" if hour_24 < 12 else "PM"]
	var date := "%s %d, %d" % [months[int(now.get("month", 1)) - 1], int(now.get("day", 1)), int(now.get("year", 0))]
	var answer := "Right now it is %s on %s, using this computer's local clock." % [clock, date]
	if asks_date and not asks_time:
		answer = "Today is %s, using this computer's local clock." % date
	input_box.clear()
	set_microphone_available(false)
	append_chat("user", user_text, attached_image_path, attached_file_path)
	history.append({"role": "user", "content": user_text})
	history.append({"role": "assistant", "content": answer})
	append_chat("assistant", answer, "", "", history.size() - 1)
	sent_messages.append(user_text)
	history_cursor = -1
	history_draft = ""
	save_history()
	set_microphone_available(true)
	set_status("LOCAL CLOCK • NO INTERNET USED", colors.green)
	show_toast("Time read directly from this computer")
	return true

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
			chat_log.append_text("[url=image:%s]" % image_path)
			chat_log.add_image(texture, 144, 96)
			chat_log.append_text("[/url]\n[color=#8292ad]Click image to enlarge[/color]  •  [url=useimage:%s][color=#76f7a6][b]↻ USE THIS IMAGE AGAIN[/b][/color][/url]\n" % image_path)
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
	rendered_code_paths.clear()
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
		rendered_code_paths.append("")
		var code_actions := "[font_size=22][url=viewcode:%s][color=#4deeea]👁[/color][/url]   [url=savecode:%s][color=#76f7a6]💾[/color][/url]   [url=editcode:%s][color=#4deeea]✏[/color][/url]   [url=runcode:%s][color=#f9c74f]▶[/color][/url]   [url=runadmincode:%s][color=#ff667d]🛡[/color][/url]   [url=openwithcode:%s][color=#8292ad]📂[/color][/url][/font_size]" % [code_id, code_id, code_id, code_id, code_id, code_id]
		chat_log.append_text("\n[table=1][cell bg=#17283a border=#2b3c55][color=#8da4be]  %s[/color]     [url=copycode:%s][color=#4deeea][b]⧉ COPY CODE[/b][/color][/url]\n\n[bgcolor=#0a111c][color=#d8e7ff][indent]%s[/indent][/color][/bgcolor]\n\n[right]%s  [/right][/cell][/table]\n" % [escape_bbcode(language_label), code_id, escape_bbcode(code), code_actions])
		cursor = fence_end + 3 if fence_end < content.length() else content.length()

func is_sound_creation_request(value: String) -> bool:
	var lower := value.to_lower()
	var creation := lower.contains("make") or lower.contains("create") or lower.contains("generate") or lower.contains("build") or lower.contains("synthesize")
	var audio := lower.contains("sound") or lower.contains("sound effect") or lower.contains("sfx") or lower.contains("audio") or lower.contains("wav")
	return creation and audio

func is_artifact_creation_request(value: String) -> bool:
	var lower := value.to_lower()
	var creation := lower.contains("make me") or lower.contains("create me") or lower.contains("build me") or lower.contains("write me") or lower.contains("generate me") or lower.contains("make a") or lower.contains("create a") or lower.contains("build a") or lower.contains("generate a") or lower.contains("write a")
	var artifact := lower.contains("script") or lower.contains("program") or lower.contains("app") or lower.contains("game") or lower.contains("project") or lower.contains("shader") or lower.contains("effect") or lower.contains("animation") or lower.contains("show") or lower.contains("visual") or lower.contains("firework") or lower.contains("background") or lower.contains("demo") or lower.contains("simulation")
	return creation and artifact

func is_visual_creation_request(value: String) -> bool:
	var lower := value.to_lower()
	return lower.contains("godot") or lower.contains("gdscript") or lower.contains("gpu") or lower.contains("shader") or lower.contains("firework") or lower.contains("3d") or lower.contains("visual") or lower.contains("animation") or lower.contains("trippy background")

func is_archive_action_request(value: String) -> bool:
	var lower := value.to_lower()
	return lower.contains("unzip") or lower.contains("extract this") or lower.contains("extract the") or lower.contains("decompress")

func is_executable_action_request(value: String) -> bool:
	var lower := value.to_lower()
	if is_archive_action_request(value):
		return true
	if lower.contains("run this") or lower.contains("execute this") or lower.contains("install this") or lower.contains("open this with"):
		return true
	var image_action := lower.contains("edit this image") or lower.contains("edit this picture") or lower.contains("edit this photo") or lower.contains("change the color") or lower.contains("change her ") or lower.contains("change his ") or lower.contains("recolor ")
	var specific_edit := lower.contains("remove the background") or lower.contains("crop ") or lower.contains("resize ") or lower.contains("rotate ") or lower.contains("blur ") or lower.contains("brighten ") or lower.contains("erase ") or lower.contains("shirt") or lower.contains("dress") or lower.contains("clothes") or lower.contains("color")
	return image_action and specific_edit

func _on_chat_meta_clicked(meta: Variant) -> void:
	var value := str(meta)
	if value.begins_with("useimage:"):
		var reuse_path := value.trim_prefix("useimage:")
		if attach_file(reuse_path):
			input_box.grab_focus()
			show_toast("Generated image attached • describe the next change")
		else:
			show_toast("That generated image is no longer available")
		return
	if value.begins_with("image:"):
		show_chat_image_viewer(value.trim_prefix("image:"))
		return
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
	if value.begins_with("viewcode:"):
		show_code_preview(int(value.trim_prefix("viewcode:")))
		return
	if value.begins_with("runcode:"):
		request_run_rendered_code(int(value.trim_prefix("runcode:")))
		return
	if value.begins_with("editcode:"):
		request_edit_rendered_code(int(value.trim_prefix("editcode:")))
		return
	if value.begins_with("runadmincode:"):
		request_run_rendered_code_as_admin(int(value.trim_prefix("runadmincode:")))
		return
	if value.begins_with("openwithcode:"):
		request_open_with_rendered_code(int(value.trim_prefix("openwithcode:")))
		return
	if not value.begins_with("copycode:"):
		return
	var code_id := int(value.trim_prefix("copycode:"))
	if code_id < 0 or code_id >= rendered_code_blocks.size():
		return
	DisplayServer.clipboard_set(rendered_code_blocks[code_id])
	show_toast("✓ Code copied to clipboard")

func show_chat_image_viewer(path: String) -> void:
	if not FileAccess.file_exists(path):
		show_toast("That image file is no longer available")
		return
	var image := Image.load_from_file(path)
	if image.is_empty():
		show_toast("Could not load that image")
		return
	var dialog := AcceptDialog.new()
	dialog.title = path.get_file()
	dialog.ok_button_text = "CLOSE"
	dialog.min_size = Vector2i(900, 700)
	var viewer := TextureRect.new()
	viewer.texture = ImageTexture.create_from_image(image)
	viewer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	viewer.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	viewer.custom_minimum_size = Vector2(860, 610)
	dialog.add_child(viewer)
	var copy_button := dialog.add_button("COPY IMAGE", false, "copy_image")
	copy_button.tooltip_text = "Copy the full-resolution image to the clipboard"
	dialog.add_button("OPEN FULL IMAGE", false, "open_image")
	dialog.add_button("USE THIS IMAGE AGAIN", false, "use_again")
	dialog.custom_action.connect(func(action: StringName):
		if action == &"copy_image":
			copy_image_to_clipboard(path)
		elif action == &"open_image":
			OS.shell_open(path)
		elif action == &"use_again":
			if attach_file(path):
				show_toast("Image attached • describe the next change")
				dialog.queue_free())
	dialog.confirmed.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, colors.cyan)
	dialog.popup_centered(Vector2i(940, 740))

func copy_image_to_clipboard(path: String) -> void:
	if OS.get_name() != "Windows":
		DisplayServer.clipboard_set(path)
		show_toast("Image path copied • direct image copy is currently Windows-only")
		return
	var safe_path := path.replace("'", "''")
	var command := "Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $img=[System.Drawing.Image]::FromFile('%s'); [System.Windows.Forms.Clipboard]::SetImage($img); $img.Dispose()" % safe_path
	var pid := OS.create_process("powershell.exe", PackedStringArray(["-NoProfile", "-STA", "-WindowStyle", "Hidden", "-Command", command]), false)
	show_toast("Full-resolution image copied" if pid > 0 else "Could not copy the image")

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
	if not safely_replace_text_file(path, rendered_code_blocks[code_id], "generated-code-save"):
		show_toast("Save canceled • SAM could not create a safe revision")
		return
	if code_id < rendered_code_paths.size():
		rendered_code_paths[code_id] = path
	show_toast("Code saved safely • " + path.get_file())

func sam_backup_root() -> String:
	var preferred := "E:/sam-ai/SAM-AI-Backups"
	if DirAccess.dir_exists_absolute("E:/sam-ai"):
		return preferred
	return command_workspace_dir().path_join("SAM-AI-Backups")

func remove_backup_tree(path: String) -> bool:
	var directory := DirAccess.open(path)
	if directory == null:
		return not FileAccess.file_exists(path) or DirAccess.remove_absolute(path) == OK
	for filename in directory.get_files():
		if DirAccess.remove_absolute(path.path_join(filename)) != OK:
			return false
	for child in directory.get_directories():
		if not remove_backup_tree(path.path_join(child)):
			return false
	return DirAccess.remove_absolute(path) == OK

func prune_backup_folders(root: String, prefix: String, keep: int) -> void:
	var directory := DirAccess.open(root)
	if directory == null:
		return
	var candidates: Array[Dictionary] = []
	for child in directory.get_directories():
		if child.begins_with(prefix):
			var child_path := root.path_join(child)
			candidates.append({"path": child_path, "modified": FileAccess.get_modified_time(child_path)})
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.modified) > int(b.modified))
	for index in range(keep, candidates.size()):
		var stale_path := str(candidates[index].path)
		if remove_backup_tree(stale_path):
			log_line("BACKUP", "Pruned expired safety snapshot: " + stale_path)

func validate_staged_text_file(path: String, contents: String) -> Dictionary:
	if contents.strip_edges().is_empty():
		return {"ok": false, "detail": "The replacement file is empty."}
	var extension := path.get_extension().to_lower()
	if extension == "json":
		var parsed = JSON.parse_string(contents)
		return {"ok": parsed != null, "detail": "JSON parsed successfully." if parsed != null else "JSON is malformed."}
	if extension == "py":
		var python_path := str(settings.get("voice_python_path", VOICE_PYTHON))
		if not FileAccess.file_exists(python_path):
			return {"ok": true, "detail": "Python runtime unavailable; structural validation only."}
		var output: Array = []
		var check_code := "import pathlib,sys; p=pathlib.Path(sys.argv[1]); compile(p.read_text(encoding='utf-8'),str(p),'exec')"
		var result := OS.execute(python_path, PackedStringArray(["-c", check_code, path]), output, true, false)
		return {"ok": result == 0, "detail": "Python syntax check passed." if result == 0 else "Python syntax check failed: " + "\n".join(output).left(1200)}
	return {"ok": true, "detail": "Structural validation passed."}

func file_revision_backup(path: String, reason: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var backup_root := sam_backup_root().path_join("File Revisions")
	var stamp := Time.get_datetime_string_from_system().replace(":", "-") + "-%d" % Time.get_ticks_msec()
	var backup_prefix := path.get_file().validate_filename() + "_"
	var folder := backup_root.path_join(backup_prefix + stamp)
	if DirAccess.make_dir_recursive_absolute(folder) != OK:
		return ""
	var backup_path := folder.path_join(path.get_file())
	if DirAccess.copy_absolute(path, backup_path) != OK:
		return ""
	var metadata := {
		"created": Time.get_datetime_string_from_system(),
		"reason": reason,
		"original_path": path,
		"backup_path": backup_path
	}
	save_json(folder.path_join("revision.json"), metadata)
	log_line("BACKUP", "Saved pre-change revision of %s at %s" % [path, backup_path])
	prune_backup_folders(backup_root, backup_prefix, 12)
	return backup_path

func safely_replace_text_file(path: String, contents: String, reason: String) -> bool:
	var existed := FileAccess.file_exists(path)
	var backup_path := ""
	if existed:
		backup_path = file_revision_backup(path, reason)
		if backup_path.is_empty():
			log_line("SAFETY", "Refused to overwrite without a backup: " + path)
			return false
		var project_root := find_godot_project_root(path)
		if not project_root.is_empty():
			var project_backup := backup_godot_project(project_root)
			if project_backup.is_empty():
				log_line("SAFETY", "Refused project overwrite because the project checkpoint failed: " + path)
				return false
	var extension := path.get_extension()
	var temporary := path + ".sam-new-%d" % Time.get_ticks_msec()
	if not extension.is_empty():
		temporary = path.get_basename() + ".sam-new-%d.%s" % [Time.get_ticks_msec(), extension]
	var staged := FileAccess.open(temporary, FileAccess.WRITE)
	if staged == null:
		return false
	staged.store_string(contents)
	staged.close()
	if FileAccess.get_file_as_string(temporary) != contents:
		DirAccess.remove_absolute(temporary)
		return false
	var validation := validate_staged_text_file(temporary, contents)
	if not bool(validation.get("ok", false)):
		log_line("SAFETY", "Rejected staged replacement for %s • %s" % [path, str(validation.get("detail", "validation failed"))])
		DirAccess.remove_absolute(temporary)
		return false
	var displaced := path + ".sam-previous-%d" % Time.get_ticks_msec()
	if existed and DirAccess.rename_absolute(path, displaced) != OK:
		DirAccess.remove_absolute(temporary)
		return false
	if DirAccess.rename_absolute(temporary, path) != OK:
		if existed:
			DirAccess.rename_absolute(displaced, path)
		DirAccess.remove_absolute(temporary)
		return false
	if existed:
		DirAccess.remove_absolute(displaced)
	log_line("SAFETY", "Promoted validated staged file (%s); rollback revision: %s" % [str(validation.get("detail", "validated")), backup_path if not backup_path.is_empty() else "new file"])
	return true

func code_extension_for(language: String) -> String:
	var extensions := {"gdscript": "gd", "python": "py", "py": "py", "javascript": "js", "typescript": "ts", "csharp": "cs", "c#": "cs", "cpp": "cpp", "c++": "cpp", "c": "c", "java": "java", "rust": "rs", "go": "go", "html": "html", "css": "css", "json": "json", "sql": "sql", "powershell": "ps1", "ps1": "ps1", "bash": "sh", "shell": "sh"}
	return str(extensions.get(language.to_lower(), "txt"))

func show_code_preview(code_id: int) -> void:
	if code_id < 0 or code_id >= rendered_code_blocks.size():
		return
	var dialog := AcceptDialog.new()
	dialog.title = "SAM-AI GENERATED CODE PREVIEW"
	dialog.ok_button_text = "CLOSE"
	var editor := TextEdit.new()
	editor.text = rendered_code_blocks[code_id]
	editor.editable = true
	editor.custom_minimum_size = Vector2(900, 560)
	dialog.add_child(editor)
	dialog.confirmed.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, colors.cyan)
	dialog.popup_centered(Vector2i(960, 650))

func prepare_rendered_code_in_workspace(code_id: int) -> String:
	if code_id < 0 or code_id >= rendered_code_blocks.size():
		return ""
	if code_id < rendered_code_paths.size() and not rendered_code_paths[code_id].is_empty() and FileAccess.file_exists(rendered_code_paths[code_id]) and path_is_in_command_workspace(rendered_code_paths[code_id]):
		return rendered_code_paths[code_id]
	var timestamp := Time.get_datetime_string_from_system().replace(":", "-")
	var project_dir := active_session_workspace_dir().path_join("sam_project_" + timestamp)
	DirAccess.make_dir_recursive_absolute(project_dir)
	var extension := code_extension_for(rendered_code_languages[code_id] if code_id < rendered_code_languages.size() else "code")
	var path := project_dir.path_join("main." + extension)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return ""
	file.store_string(rendered_code_blocks[code_id])
	file.close()
	rendered_code_paths[code_id] = path
	return path

func write_supervised_command_runner(path: String, language: String, elevated: bool) -> String:
	var runner_path := path.get_base_dir().path_join("run_as_admin.cmd" if elevated else "run_debug.cmd")
	var run_kind := "admin" if elevated else "standard"
	var output_path := path.get_base_dir().path_join("run_%s_output.log" % run_kind)
	var exit_path := path.get_base_dir().path_join("run_%s_exit.txt" % run_kind)
	var batch_output_path := output_path.replace("/", "\\")
	var batch_exit_path := exit_path.replace("/", "\\")
	var batch_project_dir := path.get_base_dir().replace("/", "\\")
	var batch_script_path := path.replace("/", "\\")
	var normalized := language.to_lower()
	var command := ""
	var interactive_console := false
	if normalized in ["python", "py"]:
		command = "\"%s\" \"%s\"" % [str(settings.voice_python_path), path]
		if FileAccess.file_exists(path):
			interactive_console = FileAccess.get_file_as_string(path).contains("input(")
	elif normalized in ["powershell", "ps1"]:
		command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"%s\"" % path
	elif normalized in ["gdscript", "gd", "godot", "godot 4 gdscript"]:
		if not prepare_godot_runner_project(path):
			return ""
		command = "\"%s\" --path \"%s\"" % [OS.get_executable_path(), path.get_base_dir()]
	else:
		return ""
	var command_line := command if interactive_console else "%s > \"%s\" 2>&1" % [command, batch_output_path]
	var output_line := "" if interactive_console else "if exist \"%s\" type \"%s\"" % [batch_output_path, batch_output_path]
	var runner_text := "@echo off\r\ntitle SAM-AI SUPERVISED RUN - Close this window to stop\r\ncolor 0B\r\ncd /d \"%s\"\r\necho ============================================================\r\necho  SAM-AI SUPERVISED %s RUN\r\necho  Close this window at any time to stop the script.\r\necho ============================================================\r\necho Script: %s\r\necho.\r\n%s\r\nset SAM_EXIT=%%ERRORLEVEL%%\r\n%s\r\nif not \"%%SAM_EXIT%%\"==\"0\" (\r\n  echo.\r\n  echo ============================================================\r\n  echo  Script failed with exit code %%SAM_EXIT%%.\r\n  echo  SAM-AI captured the error and is handling recovery in the app.\r\n  echo  This debug window will remain open for inspection.\r\n  echo  Press any key or close this window when you are finished.\r\n  echo ============================================================\r\n  >\"%s\" echo %%SAM_EXIT%%\r\n  pause ^>nul\r\n  exit /b %%SAM_EXIT%%\r\n)\r\n>\"%s\" echo 0\r\nstart \"\" explorer.exe \"%s\"\r\necho.\r\necho ============================================================\r\necho  Script finished successfully.\r\necho  The generated project folder has been opened.\r\necho  This window stays open so you can inspect the output.\r\necho  Press any key or close the window to finish.\r\necho ============================================================\r\npause ^>nul\r\nexit /b 0\r\n" % [batch_project_dir, "ADMINISTRATOR" if elevated else "STANDARD", batch_script_path, command_line, output_line, batch_exit_path, batch_exit_path, batch_project_dir]
	var runner := FileAccess.open(runner_path, FileAccess.WRITE)
	if runner == null:
		return ""
	runner.store_string(runner_text)
	runner.close()
	return runner_path

func prepare_godot_runner_project(script_path: String) -> bool:
	var project_path := script_path.get_base_dir().path_join("project.godot")
	var scene_path := script_path.get_base_dir().path_join("main.tscn")
	var project := FileAccess.open(project_path, FileAccess.WRITE)
	if project == null:
		return false
	project.store_string("[application]\nconfig/name=\"SAM-AI Generated Project\"\nrun/main_scene=\"res://main.tscn\"\n\n[display]\nwindow/size/viewport_width=1280\nwindow/size/viewport_height=720\nwindow/size/window_width_override=1280\nwindow/size/window_height_override=720\n\n[rendering]\nrenderer/rendering_method=\"gl_compatibility\"\nrenderer/rendering_method.mobile=\"gl_compatibility\"\n")
	project.close()
	var scene := FileAccess.open(scene_path, FileAccess.WRITE)
	if scene == null:
		return false
	scene.store_string("[gd_scene load_steps=2 format=3]\n\n[ext_resource type=\"Script\" path=\"res://%s\" id=\"1_script\"]\n\n[node name=\"GeneratedProject\" type=\"Node3D\"]\nscript = ExtResource(\"1_script\")\n" % script_path.get_file())
	scene.close()
	return true

func visual_prompt_from_script(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var source := FileAccess.get_file_as_string(path)
	for marker in ["EDIT_PROMPT = r\"\"\"", "PROMPT = r\"\"\""]:
		var start := source.find(marker)
		if start < 0:
			continue
		start += marker.length()
		var finish := source.find("\"\"\"", start)
		if finish >= start:
			return source.substr(start, finish - start)
	return ""

func replace_visual_prompt_in_script(path: String, prompt: String) -> bool:
	if prompt.strip_edges().is_empty() or not FileAccess.file_exists(path):
		return false
	var source := FileAccess.get_file_as_string(path)
	for marker in ["EDIT_PROMPT = r\"\"\"", "PROMPT = r\"\"\""]:
		var start := source.find(marker)
		if start < 0:
			continue
		start += marker.length()
		var finish := source.find("\"\"\"", start)
		if finish < start:
			return false
		var safe_prompt := prompt.replace("\"\"\"", "\\\"\\\"\\\"")
		source = source.left(start) + safe_prompt + source.substr(finish)
		var output := FileAccess.open(path, FileAccess.WRITE)
		if output == null:
			return false
		output.store_string(source)
		output.close()
		return true
	return false

func parse_visual_plan_response(content: String) -> Dictionary:
	var cleaned := content.strip_edges()
	if cleaned.begins_with("```"):
		var first_newline := cleaned.find("\n")
		if first_newline >= 0:
			cleaned = cleaned.substr(first_newline + 1)
		if cleaned.ends_with("```"):
			cleaned = cleaned.left(cleaned.length() - 3).strip_edges()
	var first_brace := cleaned.find("{")
	var last_brace := cleaned.rfind("}")
	if first_brace >= 0 and last_brace > first_brace:
		cleaned = cleaned.substr(first_brace, last_brace - first_brace + 1)
	var parsed = JSON.parse_string(cleaned)
	return parsed if parsed is Dictionary else {}

func request_local_visual_plan(original_prompt: String, job_path: String, prompt_editor: TextEdit, status_label: Label, checkbox: CheckBox, run_button: Button) -> void:
	if not checkbox.button_pressed:
		return
	if not server_ready or engine_mode != "primary":
		status_label.text = "Local planner unavailable • using the original prompt"
		run_button.disabled = false
		return
	status_label.text = "SAM is interpreting the complete visual request locally…"
	run_button.disabled = true
	var request := HTTPRequest.new()
	request.timeout = 45.0
	checkbox.add_child(request)
	var system_prompt := "You are SAM's local visual request planner. Convert the user's request into one concise image/video generation prompt. Preserve every explicitly requested attribute: output kind, motion, pose, body orientation, gaze, expression, face/eyes, hair, clothing, accessories, setting, lighting, and camera. NEVER invent clothing, expression, lighting, setting, motion, or styling the user did not request. Major pose, viewpoint, background, or scene transformations should recommend wan; localized clothing/color/accessory edits should recommend local. Wan TI2V is reference-conditioned, not a true still-image editor: for a major still pose or scene change, include a warning that it may preserve the source composition and that a dedicated instruction-image-edit model would be needed for reliable relocation. Return ONLY compact JSON with keys enhanced_prompt (string), summary (string), output_kind (image or video), recommended_engine (wan or local), warnings (array of short strings). Keep enhanced_prompt under 55 words."
	var payload := {
		"messages": [
			{"role": "system", "content": system_prompt},
			{"role": "user", "content": "Active module preference: %s\nGenerated job: %s\nRequest: %s" % [str(settings.get("visual_module_preference", "auto")), "wan" if job_path.replace("\\", "/").contains("/wan22_") else "local", original_prompt]}
		],
		"temperature": 0.05,
		"max_tokens": 320,
		"stream": false
	}
	request.request_completed.connect(func(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray):
		if not is_instance_valid(prompt_editor) or not is_instance_valid(run_button):
			return
		run_button.disabled = false
		if not checkbox.button_pressed:
			request.queue_free()
			return
		if result != HTTPRequest.RESULT_SUCCESS or response_code < 200 or response_code >= 300:
			status_label.text = "Planner unavailable • original prompt preserved"
			request.queue_free()
			return
		var response = JSON.parse_string(body.get_string_from_utf8())
		var content := ""
		if response is Dictionary and response.has("choices") and not response.choices.is_empty():
			content = str(response.choices[0].get("message", {}).get("content", ""))
		var plan := parse_visual_plan_response(content)
		var enhanced := str(plan.get("enhanced_prompt", "")).strip_edges()
		if enhanced.is_empty():
			status_label.text = "Planner returned no usable plan • original prompt preserved"
			request.queue_free()
			return
		prompt_editor.text = enhanced
		var summary := str(plan.get("summary", "Visual request interpreted"))
		var recommended := str(plan.get("recommended_engine", "")).capitalize()
		var actual := "Wan" if job_path.replace("\\", "/").contains("/wan22_") else "Local"
		status_label.text = "%s\nRecommended: %s • This run: %s" % [summary, recommended, actual]
		var warnings = plan.get("warnings", [])
		if warnings is Array and not warnings.is_empty():
			status_label.text += "\nNote: " + " • ".join(PackedStringArray(warnings))
		request.queue_free())
	var error := request.request("http://%s:%d/v1/chat/completions" % [HOST, int(settings.port)], ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(payload))
	if error != OK:
		status_label.text = "Planner could not start • original prompt preserved"
		run_button.disabled = false
		request.queue_free()

func request_run_rendered_code(code_id: int) -> void:
	if not bool(settings.get("pc_commands_enabled", false)):
		show_toast("PC commands are locked • enable Workspace Tools from the top lock")
		return
	if code_id < 0 or code_id >= rendered_code_blocks.size():
		return
	var language := rendered_code_languages[code_id].to_lower() if code_id < rendered_code_languages.size() else ""
	if language not in ["python", "py", "powershell", "ps1", "gdscript", "gd", "godot", "godot 4 gdscript"]:
		show_toast("Direct run supports Python, PowerShell, and Godot 4 GDScript")
		return
	var path := prepare_rendered_code_in_workspace(code_id)
	if path.is_empty():
		show_toast("Could not create the playground project")
		return
	var executable := "powershell.exe"
	if language in ["python", "py"]:
		executable = str(settings.voice_python_path)
	elif language in ["gdscript", "gd", "godot", "godot 4 gdscript"]:
		executable = OS.get_executable_path() + " --path " + path.get_base_dir()
	var dialog := ConfirmationDialog.new()
	dialog.title = "RUN GENERATED CODE?"
	dialog.dialog_text = "Review the code before running it. Generated scripts can modify files, use the network, or launch other programs.\n\nExecutable:\n%s\n\nScript:\n%s\n\nWorking boundary for generated files:\n%s\n\nThis run is not elevated." % [executable, path, command_workspace_dir()]
	dialog.ok_button_text = "RUN ONCE"
	var normalized_visual_path := path.replace("\\", "/")
	var is_visual_job := normalized_visual_path.contains("/clothing_replace_") or normalized_visual_path.contains("/wan22_")
	var original_visual_prompt := visual_prompt_from_script(path) if is_visual_job else ""
	if is_visual_job:
		dialog.dialog_text = "Review the visual plan before running it. The script can create files and launch the finished result.\n\nScript: %s\nBoundary: %s\nNot elevated." % [path, command_workspace_dir()]
	var planner_toggle: CheckBox
	var planner_status: Label
	var planner_prompt: TextEdit
	if is_visual_job and not original_visual_prompt.is_empty():
		# ConfirmationDialog exposes its message Label, not a get_vbox() helper.
		# Its parent is the dialog's managed content container in Godot 4.6.
		var dialog_label := dialog.get_label()
		var dialog_content := dialog_label.get_parent()
		# Use one managed child instead of several siblings. MarginContainer lays
		# siblings over one another, which caused the safety text, checkbox, status,
		# and editor to occupy the same pixels.
		dialog_label.hide()
		var separator := HSeparator.new()
		var planner_scroll := ScrollContainer.new()
		planner_scroll.custom_minimum_size = Vector2(0, 205)
		planner_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		planner_scroll.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		planner_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		planner_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
		dialog_content.add_child(planner_scroll)
		var planner_box := VBoxContainer.new()
		planner_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		planner_scroll.add_child(planner_box)
		var safety_text := Label.new()
		safety_text.text = "Review the visual plan before running.\nScript: %s\nBoundary: %s\nThis run is not elevated." % [path, command_workspace_dir()]
		safety_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		safety_text.max_lines_visible = 4
		safety_text.clip_text = true
		planner_box.add_child(safety_text)
		planner_box.add_child(separator)
		planner_toggle = CheckBox.new()
		planner_toggle.text = "AI-assisted visual planning (local)"
		planner_toggle.tooltip_text = "Ask SAM's local model to interpret every requested pose, gaze, face, hair, clothing, scene, camera, and motion attribute before this run."
		planner_toggle.button_pressed = bool(settings.get("ai_visual_planning_enabled", true))
		planner_box.add_child(planner_toggle)
		planner_status = Label.new()
		planner_status.text = "Original prompt shown below. SAM will create an editable plan before Run Once."
		planner_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		planner_status.custom_minimum_size = Vector2(0, 42)
		planner_status.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		planner_status.max_lines_visible = 3
		planner_status.clip_text = true
		planner_box.add_child(planner_status)
		planner_prompt = TextEdit.new()
		planner_prompt.custom_minimum_size = Vector2(0, 78)
		planner_prompt.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		planner_prompt.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
		planner_prompt.text = original_visual_prompt
		planner_prompt.tooltip_text = "Review or edit the exact prompt that the visual engine will receive."
		planner_box.add_child(planner_prompt)
		planner_toggle.toggled.connect(func(enabled: bool):
			settings.ai_visual_planning_enabled = enabled
			save_json(SETTINGS_FILE, settings)
			if not enabled:
				planner_prompt.text = original_visual_prompt
				planner_status.text = "AI planning disabled • the original prompt will be used"
				dialog.get_ok_button().disabled = false
			else:
				request_local_visual_plan(original_visual_prompt, path, planner_prompt, planner_status, planner_toggle, dialog.get_ok_button()))
	dialog.confirmed.connect(func():
		if is_visual_job and is_instance_valid(planner_toggle) and planner_toggle.button_pressed:
			if not replace_visual_prompt_in_script(path, planner_prompt.text):
				show_toast("Could not apply the visual plan • run canceled")
				dialog.queue_free()
				return
		var runner := write_supervised_command_runner(path, language, false)
		if runner.is_empty():
			show_toast("Could not create the supervised debug runner")
		else:
			var normalized_job_path := path.replace("\\", "/")
			var needs_gpu_handoff := normalized_job_path.contains("/clothing_replace_") or normalized_job_path.contains("/wan22_")
			if needs_gpu_handoff:
				stop_engine()
				show_model_switch_overlay()
				set_startup_progress(2.0, "PREPARING LOCAL VISUAL ENGINE", "Unloading the chat model and releasing CUDA memory")
				set_status("FREEING VRAM FOR IMAGE EDIT", colors.amber)
				show_toast("Primary model unloaded • starting local visual generation")
				# Give Windows time to return the chat model's several GB of committed
				# memory before Wan begins loading its five weight shards.
				await get_tree().create_timer(3.0).timeout
			register_supervised_run(path, language, false, needs_gpu_handoff)
			var pid := OS.create_process("cmd.exe", PackedStringArray(["/d", "/c", "call", runner]), true)
			if pid > 0:
				command_process_pids.append(pid)
			log_line("PC TOOL", "User opened supervised standard run for %s (PID %d)" % [path, pid])
			show_toast("Supervised debug window opened • close it to stop the script" if pid > 0 else "Could not open the supervised debug window")
		dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, colors.amber)
	if is_visual_job:
		dialog.min_size = Vector2i(780, 560)
		dialog.max_size = Vector2i(780, 560)
		dialog.unresizable = true
	dialog.popup_centered(Vector2i(780, 560) if is_visual_job else Vector2i(760, 480))
	if is_visual_job and is_instance_valid(planner_toggle) and planner_toggle.button_pressed:
		request_local_visual_plan.call_deferred(original_visual_prompt, path, planner_prompt, planner_status, planner_toggle, dialog.get_ok_button())

func request_open_with_rendered_code(code_id: int) -> void:
	if not bool(settings.get("pc_commands_enabled", false)):
		show_toast("PC commands are locked • enable Workspace Tools from the top lock")
		return
	var path := prepare_rendered_code_in_workspace(code_id)
	if path.is_empty():
		show_toast("Could not prepare that file")
		return
	OS.shell_open(path.get_base_dir())
	show_toast("Opened generated project folder")

func request_edit_rendered_code(code_id: int) -> void:
	if not bool(settings.get("pc_commands_enabled", false)):
		show_toast("PC commands are locked • enable Workspace Tools from the top lock")
		return
	var path := prepare_rendered_code_in_workspace(code_id)
	if path.is_empty():
		show_toast("Could not prepare that file")
		return
	OS.shell_open(path)

func request_run_rendered_code_as_admin(code_id: int) -> void:
	if not bool(settings.get("pc_commands_enabled", false)):
		show_toast("PC commands are locked • enable Workspace Tools first")
		return
	if OS.get_name() != "Windows":
		show_toast("Administrator launch is currently available only on Windows")
		return
	if code_id < 0 or code_id >= rendered_code_blocks.size():
		return
	var language := rendered_code_languages[code_id].to_lower() if code_id < rendered_code_languages.size() else ""
	if language not in ["python", "py", "powershell", "ps1", "gdscript", "gd", "godot", "godot 4 gdscript"]:
		show_toast("Administrator run supports Python, PowerShell, and Godot 4 GDScript")
		return
	var path := prepare_rendered_code_in_workspace(code_id)
	if path.is_empty():
		show_toast("Could not create the playground project")
		return
	pc_admin_request_active = true
	set_session_status("admin")
	refresh_pc_commands_indicator()
	var dialog := ConfirmationDialog.new()
	dialog.title = "REQUEST WINDOWS ADMINISTRATOR ACCESS?"
	dialog.dialog_text = "DANGER: Administrator code can change protected system settings, install software, disable security controls, or destroy data. Only continue if you inspected and understand the complete script.\n\nScript:\n%s\n\nSAM-AI will now request a separate Windows UAC confirmation. This permission applies to this run only and is never stored." % path
	dialog.ok_button_text = "REQUEST UAC FOR THIS RUN"
	dialog.confirmed.connect(func():
		var runner := write_supervised_command_runner(path, language, true)
		admin_status_path = path.get_base_dir().path_join("admin_status.json")
		if FileAccess.file_exists(admin_status_path):
			DirAccess.remove_absolute(admin_status_path)
		var helper := ProjectSettings.globalize_path("res://tools/sam_elevate.pyw")
		var pythonw := str(settings.voice_python_path).replace("python.exe", "pythonw.exe")
		if runner.is_empty() or not FileAccess.file_exists(pythonw):
			pc_admin_request_active = false
			refresh_pc_commands_indicator()
			show_toast("Could not prepare the trusted Windows UAC request")
		else:
			var normalized_job_path := path.replace("\\", "/")
			var needs_gpu_handoff := normalized_job_path.contains("/clothing_replace_") or normalized_job_path.contains("/wan22_")
			if needs_gpu_handoff:
				stop_engine()
				show_model_switch_overlay()
				set_startup_progress(2.0, "PREPARING LOCAL VISUAL ENGINE", "Unloading the chat model and releasing CUDA memory")
				set_status("FREEING VRAM FOR IMAGE EDIT", colors.amber)
				show_toast("Primary model unloaded • requesting local visual generation")
				await get_tree().create_timer(1.5).timeout
			register_supervised_run(path, language, true, needs_gpu_handoff)
			admin_helper_pid = OS.create_process(pythonw, PackedStringArray([helper, runner, path.get_base_dir(), admin_status_path]), false)
			log_line("PC TOOL", "Native Windows UAC requested for " + path)
			show_toast("Windows security confirmation requested • no command launcher window")
		dialog.queue_free())
	dialog.canceled.connect(func():
		pc_admin_request_active = false
		refresh_pc_commands_indicator()
		dialog.queue_free())
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, colors.red)
	dialog.popup_centered(Vector2i(780, 500))

func register_supervised_run(path: String, language: String, elevated := false, restart_engine_after := false) -> void:
	var run_kind := "admin" if elevated else "standard"
	var output_path := path.get_base_dir().path_join("run_%s_output.log" % run_kind)
	var exit_path := path.get_base_dir().path_join("run_%s_exit.txt" % run_kind)
	if FileAccess.file_exists(output_path):
		DirAccess.remove_absolute(output_path)
	if FileAccess.file_exists(exit_path):
		DirAccess.remove_absolute(exit_path)
	var progress_path := path.get_base_dir().path_join("wan_progress.json")
	if FileAccess.file_exists(progress_path):
		DirAccess.remove_absolute(progress_path)
	if restart_engine_after:
		visual_job_previous_max_fps = Engine.max_fps
		# Wan saturates the RTX GPU. Rendering this UI above 30 FPS only steals GPU
		# scheduling time and makes Windows more likely to label it unresponsive.
		Engine.max_fps = 30
	supervised_run_jobs.append({"kind": "run", "path": path, "language": language, "output": output_path, "exit": exit_path, "restart_engine": restart_engine_after, "started_msec": Time.get_ticks_msec(), "progress_poll_msec": 0, "progress_file_msec": 0, "cached_progress": {}, "display_percent": 0.0, "last_raw_percent": -1.0, "last_raw_change_msec": Time.get_ticks_msec(), "generation_started_msec": 0})

func visual_clock(total_seconds: float) -> String:
	var seconds := maxi(0, int(round(total_seconds)))
	return "%02d:%02d" % [seconds / 60, seconds % 60]

func visual_wait_message(elapsed_seconds: float) -> String:
	var messages := [
		# --- Flight of the Conchords & Deadpan Awkwardness ---
		"Presenting the GPU with a business card (it's sensible, in a subtle off-white)",
		"It's business time (which means waiting for the buffer)",
		"Removing all the cutlery from the kitchen sink...",
		"The render is wearing its business socks",
		"Conditioning the pixels with hair gel from 1998",
		"Trying to build a camera out of a camera and an old shoe",
		"Polite applause from a crowd of two people",

		# --- Retro Gaming (NES, SNES, Genesis, Sega CD, N64) ---
		"Blowing into the cartridge... wait, almost got it...",
		"Searching for the missing page of the Nintendo Power strategy guide",
		"The Sega CD laser is warm, but it's doing its best",
		"Inserting Disc 3 of 4; please do not turn off your system",
		"Renting a game based solely on how cool the box art looks",
		"Waiting for the Expansion Pak to register the high-res texture",
		"Accidentally hitting the reset button with a big toe",
		"Holding Reset while pressing Power to save your game",
		"Swapping out the RF switch for a gold-plated A/V cable",
		"Telling your friend it's their turn as soon as you die",
		"The Sega Scream is echoing in the background...",
		"Waiting for the Virtual Boy eye strain to pass",
		"Looking up cheat codes on a printout from 1997",

		# --- 80s/90s Cartoons & TV (Fraggle Rock, Gummi Bears, Ahhh! Real Monsters, Hey Dude) ---
		"Dance your cares away, the render's taking all day...",
		"Bouncing here and there and everywhere while it loads",
		"Grummbo is collecting trash under the city while we wait",
		"Ickis is practicing his scare face in the mirror",
		"It's a little wild and a little strange out on the ranch",
		"Better watch out for the man with the big red face",
		"Sprocket is barking at the computer tower again",
		"Calling the Doozers to finish building the remaining polygons",
		"Oblina is pulling a whole frame out of her throat",
		"Krumm is holding his eyes up to inspect the frame rate",
		"Drinking secret Gummiberry Juice to speed up the clock rate",

		# --- 80s/90s Movies (This Boy's Life, VHS, Blockbuster) ---
		"Rewinding the VHS tape before taking it back to Blockbuster",
		"I'm not crying, Toby, my eyes are just sweating from the resolution",
		"Dwight is telling the GPU that concrete is good for character",
		"Renting a movie on a Friday night because the blue light was on",
		"Adjusting the tracking wheel so the static line goes away",
		"Waiting for the preview for 'Coming Soon to Videocassette'",
		"Polishing up the wingtips for a night on the town",
		"Trying to tune the CRT TV using a coat hanger and foil",

		# --- Dial-Up & Late '90s Tech Pain ---
		"Waiting for the dial-up handshake to finish screeching",
		"Someone picked up the landline phone; reconnecting...",
		"Downloading at 2.1 KB/s; estimated time remaining: 14 hours",
		"Defragging the hard drive just to watch the little colored squares",
		"Waiting for the screen saver with the flying toasters to turn off"
	]
	return str(messages[int(elapsed_seconds / 7.0) % messages.size()])
	
func update_visual_job_progress(job: Dictionary) -> void:
	var path := str(job.get("path", "")).replace("\\", "/").to_lower()
	if not path.contains("/wan22_"):
		return
		
	var progress_path := str(job.get("path", "")).get_base_dir().path_join("wan_progress.json")
	var now := Time.get_ticks_msec()
	var total_elapsed := maxf(0.0, (now - int(job.get("started_msec", now))) / 1000.0)
	
	if not FileAccess.file_exists(progress_path):
		var launch_percent := minf(7.5, 4.0 + total_elapsed * 0.10)
		job.display_percent = launch_percent
		set_startup_progress(
			launch_percent,
			"STARTING WAN 2.2",
			"Launching the private CUDA runtime",
			"ELAPSED %s   %s   ACTIVE" % [visual_clock(total_elapsed), visual_scanner()]
		)
		set_status("WAN 2.2 * STARTING", colors.amber)
		return

	var progress: Dictionary = job.get("cached_progress", {})
	if progress.is_empty() or now - int(job.get("progress_file_msec", 0)) >= 500:
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(progress_path))
		if parsed is Dictionary:
			progress = parsed
			job.cached_progress = progress
			job.progress_file_msec = now

	if progress.is_empty():
		return

	var raw_percent := clampf(float(progress.get("percent", 4.0)), 0.0, 100.0)
	var previous_raw := float(job.get("last_raw_percent", -1.0))
	var displayed := maxf(float(job.get("display_percent", 0.0)), raw_percent)

	if raw_percent > previous_raw + 0.01:
		job.last_raw_percent = raw_percent
		job.last_raw_change_msec = now
		if str(progress.get("stage", "")) == "generating" and int(job.get("generation_started_msec", 0)) <= 0:
			job.generation_started_msec = now
	else:
		# Diffusers only reports whole steps. Glide gently between steps
		# while keeping a slight buffer so the progress bar never overshoots.
		var stage := str(progress.get("stage", ""))
		var glide_span := 1.40 if stage == "generating" else 4.0
		var since_change := maxf(0.0, (now - int(job.get("last_raw_change_msec", now))) / 1000.0)
		var glide_duration := 8.0 if stage == "generating" else 35.0
		displayed = maxf(displayed, raw_percent + glide_span * minf(0.90, since_change / glide_duration))

	displayed = minf(displayed, 99.0 if raw_percent < 100.0 else 100.0)
	job.display_percent = displayed

	var title := str(progress.get("title", "WAN 2.2 WORKING"))
	var detail := str(progress.get("detail", "Local visual generation is active"))
	var active_prompt := str(progress.get("prompt", "")).strip_edges()

	if active_prompt.contains("\n\n"):
		active_prompt = active_prompt.get_slice("\n\n", 0).strip_edges()
	active_prompt = active_prompt.replace("\r", " ").replace("\n", " ")
	while active_prompt.contains("  "):
		active_prompt = active_prompt.replace("  ", " ")
	if active_prompt.length() > 240:
		active_prompt = active_prompt.left(237).strip_edges() + "..."

	if is_instance_valid(startup_visual_prompt):
		startup_visual_prompt.text = "PROMPT \"%s\"" % active_prompt if not active_prompt.is_empty() else "PROMPT Waiting for request details..."

	var eta := str(progress.get("eta", ""))
	var stage_name := str(progress.get("stage", ""))
	var telemetry := "ELAPSED %s   %s   ACTIVE" % [visual_clock(total_elapsed), visual_scanner()]

	if stage_name == "generating":
		var matcher := RegEx.new()
		matcher.compile("step (\\d+)/(\\d+)")
		var match_result := matcher.search(detail)
		if match_result:
			var completed := maxi(1, int(match_result.get_string(1)))
			var total_steps := maxi(completed, int(match_result.get_string(2)))
			var generation_started := int(job.get("generation_started_msec", now))
			var generation_elapsed := maxf(0.5, (now - generation_started) / 1000.0)
			var remaining := (generation_elapsed / completed) * (total_steps - completed)
			eta = visual_clock(remaining)
			
			var smooth_stage_percent := clampf((displayed - 30.0) / 0.64, 0.0, 99.0)
			var visual_kind := "IMAGE" if path.contains("wan22_reference") or path.contains("wan22_image") else "VIDEO"
			
			title = "CREATING %s * %.1f%%" % [visual_kind, smooth_stage_percent]
			# Inject custom funny/nostalgic loading status during active rendering steps
			detail = visual_wait_message(generation_elapsed)
			telemetry = "STEP %02d/%02d   ELAPSED %s   %s   ETA %s" % [completed, total_steps, visual_clock(total_elapsed), visual_scanner(), eta]

	elif stage_name in ["preparing", "loading", "pipeline_ready"]:
		if stage_name == "loading":
			detail = "Loading model weights into RAM and VRAM"
		elif stage_name == "pipeline_ready":
			detail = "CUDA is warm * diffusion is beginning"
		else:
			detail = "Checking the local model and CUDA runtime"

	elif stage_name == "memory_blocked":
		detail = str(progress.get("detail", "Wan needs more free RAM or pagefile space"))
		telemetry = "SAFE STOP   %s   NO FILES WERE DAMAGED" % visual_scanner()

	set_startup_progress(displayed, title, detail, telemetry)
	set_status("WAN VISUAL * %.1f%%%s" % [displayed, " * ABOUT " + eta if not eta.is_empty() else " * ACTIVE"], colors.amber)
func poll_supervised_run_jobs() -> void:
	for index in range(supervised_run_jobs.size() - 1, -1, -1):
		var job: Dictionary = supervised_run_jobs[index]
		var exit_path := str(job.get("exit", ""))
		if exit_path.is_empty() or not FileAccess.file_exists(exit_path):
			var now := Time.get_ticks_msec()
			if now - int(job.get("progress_poll_msec", 0)) >= 80:
				job.progress_poll_msec = now
				update_visual_job_progress(job)
				supervised_run_jobs[index] = job
			continue
		var exit_code := int(FileAccess.get_file_as_string(exit_path).strip_edges())
		var output := FileAccess.get_file_as_string(str(job.get("output", ""))).strip_edges()
		DirAccess.remove_absolute(exit_path)
		supervised_run_jobs.remove_at(index)
		if bool(job.get("restart_engine", false)):
			Engine.max_fps = visual_job_previous_max_fps
			engine_mode = "primary"
			start_engine.call_deferred()
		if str(job.get("kind", "run")) == "image_edit_install":
			set_privacy_activity(false)
			if exit_code == 0 and FileAccess.file_exists(str(job.get("path", ""))):
				show_toast("Image-edit capability installed • resuming the requested edit")
				set_session_status("working")
				if not pending_image_capability_path.is_empty() and FileAccess.file_exists(pending_image_capability_path):
					attach_file(pending_image_capability_path)
				input_box.text = pending_image_capability_request
				pending_image_capability_request = ""
				pending_image_capability_path = ""
				call_deferred("send_message")
			else:
				set_session_status("dependency")
				set_status("IMAGE-EDIT CAPABILITY INSTALL FAILED", colors.red)
				show_toast("Image-edit setup failed • installer window and log remain available")
			continue
		if str(job.get("kind", "run")) == "wan_install":
			set_privacy_activity(false)
			if exit_code == 0 and FileAccess.file_exists(str(job.get("path", ""))):
				settings.video_generation_engine = "Wan 2.2 TI2V-5B"
				save_json(SETTINGS_FILE, settings)
				set_session_status("complete")
				show_toast("Wan 2.2 installed locally • available in Modules")
			else:
				set_session_status("dependency")
				set_status("WAN 2.2 INSTALL FAILED", colors.red)
				show_toast("Wan setup failed • installer window and log remain available")
			continue
		if str(job.get("kind", "run")) == "install":
			set_privacy_activity(false)
			if exit_code == 0:
				show_toast("Dependency installed locally • retrying the script")
				launch_supervised_retry(str(job.get("path", "")), str(job.get("language", "")))
			else:
				place_run_error_in_composer(str(job.get("path", "")), output)
			continue
		if exit_code == 0:
			set_session_status("complete")
			var completed_script := str(job.get("path", ""))
			var completed_image := find_completed_visual_image(completed_script)
			if not completed_image.is_empty():
				var completion_message := "Your image is ready. Use **USE THIS IMAGE AGAIN** beneath it to attach this result and continue editing it."
				history.append({"role": "assistant", "content": completion_message, "image_path": completed_image})
				save_history()
				redraw_history()
				show_toast("Image complete • ready to view or use again")
			else:
				show_toast("Generated project completed successfully")
			continue
		var missing_module := extract_missing_python_module(output)
		if not missing_module.is_empty() and str(job.get("language", "")).to_lower() in ["python", "py"]:
			show_missing_dependency_dialog(missing_module, str(job.get("path", "")), str(job.get("language", "")), output)
		elif try_repair_missing_python_image(str(job.get("path", "")), str(job.get("language", "")), output):
			pass
		elif try_repair_invalid_python_output_path(str(job.get("path", "")), str(job.get("language", "")), output):
			pass
		else:
			place_run_error_in_composer(str(job.get("path", "")), output)

func find_completed_visual_image(script_path: String) -> String:
	var normalized := script_path.replace("\\", "/").to_lower()
	if not normalized.contains("/wan22_image_") and not normalized.contains("/wan22_reference_"):
		return ""
	var folder := script_path.get_base_dir()
	var candidates := [
		folder.path_join("wan22_reference_image_face_restored.png"),
		folder.path_join("wan22_reference_image.png"),
		folder.path_join("wan22_generated_image_face_restored.png"),
		folder.path_join("wan22_generated_image.png")
	]
	for candidate_value in candidates:
		var candidate := str(candidate_value)
		if FileAccess.file_exists(candidate):
			return candidate
	return ""

func try_repair_missing_python_image(path: String, language: String, output: String) -> bool:
	if language.to_lower() not in ["python", "py"] or not output.contains("FileNotFoundError") or not FileAccess.file_exists(path):
		return false
	var missing_regex := RegEx.new()
	missing_regex.compile("No such file or directory: ['\\\"]([^'\\\"]+)['\\\"]")
	var match := missing_regex.search(output)
	if match == null:
		return false
	var missing_path := match.get_string(1)
	var real_image := ""
	for history_index in range(history.size() - 1, -1, -1):
		var item = history[history_index]
		if item is Dictionary:
			var candidate := str(item.get("image_path", ""))
			if not candidate.is_empty() and FileAccess.file_exists(candidate):
				real_image = candidate
				break
	if real_image.is_empty():
		return false
	var source := FileAccess.get_file_as_string(path)
	if not source.contains(missing_path):
		return false
	source = source.replace(missing_path, real_image.replace("\\", "/"))
	if not safely_replace_text_file(path, source, "automatic-missing-image-repair"):
		return false
	log_line("REPAIR", "Replaced missing generated image path with the actual attached image")
	show_toast("Corrected the missing image path • retrying once")
	launch_supervised_retry(path, language)
	return true

func try_repair_invalid_python_output_path(path: String, language: String, output: String) -> bool:
	if language.to_lower() not in ["python", "py"] or not output.contains("Invalid argument: 'edited_"):
		return false
	if bool(automatic_path_repairs.get(path, false)) or not FileAccess.file_exists(path):
		return false
	var source := FileAccess.get_file_as_string(path)
	var changed := false
	for image_variable in ["new_img", "edited_img", "img"]:
		for quote in ["'", "\""]:
			var broken := "%s.save(%sedited_%s + image_path)" % [image_variable, quote, quote]
			if source.contains(broken):
				var replacement := "output_path = Path(image_path).with_name('edited_' + Path(image_path).stem + '.png')\n    %s.save(output_path)" % image_variable
				source = source.replace(broken, replacement)
				changed = true
	if not changed:
		return false
	if not source.contains("from pathlib import Path"):
		source = "from pathlib import Path\n" + source
	for image_variable in ["new_img", "edited_img", "img"]:
		source = source.replace("return %s.filename" % image_variable, "return str(output_path)")
	if not safely_replace_text_file(path, source, "automatic-output-path-repair"):
		return false
	automatic_path_repairs[path] = true
	set_session_status("working")
	set_status("AUTO-REPAIRED OUTPUT PATH • RETRYING", colors.amber)
	show_toast("SAM repaired the invalid Windows output path • retrying without administrator access")
	log_line("AUTO REPAIR", "Corrected malformed output filename in " + path)
	launch_supervised_retry(path, language)
	return true

func extract_missing_python_module(output: String) -> String:
	var marker := "No module named '"
	var start := output.find(marker)
	if start < 0:
		return ""
	start += marker.length()
	var finish := output.find("'", start)
	if finish < 0:
		return ""
	var module := output.substr(start, finish - start).get_slice(".", 0)
	for character in module:
		if not (str(character).to_lower() in "abcdefghijklmnopqrstuvwxyz0123456789_-"):
			return ""
	return module

func dependency_package_name(module: String) -> String:
	var aliases := {"pil": "Pillow", "cv2": "opencv-python", "yaml": "PyYAML", "sklearn": "scikit-learn"}
	return str(aliases.get(module.to_lower(), module))

func show_missing_dependency_dialog(module: String, path: String, language: String, output: String) -> void:
	set_session_status("dependency")
	var package := dependency_package_name(module)
	var dialog := ConfirmationDialog.new()
	dialog.title = "MISSING PYTHON MODULE"
	dialog.dialog_text = "The generated script stopped because Python could not find:\n\n%s\n\nSAM-AI can temporarily access the internet to ask Python's package installer for '%s'. The package will be installed only into SAM-AI's private Python environment. Internet activity ends when installation finishes, then SAM-AI will retry the script once.\n\nPackages are third-party software. Review the package name before continuing. Choose Cancel to install it yourself instead.\n\nManual command:\n\"%s\" -m pip install %s" % [module, package, str(settings.voice_python_path), package]
	dialog.ok_button_text = "INSTALL + RETRY"
	dialog.confirmed.connect(func():
		dialog.queue_free()
		install_python_dependency(package, path, language))
	dialog.canceled.connect(func():
		DisplayServer.clipboard_set("\"%s\" -m pip install %s" % [str(settings.voice_python_path), package])
		place_run_error_in_composer(path, output)
		show_toast("Nothing installed • manual command copied • error placed in composer")
		dialog.queue_free())
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, colors.amber)
	dialog.popup_centered(Vector2i(820, 560))

func install_python_dependency(package: String, path: String, language: String) -> void:
	var directory := path.get_base_dir()
	var output_path := directory.path_join("dependency_install.log")
	var exit_path := directory.path_join("dependency_exit.txt")
	var runner_path := directory.path_join("install_dependency.cmd")
	var runner := FileAccess.open(runner_path, FileAccess.WRITE)
	if runner == null:
		show_toast("Could not create dependency installer")
		return
	runner.store_string("@echo off\r\ntitle SAM-AI DEPENDENCY INSTALL - Internet access is active\r\ncolor 0E\r\necho Installing %s into SAM-AI's private Python environment...\r\n\"%s\" -m pip install %s > \"%s\" 2>&1\r\nset SAM_EXIT=%%ERRORLEVEL%%\r\ntype \"%s\"\r\necho.\r\necho Installation finished. SAM-AI will continue in the app.\r\ntimeout /t 1 /nobreak ^>nul\r\necho %%SAM_EXIT%%>\"%s\"\r\nexit /b %%SAM_EXIT%%\r\n" % [package, str(settings.voice_python_path), package, output_path, output_path, exit_path])
	runner.close()
	if FileAccess.file_exists(exit_path):
		DirAccess.remove_absolute(exit_path)
	supervised_run_jobs.append({"kind": "install", "path": path, "language": language, "output": output_path, "exit": exit_path})
	set_privacy_activity(true, "Installing Python dependency", "Python Package Index (PyPI)", "The user approved downloading the missing '%s' package." % package, 7, "Internet access is limited to Python's package installer for this confirmed dependency.")
	var pid := OS.create_process("cmd.exe", PackedStringArray(["/d", "/c", "call", runner_path]), true)
	if pid > 0:
		command_process_pids.append(pid)
	show_toast("Internet in use • installing %s" % package)

func launch_supervised_retry(path: String, language: String) -> void:
	var runner := write_supervised_command_runner(path, language, false)
	if runner.is_empty():
		show_toast("Dependency installed, but retry could not be prepared")
		return
	register_supervised_run(path, language, false)
	var pid := OS.create_process("cmd.exe", PackedStringArray(["/d", "/c", "call", runner]), true)
	if pid > 0:
		command_process_pids.append(pid)
	show_toast("Dependency installed • supervised retry started")

func place_run_error_in_composer(path: String, output: String) -> void:
	set_session_status("attention")
	var error_summary := "Script exited with an unknown error."
	var output_lines := output.split("\n", false)
	for index in range(output_lines.size() - 1, -1, -1):
		var candidate := str(output_lines[index]).strip_edges()
		if candidate.is_empty() or candidate.begins_with("^") or candidate.begins_with("File "):
			continue
		if candidate.contains("Error") or candidate.contains("Exception") or candidate.contains("Traceback"):
			error_summary = candidate.left(500)
			break
	var log_path := path.get_base_dir().path_join("run_output.log")
	for candidate_name in ["run_standard_output.log", "run_admin_output.log"]:
		var candidate_path := path.get_base_dir().path_join(candidate_name)
		if FileAccess.file_exists(candidate_path):
			log_path = candidate_path
			break
	attach_file(path)
	var report := "Please fix the attached generated script and return the complete corrected file.\n\nError: %s\nFull debug log: %s" % [error_summary, log_path]
	input_box.text = report
	input_box.grab_focus()
	set_status("SCRIPT NEEDS REPAIR", colors.amber)
	show_toast("Run failed • script attached with a concise repair summary")

func poll_admin_console_status() -> void:
	if not admin_status_path.is_empty() and FileAccess.file_exists(admin_status_path):
		var result = load_json(admin_status_path)
		DirAccess.remove_absolute(admin_status_path)
		admin_status_path = ""
		admin_helper_pid = -1
		if result is Dictionary and str(result.get("state", "")) == "accepted":
			admin_console_pid = int(result.get("pid", -1))
			pc_admin_request_active = true
			refresh_pc_commands_indicator()
			show_toast("Administrator run approved • shield stays red while it runs")
		else:
			pc_admin_request_active = false
			admin_console_pid = -1
			refresh_pc_commands_indicator()
			show_toast("Administrator request was denied or could not start")
	if admin_console_pid > 0 and not OS.is_process_running(admin_console_pid):
		admin_console_pid = -1
		pc_admin_request_active = false
		refresh_pc_commands_indicator()
		show_toast("Administrator run ended • elevated access cleared")
	elif admin_helper_pid > 0 and not OS.is_process_running(admin_helper_pid) and not admin_status_path.is_empty() and not FileAccess.file_exists(admin_status_path):
		admin_helper_pid = -1
		admin_status_path = ""
		pc_admin_request_active = false
		refresh_pc_commands_indicator()
		show_toast("Windows UAC helper ended before starting the administrator run")

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
	if not is_instance_valid(memory_editor):
		log_line("ERROR", "Memory editor node is invalid")
		return

	var raw_path := str(settings.get("memory_path", "user://memory_core.json"))
	var clean_path := ProjectSettings.globalize_path(raw_path)
	var temp_path := clean_path + ".tmp"

	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		var err := FileAccess.get_open_error()
		log_line("ERROR", "Could not open temporary memory file for writing (Error code: %d)" % err)
		return

	var text_to_save := memory_editor.text.strip_edges() + "\n"
	file.store_string(text_to_save)
	file.close()

	# Replace the target file atomically with the temporary file
	var rename_err := DirAccess.rename_absolute(temp_path, clean_path)
	if rename_err != OK:
		log_line("ERROR", "Failed to finalize memory file save (Error code: %d)" % rename_err)
		return

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
	# Cancel before reading the edited fields, so an unconfirmed auto-reload
	# cannot overwrite the user's explicitly selected context on Save.
	if context_reload_pending:
		context_reload_pending = false
		context_rollback_pending = false
		context_resume_serial = -1
	if generating:
		restore_primary_when_done = false
		stop_generation()
	context_growth_blocked.clear()
	settings.model_path = fields.model_path.text.strip_edges()
	settings.server_path = fields.server_path.text.strip_edges()
	settings.mmproj_path = fields.mmproj_path.text.strip_edges()
	settings.vision_model_path = fields.vision_model_path.text.strip_edges()
	settings.vision_mmproj_path = fields.vision_mmproj_path.text.strip_edges()
	settings.memory_path = fields.memory_path.text.strip_edges()
	settings.background_path = fields.background_path.text.strip_edges()
	settings.port = int(fields.port.text)
	settings.gpu_layers = int(fields.gpu_layers.text)
	settings.context_size = maxi(2048, int(fields.context_size.text))
	var requested_max_tokens := maxi(256, int(fields.max_tokens.text))
	settings.max_tokens = mini(requested_max_tokens, maxi(256, int(settings.context_size) - 512))
	fields.context_size.text = str(settings.context_size)
	fields.max_tokens.text = str(settings.max_tokens)
	if requested_max_tokens != int(settings.max_tokens):
		show_toast("Max output adjusted to fit the shared context window")
	settings.temperature = float(fields.temperature.text)
	save_json(SETTINGS_FILE, settings)
	load_memory_editor()
	load_background()
	engine_mode = "primary"
	start_engine()

func use_qwen_coder_preset() -> void:
	fields.model_path.text = QWEN_CODER_14B_MODEL
	fields.gpu_layers.text = "99"
	fields.context_size.text = "4992"
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
	dialog.add_filter("*.gd,*.gdshader,*.tscn,*.tres,*.godot,*.glsl,*.hlsl,*.shader,*.compute,*.inc,*.py,*.js,*.ts,*.tsx,*.jsx,*.cs,*.cpp,*.c,*.h,*.hpp,*.java,*.rs,*.go,*.html,*.css,*.scss,*.sql,*.sh,*.ps1,*.bat", "Source code and Godot resources")
	dialog.add_filter("*.zip", "ZIP archives")
	dialog.add_filter("*.*", "All files (unknown binaries attach as metadata only)")
	dialog.file_selected.connect(func(path: String): attach_file(path); dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered_ratio(0.75)

func _on_files_dropped(files: PackedStringArray) -> void:
	if files.is_empty():
		return
	if command_center_is_active():
		var accepted := 0
		for path in files:
			if not FileAccess.file_exists(path):
				continue
			accepted += 1
			call_deferred("command_center_attach_file", path)
		if accepted > 0:
			show_toast("Adding %d item%s to Command Center…" % [accepted, "" if accepted == 1 else "s"])
			return
		show_toast("No readable file was found in that drop")
		return
	for path in files:
		if FileAccess.file_exists(path):
			show_toast("Preparing %s…" % path.get_file())
			call_deferred("attach_file", path)
			return
	show_toast("No readable file was found in that drop")

func show_attachment_action_dialog() -> void:
	var path := attached_image_path if not attached_image_path.is_empty() else attached_file_path
	var dialog := ConfirmationDialog.new()
	dialog.title = "WHAT SHOULD SAM DO WITH THIS ATTACHMENT?"
	dialog.dialog_text = "%s\n\nAnalyze only keeps the attachment in this chat turn. Scan + Learn stores searchable, source-tagged chunks in KnowledgeVault. Godot scripts are marked with their detected project version and unresolved project dependencies are not automatically treated as errors." % path.get_file()
	dialog.ok_button_text = "ANALYZE ONLY"
	if attached_file_path.get_extension().to_lower() in ["gd", "gdshader"]:
		dialog.add_button("SCAN + LEARN GODOT", true, "learn_godot")
	elif not attached_file_path.is_empty():
		dialog.add_button("ADD TO KNOWLEDGE", true, "learn_file")
	dialog.add_button("KEEP ATTACHED", true, "keep")
	dialog.confirmed.connect(func():
		input_box.text = "Analyze this attached file. Explain what it does, identify dependencies or missing context without assuming they are errors, and tell me what else you need."
		dialog.queue_free()
		call_deferred("send_message"))
	dialog.custom_action.connect(func(action: StringName):
		if action == "learn_godot":
			show_godot_script_learning_confirmation("Analyze this attached working Godot script, learn its reusable Godot API patterns, and explain any external project dependencies without assuming they are errors.")
		elif action == "learn_file":
			import_current_attachment_to_knowledge()
			input_box.text = "Analyze the attached file and explain the useful knowledge that was added to KnowledgeVault."
			call_deferred("send_message")
		dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, colors.cyan)
	dialog.popup_centered(Vector2i(760, 390))

func attachment_request_wants_learning(request: String) -> bool:
	var lower := request.to_lower()
	return contains_any(lower, ["scan and learn", "scan the file", "learn from", "update memory", "update your memory", "add to knowledge", "remember this code"])

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
	var code_extensions := ["gd", "gdshader", "tscn", "tres", "godot", "glsl", "hlsl", "shader", "compute", "inc", "py", "js", "ts", "tsx", "jsx", "cs", "cpp", "c", "h", "hpp", "java", "rs", "go", "html", "css", "scss", "sql", "sh", "ps1", "bat"]
	var text_extensions := ["txt", "md", "log", "json", "jsonl", "csv", "tsv", "xml", "yaml", "yml", "ini", "cfg", "conf", "toml", "env", "gitignore", "dockerfile", "license", "manifest"]
	clear_attachment()
	if extension == "zip":
		show_zip_archive_dialog(path)
		return true
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
	# Unknown binary formats remain attachable for safe metadata/file-management
	# requests, but SAM never guesses at their contents or executes them automatically.
	attached_file_path = path
	attached_file_kind = "binary"
	attachment_tools.visible = true
	attachment_snippet.visible = true
	attachment_snippet.clear()
	var binary := FileAccess.open(path, FileAccess.READ)
	var binary_size := binary.get_length() if binary else 0
	attachment_snippet.append_text("[color=#f9c74f]BINARY / UNKNOWN FILE[/color]\n%s\n%.2f MB • contents not decoded or executed" % [escape_bbcode(path.get_file()), float(binary_size) / 1048576.0])
	attachment_label.text = "📦 %s • metadata attached safely" % path.get_file()
	attachment_label.add_theme_color_override("font_color", colors.amber)
	show_toast("Unknown file attached as metadata • SAM will not execute it automatically")
	return true

func show_zip_archive_dialog(path: String) -> void:
	var reader := ZIPReader.new()
	var open_error := reader.open(path)
	if open_error != OK:
		show_toast("That ZIP archive could not be opened")
		return
	var entries := reader.get_files()
	reader.close()
	var preview: Array[String] = []
	for index in range(mini(20, entries.size())):
		preview.append("• " + str(entries[index]))
	if entries.size() > 20:
		preview.append("• …and %d more entries" % (entries.size() - 20))
	var dialog := ConfirmationDialog.new()
	dialog.title = "INSPECT AND EXTRACT ZIP SAFELY?"
	dialog.dialog_text = "%s\n\n%d archive entries\n\n%s\n\nExtraction is local and read-only toward the original ZIP. SAM blocks absolute paths and ../ traversal, limits extraction to 500 files / 100 MB, and never executes extracted programs automatically." % [path.get_file(), entries.size(), "\n".join(preview)]
	dialog.ok_button_text = "EXTRACT TO PLAYGROUND"
	dialog.add_button("EXTRACT + LEARN TEXT/SOURCE", true, "extract_learn")
	dialog.confirmed.connect(func(): dialog.queue_free(); extract_zip_archive_safely(path, false))
	dialog.custom_action.connect(func(action: StringName):
		if action == "extract_learn":
			dialog.queue_free()
			extract_zip_archive_safely(path, true))
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, colors.cyan)
	dialog.popup_centered(Vector2i(820, 560))

func extract_zip_archive_safely(zip_path: String, learn_after: bool) -> void:
	var reader := ZIPReader.new()
	if reader.open(zip_path) != OK:
		show_toast("ZIP extraction failed before any files were written")
		return
	var entries := reader.get_files()
	if entries.size() > 500:
		reader.close()
		show_toast("ZIP blocked • more than 500 entries")
		return
	var folder_name := zip_path.get_file().get_basename().validate_filename() + "_extracted_" + Time.get_datetime_string_from_system().replace(":", "-")
	var extraction_root := command_workspace_dir().path_join(folder_name)
	DirAccess.make_dir_recursive_absolute(extraction_root)
	var written_paths: Array[String] = []
	var total_bytes := 0
	for raw_entry in entries:
		var entry := str(raw_entry).replace("\\", "/")
		if entry.begins_with("/") or entry.contains("../") or entry == ".." or entry.contains(":"):
			log_line("ARCHIVE", "Blocked unsafe ZIP path: " + entry)
			continue
		var destination := extraction_root.path_join(entry).simplify_path()
		if not destination.replace("\\", "/").begins_with(extraction_root.replace("\\", "/") + "/"):
			continue
		if entry.ends_with("/"):
			DirAccess.make_dir_recursive_absolute(destination)
			continue
		var data := reader.read_file(str(raw_entry))
		total_bytes += data.size()
		if total_bytes > 100 * 1024 * 1024:
			reader.close()
			show_toast("ZIP stopped at the 100 MB safety limit • partial extraction kept for inspection")
			OS.shell_open(extraction_root)
			refresh_playground_manager()
			return
		DirAccess.make_dir_recursive_absolute(destination.get_base_dir())
		var output := FileAccess.open(destination, FileAccess.WRITE)
		if output:
			output.store_buffer(data)
			output.close()
			written_paths.append(destination)
	reader.close()
	refresh_playground_manager()
	if learn_after:
		learn_extracted_archive_files(zip_path, extraction_root, written_paths)
	else:
		OS.shell_open(extraction_root)
		show_toast("ZIP extracted safely • nothing inside was executed")

func learn_extracted_archive_files(zip_path: String, extraction_root: String, paths: Array[String]) -> void:
	var readable_extensions := ["txt", "md", "log", "json", "jsonl", "csv", "tsv", "xml", "yaml", "yml", "ini", "cfg", "conf", "toml", "env", "gd", "gdshader", "tscn", "tres", "godot", "glsl", "hlsl", "shader", "compute", "inc", "py", "js", "ts", "tsx", "jsx", "cs", "cpp", "c", "h", "hpp", "java", "rs", "go", "html", "css", "scss", "sql", "sh", "ps1", "bat"]
	var bundle := "ARCHIVE SOURCE: %s\nEXTRACTED TO: %s\n" % [zip_path, extraction_root]
	var learned_files := 0
	for path in paths:
		if path.get_extension().to_lower() not in readable_extensions:
			continue
		var source := FileAccess.open(path, FileAccess.READ)
		if source == null or source.get_length() > 1024 * 1024:
			continue
		var section := "\n\n--- FILE: %s ---\n%s" % [path.trim_prefix(extraction_root).trim_prefix("\\").trim_prefix("/"), source.get_as_text()]
		if bundle.length() + section.length() > 900000:
			break
		bundle += section
		learned_files += 1
	var bundle_path := extraction_root.path_join("SAM_ARCHIVE_KNOWLEDGE.txt")
	var output := FileAccess.open(bundle_path, FileAccess.WRITE)
	if output:
		output.store_string(bundle)
		output.close()
		attach_file(bundle_path)
		import_current_attachment_to_knowledge()
		show_toast("ZIP extracted • %d readable files added to KnowledgeVault" % learned_files)
	OS.shell_open(extraction_root)

func build_text_attachment_prompt(instruction: String) -> String:
	var kind_note := "source code" if attached_file_kind == "code" else "text document"
	return "%s\n\nATTACHED %s: %s\nRead the attached contents literally and follow the user's instruction. If this is code, inspect it for syntax errors, incorrect identifiers, logic problems, security issues, and incomplete behavior. Cite relevant lines or snippets and provide corrected code when requested.\n\n--- BEGIN ATTACHED FILE ---\n%s\n--- END ATTACHED FILE ---" % [instruction, kind_note, attached_file_path.get_file(), attached_file_text]

func import_current_attachment_to_knowledge() -> void:
	if vault_loading or vault_write_blocked or shutdown_started:
		show_toast("Knowledge Vault is loading or needs index repair • try again when ready")
		return
	if attached_file_path.is_empty() or not FileAccess.file_exists(attached_file_path):
		show_toast("Attach a text, documentation, or source-code file first")
		return
	var source := FileAccess.open(attached_file_path, FileAccess.READ)
	if source == null:
		show_toast("SAM could not read that file")
		return
	var byte_count := source.get_length()
	if byte_count > 1048576:
		show_toast("Knowledge imports are limited to 1 MB per file to protect memory")
		return
	var full_text := source.get_as_text().strip_edges()
	if full_text.is_empty():
		show_toast("That file contains no readable text")
		return
	var source_path := attached_file_path
	var source_name := source_path.get_file()
	var retained_entries: Array = []
	for existing_entry_value in knowledge_entries:
		if existing_entry_value is Dictionary and str(existing_entry_value.get("source_path", "")) == source_path:
			continue
		retained_entries.append(existing_entry_value)
	knowledge_entries = retained_entries
	var imported_at := Time.get_datetime_string_from_system()
	var session_name := "document-" + source_name.validate_filename() + "-" + imported_at.replace(":", "-")
	var chunk_number := 0
	for chunk_text_value in semantic_chunk_text(full_text):
		var chunk_text := str(chunk_text_value)
		if not chunk_text.is_empty():
			chunk_number += 1
			var entry := {
				"id": "%s-%04d" % [session_name, chunk_number], "session": session_name,
				"chunk": chunk_number, "created": imported_at, "category": "Document",
				"confidence": "user-provided local document", "source_mode": "File import",
				"input_device": "None", "source_path": source_path, "source_name": source_name,
				"summary": knowledge_summary(chunk_text), "notes": [], "transcript": chunk_text, "audio_path": ""
			}
			_vault_prepare_incoming(entry)
			_vault_add_entry(entry)
	save_json(knowledge_index_file(), knowledge_entries)
	refresh_knowledge_report()
	refresh_knowledge_discoveries()
	refresh_knowledge_storage_stats()
	show_toast("Added %s to KnowledgeVault • %d searchable chunks" % [source_name, chunk_number])
	log_line("KNOWLEDGE", "Imported %s into %d searchable chunks" % [source_name, chunk_number])


func find_godot_project_root(path: String) -> String:
	var current := path.get_base_dir() if not DirAccess.dir_exists_absolute(path) else path
	for _depth in range(10):
		if FileAccess.file_exists(current.path_join("project.godot")):
			return current
		var parent := current.get_base_dir()
		if parent == current or parent.is_empty():
			break
		current = parent
	return ""

func detect_godot_project_version(project_root: String) -> String:
	var project_file := project_root.path_join("project.godot")
	if FileAccess.file_exists(project_file):
		for raw_line in FileAccess.get_file_as_string(project_file).split("\n"):
			var line := str(raw_line).strip_edges()
			if line.begins_with("config/features"):
				var version_regex := RegEx.new()
				version_regex.compile("[0-9]+\\.[0-9]+")
				var version_match := version_regex.search(line)
				if version_match:
					return version_match.get_string()
	var runtime_version := Engine.get_version_info()
	return "%d.%d (inferred from SAM runtime)" % [int(runtime_version.get("major", 4)), int(runtime_version.get("minor", 0))]

func gdscript_dependency_notes(source_text: String) -> Array[String]:
	var notes: Array[String] = []
	for raw_line in source_text.split("\n"):
		var line := str(raw_line).strip_edges()
		if line.begins_with("extends ") and not notes.has(line):
			notes.append(line.left(180))
		elif line.begins_with("class_name ") and not notes.has(line):
			notes.append(line.left(180))
		elif (line.contains("preload(") or line.contains("load(") or line.contains("$\"") or line.contains("$")) and notes.size() < 16:
			notes.append(line.left(220))
		if notes.size() >= 16:
			break
	return notes

func show_godot_script_learning_confirmation(original_request: String) -> void:
	var project_root := find_godot_project_root(attached_file_path)
	var version := detect_godot_project_version(project_root) if not project_root.is_empty() else "4.x (project file not found)"
	var dialog := ConfirmationDialog.new()
	dialog.title = "SCAN THIS GODOT SCRIPT INTO KNOWLEDGEVAULT?"
	dialog.dialog_text = "READ-ONLY OPERATION\n\nFile: %s\nDetected Godot version: %s\nProject context: %s\n\nSAM will copy searchable code knowledge into KnowledgeVault. It will not edit the script or project. Node paths, autoloads, custom classes, scenes, and resources may live in other files; unresolved references will be recorded as dependencies, not assumed errors." % [attached_file_path, version, project_root if not project_root.is_empty() else "Not connected"]
	dialog.ok_button_text = "SCAN READ-ONLY"
	if not project_root.is_empty():
		dialog.add_button("BACK UP PROJECT + SCAN", true, "backup_scan")
	dialog.confirmed.connect(func():
		scan_attached_godot_script_to_knowledge(false)
		skip_attachment_learning_confirm = true
		input_box.text = original_request
		dialog.queue_free()
		call_deferred("send_message"))
	dialog.custom_action.connect(func(action: StringName):
		if action == "backup_scan":
			var backup_path := backup_godot_project(project_root)
			if backup_path.is_empty():
				show_toast("Backup failed • scan canceled")
			else:
				scan_attached_godot_script_to_knowledge(false)
				skip_attachment_learning_confirm = true
				input_box.text = original_request
				show_toast("Backup created before scan • " + backup_path.get_file())
				call_deferred("send_message")
		dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, colors.green)
	dialog.popup_centered(Vector2i(820, 470))

func scan_attached_godot_script_to_knowledge(send_analysis: bool) -> void:
	if vault_loading or vault_write_blocked or shutdown_started:
		show_toast("Knowledge Vault is loading or needs index repair • try again when ready")
		return
	if attached_file_path.get_extension().to_lower() not in ["gd", "gdshader"] or not FileAccess.file_exists(attached_file_path):
		show_toast("Attach a readable .gd or .gdshader source file first")
		return
	var source_path := attached_file_path
	var source_text := FileAccess.get_file_as_string(source_path)
	var project_root := find_godot_project_root(source_path)
	var version := detect_godot_project_version(project_root) if not project_root.is_empty() else "4.x (unverified)"
	var dependencies := gdscript_dependency_notes(source_text)
	import_current_attachment_to_knowledge()
	for entry_value in knowledge_entries:
		if entry_value is Dictionary and str(entry_value.get("source_path", "")) == source_path:
			entry_value.category = "Godot Code"
			entry_value.confidence = "user-provided source code; runtime behavior and external dependencies unverified"
			entry_value.godot_version = version
			entry_value.project_root = project_root
			entry_value.dependency_notes = dependencies
	save_json(knowledge_index_file(), knowledge_entries)
	refresh_knowledge_report()
	if send_analysis:
		input_box.text = "Analyze this working Godot %s script and add its reusable API patterns to KnowledgeVault. Identify node paths, autoloads, custom classes, scenes, resources, or sibling scripts it depends on. Do not call an unresolved project reference an error unless the supplied project context proves it is missing." % version
		skip_attachment_learning_confirm = true
		call_deferred("send_message")

func choose_godot_project_folder() -> void:
	var dialog := FileDialog.new()
	dialog.title = "Choose a Godot Project Folder (project.godot required)"
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.dir_selected.connect(func(path: String): dialog.queue_free(); show_godot_project_scan_confirmation(path))
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered_ratio(0.78)

func collect_godot_project_files(current: String, result: Array[String]) -> void:
	if result.size() >= 250:
		return
	var directory := DirAccess.open(current)
	if directory == null:
		return
	for filename in directory.get_files():
		var extension := filename.get_extension().to_lower()
		if filename == "project.godot" or extension in ["gd", "tscn", "tres", "gdshader", "cfg", "json"]:
			result.append(current.path_join(filename))
			if result.size() >= 250:
				return
	for child in directory.get_directories():
		if child in [".godot", ".git", ".import", "build", "bin", "dist", "exports", "__pycache__"] or directory.is_link(child):
			continue
		collect_godot_project_files(current.path_join(child), result)
		if result.size() >= 250:
			return

func show_godot_project_scan_confirmation(project_root: String) -> void:
	if not FileAccess.file_exists(project_root.path_join("project.godot")):
		show_toast("That folder does not contain project.godot")
		return
	var files: Array[String] = []
	collect_godot_project_files(project_root, files)
	var total_bytes := 0
	for path in files:
		var source := FileAccess.open(path, FileAccess.READ)
		if source:
			total_bytes += source.get_length()
	var version := detect_godot_project_version(project_root)
	var dialog := ConfirmationDialog.new()
	dialog.title = "CONNECT GODOT PROJECT READ-ONLY?"
	dialog.dialog_text = "Project: %s\nDetected Godot: %s\nRelevant files found: %d\nReadable source size: %.2f MB\n\nSAM will read up to 250 relevant files / 5 MB and store a source-tagged KnowledgeVault snapshot. Generated caches and Git metadata are skipped. No project file will be edited. Rescanning replaces the previous snapshot." % [project_root, version, files.size(), total_bytes / 1048576.0]
	dialog.ok_button_text = "SCAN READ-ONLY"
	dialog.add_button("BACK UP PROJECT + SCAN", true, "backup_scan")
	dialog.confirmed.connect(func(): dialog.queue_free(); scan_godot_project(project_root))
	dialog.custom_action.connect(func(action: StringName):
		if action == "backup_scan":
			var backup_path := backup_godot_project(project_root)
			if backup_path.is_empty():
				show_toast("Backup failed • project scan canceled")
			else:
				show_toast("Backup created • starting read-only scan")
				scan_godot_project(project_root)
		dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, colors.green)
	dialog.popup_centered(Vector2i(820, 480))

func backup_godot_project(project_root: String) -> String:
	if project_root.is_empty() or not FileAccess.file_exists(project_root.path_join("project.godot")):
		return ""
	var backup_parent := sam_backup_root().path_join("Project Checkpoints")
	var backup_prefix := project_root.get_file().validate_filename() + "_"
	var backup_name := backup_prefix + Time.get_datetime_string_from_system().replace(":", "-") + "-%d" % Time.get_ticks_msec()
	var destination := backup_parent.path_join(backup_name)
	DirAccess.make_dir_recursive_absolute(destination)
	if not copy_godot_project_backup(project_root, destination):
		return ""
	var checkpoint := {"created": Time.get_datetime_string_from_system(), "source_project": project_root, "backup_path": destination, "recovery": "Preserve the broken version, then copy this checkpoint back over the source project."}
	save_json(destination.path_join("sam-checkpoint.json"), checkpoint)
	prune_backup_folders(backup_parent, backup_prefix, 5)
	log_line("BACKUP", "Created Godot project backup at " + destination)
	return destination

func copy_godot_project_backup(source_path: String, destination_path: String) -> bool:
	var source := DirAccess.open(source_path)
	if source == null:
		return false
	DirAccess.make_dir_recursive_absolute(destination_path)
	for filename in source.get_files():
		if DirAccess.copy_absolute(source_path.path_join(filename), destination_path.path_join(filename)) != OK:
			return false
	for child in source.get_directories():
		if child in [".godot", ".git", ".import", "__pycache__", "SAM-AI Backups"] or source.is_link(child):
			continue
		if not copy_godot_project_backup(source_path.path_join(child), destination_path.path_join(child)):
			return false
	return true

func scan_godot_project(project_root: String) -> void:
	if vault_loading or vault_write_blocked or shutdown_started:
		show_toast("Knowledge Vault is loading or needs index repair • try again when ready")
		return
	var files: Array[String] = []
	collect_godot_project_files(project_root, files)
	var version := detect_godot_project_version(project_root)
	var retained: Array = []
	for existing_entry_value in knowledge_entries:
		if existing_entry_value is Dictionary and str(existing_entry_value.get("project_root", "")) == project_root:
			continue
		retained.append(existing_entry_value)
	knowledge_entries = retained
	var total_bytes := 0
	var imported_files := 0
	var imported_chunks := 0
	var imported_at := Time.get_datetime_string_from_system()
	var project_session := "godot-project-" + project_root.get_file().validate_filename() + "-" + imported_at.replace(":", "-")
	for path in files:
		var source := FileAccess.open(path, FileAccess.READ)
		if source == null:
			continue
		var file_bytes := source.get_length()
		if file_bytes > 1048576 or total_bytes + file_bytes > 5242880:
			continue
		var text := source.get_as_text().strip_edges()
		if text.is_empty():
			continue
		total_bytes += file_bytes
		imported_files += 1
		var relative_path := path.trim_prefix(project_root).trim_prefix("/").trim_prefix("\\")
		var file_chunk := 0
		for chunk_text_value in semantic_chunk_text(text):
			var chunk_text := str(chunk_text_value).strip_edges()
			if not chunk_text.is_empty():
				file_chunk += 1
				imported_chunks += 1
				var entry := {"id": "%s-%05d" % [project_session, imported_chunks], "session": project_session, "chunk": imported_chunks, "created": imported_at, "category": "Godot Project", "confidence": "read-only local project snapshot; runtime behavior not independently verified", "source_mode": "Godot project import", "input_device": "None", "source_path": path, "source_name": relative_path, "project_root": project_root, "godot_version": version, "file_chunk": file_chunk, "summary": knowledge_summary(chunk_text), "notes": gdscript_dependency_notes(chunk_text) if path.get_extension().to_lower() == "gd" else [], "transcript": chunk_text, "audio_path": ""}
				_vault_prepare_incoming(entry)
				_vault_add_entry(entry)
	save_json(knowledge_index_file(), knowledge_entries)
	refresh_knowledge_report()
	refresh_knowledge_discoveries()
	refresh_knowledge_storage_stats()
	show_toast("Godot %s project queued for study read-only • %d files / %d chunks" % [version, imported_files, imported_chunks])
	log_line("KNOWLEDGE", "Scanned Godot project read-only: %s (%d files, %d chunks)" % [project_root, imported_files, imported_chunks])


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
	if total_ram_gb > 0.0:
		available_ram_gb = minf(available_ram_gb, total_ram_gb)
	var gpu_name := detected_gpu_name()
	var gpu_api := RenderingServer.get_video_adapter_api_version()
	var gpu_vram_mb := 0.0
	var gpu_used_mb := 0.0
	var gpu_temp := -1.0
	var gpu_load := -1.0
	var model_gb := get_selected_model_size_gb()
	var verdict := "GPU memory could not be measured; SAM will test CUDA during engine startup."
	var verdict_color := "#f9c74f"
	if running_in_windows_sandbox():
		verdict = "Windows Sandbox may display the host GPU name without exposing CUDA or VRAM to apps. The bundled CPU runtime is the reliable Sandbox path; validate CUDA performance on a normal Windows installation."
	elif not server_directory_has_acceleration(str(settings.server_path)):
		verdict = "The bundled CPU runtime is selected. This works without CUDA, but larger models can be slow. Install an official CUDA/Vulkan llama.cpp runtime from Modules for compatible GPU acceleration."
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
	return model_size_gb_for_path(str(settings.model_path))

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

func knowledge_storage_dir() -> String:
	var configured := str(settings.get("knowledge_storage_path", "")).strip_edges()
	return configured if not configured.is_empty() else DEFAULT_KNOWLEDGE_DIR

func knowledge_index_file() -> String:
	return knowledge_storage_dir().path_join("index.json")

func directory_size_bytes(path: String) -> int:
	if ProjectSettings.globalize_path(path) == ProjectSettings.globalize_path(knowledge_storage_dir()):
		return int(vault_stats.get("bytes", 0))
	var directory := DirAccess.open(path)
	if directory == null:
		return 0
	var total := 0
	directory.list_dir_begin()
	var filename := directory.get_next()
	while not filename.is_empty():
		if not directory.current_is_dir():
			var file_path := path.path_join(filename)
			if FileAccess.file_exists(file_path):
				var file := FileAccess.open(file_path, FileAccess.READ)
				if file != null:
					total += file.get_length()
					file.close()
		else:
			if filename != "." and filename != "..":
				total += directory_size_bytes(path.path_join(filename))
		filename = directory.get_next()
	directory.list_dir_end()
	return total


func knowledge_limit_reached() -> bool:
	var limit_bytes := int(float(settings.get("knowledge_limit_gb", 10.0)) * 1073741824.0)
	return vault_stats_ready and int(vault_stats.get("bytes", 0)) >= limit_bytes


func refresh_knowledge_storage_stats() -> void:
	vault_stats_due = 0
	_vault_render_storage_stats()


func choose_knowledge_storage_location() -> void:
	if knowledge_recording or knowledge_process_pid > 0:
		show_toast("Stop recording and wait for transcription before moving the vault")
		return
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.dir_selected.connect(func(path: String): migrate_knowledge_storage(path); dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered_ratio(0.75)

func migrate_knowledge_storage(new_parent: String) -> void:
	if vault_loading or knowledge_recording or knowledge_process_pid > 0 or vault_jobs.has("study") or vault_jobs.has("save") or vault_save_cursor >= 0 or vault_revision > vault_saved_revision:
		show_toast("Pause Live Study, stop capture and wait for saves before copying the vault")
		return
	var old_path := ProjectSettings.globalize_path(knowledge_storage_dir())
	var new_path := new_parent.path_join("SAM-AI-KnowledgeVault")
	DirAccess.make_dir_recursive_absolute(new_path)
	copy_directory_contents(old_path, new_path)
	settings.knowledge_storage_path = new_path
	save_json(SETTINGS_FILE, settings)
	refresh_knowledge_storage_stats()
	show_toast("Knowledge Vault copied and future data will use the new location")


func copy_directory_contents(source: String, destination: String) -> void:
	var directory := DirAccess.open(source)
	if directory == null:
		return
	DirAccess.make_dir_recursive_absolute(destination)
	for filename in directory.get_files():
		DirAccess.copy_absolute(source.path_join(filename), destination.path_join(filename))
	for child in directory.get_directories():
		copy_directory_contents(source.path_join(child), destination.path_join(child))

func choose_knowledge_backup_location() -> void:
	var dialog := FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.dir_selected.connect(func(path: String): create_knowledge_backup(path); dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered_ratio(0.75)

func create_knowledge_backup(parent: String) -> void:
	if vault_loading or knowledge_recording or knowledge_process_pid > 0 or vault_jobs.has("study") or vault_jobs.has("save") or vault_save_cursor >= 0 or vault_revision > vault_saved_revision:
		show_toast("Pause Live Study, stop capture and wait for saves before copying the vault")
		return
	var stamp := Time.get_datetime_string_from_system().replace(":", "-").validate_filename()
	var backup_dir := parent.path_join("SAM-AI-Backup-" + stamp)
	copy_directory_contents(ProjectSettings.globalize_path(knowledge_storage_dir()), backup_dir.path_join("KnowledgeVault"))
	if FileAccess.file_exists(str(settings.memory_path)):
		DirAccess.make_dir_recursive_absolute(backup_dir.path_join("MemoryCore"))
		DirAccess.copy_absolute(str(settings.memory_path), backup_dir.path_join("MemoryCore").path_join(str(settings.memory_path).get_file()))
	DirAccess.copy_absolute(ProjectSettings.globalize_path(SETTINGS_FILE), backup_dir.path_join("settings.json"))
	show_toast("Backup created • " + backup_dir)


func add_study_basket(parent: HBoxContainer, title_text: String, value_text: String, accent: Color) -> Label:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(box)
	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", accent)
	title.add_theme_font_size_override("font_size", 16)
	box.add_child(title)
	var value := Label.new()
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(value)
	return value

func study_link_for_entry(entry: Dictionary) -> String:
	return VaultWorker.linked_summary(entry, vault_links)


func _study_stage_label(text_value: String, color_value: Color, font_size: int) -> Label:
	var label := Label.new()
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color_value)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _study_live_visuals_active() -> bool:
	return is_instance_valid(study_stage) and study_stage.is_visible_in_tree()

func _study_target_position(status: String) -> Vector2:
	var width := maxf(980.0, study_stage.size.x if is_instance_valid(study_stage) else 980.0)
	var x := width * 0.62
	if status == "rejected":
		x = width * 0.77
	elif status == "archived":
		x = width * 0.91
	return Vector2(x, 49.0)

func _study_render_animation() -> void:
	if not is_instance_valid(study_stage):
		return
	var width := maxf(980.0, study_stage.size.x)
	var icon_size := Vector2(118, 70)
	study_inbox_icon.position = Vector2(width * 0.02, 12)
	study_desk_icon.position = Vector2(width * 0.34, 12)
	study_retain_icon.position = Vector2(width * 0.58, 12)
	study_review_icon.position = Vector2(width * 0.73, 12)
	study_archive_icon.position = Vector2(width * 0.87, 12)
	for label in [study_inbox_icon, study_desk_icon, study_retain_icon, study_review_icon, study_archive_icon]:
		if is_instance_valid(label):
			label.size = icon_size
	if is_instance_valid(study_working_title):
		study_working_title.position = Vector2(125, 105)
		study_working_title.size = Vector2(maxf(300.0, width - 250.0), 34)
	var source := Vector2(width * 0.07, 55)
	var desk := Vector2(width * 0.39, 55)
	var cat_pos := desk
	var paper_pos := desk + Vector2(36, 6)
	var show_paper := false
	var bob := sin(study_elapsed * 8.0) * 3.0
	if study_animation_state == "to_desk":
		var t := clampf(study_animation_elapsed / STUDY_WALK_SECONDS, 0.0, 1.0)
		cat_pos = source.lerp(desk, t)
		paper_pos = cat_pos + Vector2(35, 8)
		show_paper = true
	elif study_animation_state == "reading":
		cat_pos = desk + Vector2(0, bob)
		paper_pos = desk + Vector2(45, 11)
		show_paper = true
	elif study_animation_state == "to_target":
		var pending_entry: Dictionary = study_pending_worker_result.get("entry", {})
		var destination := _study_target_position(str(pending_entry.get("study_status", "rejected")))
		var t := clampf(study_animation_elapsed / STUDY_WALK_SECONDS, 0.0, 1.0)
		cat_pos = desk.lerp(destination, t)
		paper_pos = cat_pos + Vector2(35, 8)
		show_paper = true
	elif study_animation_state == "archive_wait":
		cat_pos = _study_target_position("archived") + Vector2(0, bob)
		paper_pos = cat_pos + Vector2(35, 8)
		show_paper = true
	else:
		cat_pos = desk + Vector2(0, bob)
	if is_instance_valid(study_cat):
		study_cat.position = cat_pos - Vector2(28, 22)
		study_cat.size = Vector2(64, 52)
	if is_instance_valid(study_paper):
		study_paper.position = paper_pos - Vector2(18, 16)
		study_paper.size = Vector2(42, 42)
		study_paper.visible = show_paper

func _study_reset_animation() -> void:
	study_animation_state = "idle"
	study_animation_elapsed = 0.0
	study_worker_done = false
	study_pending_worker_result.clear()
	study_pending_archive.clear()
	study_archive_deadline_ms = 0
	if is_instance_valid(study_pending_archive_panel):
		study_pending_archive_panel.visible = false
	if is_instance_valid(study_working_title):
		study_working_title.text = "Listening for new captures" if knowledge_recording else "Meow Meow is ready for the next file"
	_study_render_animation()

func _study_apply_worker_result_now() -> void:
	if study_pending_worker_result.is_empty():
		return
	var index := int(study_pending_worker_result.get("index", -1))
	var entry: Dictionary = study_pending_worker_result.get("entry", {})
	study_pending_worker_result = {}
	study_worker_done = false
	study_animation_state = "idle"
	study_animation_elapsed = 0.0
	_on_batch_processing_complete(index, entry)
	_study_render_animation()

func _study_begin_archive_confirmation() -> void:
	if study_pending_worker_result.is_empty():
		return
	study_pending_archive = study_pending_worker_result.duplicate(true)
	study_pending_worker_result.clear()
	study_worker_done = false
	study_animation_state = "archive_wait"
	study_animation_elapsed = 0.0
	study_archive_deadline_ms = Time.get_ticks_msec() + STUDY_ARCHIVE_CONFIRM_MS
	var entry: Dictionary = study_pending_archive.get("entry", {})
	if is_instance_valid(study_pending_archive_text):
		study_pending_archive_text.text = "[color=#f9c74f][b]MEOW MEOW SUGGESTS ARCHIVE[/b][/color]  •  %s\n[color=#a9bad3]Archive means saved but excluded from normal chat retrieval — it is not deletion. You are watching the decision before it is applied.[/color]" % escape_bbcode(str(entry.get("summary", entry.get("transcript", ""))).left(360))
	if is_instance_valid(study_pending_archive_panel):
		study_pending_archive_panel.visible = true

func _study_confirm_pending_archive() -> void:
	if study_pending_archive.is_empty():
		return
	var index := int(study_pending_archive.get("index", -1))
	var entry: Dictionary = study_pending_archive.get("entry", {})
	if index >= 0 and index < knowledge_entries.size() and knowledge_entries[index] is Dictionary:
		study_last_archive_before = (knowledge_entries[index] as Dictionary).duplicate(true)
		study_last_archive_id = str(entry.get("id", ""))
	study_pending_archive = {}
	if is_instance_valid(study_pending_archive_panel):
		study_pending_archive_panel.visible = false
	study_animation_state = "idle"
	study_archive_deadline_ms = 0
	_on_batch_processing_complete(index, entry)
	if is_instance_valid(study_working_title):
		study_working_title.text = "Archived safely • transcript kept outside chat retrieval"
	_study_render_animation()

func _study_keep_pending_archive() -> void:
	if study_pending_archive.is_empty():
		return
	var index := int(study_pending_archive.get("index", -1))
	var entry: Dictionary = (study_pending_archive.get("entry", {}) as Dictionary).duplicate(true)
	entry.pinned = true
	entry.study_status = "relevant"
	entry.study_reason = "User chose KEEP + RETAIN during the archive review window. Pinned for retrieval; factual verification is still separate."
	evaluate_knowledge_interest(entry)
	study_pending_archive = {}
	if is_instance_valid(study_pending_archive_panel):
		study_pending_archive_panel.visible = false
	study_animation_state = "idle"
	study_archive_deadline_ms = 0
	_on_batch_processing_complete(index, entry)
	show_toast("Kept + pinned • available to chat retrieval")
	_study_render_animation()

func _study_forget_pending_archive() -> void:
	if study_pending_archive.is_empty():
		return
	study_archive_deadline_ms = Time.get_ticks_msec() + 60000
	var entry: Dictionary = study_pending_archive.get("entry", {})
	var entry_id := str(entry.get("id", ""))
	var dialog := ConfirmationDialog.new()
	dialog.title = "PERMANENTLY FORGET THIS NOTE?"
	dialog.dialog_text = "Archive is normally reversible and keeps the transcript. FORGET permanently removes this KnowledgeVault entry.\n\n%s" % str(entry.get("summary", entry.get("transcript", ""))).left(500)
	dialog.ok_button_text = "FORGET ENTRY"
	dialog.confirmed.connect(func():
		for index in range(knowledge_entries.size() - 1, -1, -1):
			if str((knowledge_entries[index] as Dictionary).get("id", "")) == entry_id:
				knowledge_entries.remove_at(index)
				break
		study_pending_archive = {}
		is_processing_batch = false
		if is_instance_valid(study_pending_archive_panel): study_pending_archive_panel.visible = false
		study_animation_state = "idle"
		_vault_mark_changed()
		show_toast("Knowledge entry permanently forgotten")
		dialog.queue_free())
	dialog.canceled.connect(func(): study_archive_deadline_ms = Time.get_ticks_msec() + STUDY_ARCHIVE_CONFIRM_MS; dialog.queue_free())
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, colors.red)
	dialog.popup_centered(Vector2i(700, 360))

func _study_undo_last_archive() -> void:
	if study_last_archive_id.is_empty() or study_last_archive_before.is_empty():
		show_toast("No recent archive is available to undo")
		return
	var index := int(vault_index.get(study_last_archive_id, -1))
	if index < 0 or index >= knowledge_entries.size():
		show_toast("That archived note is no longer available")
		study_last_archive_id = ""
		study_last_archive_before.clear()
		return
	var restored := study_last_archive_before.duplicate(true)
	restored.study_status = "rejected"
	restored.study_reason = "User undid the last archive decision; returned to Review Later."
	restored.review_version = VaultWorker.REVIEW_VERSION
	_on_batch_processing_complete(index, restored)
	study_last_archive_id = ""
	study_last_archive_before.clear()
	show_toast("Last archive undone • returned to Review Later")

func _study_advance_animation(delta: float) -> bool:
	if not _study_live_visuals_active():
		if study_animation_state == "archive_wait" and not study_pending_archive.is_empty():
			_study_confirm_pending_archive()
		elif study_worker_done and not study_pending_worker_result.is_empty():
			var pending_entry: Dictionary = study_pending_worker_result.get("entry", {})
			if str(pending_entry.get("study_status", "")) == "archived":
				# No need to hold a visual decision when the user is not watching the desk.
				study_pending_archive = study_pending_worker_result.duplicate(true)
				study_pending_worker_result.clear()
				_study_confirm_pending_archive()
			else:
				_study_apply_worker_result_now()
		return is_processing_batch
	study_animation_elapsed += delta
	if study_animation_state == "to_desk" and study_animation_elapsed >= STUDY_WALK_SECONDS:
		study_animation_state = "reading"
		study_animation_elapsed = 0.0
		if is_instance_valid(study_working_title):
			study_working_title.text = "Meow Meow is reading and checking this file…"
	elif study_animation_state == "reading" and study_animation_elapsed >= STUDY_READ_SECONDS and study_worker_done:
		study_animation_state = "to_target"
		study_animation_elapsed = 0.0
		var pending_entry: Dictionary = study_pending_worker_result.get("entry", {})
		var status := str(pending_entry.get("study_status", "rejected"))
		if is_instance_valid(study_working_title):
			study_working_title.text = "Carrying result to %s…" % ("Retained" if status == "relevant" else ("Review Later" if status == "rejected" else "Archive review"))
	elif study_animation_state == "to_target" and study_animation_elapsed >= STUDY_WALK_SECONDS:
		var pending_entry: Dictionary = study_pending_worker_result.get("entry", {})
		if str(pending_entry.get("study_status", "")) == "archived":
			_study_begin_archive_confirmation()
		else:
			_study_apply_worker_result_now()
	elif study_animation_state == "archive_wait" and not study_pending_archive.is_empty():
		var remaining_ms := maxi(0, study_archive_deadline_ms - Time.get_ticks_msec())
		if is_instance_valid(study_pending_archive_countdown):
			study_pending_archive_countdown.text = "Watching this decision • auto-archive in %.1f seconds unless you choose an action." % (float(remaining_ms) / 1000.0)
		if remaining_ms <= 0:
			_study_confirm_pending_archive()
	_study_render_animation()
	return is_processing_batch or study_animation_state != "idle"

func study_decision(entry: Dictionary, seek_link: bool = true) -> Dictionary:
	var duplicate_id := str(vault_fingerprints.get(str(entry.get("fingerprint", "")), ""))
	return VaultWorker.decide(entry, vault_links if seek_link else [], duplicate_id)


func study_decide_entry(entry: Dictionary, announce: bool, evaluate_discovery: bool = true, seek_link: bool = true) -> void:
	enrich_knowledge_entry(entry)
	var decision := study_decision(entry, seek_link)
	entry.study_status = "relevant" if bool(decision.relevant) else "rejected"
	entry.study_reason = str(decision.reason)
	entry.study_score = int(decision.score)
	entry.linked_to = str(decision.linked)
	entry.study_reviewed = Time.get_datetime_string_from_system()
	entry.review_version = VaultWorker.REVIEW_VERSION
	if evaluate_discovery:
		evaluate_knowledge_interest(entry)
	if announce:
		_vault_decision_activity(entry)

func study_counts() -> Dictionary:
	return vault_counts.duplicate()

var is_processing_batch: bool = false

func _process_pending_entry_async(entry_index: int, final_pass: bool = false) -> void:
	# Scheduler runs on main; the callable below owns only duplicated plain data.
	if vault_jobs.has("study") or entry_index < 0 or entry_index >= knowledge_entries.size():
		return
	var original: Dictionary = knowledge_entries[entry_index]
	var copy: Dictionary = original.duplicate(true)
	copy.fingerprint = VaultWorker.fingerprint(str(copy.get("transcript", "")))
	is_processing_batch = true
	study_current_id = str(copy.get("id", ""))
	study_worker_done = false
	study_pending_worker_result.clear()
	if _study_live_visuals_active():
		study_animation_state = "to_desk"
		study_animation_elapsed = 0.0
		study_working_title.text = "Meow Meow picked up: %s" % str(copy.get("summary", copy.get("transcript", ""))).left(110)
		_study_render_animation()
	_vault_start_job("study", {"entry": copy, "links": vault_links.duplicate(true), "interests": vault_interest_cache.duplicate(), "duplicate_id": str(vault_fingerprints.get(str(copy.fingerprint), "")), "final_pass": final_pass}, {"id": study_current_id, "signature": _vault_entry_signature(original), "recheck_generation": vault_recheck_generation, "final_pass": final_pass})


func _on_batch_processing_failed() -> void:
	is_processing_batch = false
	_vault_append_activity("[color=#ff8095]Review failed; source kept for retry.[/color]")

func _on_batch_processing_complete(entry_index: int, processed_entry: Dictionary) -> void:
	is_processing_batch = false
	if entry_index < 0 or entry_index >= knowledge_entries.size():
		return
	var previous: Dictionary = knowledge_entries[entry_index]
	if str(previous.get("id", "")) != str(processed_entry.get("id", "")):
		return
	var old_status := str(previous.get("study_status", "pending"))
	var new_status := str(processed_entry.get("study_status", "pending"))
	vault_counts[old_status] = maxi(0, int(vault_counts.get(old_status, 0)) - 1)
	vault_counts[new_status] = int(vault_counts.get(new_status, 0)) + 1
	var old_unread := 1 if old_status == "relevant" and bool(previous.get("unread_discovery", false)) else 0
	var new_unread := 1 if new_status == "relevant" and bool(processed_entry.get("unread_discovery", false)) else 0
	vault_unread_count = maxi(0, vault_unread_count - old_unread + new_unread)
	knowledge_entries[entry_index] = processed_entry
	for link_index in range(vault_links.size() - 1, -1, -1):
		if str(vault_links[link_index].get("id", "")) == str(processed_entry.get("id", "")):
			vault_links.remove_at(link_index)
	var fingerprint := str(processed_entry.get("fingerprint", ""))
	if not fingerprint.is_empty() and not vault_fingerprints.has(fingerprint):
		vault_fingerprints[fingerprint] = str(processed_entry.get("id", ""))
	if new_status == "relevant":
		vault_links.append(_vault_link_record(processed_entry))
		if vault_links.size() > 64:
			vault_links.pop_front()
		_vault_add_entry_to_term_index(processed_entry)
	_vault_decision_activity(processed_entry)
	# Persist only AFTER the accepted result is applied to the live array.
	_vault_mark_changed(false)

	
func update_live_study(delta: float) -> void:
	if shutdown_started or not is_instance_valid(study_cat):
		return
	study_elapsed += delta
	study_process_elapsed += delta
	if _study_advance_animation(delta):
		if is_instance_valid(study_queue_count):
			study_queue_count.text = "%d incoming • %d reviews left" % [int(vault_counts.get("pending", 0)), maxi(0, vault_pending_ids.size() - vault_pending_head)]
			study_relevant_count.text = "%d retained" % int(vault_counts.get("relevant", 0))
			study_discard_count.text = "%d review later • %d archived" % [int(vault_counts.get("rejected", 0)), int(vault_counts.get("archived", 0))]
		return
	if is_instance_valid(study_queue_count) and int(study_elapsed * 4.0) != study_animation_frame:
		study_animation_frame = int(study_elapsed * 4.0)
		study_queue_count.text = "%d incoming • %d reviews left" % [int(vault_counts.get("pending", 0)), maxi(0, vault_pending_ids.size() - vault_pending_head)]
		study_relevant_count.text = "%d retained" % int(vault_counts.get("relevant", 0))
		study_discard_count.text = "%d review later • %d archived" % [int(vault_counts.get("rejected", 0)), int(vault_counts.get("archived", 0))]
		_study_render_animation()
	if vault_loading or vault_write_blocked or vault_cache_dirty or vault_cache_cursor >= 0 or vault_save_cursor >= 0:
		return
	if vault_review_paused:
		if study_working_title.text != "Study paused • capture can continue":
			study_working_title.text = "Study paused • capture can continue"
		return
	if is_processing_batch or study_process_elapsed < 0.08:
		return
	study_process_elapsed = 0.0
	var examined := 0
	while vault_pending_head < vault_pending_ids.size() and examined < 32:
		var entry_id := vault_pending_ids[vault_pending_head]
		vault_pending_head += 1
		examined += 1
		var index := int(vault_index.get(entry_id, -1))
		if index < 0 or index >= knowledge_entries.size():
			continue
		var entry: Dictionary = knowledge_entries[index]
		if str(entry.get("id", "")) != entry_id:
			continue
		study_working_title.text = "Next file: %s\nCategory: %s" % [str(entry.get("summary", entry.get("transcript", ""))).left(80), str(entry.get("category", "Unknown"))]
		_process_pending_entry_async(index)
		return
	if vault_pending_head >= vault_pending_ids.size():
		vault_recheck_all = false
		vault_recheck_done.clear()
		# Review Later is a bounded quarantine. Extras receive one final pass; low
		# information notes are archived (preserved, but excluded from chat retrieval).
		while int(vault_counts.get("rejected", 0)) > KNOWLEDGE_REVIEW_LATER_LIMIT and vault_final_review_head < vault_final_review_ids.size():
			var final_id := vault_final_review_ids[vault_final_review_head]
			vault_final_review_head += 1
			var final_index := int(vault_index.get(final_id, -1))
			if final_index < 0 or final_index >= knowledge_entries.size():
				continue
			var final_entry: Dictionary = knowledge_entries[final_index]
			if str(final_entry.get("study_status", "")) != "rejected":
				continue
			study_working_title.text = "Final review: %s" % str(final_entry.get("summary", final_entry.get("transcript", ""))).left(90)
			_process_pending_entry_async(final_index, true)
			return
		if int(vault_counts.get("rejected", 0)) > KNOWLEDGE_REVIEW_LATER_LIMIT and vault_final_review_head >= vault_final_review_ids.size():
			vault_cache_dirty = true
			return
		study_working_title.text = "Listening for new captures" if knowledge_recording else "Meow Meow is ready for the next file"

		
func recheck_and_archive_discards() -> void:
	# Retention is non-destructive: a failed heuristic is not permission to delete.
	# Rechecks are individual background jobs, never a 100-item UI-thread burst.
	_vault_request_recheck()



func setup_knowledge_vault() -> void:
	# UI first. Disk load, original backup and legacy review run off the hot path.
	vault_loading = true
	var page := VBoxContainer.new()
	page.name = "KnowledgeVault"
	page.add_theme_constant_override("separation", 10)
	$Page/Tabs.add_child(page)
	var heading := Label.new()
	heading.text = "KNOWLEDGE VAULT  //  RECORD • TRANSCRIBE • ORGANIZE • RETRIEVE"
	heading.add_theme_font_size_override("font_size", 22)
	heading.add_theme_color_override("font_color", colors.cyan)
	page.add_child(heading)
	knowledge_inner_tabs = TabContainer.new()
	knowledge_inner_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(knowledge_inner_tabs)
	var capture_page := VBoxContainer.new()
	capture_page.name = "Capture & Queue"
	knowledge_inner_tabs.add_child(capture_page)
	var explanation := Label.new()
	explanation.text = "Capture audio from a phone, television, movie, tutorial, or conversation. Audio is split into 10-second chunks and transcribed continuously so you can verify it live."
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	capture_page.add_child(explanation)
	var device_row := HBoxContainer.new()
	capture_page.add_child(device_row)
	var source_label := Label.new()
	source_label.text = "RECORD:"
	device_row.add_child(source_label)
	knowledge_source_selector = OptionButton.new()
	knowledge_source_selector.add_item("Microphone")
	knowledge_source_selector.add_item("PC output (loopback input)")
	knowledge_source_selector.add_item("Microphone + PC output (mixed input)")
	var saved_mode := str(settings.get("knowledge_source_mode", "Microphone"))
	for mode_index in range(knowledge_source_selector.item_count):
		if knowledge_source_selector.get_item_text(mode_index) == saved_mode:
			knowledge_source_selector.select(mode_index)
	knowledge_source_selector.item_selected.connect(_on_knowledge_source_selected)
	device_row.add_child(knowledge_source_selector)
	var device_label := Label.new()
	device_label.text = "INPUT DEVICE:"
	device_row.add_child(device_label)
	knowledge_device_selector = OptionButton.new()
	knowledge_device_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	knowledge_device_selector.item_selected.connect(_on_knowledge_device_selected)
	device_row.add_child(knowledge_device_selector)
	device_row.add_child(make_button("↻ DEVICES", refresh_knowledge_audio_devices, colors.cyan))
	knowledge_device_hint = Label.new()
	knowledge_device_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	knowledge_device_hint.add_theme_color_override("font_color", colors.amber)
	capture_page.add_child(knowledge_device_hint)
	var meter_row := HBoxContainer.new()
	capture_page.add_child(meter_row)
	var meter_label := Label.new()
	meter_label.text = "LIVE INPUT LEVEL"
	meter_row.add_child(meter_label)
	knowledge_level_meter = ProgressBar.new()
	knowledge_level_meter.min_value = -60.0
	knowledge_level_meter.max_value = 0.0
	knowledge_level_meter.value = -60.0
	knowledge_level_meter.show_percentage = false
	knowledge_level_meter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	meter_row.add_child(knowledge_level_meter)
	refresh_knowledge_audio_devices()
	knowledge_device_selector.disabled = saved_mode.begins_with("PC output")
	update_knowledge_source_hint()
	var controls := HBoxContainer.new()
	capture_page.add_child(controls)
	knowledge_record_button = make_button("● START KNOWLEDGE RECORDING", toggle_knowledge_recording, colors.red)
	controls.add_child(knowledge_record_button)
	var refresh := make_button("↻ REFRESH LIBRARY", refresh_knowledge_report, colors.cyan)
	controls.add_child(refresh)
	knowledge_status = Label.new()
	knowledge_status.text = "READY • recordings stay private on this computer"
	knowledge_status.add_theme_color_override("font_color", colors.muted)
	knowledge_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	capture_page.add_child(knowledge_status)
	var live_title := Label.new()
	live_title.text = "LIVE TRANSCRIPT"
	live_title.add_theme_color_override("font_color", colors.cyan)
	capture_page.add_child(live_title)
	knowledge_live_transcript = RichTextLabel.new()
	knowledge_live_transcript.bbcode_enabled = true
	knowledge_live_transcript.selection_enabled = true
	knowledge_live_transcript.custom_minimum_size.y = 120
	knowledge_live_transcript.text = "Waiting for the first 10-second audio segment…"
	capture_page.add_child(knowledge_live_transcript)
	knowledge_live_transcript.size_flags_vertical = Control.SIZE_EXPAND_FILL
	knowledge_live_transcript.meta_clicked.connect(_on_knowledge_library_meta_clicked)
	_vault_install_pager(capture_page, "transcripts", knowledge_live_transcript)
	var guidance := RichTextLabel.new()
	guidance.bbcode_enabled = true
	guidance.fit_content = true
	guidance.append_text("[color=#8292ad]BACKGROUND PIPELINE[/color]\n1. Record audio locally\n2. Reject silent chunks\n3. Transcribe with Whisper\n4. Detect likely source/category\n5. Extract observed notes and keywords\n6. Retrieve matching notes only when a chat needs them\n\n[color=#f9c74f]Knowledge captured from media is marked unverified. SAM will preserve the recording/session source instead of treating everything it hears as fact.[/color]")
	capture_page.add_child(guidance)
	var library_page := VBoxContainer.new()
	library_page.name = "Live Study"
	knowledge_inner_tabs.add_child(library_page)
	var study_heading := Label.new()
	study_heading.text = "MEOW MEOW'S LIVE STUDY DESK  //  CAPTURE • REVIEW • CONNECT • RETAIN"
	study_heading.add_theme_font_size_override("font_size", 18)
	study_heading.add_theme_color_override("font_color", colors.cyan)
	library_page.add_child(study_heading)
	var study_note := Label.new()
	study_note.text = "Local review checks topic cues, reusable detail and duplicates; it does not verify facts. Review Later is capped at 100: older uncertain notes get one final background pass, then low-value fragments are archived outside chat retrieval. Only retained notes enter chat retrieval."
	study_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	study_note.add_theme_color_override("font_color", colors.muted)
	library_page.add_child(study_note)
	# Animated study desk: incoming file -> Meow Meow's desk -> retained/review/trash.
	# Worker results can finish instantly, but when this tab is visible we hold the
	# result long enough for the user to actually see what the local reviewer did.
	study_stage = Control.new()
	study_stage.custom_minimum_size = Vector2(0, 142)
	study_stage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	library_page.add_child(study_stage)
	var study_stage_back := Panel.new()
	study_stage_back.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	study_stage_back.mouse_filter = Control.MOUSE_FILTER_IGNORE
	study_stage.add_child(study_stage_back)
	study_inbox_icon = _study_stage_label("📥\nINBOX", colors.amber, 18)
	study_stage.add_child(study_inbox_icon)
	study_desk_icon = _study_stage_label("📖\nREADING DESK", colors.cyan, 16)
	study_stage.add_child(study_desk_icon)
	study_retain_icon = _study_stage_label("📚\nRETAIN", colors.green, 16)
	study_stage.add_child(study_retain_icon)
	study_review_icon = _study_stage_label("🗂\nREVIEW", colors.pink, 16)
	study_stage.add_child(study_review_icon)
	study_archive_icon = _study_stage_label("🗑\nARCHIVE", colors.muted, 16)
	study_stage.add_child(study_archive_icon)
	study_cat = _study_stage_label("🐈", colors.cyan, 27)
	study_stage.add_child(study_cat)
	study_paper = _study_stage_label("📄", Color.WHITE, 21)
	study_stage.add_child(study_paper)
	study_working_title = Label.new()
	study_working_title.text = "Meow Meow is ready for the next file"
	study_working_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	study_working_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	study_working_title.add_theme_color_override("font_color", colors.muted)
	study_working_title.position = Vector2(165, 104)
	study_working_title.size = Vector2(900, 34)
	study_stage.add_child(study_working_title)
	var study_flow := HBoxContainer.new()
	study_flow.custom_minimum_size.y = 84
	study_flow.add_theme_constant_override("separation", 8)
	library_page.add_child(study_flow)
	study_queue_count = add_study_basket(study_flow, "📥 INCOMING QUEUE", "0 waiting", colors.amber)
	study_relevant_count = add_study_basket(study_flow, "📚 RETAINED", "0 retained", colors.green)
	study_discard_count = add_study_basket(study_flow, "🗂 REVIEW / ARCHIVE", "0 review later • 0 archived", colors.pink)
	study_activity = RichTextLabel.new()
	study_activity.bbcode_enabled = true
	study_activity.custom_minimum_size.y = 82
	study_activity.scroll_active = true
	study_activity.append_text("[color=#8292ad]Latest 120 decisions appear here. Each note keeps its review reason.[/color]")
	library_page.add_child(study_activity)
	study_pending_archive_panel = PanelContainer.new()
	study_pending_archive_panel.visible = false
	library_page.add_child(study_pending_archive_panel)
	var archive_box := VBoxContainer.new()
	archive_box.add_theme_constant_override("separation", 6)
	study_pending_archive_panel.add_child(archive_box)
	study_pending_archive_text = RichTextLabel.new()
	study_pending_archive_text.bbcode_enabled = true
	study_pending_archive_text.fit_content = true
	study_pending_archive_text.custom_minimum_size.y = 58
	archive_box.add_child(study_pending_archive_text)
	study_pending_archive_countdown = Label.new()
	study_pending_archive_countdown.add_theme_color_override("font_color", colors.amber)
	archive_box.add_child(study_pending_archive_countdown)
	var archive_actions := HBoxContainer.new()
	archive_actions.add_theme_constant_override("separation", 8)
	archive_box.add_child(archive_actions)
	archive_actions.add_child(make_button("✓ CONFIRM ARCHIVE", _study_confirm_pending_archive, colors.cyan))
	archive_actions.add_child(make_button("📌 KEEP + RETAIN", _study_keep_pending_archive, colors.green))
	archive_actions.add_child(make_button("✕ FORGET PERMANENTLY…", _study_forget_pending_archive, colors.red))
	archive_actions.add_child(make_button("↶ UNDO LAST ARCHIVE", _study_undo_last_archive, colors.amber))
	var filters := HBoxContainer.new()
	library_page.add_child(filters)
	knowledge_search = LineEdit.new()
	knowledge_search.placeholder_text = "Search transcripts, summaries, and extracted notes"
	knowledge_search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	knowledge_search.text_changed.connect(func(_value: String): _vault_filter_changed())
	filters.add_child(knowledge_search)
	knowledge_category = OptionButton.new()
	for category_name in ["All"] + VaultWorker.CATEGORIES:
		knowledge_category.add_item(category_name)
	knowledge_category.item_selected.connect(func(_index: int): _vault_filter_changed())
	filters.add_child(knowledge_category)
	filters.add_child(make_button("✦ RECENT 5", show_recent_learning_summary, colors.amber))
	filters.add_child(make_button("＋ PASTE KNOWLEDGE", show_paste_knowledge_dialog, colors.cyan))
	filters.add_child(make_button("＋ IMPORT GODOT PROJECT", choose_godot_project_folder, colors.green))
	knowledge_report = RichTextLabel.new()
	knowledge_report.bbcode_enabled = true
	knowledge_report.selection_enabled = true
	knowledge_report.size_flags_vertical = Control.SIZE_EXPAND_FILL
	knowledge_report.meta_clicked.connect(_on_knowledge_library_meta_clicked)
	library_page.add_child(knowledge_report)
	_vault_install_pager(library_page, "notes", knowledge_report)
	var review_controls := HBoxContainer.new()
	library_page.add_child(review_controls)
	library_page.move_child(review_controls, knowledge_report.get_index() - 1)
	vault_status_filter = OptionButton.new()
	for status_name in ["Retained", "Needs review", "Pending", "Archived low-value", "All saved"]:
		vault_status_filter.add_item(status_name)
	vault_status_filter.item_selected.connect(func(_index: int): _vault_filter_changed())
	review_controls.add_child(vault_status_filter)
	vault_pause_button = make_button("PAUSE STUDY", _vault_toggle_pause, colors.amber)
	review_controls.add_child(vault_pause_button)
	review_controls.add_child(make_button("RECHECK SAVED NOTES", _vault_request_recheck, colors.cyan))
	var pin_help := Label.new()
	pin_help.text = "PIN + RETAIN = keep this note available to chat even if the local relevance heuristic would reject it. It does not verify that the note is true."
	pin_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pin_help.add_theme_color_override("font_color", colors.muted)
	library_page.add_child(pin_help)
	library_page.move_child(pin_help, knowledge_report.get_index())
	var for_you_page := VBoxContainer.new()
	for_you_page.name = "✦ For You"
	for_you_page.add_theme_constant_override("separation", 8)
	knowledge_inner_tabs.add_child(for_you_page)
	var for_you_heading := Label.new()
	for_you_heading.text = "✦ DISCOVERIES SAM THINKS YOU MAY FIND INTERESTING"
	for_you_heading.add_theme_font_size_override("font_size", 20)
	for_you_heading.add_theme_color_override("font_color", colors.amber)
	for_you_page.add_child(for_you_heading)
	var for_you_note := Label.new()
	for_you_note.text = "Selected locally from MemoryCore and your recurring interests. Captured media remains an unverified observation."
	for_you_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for_you_note.add_theme_color_override("font_color", colors.muted)
	for_you_page.add_child(for_you_note)
	knowledge_for_you_report = RichTextLabel.new()
	knowledge_for_you_report.bbcode_enabled = true
	knowledge_for_you_report.selection_enabled = true
	knowledge_for_you_report.size_flags_vertical = Control.SIZE_EXPAND_FILL
	knowledge_for_you_report.meta_clicked.connect(_on_knowledge_library_meta_clicked)
	for_you_page.add_child(knowledge_for_you_report)
	_vault_install_pager(for_you_page, "discoveries", knowledge_for_you_report)
	var storage_page := VBoxContainer.new()
	storage_page.name = "Storage & Backup"
	storage_page.add_theme_constant_override("separation", 10)
	knowledge_inner_tabs.add_child(storage_page)
	var storage_heading := Label.new()
	storage_heading.text = "KNOWLEDGE VAULT + MEMORYCORE STORAGE"
	storage_heading.add_theme_font_size_override("font_size", 20)
	storage_heading.add_theme_color_override("font_color", colors.cyan)
	storage_page.add_child(storage_heading)
	knowledge_storage_path_label = Label.new()
	knowledge_storage_path_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	storage_page.add_child(knowledge_storage_path_label)
	var storage_actions := HBoxContainer.new()
	storage_page.add_child(storage_actions)
	storage_actions.add_child(make_button("📁 CHOOSE VAULT LOCATION", choose_knowledge_storage_location, colors.cyan))
	storage_actions.add_child(make_button("⬇ BACK UP VAULT + MEMORY", choose_knowledge_backup_location, colors.green))
	storage_actions.add_child(make_button("↻ REFRESH STATS", refresh_knowledge_storage_stats, colors.muted))
	vault_maintenance_button = make_button("🧹 RUN SAFE MAINTENANCE", func(): _vault_run_safe_maintenance(true), colors.amber)
	storage_actions.add_child(vault_maintenance_button)
	var maintenance_row := HBoxContainer.new()
	storage_page.add_child(maintenance_row)
	var maintenance_toggle := CheckButton.new()
	maintenance_toggle.text = "DAILY SAFE MAINTENANCE"
	maintenance_toggle.button_pressed = bool(settings.get("vault_auto_maintenance", true))
	maintenance_toggle.toggled.connect(func(enabled: bool): settings.vault_auto_maintenance = enabled; save_json(SETTINGS_FILE, settings))
	maintenance_row.add_child(maintenance_toggle)
	var maintenance_help := Label.new()
	maintenance_help.text = "Rebuilds indexes, archives exact duplicate low-value notes, and enforces the 100-item Review Later cap. It never automatically deletes retained/pinned/verified notes."
	maintenance_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	maintenance_help.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	maintenance_help.add_theme_color_override("font_color", colors.muted)
	maintenance_row.add_child(maintenance_help)
	var limit_row := HBoxContainer.new()
	storage_page.add_child(limit_row)
	var limit_label := Label.new()
	limit_label.text = "DISK LIMIT (GB)"
	limit_row.add_child(limit_label)
	knowledge_limit_field = SpinBox.new()
	knowledge_limit_field.min_value = 0.25
	knowledge_limit_field.max_value = 10000.0
	knowledge_limit_field.step = 0.25
	knowledge_limit_field.value = float(settings.get("knowledge_limit_gb", 10.0))
	knowledge_limit_field.value_changed.connect(func(value: float): settings.knowledge_limit_gb = value; save_json(SETTINGS_FILE, settings); refresh_knowledge_storage_stats())
	limit_row.add_child(knowledge_limit_field)
	knowledge_compress_toggle = CheckButton.new()
	knowledge_compress_toggle.text = "LOSSLESS FLAC COMPRESSION"
	knowledge_compress_toggle.button_pressed = bool(settings.get("knowledge_compress_audio", true))
	knowledge_compress_toggle.toggled.connect(func(enabled: bool): settings.knowledge_compress_audio = enabled; save_json(SETTINGS_FILE, settings))
	limit_row.add_child(knowledge_compress_toggle)
	knowledge_keep_audio_toggle = CheckButton.new()
	knowledge_keep_audio_toggle.text = "KEEP SOURCE AUDIO AFTER TRANSCRIPTION"
	knowledge_keep_audio_toggle.button_pressed = bool(settings.get("knowledge_keep_audio", false))
	knowledge_keep_audio_toggle.toggled.connect(func(enabled: bool): settings.knowledge_keep_audio = enabled; save_json(SETTINGS_FILE, settings))
	limit_row.add_child(knowledge_keep_audio_toggle)
	knowledge_storage_stats = RichTextLabel.new()
	knowledge_storage_stats.bbcode_enabled = true
	knowledge_storage_stats.selection_enabled = true
	knowledge_storage_stats.size_flags_vertical = Control.SIZE_EXPAND_FILL
	storage_page.add_child(knowledge_storage_stats)
	refresh_knowledge_report()
	refresh_knowledge_discoveries()
	refresh_knowledge_storage_stats()

	_knowledge_stop_orphan_capture_on_startup()
	_vault_start_job("load", {"path": ProjectSettings.globalize_path(knowledge_index_file())})


func show_paste_knowledge_dialog() -> void:
	var dialog := Window.new()
	dialog.title = "Paste Knowledge into KnowledgeVault"
	dialog.transient = true
	dialog.exclusive = true
	dialog.unresizable = false
	dialog.min_size = Vector2i(680, 480)
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dialog.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)
	var heading := Label.new()
	heading.text = "PASTE A GUIDE, ARTICLE, AI RESPONSE, SCRIPT, OR REFERENCE"
	heading.add_theme_font_size_override("font_size", 20)
	heading.add_theme_color_override("font_color", colors.cyan)
	column.add_child(heading)
	var explanation := Label.new()
	explanation.text = "SAM will preserve the full text, divide it into searchable overlapping chunks, and retrieve only relevant passages during later chats. This adds reference knowledge; it does not retrain the underlying model weights."
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explanation.add_theme_color_override("font_color", colors.muted)
	column.add_child(explanation)
	var title_field := LineEdit.new()
	title_field.placeholder_text = "Source/title, for example: Godot 4 Guideline Tetris Guide"
	column.add_child(title_field)
	var paste_box := TextEdit.new()
	paste_box.placeholder_text = "Paste the complete material here…"
	paste_box.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	paste_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	paste_box.custom_minimum_size.y = 300
	column.add_child(paste_box)
	var counter := Label.new()
	counter.text = "0 characters • nothing is sent to the internet"
	counter.add_theme_color_override("font_color", colors.muted)
	column.add_child(counter)
	paste_box.text_changed.connect(func(): counter.text = "%d characters • stored locally" % paste_box.text.length())
	var actions := HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	column.add_child(actions)
	var cancel := make_button("CANCEL", func(): dialog.queue_free(), colors.muted)
	actions.add_child(cancel)
	var import_button := make_button("LEARN FROM PASTED TEXT", func():
		var pasted := paste_box.text.strip_edges()
		if pasted.length() < 20:
			show_toast("Paste at least a short paragraph before importing")
			return
		var source_title := title_field.text.strip_edges()
		if source_title.is_empty():
			source_title = "Pasted reference"
		import_pasted_knowledge(source_title, pasted)
		dialog.queue_free(), colors.green)
	actions.add_child(import_button)
	dialog.close_requested.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	dialog.popup_centered(Vector2i(900, 680))
	title_field.grab_focus()

func import_pasted_knowledge(source_title: String, full_text: String) -> void:
	if vault_loading or vault_write_blocked or shutdown_started:
		show_toast("Knowledge Vault is loading or needs index repair • try again when ready")
		return
	var cleaned := full_text.replace("\r\n", "\n").replace("\r", "\n").strip_edges()
	var import_stamp := Time.get_datetime_string_from_system().replace(":", "-")
	var import_session := "paste-" + import_stamp
	var chunks := semantic_chunk_text(cleaned)
	var imported_count := 0
	var duplicate_count := 0
	for index in range(chunks.size()):
		var chunk_text := chunks[index]
		var entry := {
			"id": "%s-%05d" % [import_session, index + 1],
			"session": import_session,
			"chunk": index + 1,
			"created": Time.get_datetime_string_from_system(),
			"category": "Document",
			"confidence": "user-imported reference; not independently verified",
			"source_mode": "Pasted text",
			"input_device": "None",
			"source_path": "",
			"source_name": source_title,
			"summary": knowledge_summary(chunk_text),
			"notes": [],
			"transcript": chunk_text,
			"audio_path": ""
		}
		_vault_prepare_incoming(entry)
		if knowledge_entry_is_duplicate(entry):
			duplicate_count += 1
			continue
		_vault_add_entry(entry)
		imported_count += 1
	save_json(knowledge_index_file(), knowledge_entries)
	refresh_knowledge_report()
	refresh_knowledge_discoveries()
	refresh_knowledge_storage_stats()
	if is_instance_valid(knowledge_search):
		knowledge_search.text = source_title
	show_toast("Knowledge imported • %d new chunks%s" % [imported_count, " • %d duplicates skipped" % duplicate_count if duplicate_count > 0 else ""])
	log_line("KNOWLEDGE", "Imported pasted reference: %s (%d characters / %d chunks)" % [source_title, cleaned.length(), chunks.size()])


func refresh_knowledge_audio_devices() -> void:
	if not is_instance_valid(knowledge_device_selector):
		return
	var saved_device := str(settings.get("audio_input_device", "Default"))
	knowledge_device_selector.clear()
	var devices := AudioServer.get_input_device_list()
	if not devices.has("Default"):
		knowledge_device_selector.add_item("Default")
	for device in devices:
		knowledge_device_selector.add_item(str(device))
	var selected := 0
	for index in range(knowledge_device_selector.item_count):
		if knowledge_device_selector.get_item_text(index) == saved_device:
			selected = index
			break
	knowledge_device_selector.select(selected)
	# Refreshing the dropdown itself never writes a new device choice. If the mic is
	# enabled and idle, safely re-apply the saved endpoint by stopping the monitor
	# first; this makes REFRESH DEVICES a useful recovery action without WASAPI hot-swap.
	if not bool(settings.get("microphone_muted", false)) and not live_voice_enabled and not recording_voice and not knowledge_recording and voice_capture_pid <= 0:
		call_deferred("_restore_saved_audio_input_after_unmute")
	update_knowledge_source_hint()

func _on_knowledge_device_selected(index: int) -> void:
	if not is_instance_valid(knowledge_device_selector) or index < 0:
		return
	var device := knowledge_device_selector.get_item_text(index)
	if live_voice_enabled or recording_voice or knowledge_recording or voice_capture_pid > 0:
		show_toast("Stop active microphone capture before changing the Windows input device")
		refresh_knowledge_audio_devices()
		return
	# Preserve the user's explicit choice for the native Windows capture helper even
	# if Godot's WASAPI monitor temporarily falls back to Default.
	settings.audio_input_device = device
	save_json(SETTINGS_FILE, settings)
	if is_instance_valid(microphone_player):
		microphone_player.stop()
		microphone_player.stream = null
	await get_tree().process_frame
	await get_tree().process_frame
	AudioServer.input_device = device
	await get_tree().create_timer(0.15).timeout
	var active_device := AudioServer.input_device
	if is_instance_valid(microphone_player):
		microphone_player.stream = AudioStreamMicrophone.new()
		microphone_player.bus = "Record"
		if not bool(settings.get("microphone_muted", false)):
			microphone_player.play()
	if active_device != device:
		show_toast("Godot monitor fell back to %s • native voice capture will still request %s" % [active_device, device])
		log_line("VOICE", "WASAPI monitor fallback: requested %s • active %s; saved preference preserved" % [device, active_device])
	else:
		if not bool(settings.get("microphone_muted", true)):
			show_toast("Audio input ready • " + device)
	update_knowledge_source_hint()

func _on_knowledge_source_selected(index: int) -> void:
	settings.knowledge_source_mode = knowledge_source_selector.get_item_text(index)
	save_json(SETTINGS_FILE, settings)
	knowledge_device_selector.disabled = str(settings.knowledge_source_mode).begins_with("PC output") or knowledge_recording
	update_knowledge_source_hint()

func update_knowledge_source_hint() -> void:
	if not is_instance_valid(knowledge_device_hint):
		return
	var mode := str(settings.get("knowledge_source_mode", "Microphone"))
	var device := str(settings.get("audio_input_device", "Default"))
	if mode == "Microphone":
		knowledge_device_hint.text = "Selected: %s • Speak and confirm the level meter moves before recording." % device
	elif mode.begins_with("PC output"):
		knowledge_device_hint.text = "AUTO LOOPBACK • SAM captures the active Windows default speaker output directly. The microphone selector is not used in this mode. Start playback and confirm SIGNAL DETECTED appears."
	else:
		knowledge_device_hint.text = "Selected: %s • 'Both' requires Windows or virtual-cable software to expose one mixed microphone + system-audio input." % device

func update_knowledge_audio_level() -> void:
	if not is_instance_valid(knowledge_level_meter):
		return
	var record_bus := AudioServer.get_bus_index("Record")
	if record_bus < 0:
		knowledge_level_meter.value = -60.0
		return
	var level_db := maxf(AudioServer.get_bus_peak_volume_left_db(record_bus, 0), AudioServer.get_bus_peak_volume_right_db(record_bus, 0))
	knowledge_level_meter.value = clampf(level_db, -60.0, 0.0)

func toggle_knowledge_recording() -> void:
	if knowledge_recording:
		knowledge_recording = false
		refresh_microphone_privacy_indicator()
		request_external_capture_stop()
		knowledge_source_selector.disabled = false
		knowledge_device_selector.disabled = str(settings.get("knowledge_source_mode", "Microphone")).begins_with("PC output")
		knowledge_record_button.text = "● START KNOWLEDGE RECORDING"
		knowledge_record_button.add_theme_color_override("font_color", colors.red)
		set_microphone_available(true)
		update_knowledge_status()
		return
	if vault_loading or vault_write_blocked or not vault_stats_ready:
		show_toast("Wait for Knowledge Vault and its storage check to finish loading")
		return
	if bool(settings.get("microphone_muted", false)) and str(settings.get("knowledge_source_mode", "Microphone")) != "PC output (loopback input)":
		show_toast("Microphone is muted • select PC output or unmute the microphone")
		return
	if recording_voice or live_voice_enabled:
		show_toast("Stop push-to-talk / Live Voice before starting Knowledge Recording")
		return
	if knowledge_limit_reached():
		show_toast("Knowledge Vault disk limit reached • raise the limit or free space")
		return
	if record_effect == null:
		show_toast("Microphone recording is not available")
		return
	knowledge_session_id = Time.get_datetime_string_from_system().replace(":", "-")
	knowledge_chunk_number = 0
	knowledge_elapsed = 0.0
	knowledge_chunk_elapsed = 0.0
	knowledge_capture_level_db = -60.0
	knowledge_capture_source = ""
	knowledge_signal_seen = false
	knowledge_silence_elapsed = 0.0
	_knowledge_prioritize_live_capture()
	if not start_external_knowledge_capture():
		show_toast("Windows audio capture could not start • open Debug Telemetry")
		return
	knowledge_recording = true
	refresh_microphone_privacy_indicator()
	knowledge_source_selector.disabled = true
	knowledge_device_selector.disabled = true
	knowledge_record_button.text = "■ STOP + SAVE RECORDING"
	knowledge_record_button.add_theme_color_override("font_color", colors.green)
	set_microphone_available(false)
	update_knowledge_status()
	show_toast("Knowledge recording started • audio remains local")


func recover_unprocessed_knowledge_audio() -> void:
	discover_unprocessed_knowledge_audio()

func discover_unprocessed_knowledge_audio() -> void:
	if vault_loading or vault_cache_dirty or vault_cache_cursor >= 0 or shutdown_started:
		return
	var now := Time.get_ticks_msec()
	if now < vault_audio_scan_due or vault_jobs.has("audio_scan") or vault_audio_cursor < vault_audio_paths.size():
		return
	var capacity := KNOWLEDGE_QUEUE_LIMIT - knowledge_queue.size()
	if capacity <= 0:
		return
	vault_audio_scan_due = now + 1000
	# Keep orphan recovery bounded. The worker scans off-thread, excludes files
	# already represented by the current index/queue, and returns one small batch.
	_vault_start_job("audio_scan", {
		"path": ProjectSettings.globalize_path(knowledge_storage_dir()),
		"known": vault_known_audio.keys(),
		"limit": mini(KNOWLEDGE_ORPHAN_RECOVERY_BATCH, capacity)
	})


func _knowledge_stop_orphan_capture_on_startup() -> void:
	# Editor Stop/crashes do not always run the normal close path. The shared stop
	# marker makes a capture helper left by a previous run exit before a new one
	# can be launched. start_external_knowledge_capture() removes this marker.
	var vault_path := ProjectSettings.globalize_path(knowledge_storage_dir())
	DirAccess.make_dir_recursive_absolute(vault_path)
	knowledge_capture_status_path = vault_path.path_join("capture_status.json")
	knowledge_capture_stop_path = vault_path.path_join("capture.stop")
	var stop_file := FileAccess.open(knowledge_capture_stop_path, FileAccess.WRITE)
	if stop_file:
		stop_file.store_string("stop")
		stop_file.close()


func _knowledge_prioritize_live_capture() -> void:
	# A stale recovery backlog must never sit in front of a recording the user just
	# started. Put those files back into discovery; the bounded scanner will pick
	# them up later after current-session chunks are handled.
	for queued_value in knowledge_queue:
		if queued_value is Dictionary:
			var queued_path := str((queued_value as Dictionary).get("audio", ""))
			if not queued_path.is_empty():
				vault_known_audio.erase(queued_path)
	knowledge_queue.clear()
	vault_audio_paths.clear()
	vault_audio_cursor = 0
	vault_audio_scan_due = 0
	vault_audio_backlog_count = 0


func start_external_knowledge_capture() -> bool:
	var helper := ProjectSettings.globalize_path("res://tools/sam_audio_capture.py")
	if not FileAccess.file_exists(helper) or not FileAccess.file_exists(str(settings.voice_python_path)):
		log_line("KNOWLEDGE ERROR", "Windows capture helper or configured Python runtime is missing")
		return false
	vault_seen_capture_chunks = -1
	vault_capture_poll_due = 0
	var vault_path := ProjectSettings.globalize_path(knowledge_storage_dir())
	knowledge_capture_status_path = vault_path.path_join("capture_status.json")
	knowledge_capture_stop_path = vault_path.path_join("capture.stop")
	for stale_path in [knowledge_capture_status_path, knowledge_capture_stop_path]:
		if FileAccess.file_exists(stale_path):
			DirAccess.remove_absolute(stale_path)
	# Retained originals use WAV so Godot can play them directly in For You.
	# Transcript-only capture may use lossless FLAC because the source is temporary.
	var audio_format := "wav" if bool(settings.get("knowledge_keep_audio", false)) else ("flac" if bool(settings.get("knowledge_compress_audio", true)) else "wav")
	var arguments := PackedStringArray([helper, "--mode", str(settings.get("knowledge_source_mode", "Microphone")), "--device", str(settings.get("audio_input_device", "Default")), "--output-dir", vault_path, "--session", knowledge_session_id.validate_filename(), "--status", knowledge_capture_status_path, "--stop-file", knowledge_capture_stop_path, "--chunk-seconds", str(KNOWLEDGE_CHUNK_SECONDS), "--format", audio_format])
	knowledge_capture_pid = OS.create_process(str(settings.voice_python_path), arguments, false)
	if knowledge_capture_pid <= 0:
		log_line("KNOWLEDGE ERROR", "Could not launch the Windows audio capture helper")
		return false
	log_line("KNOWLEDGE", "Started native Windows capture PID %d" % knowledge_capture_pid)
	return true


func request_external_capture_stop() -> void:
	if knowledge_capture_pid <= 0:
		return
	var stop_file := FileAccess.open(knowledge_capture_stop_path, FileAccess.WRITE)
	if stop_file:
		stop_file.store_string("stop")
		stop_file.close()
	if is_instance_valid(knowledge_status):
		knowledge_status.text = "STOPPING • saving the final audio chunk…"

func poll_external_knowledge_capture() -> void:
	if knowledge_capture_pid <= 0:
		return
	var now := Time.get_ticks_msec()
	if now < vault_capture_poll_due:
		return
	vault_capture_poll_due = now + 100
	if FileAccess.file_exists(knowledge_capture_status_path):
		var status_text := FileAccess.get_file_as_string(knowledge_capture_status_path).strip_edges()
		# The native recorder updates this file frequently. On Windows we can land
		# between truncate and write; ignore that partial frame without invoking
		# JSON.parse_string(), which prints a noisy engine error for expected races.
		if status_text.begins_with("{") and status_text.ends_with("}"):
			var parser := JSON.new()
			var parse_error := parser.parse(status_text)
			var status = parser.data if parse_error == OK else null
			if status is Dictionary:
				knowledge_capture_level_db = clampf(float(status.get("level_db", -60.0)), -60.0, 0.0)
				knowledge_capture_source = str(status.get("source", ""))
				if is_instance_valid(knowledge_level_meter):
					knowledge_level_meter.value = knowledge_capture_level_db
				if is_instance_valid(knowledge_device_hint) and not str(status.get("source", "")).is_empty():
					var signal_text := "SIGNAL DETECTED" if knowledge_capture_level_db > -48.0 else ("NO SIGNAL" if knowledge_silence_elapsed >= 4.0 else "checking signal")
					knowledge_device_hint.text = "CAPTURING: %s • %s • %.1f dB" % [knowledge_capture_source, signal_text, knowledge_capture_level_db]
				if int(status.get("chunks", 0)) > vault_seen_capture_chunks:
					vault_seen_capture_chunks = int(status.get("chunks", 0))
					discover_unprocessed_knowledge_audio()
	if not OS.is_process_running(knowledge_capture_pid):
		var stopped_unexpectedly := knowledge_recording
		knowledge_capture_pid = -1
		knowledge_recording = false
		discover_unprocessed_knowledge_audio()
		if is_instance_valid(knowledge_source_selector):
			knowledge_source_selector.disabled = false
		if is_instance_valid(knowledge_device_selector):
			knowledge_device_selector.disabled = str(settings.get("knowledge_source_mode", "Microphone")).begins_with("PC output")
		if is_instance_valid(knowledge_record_button):
			knowledge_record_button.text = "● START KNOWLEDGE RECORDING"
			knowledge_record_button.add_theme_color_override("font_color", colors.red)
		refresh_microphone_privacy_indicator()
		update_knowledge_source_hint()
		update_knowledge_status()
		if stopped_unexpectedly and not shutdown_started:
			show_toast("Knowledge capture helper stopped unexpectedly • recording state reset safely")
			log_line("KNOWLEDGE ERROR", "Capture helper exited while recording; SAM reset the recording state instead of continuing a phantom session")


func capture_knowledge_chunk(final_chunk: bool) -> void:
	if record_effect == null:
		return
	record_effect.set_recording_active(false)
	var recording := record_effect.get_recording()
	knowledge_chunk_elapsed = 0.0
	if knowledge_recording and not final_chunk:
		record_effect.set_recording_active(true)
	if recording == null or recording.get_length() < 0.5 or not recording_has_speech(recording):
		if final_chunk:
			show_toast("Recording stopped • final silent segment was skipped")
		return
	knowledge_chunk_number += 1
	var stem := "%s/chunk_%s_%04d" % [knowledge_storage_dir(), knowledge_session_id.validate_filename(), knowledge_chunk_number]
	var global_stem := ProjectSettings.globalize_path(stem)
	if recording.save_to_wav(global_stem) != OK:
		log_line("KNOWLEDGE ERROR", "Could not save recording chunk")
		return
	vault_known_audio[global_stem + ".wav"] = true
	knowledge_queue.append({"audio": global_stem + ".wav", "session": knowledge_session_id, "chunk": knowledge_chunk_number})
	log_line("KNOWLEDGE", "Queued recording chunk %d for transcription" % knowledge_chunk_number)
	update_knowledge_status()

func start_next_knowledge_transcription() -> void:
	if knowledge_queue.is_empty() or shutdown_started:
		return
	var job: Dictionary = knowledge_queue.pop_front()
	var output_path := str(job.audio).get_basename() + ".txt"
	var prefix := output_path.get_basename()
	var arguments := PackedStringArray(["-m", str(settings.whisper_model_path), "-f", str(job.audio), "-otxt", "-of", prefix, "-nt", "-np", "-l", "en", "-sns", "-nth", "0.45", "-et", "2.0", "-lpt", "-0.7", "--prompt", "Clear conversational English speech. Transcribe only words actually spoken by a person."])
	knowledge_active_job = job
	knowledge_active_output = output_path
	knowledge_process_pid = OS.create_process(str(settings.whisper_exe_path), arguments, false)
	if knowledge_process_pid <= 0:
		knowledge_queue.push_front(job)
		log_line("KNOWLEDGE ERROR", "Could not start Whisper for the queued recording")
	update_knowledge_status()

func _knowledge_transcription_finished(job: Dictionary, output_path: String, exit_code: int, detail: String) -> void:
	if exit_code != 0 or not FileAccess.file_exists(output_path):
		log_line("KNOWLEDGE ERROR", "Transcription failed: " + detail.right(500))
		update_knowledge_status()
		return
	var transcript := sanitize_transcript(FileAccess.get_file_as_string(output_path))
	var discard_audio := not bool(settings.get("knowledge_keep_audio", false))
	var paths: Array[String] = [output_path]
	if discard_audio:
		paths.append(str(job.audio))
	vault_known_audio[str(job.audio)] = true
	if transcript.is_empty():
		vault_cleanup.append({"revision": vault_revision, "paths": paths})
		knowledge_silent_skip_count += 1
		var silence_now := Time.get_ticks_msec()
		if knowledge_last_silence_log_ms == 0 or silence_now - knowledge_last_silence_log_ms >= KNOWLEDGE_SILENCE_LOG_INTERVAL_MS or knowledge_silent_skip_count >= 25:
			log_line("KNOWLEDGE", "Skipped %d silent/hallucinated audio chunk%s (summary)" % [knowledge_silent_skip_count, "" if knowledge_silent_skip_count == 1 else "s"])
			knowledge_silent_skip_count = 0
			knowledge_last_silence_log_ms = silence_now
		return
	var entry := build_knowledge_entry(job, transcript)
	if knowledge_entry_is_duplicate(entry):
		vault_cleanup.append({"revision": vault_revision, "paths": paths})
		log_line("KNOWLEDGE", "Exact duplicate skipped; existing note retained")
		return
	entry.capture_audio_source = str(job.audio)
	if discard_audio:
		entry.audio_path = ""
	_vault_add_entry(entry)
	_vault_mark_changed()
	vault_cleanup.append({"revision": vault_revision, "paths": paths})
	_vault_invalidate_view("transcripts")
	log_line("KNOWLEDGE", "Captured %d characters; queued for review and durable save" % transcript.length())
	update_knowledge_status()


func semantic_chunk_text(source_text: String) -> Array[String]:
	# Keep headings, paragraphs, lists, and code blocks together. This is deliberately
	# lexical and local: no model call, embedding server, or background process.
	var normalized := source_text.replace("\r\n", "\n").replace("\r", "\n").strip_edges()
	var units: Array[String] = []
	var paragraph := ""
	var in_code := false
	for raw_line in normalized.split("\n", true):
		var line := str(raw_line)
		if line.strip_edges().begins_with("```"):
			in_code = not in_code
		if line.strip_edges().is_empty() and not in_code:
			if not paragraph.strip_edges().is_empty():
				units.append(paragraph.strip_edges())
			paragraph = ""
		else:
			paragraph += ("\n" if not paragraph.is_empty() else "") + line
	if not paragraph.strip_edges().is_empty():
		units.append(paragraph.strip_edges())
	var chunks: Array[String] = []
	var current := ""
	for unit in units:
		var pending := unit
		while pending.length() > 3800:
			var cut := pending.rfind(". ", 3800)
			if cut < 1200:
				cut = pending.rfind("\n", 3800)
			if cut < 1200:
				cut = 3800
			var piece := pending.left(cut + (2 if pending.substr(cut, 2) == ". " else 0)).strip_edges()
			if not current.is_empty():
				chunks.append(current)
				current = ""
			chunks.append(piece)
			pending = pending.substr(piece.length()).strip_edges()
		if current.length() > 0 and current.length() + pending.length() + 2 > 3000:
			chunks.append(current)
			current = ""
		current += ("\n\n" if not current.is_empty() else "") + pending
	if not current.strip_edges().is_empty():
		chunks.append(current.strip_edges())
	return chunks

func knowledge_summary(text_value: String) -> String:
	var useful: Array[String] = []
	for sentence_value in text_value.replace("?", ".").replace("!", ".").split(".", false):
		var sentence := str(sentence_value).strip_edges()
		if sentence.length() >= 30 and not contains_any(sentence.to_lower(), ["subscribe", "commercial break"]):
			useful.append(sentence.left(260))
		if useful.size() >= 3:
			break
	return (". ".join(useful) if not useful.is_empty() else text_value.left(600)).left(850)

func knowledge_stop_words() -> Array[String]:
	return ["this", "that", "with", "from", "have", "your", "what", "when", "where", "which", "there", "their", "about", "would", "could", "should", "into", "just", "they", "them", "then", "than", "been", "were", "will", "also", "some", "more", "like", "does", "dont", "the", "and", "for", "are", "was", "you", "its", "not", "but", "can", "how", "who", "user", "assistant", "system", "memory", "sam", "using", "want", "need", "make", "please", "really", "going", "okay", "hello"]

func detect_speaker_info(text_value: String) -> Dictionary:
	return VaultWorker.detect_speaker_info(text_value)



func enrich_knowledge_entry(entry: Dictionary) -> void:
	VaultWorker.enrich_knowledge_entry(entry)


func knowledge_entry_is_duplicate(candidate: Dictionary) -> bool:
	var fingerprint := str(candidate.get("fingerprint", ""))
	if fingerprint.is_empty():
		return false
	var existing_id := str(vault_fingerprints.get(fingerprint, ""))
	return not existing_id.is_empty() and existing_id != str(candidate.get("id", "")) and not find_knowledge_entry(existing_id).is_empty()


func build_knowledge_entry(job: Dictionary, transcript: String) -> Dictionary:
	var category := "Unknown"
	var sentences := transcript.replace("?", ".").replace("!", ".").split(".", false)
	var useful: Array[String] = []
	for sentence_value in sentences:
		var sentence := str(sentence_value).strip_edges()
		if sentence.length() >= 35 and not sentence.to_lower().contains("subscribe") and not sentence.to_lower().contains("commercial break"):
			useful.append(sentence.left(280))
		if useful.size() >= 5:
			break
	var summary := " ".join(useful).left(900)
	if summary.is_empty():
		summary = transcript.left(500)
	var entry := {"id": "%s-%04d" % [str(job.session), int(job.chunk)], "session": str(job.session), "chunk": int(job.chunk), "created": Time.get_datetime_string_from_system(), "category": category, "confidence": "unverified observation", "source_mode": str(settings.get("knowledge_source_mode", "Microphone")), "input_device": str(settings.get("audio_input_device", "Default")), "summary": summary, "notes": useful, "transcript": transcript, "audio_path": str(job.audio)}
	_vault_prepare_incoming(entry)
	return entry

func classify_knowledge(text: String) -> String:
	return str(VaultWorker.evidence(text).category)


func contains_any(text: String, needles: Array) -> bool:
	for needle in needles:
		if text.contains(str(needle)):
			return true
	return false

func update_knowledge_status() -> void:
	if not is_instance_valid(knowledge_status):
		return
	var state := "RECORDING • %02d:%02d • current chunk %ds / %ds" % [int(knowledge_elapsed) / 60, int(knowledge_elapsed) % 60, int(knowledge_chunk_elapsed), int(KNOWLEDGE_CHUNK_SECONDS)] if knowledge_recording else "READY"
	var working := knowledge_process_pid > 0 and OS.is_process_running(knowledge_process_pid)
	var processing_note := "live transcription working" if working else ("waiting for next segment" if knowledge_recording else "transcription idle")
	var signal_note := ""
	if knowledge_recording:
		if knowledge_capture_level_db > -48.0:
			signal_note = " • SIGNAL DETECTED %.1f dB" % knowledge_capture_level_db
		elif knowledge_silence_elapsed >= 4.0:
			signal_note = " • NO AUDIO SIGNAL — check Windows output and playback"
		else:
			signal_note = " • checking audio signal…"
	var backlog_note := ""
	if vault_audio_backlog_count > knowledge_queue.size():
		backlog_note = " • %d old audio files waiting in bounded recovery" % vault_audio_backlog_count
	knowledge_status.text = "%s%s • %d/%d transcribe queue%s • %s • %d saved entries" % [state, signal_note, knowledge_queue.size(), KNOWLEDGE_QUEUE_LIMIT, backlog_note, processing_note, knowledge_entries.size()]
	if not vault_save_error.is_empty():
		knowledge_status.text += " • SAVE ERROR (originals kept)"
	elif vault_revision > vault_saved_revision:
		knowledge_status.text += " • saving…"
	knowledge_status.add_theme_color_override("font_color", colors.green if knowledge_capture_level_db > -48.0 and knowledge_recording else (colors.red if knowledge_recording else colors.muted))


func refresh_knowledge_report() -> void:
	_vault_invalidate_view("notes")


func _on_knowledge_library_meta_clicked(meta: Variant) -> void:
	var action := str(meta)
	var entry_id := action.substr(action.find(":") + 1).uri_decode()
	if action.begins_with("discovery_"):
		_on_knowledge_discovery_meta_clicked(action)
		return
	var entry := find_knowledge_entry(entry_id)
	if entry.is_empty():
		show_toast("That entry is no longer available")
		return
	if action.begins_with("knowledge_open:"):
		_vault_open_entry(entry_id)
		return
	if action.begins_with("knowledge_pin:"):
		entry.pinned = not bool(entry.get("pinned", false))
		study_decide_entry(entry, false)
		_vault_mark_changed()
		show_toast("Pin updated • original transcript retained")
		return
	if action.begins_with("knowledge_verify:"):
		var dialog := ConfirmationDialog.new()
		dialog.title = "Mark this note as verified by you?"
		dialog.dialog_text = "Confirm only after checking the source. Automatic study has not verified this statement."
		dialog.confirmed.connect(func():
			var current := find_knowledge_entry(entry_id)
			if not current.is_empty():
				current.user_verified = true
				current.confidence = "verified by user; not independently verified by SAM"
				study_decide_entry(current, false)
				_vault_mark_changed()
			dialog.queue_free())
		dialog.canceled.connect(dialog.queue_free)
		add_child(dialog)
		dialog.popup_centered()
		return
	if action.begins_with("knowledge_forget:"):
		confirm_forget_knowledge(entry_id, str(entry.get("summary", "")))


func confirm_forget_knowledge(entry_id: String, summary: String) -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "Forget this knowledge?"
	dialog.dialog_text = "This removes only this KnowledgeVault entry. It does not delete unrelated memories.\n\n%s" % summary.left(500)
	dialog.ok_button_text = "FORGET ENTRY"
	dialog.confirmed.connect(func():
		for index in range(knowledge_entries.size() - 1, -1, -1):
			if str((knowledge_entries[index] as Dictionary).get("id", "")) == entry_id:
				knowledge_entries.remove_at(index)
				break
		save_json(knowledge_index_file(), knowledge_entries)
		refresh_knowledge_report()
		refresh_knowledge_discoveries()
		refresh_knowledge_storage_stats()
		show_toast("Knowledge entry forgotten")
		dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	dialog.popup_centered(Vector2i(650, 300))

func knowledge_interest_terms() -> Array[String]:
	# The worker refreshes this bounded cache; never reread MemoryCore per note.
	return vault_interest_cache.duplicate()


func evaluate_knowledge_interest(entry: Dictionary) -> void:
	VaultWorker.apply_interest(entry, vault_interest_cache)


func refresh_knowledge_discoveries() -> void:
	_vault_invalidate_view("discoveries")


func find_knowledge_entry(entry_id: String) -> Dictionary:
	var index := int(vault_index.get(entry_id, -1))
	if index >= 0 and index < knowledge_entries.size() and knowledge_entries[index] is Dictionary:
		var entry: Dictionary = knowledge_entries[index]
		if str(entry.get("id", "")) == entry_id:
			return entry
	# Imports/deletions can invalidate offsets until the next bounded cache pass.
	for value in knowledge_entries:
		if value is Dictionary and str(value.get("id", "")) == entry_id:
			return value
	return {}


func _on_knowledge_discovery_meta_clicked(meta: Variant) -> void:
	var action := str(meta)
	var entry_id := action.substr(action.find(":") + 1).uri_decode()
	var entry := find_knowledge_entry(entry_id)
	if entry.is_empty():
		show_toast("That discovery is no longer available")
		return
	if action.begins_with("discovery_speak:"):
		speak_text(str(entry.get("transcript", "")))
		return
	if action.begins_with("discovery_audio:"):
		play_knowledge_original(entry)
		return
	if action.begins_with("discovery_more:"):
		learn_discovery_preferences(str(entry.get("transcript", "")))
		entry.user_interest_feedback = "more"
		save_json(knowledge_index_file(), knowledge_entries)
		show_toast("Preference learned locally • SAM will favor similar discoveries")
		refresh_knowledge_discoveries()
		return
	if action.begins_with("discovery_hide:"):
		entry.for_you = false
		entry.unread_discovery = false
		entry.user_interest_feedback = "not_for_me"
		save_json(knowledge_index_file(), knowledge_entries)
		show_toast("Removed from For You")
		refresh_knowledge_discoveries()


func learn_discovery_preferences(text_value: String) -> void:
	var cleaned := text_value.to_lower()
	for punctuation in [".", ",", "!", "?", ":", ";", "(", ")", "[", "]", "{", "}", "\"", "'", "\n", "\r", "-", "/"]:
		cleaned = cleaned.replace(punctuation, " ")
	var ignored := ["this", "that", "with", "from", "have", "your", "what", "when", "where", "which", "there", "their", "about", "would", "could", "should", "into", "just", "they", "them", "then", "than", "been", "were", "will", "want", "also", "some", "more", "like", "need", "make", "does", "dont"]
	var counts: Dictionary = {}
	for raw_word in cleaned.split(" ", false):
		var word := str(raw_word).strip_edges()
		if word.length() < 4 or ignored.has(word) or word.is_valid_int() or word.is_valid_float():
			continue
		counts[word] = int(counts.get(word, 0)) + 1
	var ranked: Array = counts.keys()
	ranked.sort_custom(func(a: Variant, b: Variant): return int(counts[a]) > int(counts[b]))
	var learned: Array = settings.get("discovery_interest_terms", []).duplicate()
	for index in range(mini(8, ranked.size())):
		var term := str(ranked[index])
		if not learned.has(term):
			learned.append(term)
	while learned.size() > 100:
		learned.pop_front()
	settings.discovery_interest_terms = learned
	vault_profile_due = 0
	save_json(SETTINGS_FILE, settings)


func play_knowledge_original(entry: Dictionary) -> void:
	var audio_path := str(entry.get("audio_path", ""))
	if audio_path.is_empty() or not FileAccess.file_exists(audio_path):
		show_toast("Original audio was not retained • use SAM Talks instead")
		return
	if audio_path.get_extension().to_lower() != "wav":
		show_toast("Saved original is compressed FLAC • use SAM Talks for playback")
		return
	var audio := AudioStreamWAV.load_from_file(audio_path)
	if audio == null:
		show_toast("Could not open the saved original audio")
		return
	stop_voice()
	voice_player.stream = audio
	voice_player.play()
	set_voice_status("VOICE • PLAYING SAVED ORIGINAL", colors.green)

func open_knowledge_discoveries() -> void:
	var knowledge_page := knowledge_inner_tabs.get_parent() if is_instance_valid(knowledge_inner_tabs) else null
	if knowledge_page == null:
		return
	$Page/Tabs.current_tab = $Page/Tabs.get_tab_idx_from_control(knowledge_page)
	knowledge_inner_tabs.current_tab = knowledge_inner_tabs.get_tab_idx_from_control(knowledge_for_you_report.get_parent() as Control)
	var changed := false
	for entry_value in knowledge_entries:
		if entry_value is Dictionary and bool(entry_value.get("unread_discovery", false)):
			entry_value.unread_discovery = false
			changed = true
	if changed:
		save_json(knowledge_index_file(), knowledge_entries)
	refresh_knowledge_discoveries()

func refresh_knowledge_discovery_indicator() -> void:
	if not is_instance_valid(knowledge_discovery_button):
		return
	var unread := mini(25, vault_unread_count)
	if int(knowledge_discovery_button.get_meta("vault_unread", -1)) == unread:
		return
	knowledge_discovery_button.set_meta("vault_unread", unread)
	if is_instance_valid(knowledge_discovery_tween):
		knowledge_discovery_tween.kill()
	knowledge_discovery_button.modulate = Color.WHITE
	if unread <= 0:
		knowledge_discovery_button.text = "✦ DISCOVERIES"
		knowledge_discovery_button.add_theme_color_override("font_color", colors.muted)
		knowledge_discovery_button.tooltip_text = "No unread KnowledgeVault discoveries"
		return
	knowledge_discovery_button.text = "✦ NEW • READ NOW (%d)" % unread
	knowledge_discovery_button.add_theme_color_override("font_color", colors.amber)
	knowledge_discovery_button.tooltip_text = "%d new locally selected KnowledgeVault discoveries" % unread
	knowledge_discovery_tween = create_tween().set_loops()
	knowledge_discovery_tween.tween_property(knowledge_discovery_button, "modulate:a", 0.42, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	knowledge_discovery_tween.tween_property(knowledge_discovery_button, "modulate:a", 1.0, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func retrieve_explicit_memory(full_memory: String, query: String, limit: int) -> String:
	var learned_heading := "### LEARNED FACTS & MEMORY:"
	var learned_at := full_memory.find(learned_heading)
	if learned_at < 0:
		return ""
	var learned_text := full_memory.substr(learned_at + learned_heading.length())
	var next_heading := learned_text.find("\n### ")
	if next_heading >= 0:
		learned_text = learned_text.left(next_heading)
	var normalized_query := query.to_lower()
	for punctuation in ["`", "\"", "'", "(", ")", "[", "]", "{", "}", ":", ";", ",", ".", "!", "?", "\n", "\r", "\t", "/", "\\", "-"]:
		normalized_query = normalized_query.replace(punctuation, " ")
	var ignored := ["what", "when", "where", "which", "whose", "about", "tell", "please", "could", "would", "does", "whois", "update", "memory", "did", "you", "your", "that", "this", "get", "got", "info", "information", "from", "know", "source", "the", "and", "for", "with", "into", "are", "was"]
	var terms: Array[String] = []
	for raw_term in normalized_query.split(" ", false):
		var term := str(raw_term).strip_edges()
		if term.length() >= 3 and not ignored.has(term) and not terms.has(term):
			terms.append(term)
	var scored: Array[Dictionary] = []
	for raw_line in learned_text.split("\n", false):
		var fact := str(raw_line).strip_edges()
		if not fact.begins_with("- "):
			continue
		var lower_fact := normalize_retrieval_text(fact)
		var padded_fact := " " + lower_fact + " "
		var score := 0
		var matched_terms := 0
		for term in terms:
			if padded_fact.contains(" " + term + " "):
				score += 4
				matched_terms += 1
		if terms.size() >= 2 and padded_fact.contains(" " + " ".join(terms) + " "):
			score += 16
		var required_matches := mini(2, terms.size())
		if matched_terms >= required_matches and score > 0:
			scored.append({"score": score, "fact": fact})
	scored.sort_custom(func(a: Dictionary, b: Dictionary): return int(a.score) > int(b.score))
	var selected: Array[String] = []
	for index in range(mini(limit, scored.size())):
		selected.append(str(scored[index].fact))
	return "\n".join(selected)

func _rag_query_terms(query: String) -> Array[String]:
	var normalized := normalize_retrieval_text(query)
	var terms: Array[String] = []
	var ignored := knowledge_stop_words()
	for raw_term in normalized.split(" ", false):
		var term := str(raw_term).strip_edges()
		if term.length() >= 3 and not ignored.has(term) and not terms.has(term):
			terms.append(term)
	return terms

func _rag_query_phrases(terms: Array[String]) -> Array[String]:
	var phrases: Array[String] = []
	for size in [3, 2]:
		if terms.size() < size:
			continue
		for index in range(0, terms.size() - size + 1):
			var phrase := " ".join(terms.slice(index, index + size))
			if phrase.length() >= 7 and not phrases.has(phrase):
				phrases.append(phrase)
	return phrases

func retrieve_knowledge(query: String, limit: int) -> String:
	if not bool(settings.get("rag_enabled", true)) or query.strip_edges().is_empty() or knowledge_entries.is_empty():
		return ""

	var terms := _rag_query_terms(query)
	if terms.is_empty():
		return ""
	var phrases := _rag_query_phrases(terms)
	var requested_limit := clampi(mini(limit, int(settings.get("rag_top_k", 5))), 1, 12)
	var context_budget := clampi(int(settings.get("rag_context_chars", 5600)), 1200, 16000)
	var use_diversity := bool(settings.get("rag_diversity", true))

	# Stage 1: cheap inverted-index candidate recall. If there is no exact index
	# hit, use the compatibility scan for fresh imports and partial-word matches.
	var candidate_entries: Array = []
	var candidate_ids: Dictionary = {}
	if not vault_cache_dirty and vault_cache_cursor < 0 and not vault_term_index.is_empty():
		for term in terms:
			var indexed_ids: Array = vault_term_index.get(term, [])
			for indexed_id in indexed_ids:
				candidate_ids[str(indexed_id)] = true
	if not candidate_ids.is_empty():
		for candidate_id in candidate_ids.keys():
			var candidate := find_knowledge_entry(str(candidate_id))
			if not candidate.is_empty():
				candidate_entries.append(candidate)
	else:
		candidate_entries = knowledge_entries

	# Stage 2: hybrid lexical/entity/metadata scoring. SAM already owns the data
	# and retrieval pipeline, so this stays local instead of requiring LangChain
	# or a separate vector database just to answer from KnowledgeVault.
	var scored: Array[Dictionary] = []
	for entry_value in candidate_entries:
		if not (entry_value is Dictionary):
			continue
		var entry: Dictionary = entry_value
		if str(entry.get("study_status", "pending")) != "relevant":
			continue
		if str(entry.get("user_interest_feedback", "")) == "not_for_me":
			continue

		var category := str(entry.get("category", "Unknown"))
		var source_name := str(entry.get("source_name", "captured media"))
		var godot_metadata := (" godot " + str(entry.get("godot_version", ""))) if category.begins_with("Godot") else ""
		var haystack := str(entry.get("search_text", ""))
		if haystack.is_empty():
			haystack = normalize_retrieval_text(str(entry.get("summary", "")) + " " + str(entry.get("transcript", "")) + " " + category + " " + source_name + godot_metadata)
		var padded := " " + haystack + " "
		var score := 0.0
		var matched_terms := 0
		var entry_keywords: Array = entry.get("keywords", [])
		var entry_entities: Array = entry.get("entities", [])

		for term in terms:
			var term_hit := false
			if padded.contains(" " + term + " "):
				score += 5.0
				term_hit = true
			elif term.length() >= 5 and haystack.contains(term):
				score += 1.5
				term_hit = true
			if entry_keywords.has(term):
				score += 3.5
				term_hit = true
			for entity_value in entry_entities:
				if normalize_retrieval_text(str(entity_value)).contains(term):
					score += 4.5
					term_hit = true
					break
			if term_hit:
				matched_terms += 1

		for phrase in phrases:
			if padded.contains(" " + phrase + " "):
				score += 8.0 if phrase.count(" ") == 1 else 12.0

		var coverage := float(matched_terms) / float(maxi(terms.size(), 1))
		score += coverage * 8.0
		if matched_terms > 0:
			score += clampf(float(int(entry.get("quality_score", 5)) - 5), -3.0, 4.0)
			if bool(entry.get("user_verified", false)):
				score += 7.0
			if bool(entry.get("pinned", false)):
				score += 8.0
			if str(entry.get("confidence", "")).contains("user-"):
				score += 2.0
			if bool(entry.get("for_you", false)):
				score += 1.0

		var required_matches := 1 if terms.size() <= 2 else 2
		if matched_terms >= required_matches and score >= 7.0:
			scored.append({
				"score": score,
				"coverage": coverage,
				"entry": entry,
				"session": str(entry.get("session", "")),
				"category": category,
				"source": source_name
			})

	scored.sort_custom(func(a: Dictionary, b: Dictionary):
		return float(a.score) > float(b.score))

	# Stage 3: lightweight MMR-style diversity. The score still wins, but repeated
	# chunks from one session/category receive a small penalty so useful variety
	# can enter the prompt.
	var selected: Array[Dictionary] = []
	var used_fingerprints: Dictionary = {}
	var used_session_counts: Dictionary = {}
	for candidate in scored:
		if selected.size() >= requested_limit:
			break
		var entry: Dictionary = candidate.entry
		var fingerprint := str(entry.get("fingerprint", ""))
		if not fingerprint.is_empty() and used_fingerprints.has(fingerprint):
			continue
		var session := str(candidate.session)
		var adjusted := float(candidate.score)
		if use_diversity:
			adjusted -= float(int(used_session_counts.get(session, 0))) * 3.0
			for picked in selected:
				if str(picked.get("category", "")) == str(candidate.category):
					adjusted -= 0.75
		if adjusted < 6.0:
			continue
		var copy := candidate.duplicate(true)
		copy.adjusted_score = adjusted
		selected.append(copy)
		if not fingerprint.is_empty():
			used_fingerprints[fingerprint] = true
		used_session_counts[session] = int(used_session_counts.get(session, 0)) + 1

	selected.sort_custom(func(a: Dictionary, b: Dictionary):
		return float(a.adjusted_score) > float(b.adjusted_score))

	# Stage 4: bounded source packet. This is the augmentation step of RAG.
	var result_lines: Array[String] = []
	var used_chars := 0
	for picked in selected:
		if result_lines.size() >= requested_limit or used_chars >= context_budget:
			break
		var entry: Dictionary = picked.entry
		var transcript := str(entry.get("transcript", ""))
		var excerpt_start := 0
		var lower_transcript := transcript.to_lower()
		for term in terms:
			var pos := lower_transcript.find(term)
			if pos >= 0:
				excerpt_start = maxi(0, pos - 180)
				break
		var excerpt_limit := mini(900, maxi(260, context_budget - used_chars - 240))
		var excerpt := transcript.substr(excerpt_start, excerpt_limit).strip_edges()
		if excerpt_start > 0:
			excerpt = "…" + excerpt
		if excerpt_start + excerpt_limit < transcript.length():
			excerpt += "…"

		var time_note := ""
		if entry.has("start_seconds"):
			var seconds := int(entry.get("start_seconds", 0))
			time_note = " • at %02d:%02d" % [seconds / 60, seconds % 60]
		var source_note := str(entry.get("source_name", "captured media"))
		var source_urls: Array = entry.get("source_urls", [])
		if not source_urls.is_empty():
			source_note += " • " + str(source_urls[0])
		var line := "- [RAG %.1f • %s • %s • captured %s%s • session %s / chunk %d • confidence: %s] %s" % [
			float(picked.adjusted_score),
			str(entry.get("category", "Unknown")),
			source_note,
			str(entry.get("created", "unknown time")),
			time_note,
			str(entry.get("session", "")),
			int(entry.get("chunk", 0)),
			str(entry.get("confidence", "unverified observation")),
			excerpt
		]
		if used_chars + line.length() > context_budget and not result_lines.is_empty():
			break
		result_lines.append(line)
		used_chars += line.length() + 1

	log_line("RAG", "terms %d • candidates %d • scored %d • selected %d • context %d/%d chars" % [
		terms.size(), candidate_entries.size(), scored.size(), result_lines.size(), used_chars, context_budget
	])
	return "\n".join(result_lines).strip_edges()

func normalize_retrieval_text(value: String) -> String:
	var normalized := value.to_lower()
	for punctuation in ["`", "\"", "'", "(", ")", "[", "]", "{", "}", ":", ";", ",", ".", "!", "?", "\n", "\r", "\t", "/", "\\", "-", "_", "“", "”"]:
		normalized = normalized.replace(punctuation, " ")
	while normalized.contains("  "):
		normalized = normalized.replace("  ", " ")
	return normalized.strip_edges()

func setup_security_center() -> void:
	var tabs: TabContainer = $Page/Tabs
	var outer := VBoxContainer.new()
	outer.name = "Security Center"
	tabs.add_child(outer)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	outer.add_child(scroll)
	var page := VBoxContainer.new()
	page.name = "Security Center"
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 10)
	scroll.add_child(page)
	var header := HBoxContainer.new()
	page.add_child(header)
	var title := Label.new()
	title.text = "SAM NETWORK GUARD  //  FIREWALL • CONNECTIONS • RUNNING APPS"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 21)
	title.add_theme_color_override("font_color", colors.cyan)
	header.add_child(title)
	header.add_child(make_button("↻ REFRESH LIVE VIEW", refresh_security_snapshot, colors.green))
	header.add_child(make_button("✓ VERIFY ALL SIGNATURES", func(): refresh_security_snapshot(true), colors.cyan))
	header.add_child(make_button("🛡 RUN READ-ONLY AUDIT", run_security_audit, colors.green))
	header.add_child(make_button("OPEN WINDOWS SECURITY", func(): OS.shell_open("windowsdefender:"), colors.cyan))
	header.add_child(make_button("⧉ COPY REPORT", copy_security_report, colors.muted))
	var guidance := Label.new()
	guidance.text = "Connection alerts appear immediately after Windows reports a new listener or remote connection. Without a kernel driver SAM cannot pause the first packet; REMEMBER ALLOW or BLOCK creates future Windows Firewall rules. Unfamiliar does not automatically mean malicious."
	guidance.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guidance.add_theme_color_override("font_color", colors.amber)
	page.add_child(guidance)
	var guard_row := HBoxContainer.new()
	page.add_child(guard_row)
	security_guard_label = Label.new()
	security_guard_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	security_guard_label.add_theme_font_size_override("font_size", 18)
	guard_row.add_child(security_guard_label)
	network_guard_button = make_button("ENABLE NETWORK GUARD", toggle_network_guard, colors.green)
	guard_row.add_child(network_guard_button)
	guard_row.add_child(make_button("⛔ STOP INTERNET (EMERGENCY)", request_emergency_lockdown, colors.red))
	guard_row.add_child(make_button("RESTORE INTERNET", request_restore_network, colors.green))
	guard_row.add_child(make_button("WINDOWS FIREWALL RULES", func(): OS.shell_open("wf.msc"), colors.cyan))
	refresh_network_guard_ui()
	var live_title := Label.new()
	live_title.text = "LIVE TCP CONNECTIONS + LISTENERS"
	live_title.add_theme_color_override("font_color", colors.cyan)
	page.add_child(live_title)
	security_connection_tree = Tree.new()
	security_connection_tree.custom_minimum_size.y = 230
	security_connection_tree.columns = 6
	security_connection_tree.column_titles_visible = true
	for column in range(6):
		security_connection_tree.set_column_title(column, ["APP", "PID", "STATE", "LOCAL", "REMOTE", "DIRECTION"][column])
	security_connection_tree.hide_root = true
	security_connection_tree.column_title_clicked.connect(sort_security_connections)
	security_connection_tree.item_mouse_selected.connect(_on_security_connection_mouse_selected)
	page.add_child(security_connection_tree)
	var apps_title := Label.new()
	apps_title.text = "RUNNING APPLICATIONS  //  SELECT AN APP FOR SAFE ACTIONS"
	apps_title.add_theme_color_override("font_color", colors.green)
	page.add_child(apps_title)
	security_process_tree = Tree.new()
	security_process_tree.custom_minimum_size.y = 280
	security_process_tree.columns = 5
	security_process_tree.column_titles_visible = true
	for column in range(5):
		security_process_tree.set_column_title(column, ["APP", "PID", "MEMORY", "PUBLISHER / RATING", "PATH"][column])
	security_process_tree.hide_root = true
	security_process_tree.item_selected.connect(select_security_process)
	security_process_tree.item_activated.connect(show_selected_process_details)
	security_process_tree.item_mouse_selected.connect(_on_security_process_mouse_selected)
	security_process_tree.column_title_clicked.connect(sort_security_processes)
	page.add_child(security_process_tree)
	var app_actions := HBoxContainer.new()
	page.add_child(app_actions)
	app_actions.add_child(make_button("✦ ASK SAM WHAT IT IS", explain_selected_process, colors.cyan))
	app_actions.add_child(make_button("🌐 SEARCH ONLINE", search_selected_process, colors.cyan))
	app_actions.add_child(make_button("BLOCK NETWORK", func(): request_process_firewall_change(true), colors.amber))
	app_actions.add_child(make_button("UNBLOCK", func(): request_process_firewall_change(false), colors.green))
	app_actions.add_child(make_button("END TASK", func(): request_end_selected_process(false), colors.amber))
	app_actions.add_child(make_button("FORCE END", func(): request_end_selected_process(true), colors.red))
	var persistence_title := Label.new()
	persistence_title.text = "WINDOWS STARTUP APPS  //  COMMON PERSISTENCE LOCATIONS"
	persistence_title.add_theme_color_override("font_color", colors.amber)
	page.add_child(persistence_title)
	security_startup_tree = Tree.new()
	security_startup_tree.custom_minimum_size.y = 220
	security_startup_tree.columns = 4
	security_startup_tree.column_titles_visible = true
	for column in range(4):
		security_startup_tree.set_column_title(column, ["NAME", "COMMAND", "LOCATION", "USER"][column])
	security_startup_tree.hide_root = true
	page.add_child(security_startup_tree)
	var services_title := Label.new()
	services_title.text = "WINDOWS SERVICES  //  BACKGROUND + AUTO-START COMPONENTS"
	services_title.add_theme_color_override("font_color", colors.amber)
	page.add_child(services_title)
	security_services_tree = Tree.new()
	security_services_tree.custom_minimum_size.y = 260
	security_services_tree.columns = 6
	security_services_tree.column_titles_visible = true
	for column in range(6):
		security_services_tree.set_column_title(column, ["SERVICE", "DISPLAY NAME", "STATE", "START", "ACCOUNT", "PATH"][column])
	security_services_tree.hide_root = true
	page.add_child(security_services_tree)
	var rules_title := Label.new()
	rules_title.text = "FIREWALL RULES  //  RIGHT-CLICK SAM RULES TO ENABLE, DISABLE, OR REMOVE"
	rules_title.add_theme_color_override("font_color", colors.cyan)
	page.add_child(rules_title)
	security_rules_tree = Tree.new()
	security_rules_tree.custom_minimum_size.y = 300
	security_rules_tree.columns = 7
	security_rules_tree.column_titles_visible = true
	for column in range(7):
		security_rules_tree.set_column_title(column, ["RULE", "DIRECTION", "ACTION", "ENABLED", "PROFILE", "PROGRAM", "OWNER"][column])
	security_rules_tree.hide_root = true
	security_rules_tree.item_selected.connect(select_security_rule)
	security_rules_tree.item_mouse_selected.connect(_on_security_rule_mouse_selected)
	page.add_child(security_rules_tree)
	security_report = RichTextLabel.new()
	security_report.bbcode_enabled = true
	security_report.selection_enabled = true
	security_report.custom_minimum_size.y = 300
	security_report.append_text("[font_size=20][color=#76f7a6]READY FOR A LOCAL SECURITY AUDIT[/color][/font_size]\n\n")
	security_report.append_text("The report checks Defender, firewall profiles, listening ports, established connections, startup programs, non-Microsoft scheduled tasks, recent failed Windows sign-ins, and installed hotfixes.\n\n")
	security_report.append_text("[color=#8292ad]Workspace Tools must be enabled. Administrative access is not used; sections Windows protects may be reported as unavailable.[/color]")
	page.add_child(security_report)
	var footer := HBoxContainer.new()
	page.add_child(footer)
	footer.add_child(make_button("✦ ASK SAM TO EXPLAIN REPORT", ask_sam_about_security_report, colors.cyan))
	footer.add_child(make_button("📂 OPEN REPORT FOLDER", open_security_report_folder, colors.muted))
	apply_theme_recursive(page)
	setup_security_context_menu()
	refresh_security_snapshot.call_deferred()

func refresh_network_guard_ui() -> void:
	if not is_instance_valid(security_guard_label):
		return
	var enabled := bool(settings.get("network_guard_enabled", false))
	var guard_mode := "KERNEL INTERCEPT" if security_wfp_driver_state == "Running" else "STANDARD OBSERVER"
	security_guard_label.text = ("⛔ EMERGENCY LOCKDOWN • INTERNET BLOCKED" if security_lockdown_active else ("● ACTIVE • %s • %d SAM rules" % [guard_mode, security_blocked_rules])) if enabled else "○ OFF • Windows Firewall remains under Windows control"
	security_guard_label.add_theme_color_override("font_color", colors.red if security_lockdown_active else (colors.green if enabled else colors.muted))
	if is_instance_valid(network_guard_button):
		network_guard_button.text = "DISABLE NETWORK GUARD" if enabled else "ENABLE NETWORK GUARD"
	refresh_network_guard_header()

func toggle_network_guard() -> void:
	settings.network_guard_enabled = not bool(settings.get("network_guard_enabled", false))
	save_json(SETTINGS_FILE, settings)
	refresh_network_guard_ui()
	show_toast("SAM Network Guard enabled • click its header badge any time" if bool(settings.network_guard_enabled) else "SAM Network Guard display disabled • Windows Firewall settings were not changed")

func refresh_security_snapshot(verify_signatures := false) -> void:
	if OS.get_name() != "Windows":
		show_toast("The live security console currently supports Windows")
		return
	if security_snapshot_pid > 0 and OS.is_process_running(security_snapshot_pid):
		return
	var script := ProjectSettings.globalize_path("res://tools/sam_security_snapshot.ps1")
	security_snapshot_output = ProjectSettings.globalize_path("user://security_snapshot.json")
	security_verify_requested = verify_signatures
	var args := PackedStringArray(["-NoLogo", "-NoProfile", "-NonInteractive", "-WindowStyle", "Hidden", "-ExecutionPolicy", "Bypass", "-File", script, "-OutputPath", security_snapshot_output])
	if verify_signatures:
		args.append("-VerifySignatures")
		show_toast("Verifying executable signatures • this deeper check can take a moment")
	security_snapshot_pid = OS.create_process("powershell.exe", args, false)
	if security_snapshot_pid <= 0:
		show_toast("Could not start the local security inventory")

func poll_security_snapshot() -> void:
	if security_snapshot_pid <= 0 or OS.is_process_running(security_snapshot_pid):
		return
	security_snapshot_pid = -1
	if not FileAccess.file_exists(security_snapshot_output):
		return
	var snapshot = JSON.parse_string(FileAccess.get_file_as_string(security_snapshot_output))
	if not snapshot is Dictionary:
		return
	security_blocked_rules = int(snapshot.get("sam_block_rules", 0))
	security_lockdown_active = bool(snapshot.get("lockdown", false))
	security_wfp_driver_state = str(snapshot.get("wfp_driver_state", "Not installed"))
	security_processes = snapshot.get("processes", [])
	security_connections = snapshot.get("connections", [])
	security_startup_items = snapshot.get("startup", [])
	security_services = snapshot.get("services", [])
	security_rules = snapshot.get("rules", [])
	detect_new_security_connections(security_connections)
	populate_security_processes(security_processes)
	populate_security_connections(security_connections)
	populate_security_startup(security_startup_items)
	populate_security_services(security_services)
	populate_security_rules(security_rules)
	refresh_network_guard_ui()
	if bool(snapshot.get("verified", false)):
		show_toast("Publisher and Authenticode signature check complete")

func populate_security_processes(processes: Array) -> void:
	security_process_tree.clear()
	var root := security_process_tree.create_item()
	for value in processes:
		if not value is Dictionary:
			continue
		var item := security_process_tree.create_item(root)
		var name := str(value.get("name", "Unknown"))
		var path := str(value.get("path", ""))
		var publisher := str(value.get("publisher", "Unverified"))
		var signature := str(value.get("signature", "Not checked"))
		var rating := "WINDOWS" if publisher.contains("Microsoft Windows") or path.to_lower().begins_with("c:\\windows\\") else ("SIGNED" if signature == "Valid" else ("KNOWN PUBLISHER" if publisher != "Unverified" and not publisher.is_empty() else "REVIEW"))
		item.set_text(0, name)
		item.set_text(1, str(int(value.get("pid", 0))))
		item.set_text(2, "%.1f MB" % (float(value.get("memory", 0)) / 1048576.0))
		item.set_text(3, "%s • %s • %s" % [publisher, signature, rating])
		item.set_text(4, path if not path.is_empty() else "Protected or unavailable")
		item.set_metadata(0, value)

func populate_security_connections(connections: Array) -> void:
	security_connection_tree.clear()
	var root := security_connection_tree.create_item()
	for value in connections:
		if not value is Dictionary:
			continue
		var item := security_connection_tree.create_item(root)
		for column in range(6):
			item.set_text(column, str(int(value.get("pid", 0))) if column == 1 else str(value.get(["name", "pid", "state", "local", "remote", "direction"][column], "")))
		item.set_metadata(0, value)

func populate_security_startup(items: Array) -> void:
	security_startup_tree.clear()
	var root := security_startup_tree.create_item()
	for value in items:
		if value is Dictionary:
			var item := security_startup_tree.create_item(root)
			for column in range(4):
				item.set_text(column, str(value.get(["name", "command", "location", "user"][column], "")))

func populate_security_services(items: Array) -> void:
	security_services_tree.clear()
	var root := security_services_tree.create_item()
	for value in items:
		if value is Dictionary:
			var item := security_services_tree.create_item(root)
			for column in range(6):
				item.set_text(column, str(value.get(["name", "display", "state", "start_mode", "account", "path"][column], "")))

func populate_security_rules(items: Array) -> void:
	security_rules_tree.clear()
	var root := security_rules_tree.create_item()
	for value in items:
		if value is Dictionary:
			var item := security_rules_tree.create_item(root)
			for column in range(6):
				item.set_text(column, str(value.get(["name", "direction", "action", "enabled", "profile", "program"][column], "")))
			item.set_text(6, "SAM" if bool(value.get("sam_owned", false)) else "WINDOWS / APP")
			item.set_metadata(0, value)

func sort_security_processes(column: int, _button: int) -> void:
	if security_process_sort_column == column:
		security_process_sort_ascending = not security_process_sort_ascending
	else:
		security_process_sort_column = column
		security_process_sort_ascending = true
	var keys := ["name", "pid", "memory", "publisher", "path"]
	var key: String = keys[column]
	security_processes.sort_custom(func(a: Dictionary, b: Dictionary):
		var left = a.get(key, "")
		var right = b.get(key, "")
		var less := float(left) < float(right) if key in ["pid", "memory"] else str(left).naturalnocasecmp_to(str(right)) < 0
		return less if security_process_sort_ascending else not less)
	populate_security_processes(security_processes)

func sort_security_connections(column: int, _button: int) -> void:
	if security_connection_sort_column == column:
		security_connection_sort_ascending = not security_connection_sort_ascending
	else:
		security_connection_sort_column = column
		security_connection_sort_ascending = true
	var keys := ["name", "pid", "state", "local", "remote", "direction"]
	var key: String = keys[column]
	security_connections.sort_custom(func(a: Dictionary, b: Dictionary):
		var less := float(a.get(key, 0)) < float(b.get(key, 0)) if key == "pid" else str(a.get(key, "")).naturalnocasecmp_to(str(b.get(key, ""))) < 0
		return less if security_connection_sort_ascending else not less)
	populate_security_connections(security_connections)

func _on_security_process_mouse_selected(_position: Vector2, button: int) -> void:
	select_security_process()
	if button == MOUSE_BUTTON_RIGHT:
		show_security_context_menu(true)

func _on_security_connection_mouse_selected(_position: Vector2, button: int) -> void:
	var item := security_connection_tree.get_selected()
	if item != null and item.get_metadata(0) is Dictionary:
		var value: Dictionary = item.get_metadata(0)
		security_selected_pid = int(value.get("pid", -1))
		security_selected_name = str(value.get("name", ""))
		security_selected_path = str(value.get("path", ""))
	if button == MOUSE_BUTTON_RIGHT:
		show_security_context_menu(false)

func setup_security_context_menu() -> void:
	security_context_menu = PopupMenu.new()
	security_context_menu.add_item("View details", 1)
	security_context_menu.add_item("Ask SAM what it is", 2)
	security_context_menu.add_item("Search online", 3)
	security_context_menu.add_separator()
	security_context_menu.add_item("Block network", 4)
	security_context_menu.add_item("Unblock / remove SAM rules", 5)
	security_context_menu.add_separator()
	security_context_menu.add_item("Copy name + PID", 6)
	security_context_menu.add_item("Copy executable path", 7)
	security_context_menu.add_item("Open file location", 8)
	security_context_menu.add_separator()
	security_context_menu.add_item("End task", 9)
	security_context_menu.add_item("Force end as administrator", 10)
	security_context_menu.id_pressed.connect(handle_security_context_action)
	add_child(security_context_menu)

func show_security_context_menu(_from_process: bool) -> void:
	if security_selected_pid < 0:
		return
	security_context_menu.position = DisplayServer.mouse_get_position()
	security_context_menu.popup()

func handle_security_context_action(id: int) -> void:
	match id:
		1: show_selected_process_details()
		2: explain_selected_process()
		3: search_selected_process()
		4: request_process_firewall_change(true)
		5: request_process_firewall_change(false)
		6: DisplayServer.clipboard_set("%s • PID %d" % [security_selected_name, security_selected_pid]); show_toast("Process name and PID copied")
		7: DisplayServer.clipboard_set(security_selected_path); show_toast("Executable path copied")
		8:
			if FileAccess.file_exists(security_selected_path): OS.shell_open(security_selected_path.get_base_dir())
			else: show_toast("That executable path is protected or unavailable")
		9: request_end_selected_process(false)
		10: request_end_selected_process(true)

func show_selected_process_details() -> void:
	select_security_process()
	if security_selected_pid < 0:
		return
	var details := AcceptDialog.new()
	details.title = "%s • PID %d" % [security_selected_name, security_selected_pid]
	details.dialog_text = "Executable: %s\n\nUse the buttons below or right-click the table for research, firewall, file-location, copy, and process controls." % (security_selected_path if not security_selected_path.is_empty() else "Protected or unavailable")
	details.add_button("ASK SAM", true, "ask")
	details.add_button("SEARCH ONLINE", true, "search")
	details.add_button("OPEN LOCATION", true, "open")
	details.custom_action.connect(func(action: StringName):
		if action == &"ask": explain_selected_process()
		elif action == &"search": search_selected_process()
		elif action == &"open" and FileAccess.file_exists(security_selected_path): OS.shell_open(security_selected_path.get_base_dir()))
	details.canceled.connect(details.queue_free)
	details.confirmed.connect(details.queue_free)
	add_child(details)
	apply_theme_recursive(details)
	details.popup_centered(Vector2i(760, 380))

func select_security_rule() -> void:
	var item := security_rules_tree.get_selected()
	if item != null and item.get_metadata(0) is Dictionary:
		security_selected_rule = str((item.get_metadata(0) as Dictionary).get("name", ""))

func _on_security_rule_mouse_selected(_position: Vector2, button: int) -> void:
	select_security_rule()
	if button == MOUSE_BUTTON_RIGHT:
		show_rule_context_menu()

func show_rule_context_menu() -> void:
	if security_selected_rule.is_empty(): return
	var menu := PopupMenu.new()
	menu.add_item("Copy rule", 1); menu.add_item("Enable SAM rule", 2); menu.add_item("Disable SAM rule", 3); menu.add_item("Remove SAM rule", 4)
	menu.id_pressed.connect(func(id: int):
		if id == 1: DisplayServer.clipboard_set(security_selected_rule); show_toast("Rule name copied")
		elif id == 2: run_firewall_admin_action("rule_enable", "", "", security_selected_rule)
		elif id == 3: run_firewall_admin_action("rule_disable", "", "", security_selected_rule)
		elif id == 4: run_firewall_admin_action("rule_remove", "", "", security_selected_rule)
		menu.queue_free())
	menu.popup_hide.connect(menu.queue_free)
	add_child(menu); menu.position = DisplayServer.mouse_get_position(); menu.popup()

func detect_new_security_connections(items: Array) -> void:
	var current: Dictionary = {}
	for value in items:
		if not value is Dictionary: continue
		var remote := str(value.get("remote", ""))
		var key := "%s|%s|%s|%s" % [value.get("pid", 0), value.get("state", ""), value.get("local", ""), remote]
		current[key] = true
		if security_alert_baseline_ready and not security_seen_connections.has(key) and is_external_security_connection(value) and security_alert_queue.size() < 8:
			security_alert_queue.append(value)
	security_seen_connections = current
	if not security_alert_baseline_ready:
		security_alert_baseline_ready = true
	elif bool(settings.get("network_guard_enabled", false)):
		show_next_security_alert()

func is_external_security_connection(value: Dictionary) -> bool:
	var remote := str(value.get("remote", ""))
	var local := str(value.get("local", ""))
	if str(value.get("state", "")) == "Listen":
		return not local.begins_with("127.") and not local.begins_with("[::1]")
	return not remote.begins_with("127.") and not remote.begins_with("[::1]") and not remote.begins_with("0.0.0.0")

func show_next_security_alert() -> void:
	if security_alert_dialog_open or security_alert_queue.is_empty() or not bool(settings.get("network_guard_enabled", false)):
		return
	var connection: Dictionary = security_alert_queue.pop_front()
	security_alert_dialog_open = true
	var dialog := AcceptDialog.new()
	dialog.title = "SAM NETWORK GUARD • NEW NETWORK ACTIVITY"
	var is_listener := str(connection.get("state", "")) == "Listen"
	dialog.dialog_text = "%s\n\nApp: %s\nPID: %s\nDirection: %s\nLocal: %s\nRemote: %s\nExecutable: %s\n\nALLOW ONCE dismisses this alert. REMEMBER ALLOW or BLOCK creates inbound and outbound Windows Firewall rules and requests one-time administrator approval." % ["An app opened a non-loopback inbound listener." if is_listener else "An app connected to a remote address.", connection.get("name", "unknown"), connection.get("pid", 0), connection.get("direction", ""), connection.get("local", ""), connection.get("remote", ""), connection.get("path", "Unavailable")]
	dialog.ok_button_text = "ALLOW ONCE"
	dialog.add_button("REMEMBER ALLOW", true, "allow")
	dialog.add_button("BLOCK APP", true, "block")
	dialog.add_button("SEARCH", true, "search")
	dialog.custom_action.connect(func(action: StringName):
		var app_name := str(connection.get("name", "unknown"))
		var app_path := str(connection.get("path", ""))
		if action == &"allow" and FileAccess.file_exists(app_path): run_firewall_admin_action("allow", app_name, app_path)
		elif action == &"block" and FileAccess.file_exists(app_path): run_firewall_admin_action("block", app_name, app_path)
		elif action == &"search": open_web_url("https://www.google.com/search?q=" + app_name.uri_encode() + "+Windows+process", "Research the app behind this network activity")
		dialog.hide())
	dialog.visibility_changed.connect(func():
		if not dialog.visible:
			security_alert_dialog_open = false
			dialog.queue_free()
			show_next_security_alert.call_deferred())
	add_child(dialog); apply_theme_recursive(dialog); style_security_dialog(dialog, colors.amber); dialog.popup_centered(Vector2i(820, 560))

func request_emergency_lockdown() -> void:
	if security_lockdown_active:
		show_toast("Emergency lockdown is already active")
		return
	var dialog := ConfirmationDialog.new()
	dialog.title = "STOP INTERNET WITH EMERGENCY LOCKDOWN?"
	dialog.dialog_text = "This creates two temporary SAM-owned Windows Firewall rules that block all inbound and outbound network traffic. Localhost AI remains available, but browsers, downloads, remote access, cloud sync, and online apps will disconnect.\n\nYour network adapters are NOT disabled. Use RESTORE INTERNET to remove only SAM's emergency rules. Windows UAC will ask for one-time approval."
	dialog.ok_button_text = "STOP INTERNET NOW"
	dialog.confirmed.connect(func(): run_firewall_admin_action("lockdown_on"); dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog); apply_theme_recursive(dialog); style_security_dialog(dialog, colors.red); dialog.popup_centered(Vector2i(780, 470))

func request_restore_network() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "RESTORE INTERNET?"
	dialog.dialog_text = "Remove SAM Network Guard's emergency inbound/outbound block-all rules. App-specific rules and Windows-owned firewall rules are not changed."
	dialog.ok_button_text = "RESTORE INTERNET"
	dialog.confirmed.connect(func(): run_firewall_admin_action("lockdown_off"); dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog); apply_theme_recursive(dialog); style_security_dialog(dialog, colors.green); dialog.popup_centered(Vector2i(700, 360))

func select_security_process() -> void:
	var item := security_process_tree.get_selected()
	if item == null:
		return
	var value = item.get_metadata(0)
	if value is Dictionary:
		security_selected_pid = int(value.get("pid", -1))
		security_selected_name = str(value.get("name", ""))
		security_selected_path = str(value.get("path", ""))

func explain_selected_process() -> void:
	if security_selected_pid <= 0:
		show_toast("Select a running application first")
		return
	$Page/Tabs.current_tab = 0
	input_box.text = "Explain this Windows process cautiously: %s (PID %d), file path: %s. Describe what it normally does, whether the location looks expected, what can be verified locally, and rate it as Known Windows / Known signed app / Needs review / Suspicious evidence. Do not call an app malicious merely because it is unfamiliar." % [security_selected_name, security_selected_pid, security_selected_path]
	input_box.grab_focus()
	show_toast("Process details placed in chat • transmit when ready")

func search_selected_process() -> void:
	if security_selected_name.is_empty():
		show_toast("Select a running application first")
		return
	var query := security_selected_name.uri_encode()
	open_web_url("https://www.google.com/search?q=" + query + "+Windows+process", "Search the web for public information about the selected process")

func request_end_selected_process(force: bool) -> void:
	if security_selected_pid <= 4:
		show_toast("Protected system processes cannot be ended here")
		return
	var dialog := ConfirmationDialog.new()
	dialog.title = "FORCE END PROCESS?" if force else "END PROCESS?"
	dialog.dialog_text = "%s PID %d\n%s\n\nUnsaved work in this application may be lost. Force End does not give the app time to close cleanly and requests one-time Windows administrator approval." % [security_selected_name, security_selected_pid, security_selected_path]
	dialog.ok_button_text = "FORCE END PID %d" % security_selected_pid if force else "END PID %d" % security_selected_pid
	var selected_pid := security_selected_pid
	dialog.confirmed.connect(func():
		if force:
			var command := "Start-Process -FilePath 'taskkill.exe' -Verb RunAs -WindowStyle Hidden -ArgumentList @('/PID','%d','/T','/F')" % selected_pid
			OS.create_process("powershell.exe", PackedStringArray(["-NoLogo", "-NoProfile", "-NonInteractive", "-WindowStyle", "Hidden", "-Command", command]), false)
		else:
			OS.create_process("taskkill.exe", PackedStringArray(["/PID", str(selected_pid), "/T"]), false)
		dialog.queue_free()
		await get_tree().create_timer(0.8).timeout
		refresh_security_snapshot())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, colors.red if force else colors.amber)
	dialog.popup_centered(Vector2i(700, 360))

func request_process_firewall_change(block: bool) -> void:
	if security_selected_path.is_empty() or not FileAccess.file_exists(security_selected_path):
		show_toast("Select an application with a readable executable path")
		return
	var dialog := ConfirmationDialog.new()
	dialog.title = "BLOCK THIS APP'S NETWORK?" if block else "REMOVE SAM BLOCK RULES?"
	dialog.dialog_text = "%s\n%s\n\nThis changes Windows Firewall and will request Windows administrator approval for this one action." % [security_selected_name, security_selected_path]
	dialog.ok_button_text = "BLOCK IN + OUT" if block else "UNBLOCK APP"
	var selected_path := security_selected_path
	var selected_name := security_selected_name
	dialog.confirmed.connect(func():
		run_firewall_admin_action("block" if block else "unblock", selected_name, selected_path)
		dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, colors.red if block else colors.green)
	dialog.popup_centered(Vector2i(760, 390))

func run_firewall_admin_action(action: String, app_name := "", app_path := "", rule_name := "") -> void:
	var script := ProjectSettings.globalize_path("res://tools/sam_firewall_action.ps1")
	var safe_script := script.replace("'", "''")
	var safe_name := app_name.replace("'", "''")
	var safe_path := app_path.replace("'", "''")
	var safe_rule := rule_name.replace("'", "''")
	var command := "Start-Process -FilePath 'powershell.exe' -Verb RunAs -WindowStyle Hidden -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File','%s','-Action','%s','-AppName','%s','-AppPath','%s','-RuleName','%s')" % [safe_script, action, safe_name, safe_path, safe_rule]
	OS.create_process("powershell.exe", PackedStringArray(["-NoLogo", "-NoProfile", "-NonInteractive", "-WindowStyle", "Hidden", "-Command", command]), false)
	show_toast("Windows administrator confirmation requested for " + action)
	security_refresh_due_ms = Time.get_ticks_msec() + 2500

func run_security_audit() -> void:
	if not bool(settings.get("pc_commands_enabled", false)):
		show_toast("Workspace Tools are locked • enable them before running the audit")
		return
	if security_audit_pid > 0 and OS.is_process_running(security_audit_pid):
		show_toast("A security audit is already running")
		return
	var audit_script := ProjectSettings.globalize_path("res://tools/sam_security_audit.ps1")
	if not FileAccess.file_exists(audit_script):
		show_toast("Security audit tool is missing")
		return
	var audit_folder := command_workspace_dir().path_join("Security Audits")
	DirAccess.make_dir_recursive_absolute(audit_folder)
	security_audit_output = audit_folder.path_join("security-audit-%s.txt" % Time.get_datetime_string_from_system().replace(":", "-").replace("T", "_"))
	security_report.clear()
	security_report.append_text("[font_size=20][color=#f9c74f]AUDIT RUNNING…[/color][/font_size]\n\nReading local Windows security status. No settings are being changed.")
	security_audit_pid = OS.create_process("powershell.exe", PackedStringArray(["-NoProfile", "-NonInteractive", "-ExecutionPolicy", "Bypass", "-File", audit_script, "-OutputPath", security_audit_output]), false)
	if security_audit_pid <= 0:
		security_report.text = "The local PowerShell audit could not be started."
		show_toast("Could not start security audit")
		return
	log_line("SECURITY", "Started read-only Windows audit PID %d" % security_audit_pid)
	show_toast("Read-only security audit started")

func poll_security_audit() -> void:
	if security_audit_pid <= 0 or OS.is_process_running(security_audit_pid):
		return
	var finished_pid := security_audit_pid
	security_audit_pid = -1
	if not FileAccess.file_exists(security_audit_output):
		security_report.text = "The audit process ended without producing a report. Check Windows PowerShell permissions and Debug Telemetry."
		log_line("SECURITY", "Audit PID %d ended without a report" % finished_pid)
		return
	var report_text := FileAccess.get_file_as_string(security_audit_output)
	security_report.clear()
	security_report.append_text("[font_size=20][color=#76f7a6]READ-ONLY AUDIT COMPLETE[/color][/font_size]\n[color=#8292ad]%s[/color]\n\n%s" % [escape_bbcode(security_audit_output), escape_bbcode(report_text)])
	log_line("SECURITY", "Completed read-only audit: " + security_audit_output)
	show_toast("Security audit complete • review unfamiliar items before acting")

func copy_security_report() -> void:
	if not is_instance_valid(security_report):
		return
	DisplayServer.clipboard_set(security_report.get_parsed_text())
	show_toast("Security report copied")

func open_security_report_folder() -> void:
	var folder := security_audit_output.get_base_dir() if not security_audit_output.is_empty() else command_workspace_dir().path_join("Security Audits")
	DirAccess.make_dir_recursive_absolute(folder)
	OS.shell_open(folder)

func ask_sam_about_security_report() -> void:
	if security_audit_output.is_empty() or not FileAccess.file_exists(security_audit_output):
		show_toast("Run the read-only audit first")
		return
	var report_text := FileAccess.get_file_as_string(security_audit_output)
	$Page/Tabs.current_tab = 0
	input_box.text = "Analyze this read-only Windows security audit cautiously. Separate normal/common activity from genuinely unusual items, explain uncertainty, and recommend verification steps. Do not generate blocking, deletion, quarantine, firewall, registry, service, or scheduled-task changes unless I later select a specific item and explicitly approve a preview.\n\n" + report_text.left(14000)
	input_box.grab_focus()
	input_box.set_caret_line(input_box.get_line_count() - 1)
	show_toast("Security report placed in chat for review • transmit when ready")

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
	ask.pressed.connect(func(): prepare_context_question("Stats for Nerds", "Explain the current SAM-AI telemetry and recent events in plain language. Cover model speed and memory, local network privacy, microphone state, voice capture, KnowledgeVault transcription, storage usage, retention, and any warning signs."))
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
	var mic_muted := bool(settings.get("microphone_muted", false))
	var knowledge_source := str(settings.get("knowledge_source_mode", "Microphone"))
	var knowledge_uses_mic := knowledge_recording and knowledge_source != "PC output (loopback input)"
	var mic_live := recording_voice or knowledge_uses_mic
	var mic_state := "MUTED" if mic_muted else ("LIVE / CAPTURING" if mic_live else "READY / NOT RECORDING")
	var vault_path := ProjectSettings.globalize_path(knowledge_storage_dir())
	var vault_bytes := directory_size_bytes(vault_path)
	var vault_used_gb := vault_bytes / 1073741824.0
	var vault_limit_gb := maxf(0.01, float(settings.get("knowledge_limit_gb", 10.0)))
	var vault_percent := minf(100.0, vault_used_gb / vault_limit_gb * 100.0)
	var retained_audio_files := 0
	var vault_directory := DirAccess.open(vault_path)
	if vault_directory:
		for vault_filename in vault_directory.get_files():
			if vault_filename.ends_with(".wav") or vault_filename.ends_with(".flac"):
				retained_audio_files += 1
	var category_counts: Dictionary = {}
	var discovery_count := 0
	var unread_discovery_count := 0
	for knowledge_entry_value in knowledge_entries:
		if knowledge_entry_value is Dictionary:
			var category_name := str(knowledge_entry_value.get("category", "Unknown"))
			category_counts[category_name] = int(category_counts.get(category_name, 0)) + 1
			if bool(knowledge_entry_value.get("for_you", false)):
				discovery_count += 1
			if bool(knowledge_entry_value.get("unread_discovery", false)):
				unread_discovery_count += 1
	var category_summary := "None yet"
	if not category_counts.is_empty():
		var category_parts: Array[String] = []
		for category_name in category_counts:
			category_parts.append("%s: %d" % [str(category_name), int(category_counts[category_name])])
		category_parts.sort()
		category_summary = ", ".join(category_parts)
	var network_state := "ACTIVE" if privacy_activity_active else "NOT IN USE"
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
	stats_report.append_text("Session: %s • saved sessions: %d • session history messages: %d\nGenerating: %s • elapsed: %.1fs • received: %d characters • live rate: %.1f chars/s\nRender buffer: %d characters • HTTP retries: %d\nSpell checker: %s • process PID: %d • personal dictionary: %d words\n\n" % [escape_bbcode(session_id), sessions.size(), history.size(), "YES" if generating else "NO", elapsed, response_text.length(), live_rate, render_buffer.length(), stream_retry_count, "ENABLED / LOCAL" if bool(settings.get("spellcheck_enabled", true)) else "DISABLED", spellcheck_pid, (settings.get("spellcheck_ignored_words", []) as Array).size()])
	stats_report.append_text("[font_size=20][color=#4deeea]MEMORY + VOICE PIPELINE[/color][/font_size]\n")
	stats_report.append_text("MemoryCore payload: %d bytes • path: %s • visible history begins at: %d\nKokoro worker: %s • text chunks waiting: %d • synthesis jobs: %d • audio chunks buffered: %d • playback begun: %s • playing: %s\nLive Voice: %s • state: %s • mic level: %.1f dB • silence: %.1fs • interruptions: %d\n\n" % [memory_bytes, escape_bbcode(str(settings.memory_path)), visible_history_start, daemon_state, streaming_voice_chunks.size(), streaming_pending_ids.size(), streaming_audio_chunks.size(), "YES" if streaming_voice_started else "NO", "YES" if voice_player.playing else "NO", "ON" if live_voice_enabled else "OFF", live_voice_state, live_voice_level_db, float(settings.get("live_voice_silence_seconds", 4.0)), live_voice_interrupt_count])
	stats_report.append_text("[font_size=20][color=#76f7a6]PRIVACY + NETWORK[/color][/font_size]\n")
	stats_report.append_text("Internet: [color=%s]%s[/color] • activity: %s\nDestination: %s • reason: %s\nSafety estimate: %d/10 • localhost model/voice traffic remains on this PC\nPC commands: [color=%s]%s[/color] • playground: %s\nSupervised run/dependency jobs: %d • dependency installs always require confirmation\nElevation: never persistent • Windows UAC required per elevated action\n\n" % ["#f9c74f" if privacy_activity_active else "#76f7a6", network_state, escape_bbcode(privacy_activity_title), escape_bbcode(privacy_activity_destination), escape_bbcode(privacy_activity_reason), privacy_safety_score, "#f9c74f" if bool(settings.get("pc_commands_enabled", false)) else "#76f7a6", "WORKSPACE TOOLS ENABLED" if bool(settings.get("pc_commands_enabled", false)) else "LOCKED", escape_bbcode(command_workspace_dir()), supervised_run_jobs.size()])
	stats_report.append_text("[font_size=20][color=#4deeea]MICROPHONE + SPEECH CAPTURE[/color][/font_size]\n")
	stats_report.append_text("Microphone: [color=%s]%s[/color] • selected device: %s\nPush-to-talk: %s • native capture PID: %d • preview chunk: %d\nKnowledge source: %s • knowledge capture PID: %d\nWhisper process PID: %d • Whisper model: %s\n\n" % ["#ff667d" if mic_live else ("#8292ad" if mic_muted else "#76f7a6"), mic_state, escape_bbcode(str(settings.get("audio_input_device", "Default"))), "RECORDING" if recording_voice else "IDLE", voice_capture_pid, voice_capture_next_chunk, escape_bbcode(knowledge_source), knowledge_capture_pid, knowledge_process_pid, escape_bbcode(str(settings.whisper_model_path).get_file())])
	stats_report.append_text("[font_size=20][color=#f9c74f]KNOWLEDGE VAULT + STORAGE[/color][/font_size]\n")
	var knowledge_audio_format := "WAV (playable original)" if bool(settings.get("knowledge_keep_audio", false)) else ("FLAC (temporary)" if bool(settings.get("knowledge_compress_audio", true)) else "WAV (temporary)")
	stats_report.append_text("Capture: %s • session: %s • elapsed: %.1fs • current segment: %.1fs / %.0fs\nTranscription queue: %d • learned chunks: %d • discoveries: %d total / %d unread\nCategories: %s\nRetention: %s • audio format: %s • retained audio files: %d\nStorage: %.3f GB / %.2f GB (%.1f%%) • limit reached: %s\nPath: %s\n\n" % ["RECORDING" if knowledge_recording else "IDLE", escape_bbcode(knowledge_session_id if not knowledge_session_id.is_empty() else "None"), knowledge_elapsed, knowledge_chunk_elapsed, KNOWLEDGE_CHUNK_SECONDS, knowledge_queue.size(), knowledge_entries.size(), discovery_count, unread_discovery_count, escape_bbcode(category_summary), "KEEP SOURCE AUDIO" if bool(settings.get("knowledge_keep_audio", false)) else "TRANSCRIPT ONLY", knowledge_audio_format, retained_audio_files, vault_used_gb, vault_limit_gb, vault_percent, "YES" if vault_bytes >= int(vault_limit_gb * 1073741824.0) else "NO", escape_bbcode(vault_path)])
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
	heading.text = "SAM-AI PRIVATE LOCAL INTELLIGENCE"
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
	info.append_text("[color=#8292ad]SUPPORT DEVELOPMENT[/color]\nIf SAM-AI is useful to you, you can support continued development through Buy Me a Coffee.\n[url=https://buymeacoffee.com/astroblitzcreations][color=#4deeea][u]https://buymeacoffee.com/astroblitzcreations[/u][/color][/url]\n\n[color=#8292ad]Version 1.2.0 • Windows desktop edition[/color]")
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
	if toast_tween != null and toast_tween.is_valid():
		toast_tween.kill()
	toast_label.text = message
	toast_label.modulate = Color(1, 1, 1, 1)
	toast_label.visible = true
	toast_label.move_to_front()
	toast_tween = create_tween()
	toast_tween.tween_interval(4.5)
	toast_tween.tween_property(toast_label, "modulate:a", 0.0, 0.8)
	toast_tween.tween_callback(func(): toast_label.visible = false)

func setup_toast_card() -> void:
	toast_label.z_index = 200
	toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	toast_label.offset_left = -540.0
	toast_label.offset_top = 78.0
	toast_label.offset_right = -24.0
	toast_label.offset_bottom = 158.0
	toast_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_label.add_theme_font_size_override("font_size", 17)
	toast_label.add_theme_color_override("font_color", colors.text)
	toast_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	toast_label.add_theme_constant_override("shadow_offset_x", 2)
	toast_label.add_theme_constant_override("shadow_offset_y", 2)
	var card := StyleBoxFlat.new()
	card.bg_color = Color(0.035, 0.065, 0.11, 0.98)
	card.border_color = colors.cyan
	card.set_border_width_all(2)
	card.set_corner_radius_all(10)
	card.set_content_margin_all(16)
	card.shadow_color = Color(0, 0, 0, 0.65)
	card.shadow_size = 10
	toast_label.add_theme_stylebox_override("normal", card)

func setup_session_sidebar() -> void:
	# Chat layout enhancement reparents Composer into ChatWorkspaceSplit, so find
	# this optional legacy button by name instead of relying on its original path.
	var old_new_session := $Page/Tabs/Chat.find_child("NewSession", true, false)
	if is_instance_valid(old_new_session):
		old_new_session.visible = false
	session_sidebar = PanelContainer.new()
	session_sidebar.name = "SessionSidebar"
	session_sidebar.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	session_sidebar.offset_left = -session_sidebar_width
	session_sidebar.offset_right = 0.0
	session_sidebar.offset_top = 70.0
	session_sidebar.offset_bottom = -24.0
	session_sidebar.z_index = 80
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.05, 0.09, 1.0)
	panel_style.border_color = colors.cyan
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	session_sidebar.add_theme_stylebox_override("panel", panel_style)
	session_sidebar.mouse_entered.connect(cancel_session_sidebar_auto_hide)
	session_sidebar.mouse_exited.connect(schedule_session_sidebar_auto_hide)
	add_child(session_sidebar)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	session_sidebar.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 9)
	margin.add_child(column)
	var title := Label.new()
	title.text = "PROJECT SESSIONS"
	title.add_theme_font_size_override("font_size", 19)
	title.add_theme_color_override("font_color", colors.cyan)
	column.add_child(title)
	session_active_label = Label.new()
	session_active_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(session_active_label)
	session_stats_label = Label.new()
	session_stats_label.add_theme_color_override("font_color", colors.muted)
	column.add_child(session_stats_label)
	var location_actions := HBoxContainer.new()
	column.add_child(location_actions)
	location_actions.add_child(make_button("📂 FOLDER", open_active_session_folder, colors.cyan))
	location_actions.add_child(make_button("📄 SESSION FILE", open_active_session_file, colors.muted))
	var create_button := make_button("＋ NEW PROJECT SESSION", create_new_session, colors.green)
	column.add_child(create_button)
	session_list = Tree.new()
	session_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	session_list.columns = 2
	session_list.column_titles_visible = true
	session_list.set_column_title(0, "PROJECT SESSION")
	session_list.set_column_title(1, "STATE")
	session_list.set_column_expand(0, true)
	session_list.set_column_expand(1, false)
	session_list.set_column_custom_minimum_width(1, 62)
	session_list.hide_root = true
	session_list.item_activated.connect(switch_selected_session)
	column.add_child(session_list)
	var actions := HBoxContainer.new()
	column.add_child(actions)
	actions.add_child(make_button("LOAD SESSION", switch_selected_session, colors.cyan))
	actions.add_child(make_button("ARCHIVE", archive_selected_session, colors.amber))
	actions.add_child(make_button("DELETE", delete_selected_session, colors.red))
	# Keep the resize divider outside PanelContainer. Container children are forced
	# to fill its content rect, which previously stretched this grip over the whole
	# sidebar and visually hid every session.
	session_resize_grip = ColorRect.new()
	session_resize_grip.color = Color(0.08, 0.72, 0.76, 0.92)
	session_resize_grip.tooltip_text = "Drag to resize the sessions panel"
	session_resize_grip.mouse_default_cursor_shape = Control.CURSOR_HSIZE
	session_resize_grip.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	session_resize_grip.offset_left = session_sidebar_width - 4.0
	session_resize_grip.offset_right = session_sidebar_width + 4.0
	session_resize_grip.offset_top = 70.0
	session_resize_grip.offset_bottom = -24.0
	session_resize_grip.z_index = 82
	session_resize_grip.visible = false
	session_resize_grip.gui_input.connect(_on_session_resize_input)
	session_resize_grip.mouse_entered.connect(cancel_session_sidebar_auto_hide)
	session_resize_grip.mouse_exited.connect(schedule_session_sidebar_auto_hide)
	add_child(session_resize_grip)
	session_edge_button = Button.new()
	session_edge_button.text = "<"
	session_edge_button.tooltip_text = "Open or close project sessions"
	session_edge_button.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	session_edge_button.offset_left = 3.0
	session_edge_button.offset_right = 35.0
	session_edge_button.offset_top = -28.0
	session_edge_button.offset_bottom = 28.0
	session_edge_button.custom_minimum_size = Vector2(32, 56)
	session_edge_button.clip_text = false
	session_edge_button.add_theme_font_size_override("font_size", 24)
	session_edge_button.z_index = 81
	session_edge_button.pressed.connect(func(): set_session_sidebar_open(not session_sidebar_open))
	session_edge_button.mouse_entered.connect(cancel_session_sidebar_auto_hide)
	session_edge_button.mouse_exited.connect(schedule_session_sidebar_auto_hide)
	add_child(session_edge_button)
	apply_theme_recursive(session_edge_button)
	var edge_style := StyleBoxFlat.new()
	edge_style.bg_color = Color(0.035, 0.13, 0.19, 1.0)
	edge_style.border_color = colors.cyan
	edge_style.set_border_width_all(1)
	edge_style.set_corner_radius_all(7)
	edge_style.content_margin_left = 0.0
	edge_style.content_margin_right = 0.0
	session_edge_button.add_theme_stylebox_override("normal", edge_style)
	session_edge_button.add_theme_stylebox_override("hover", edge_style.duplicate())
	$Page.offset_left = 36.0
	refresh_session_sidebar()

func set_session_sidebar_open(open: bool) -> void:
	cancel_session_sidebar_auto_hide()
	capture_session_chat_scroll()
	session_sidebar_open = open
	if not is_instance_valid(session_sidebar):
		return
	if is_instance_valid(session_sidebar_tween):
		session_sidebar_tween.kill()
	session_sidebar_tween = create_tween()
	session_sidebar_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	session_sidebar_tween.tween_property(session_sidebar, "offset_left", 0.0 if open else -session_sidebar_width, 0.48)
	session_sidebar_tween.parallel().tween_property(session_sidebar, "offset_right", session_sidebar_width if open else 0.0, 0.48)
	session_sidebar_tween.parallel().tween_property($Page, "offset_left", session_sidebar_width + 36.0 if open else 36.0, 0.48)
	session_sidebar_tween.parallel().tween_property(session_edge_button, "position:x", session_sidebar_width + 5.0 if open else 3.0, 0.48)
	session_resize_grip.visible = open
	if open:
		session_resize_grip.offset_left = session_sidebar_width - 4.0
		session_resize_grip.offset_right = session_sidebar_width + 4.0
	# The arrow shows the panel's current position: right/open or left/closed.
	session_edge_button.text = ">" if open else "<"
	restore_session_chat_scroll.call_deferred()

func cancel_session_sidebar_auto_hide() -> void:
	session_sidebar_hide_ticket += 1

func schedule_session_sidebar_auto_hide() -> void:
	if not session_sidebar_open or session_sidebar_resizing:
		return
	session_sidebar_hide_ticket += 1
	var ticket := session_sidebar_hide_ticket
	await get_tree().create_timer(2.0).timeout
	if ticket != session_sidebar_hide_ticket or not session_sidebar_open or session_sidebar_resizing:
		return
	var pointer := get_global_mouse_position()
	if session_sidebar.get_global_rect().has_point(pointer) or session_resize_grip.get_global_rect().has_point(pointer) or session_edge_button.get_global_rect().has_point(pointer):
		return
	set_session_sidebar_open(false)

func capture_session_chat_scroll() -> void:
	if not is_instance_valid(chat_log):
		return
	var bar := chat_log.get_v_scroll_bar()
	var usable := maxf(0.0, bar.max_value - bar.page)
	session_scroll_was_bottom = usable <= 1.0 or bar.value >= usable - 8.0
	session_scroll_ratio = 1.0 if usable <= 0.0 else clampf(bar.value / usable, 0.0, 1.0)

func restore_session_chat_scroll() -> void:
	await get_tree().create_timer(0.42).timeout
	await get_tree().process_frame
	if not is_instance_valid(chat_log):
		return
	var bar := chat_log.get_v_scroll_bar()
	var usable := maxf(0.0, bar.max_value - bar.page)
	bar.value = usable if session_scroll_was_bottom else usable * session_scroll_ratio

func _on_session_resize_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			capture_session_chat_scroll()
		session_sidebar_resizing = event.pressed
		if not event.pressed:
			restore_session_chat_scroll.call_deferred()
	if event is InputEventMouseMotion and session_sidebar_resizing and session_sidebar_open:
		session_sidebar_width = clampf(event.relative.x + session_sidebar_width, 290.0, minf(620.0, size.x * 0.46))
		session_sidebar.offset_right = session_sidebar_width
		$Page.offset_left = session_sidebar_width + 36.0
		session_edge_button.position.x = session_sidebar_width + 5.0
		session_resize_grip.offset_left = session_sidebar_width - 4.0
		session_resize_grip.offset_right = session_sidebar_width + 4.0

func active_session_workspace_dir() -> String:
	return command_workspace_dir().path_join("Sessions").path_join(session_id.validate_filename())

func refresh_session_sidebar() -> void:
	if not is_instance_valid(session_list):
		return
	session_list.clear()
	var root := session_list.create_item()
	var total_bytes := 0
	var total_files := 0
	for metadata in sessions:
		if bool(metadata.get("archived", false)):
			continue
		var id := str(metadata.get("id", ""))
		var item := session_list.create_item(root)
		item.set_text(0, str(metadata.get("title", "New session")))
		item.set_metadata(0, id)
		var state := str(metadata.get("status", "complete" if bool(metadata.get("complete", false)) else "idle"))
		item.set_text(1, "●")
		item.set_tooltip_text(1, session_status_label(state))
		item.set_custom_color(1, session_status_color(state))
		item.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
		if id == session_id:
			item.select(0)
		var workspace := command_workspace_dir().path_join("Sessions").path_join(id.validate_filename())
		total_bytes += directory_size_bytes(workspace)
		total_files += count_files_recursive(workspace)
	var metadata_index := find_session_index(session_id)
	var active_title := "New session"
	if metadata_index >= 0:
		active_title = str(sessions[metadata_index].get("title", active_title))
	session_active_label.text = "CURRENT\n%s\nID  %s" % [active_title, session_id]
	session_stats_label.text = "%d sessions • %d files • %s" % [sessions.size(), total_files, format_bytes(total_bytes)]

func set_session_complete(complete: bool) -> void:
	var index := find_session_index(session_id)
	if index < 0:
		return
	var metadata: Dictionary = sessions[index]
	metadata.complete = complete
	metadata.status = "complete" if complete else "working"
	metadata.updated = Time.get_datetime_string_from_system()
	sessions[index] = metadata
	save_session_index()
	refresh_session_sidebar()

func set_session_status(state: String) -> void:
	var index := find_session_index(session_id)
	if index < 0:
		return
	var metadata: Dictionary = sessions[index]
	metadata.status = state
	metadata.updated = Time.get_datetime_string_from_system()
	sessions[index] = metadata
	save_session_index()
	refresh_session_sidebar()

func session_status_label(state: String) -> String:
	var labels := {"working": "Working", "complete": "Completed", "attention": "Needs attention", "failed": "Failed", "admin": "Waiting for administrator approval", "dependency": "Missing dependency", "idle": "Ready"}
	return str(labels.get(state, "Ready"))

func session_status_color(state: String) -> Color:
	var values := {"working": colors.cyan, "complete": colors.green, "attention": colors.amber, "failed": colors.red, "admin": colors.pink, "dependency": colors.amber, "idle": colors.muted}
	return values.get(state, colors.muted)

func show_session_completion_notice() -> void:
	var index := find_session_index(session_id)
	if index < 0:
		return
	show_toast("✓ %s completed its latest work" % str(sessions[index].get("title", "Session")))

func count_files_recursive(path: String) -> int:
	var directory := DirAccess.open(path)
	if directory == null:
		return 0
	var count := directory.get_files().size()
	for child in directory.get_directories():
		count += count_files_recursive(path.path_join(child))
	return count

func format_bytes(bytes: int) -> String:
	if bytes >= 1073741824:
		return "%.2f GB" % (bytes / 1073741824.0)
	if bytes >= 1048576:
		return "%.1f MB" % (bytes / 1048576.0)
	if bytes >= 1024:
		return "%.1f KB" % (bytes / 1024.0)
	return "%d B" % bytes

func compose_new_chat_welcome() -> String:
	var recent_topics: Array[String] = []
	for reverse_index in range(knowledge_entries.size() - 1, -1, -1):
		var entry_value = knowledge_entries[reverse_index]
		if not (entry_value is Dictionary):
			continue
		var entry: Dictionary = entry_value
		if str(entry.get("study_status", "")) != "relevant":
			continue
		var category := str(entry.get("category", "Knowledge"))
		if not recent_topics.has(category):
			recent_topics.append(category)
		if recent_topics.size() >= 3:
			break
	var topic_phrase := "the things we’ve been building together"
	if recent_topics.size() == 1:
		topic_phrase = recent_topics[0]
	elif recent_topics.size() >= 2:
		topic_phrase = "%s and %s" % [recent_topics[0], recent_topics[1]]
	var project_hint := ""
	for session_value in sessions:
		if session_value is Dictionary:
			var title := str(session_value.get("title", "")).strip_edges()
			if title not in ["", "New session", "Recovered session"]:
				project_hint = title.left(55)
				break
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var openings := [
		"✨ Fresh chat, fresh canvas — I’m here and ready.",
		"🐾 Meow Meow cleared the desk, and I brought the ideas.",
		"⚡ New session online. Let’s make something interesting.",
		"🌙 Clean page, same memory, no lost momentum.",
		"🛠️ Workshop open! I’ve got the tools and you’ve got the steering wheel.",
		"🚀 SAM reporting in — systems ready and curiosity fully charged."
	]
	var invitations := [
		"What would you like to create, fix, investigate, or learn today?",
		"Want to continue an idea, test something strange, or start a completely new project?",
		"Tell me what’s on your mind and we’ll turn it into something real.",
		"What adventure are we getting into this time?",
		"Give me the rough idea — I’ll help shape it into a solid plan."
	]
	var personal_hint := " I remember our interests around %s." % topic_phrase
	if not project_hint.is_empty() and rng.randi_range(0, 1) == 1:
		personal_hint = " We can continue “%s” or start fresh." % project_hint
	return "%s%s %s" % [openings[rng.randi_range(0, openings.size() - 1)], personal_hint, invitations[rng.randi_range(0, invitations.size() - 1)]]

func start_new_chat_welcome() -> void:
	if not history.is_empty() or generating:
		return
	new_chat_welcome_text = compose_new_chat_welcome()
	new_chat_welcome_index = 0
	new_chat_welcome_elapsed = 0.0
	new_chat_welcome_active = true
	new_chat_welcome_visible = true
	chat_log.append_text("\n[color=#76f7a6][b]SAM[/b][/color]  [color=#4deeea]✦ NEW CHAT[/color]  ")
	jump_chat_bottom()

func update_new_chat_welcome(delta: float) -> void:
	if not new_chat_welcome_active or not is_instance_valid(chat_log):
		return
	new_chat_welcome_elapsed += delta
	var characters_due := mini(3, int(new_chat_welcome_elapsed / 0.028))
	if characters_due <= 0:
		return
	new_chat_welcome_elapsed -= float(characters_due) * 0.028
	var remaining := new_chat_welcome_text.length() - new_chat_welcome_index
	var amount := mini(characters_due, remaining)
	chat_log.append_text(escape_bbcode(new_chat_welcome_text.substr(new_chat_welcome_index, amount)))
	new_chat_welcome_index += amount
	if force_chat_follow or chat_is_near_bottom():
		chat_log.scroll_to_line(chat_log.get_line_count())
	if new_chat_welcome_index >= new_chat_welcome_text.length():
		finish_new_chat_welcome()

func finish_new_chat_welcome() -> void:
	if not new_chat_welcome_active:
		return
	if new_chat_welcome_index < new_chat_welcome_text.length():
		chat_log.append_text(escape_bbcode(new_chat_welcome_text.substr(new_chat_welcome_index)))
	chat_log.append_text("\n")
	new_chat_welcome_active = false
	new_chat_welcome_index = new_chat_welcome_text.length()
	jump_chat_bottom()

func create_new_session() -> void:
	if generating:
		show_toast("Finish or abort the active generation before switching sessions")
		return
	save_history()
	session_id = create_session_record("New session")
	history.clear()
	sent_messages.clear()
	new_chat_welcome_active = false
	new_chat_welcome_visible = false
	new_chat_welcome_text = ""
	# Attachments are live composer state, not global state. Never carry an image
	# or document from the previous project session into a new conversation.
	clear_attachment()
	skip_attachment_learning_confirm = false
	visible_history_start = 0
	DirAccess.make_dir_recursive_absolute(active_session_workspace_dir())
	redraw_history()
	start_new_chat_welcome()
	refresh_session_sidebar()
	set_status("NEW PROJECT SESSION", colors.cyan)
	show_toast("New session ready • its name will come from your first message")

func switch_selected_session() -> void:
	var target := selected_session_id()
	if target.is_empty() or target == session_id:
		return
	if generating:
		pending_session_switch = target
		show_toast("Session queued • it will load when the current response finishes")
		return
	switch_to_session(target)

func switch_to_session(target: String) -> void:
	save_history()
	# Clear the outgoing session's live attachment before loading the target.
	# Images saved inside either transcript remain visible as history, but are not
	# silently submitted with the next message.
	clear_attachment()
	skip_attachment_learning_confirm = false
	session_id = target
	history.clear()
	sent_messages.clear()
	new_chat_welcome_active = false
	new_chat_welcome_visible = false
	new_chat_welcome_text = ""
	load_history()
	visible_history_start = 0
	redraw_history()
	if history.is_empty():
		start_new_chat_welcome()
	save_session_index()
	refresh_session_sidebar()
	show_toast("Session restored with its conversation and project context")

func open_active_session_folder() -> void:
	DirAccess.make_dir_recursive_absolute(active_session_workspace_dir())
	OS.shell_open(active_session_workspace_dir())

func open_active_session_file() -> void:
	var path := ProjectSettings.globalize_path(session_history_path(session_id))
	if not FileAccess.file_exists(path):
		show_toast("This session file has not been created yet")
		return
	var file := FileAccess.open(path, FileAccess.READ)
	var bytes := file.get_length() if file else 0
	if bytes > 25 * 1024 * 1024:
		var dialog := ConfirmationDialog.new()
		dialog.title = "OPEN LARGE SESSION FILE?"
		dialog.dialog_text = "This session file is %s. It will open in an external app so SAM-AI stays responsive, but the other app may take time to load it." % format_bytes(bytes)
		dialog.ok_button_text = "OPEN EXTERNALLY"
		dialog.confirmed.connect(func(): OS.shell_open(path); dialog.queue_free())
		dialog.canceled.connect(dialog.queue_free)
		add_child(dialog)
		apply_theme_recursive(dialog)
		style_security_dialog(dialog, colors.amber)
		dialog.popup_centered(Vector2i(700, 360))
	else:
		OS.shell_open(path)

func selected_session_id() -> String:
	var selected := session_list.get_selected()
	return "" if selected == null else str(selected.get_metadata(0))

func archive_selected_session() -> void:
	var target := selected_session_id()
	var index := find_session_index(target)
	if index < 0:
		return
	if target == session_id:
		show_toast("Switch to another session before archiving this one")
		return
	sessions[index].archived = true
	save_session_index()
	refresh_session_sidebar()
	show_toast("Session archived • its files and context were preserved")

func delete_selected_session() -> void:
	var target := selected_session_id()
	var index := find_session_index(target)
	if index < 0:
		return
	if target == session_id:
		show_toast("Switch to another session before deleting this one")
		return
	show_typed_delete_confirmation("DELETE PROJECT SESSION?", "The conversation and generated project folder will be sent to the Windows Recycle Bin. Type DELETE to confirm:", "DELETE", func():
		var paths: Array[String] = [ProjectSettings.globalize_path(session_history_path(target))]
		var workspace := active_session_workspace_dir().get_base_dir().path_join(target.validate_filename())
		if DirAccess.dir_exists_absolute(workspace):
			paths.append(workspace)
		send_paths_to_windows_recycle(paths)
		sessions.remove_at(index)
		save_session_index()
		refresh_session_sidebar(), colors.red)

func clear_session() -> void:
	create_new_session()

func clear_screen() -> void:
	visible_history_start = history.size()
	chat_log.clear()
	chat_log.append_text("[center][color=#8292ad]SCREEN CLEARED • CHAT CONTEXT PRESERVED[/color][/center]\n")
	set_status("SCREEN CLEARED", colors.cyan)

func copy_chat() -> void:
	DisplayServer.clipboard_set(chat_log.get_parsed_text())
	set_status("CHAT COPIED", colors.cyan)

func setup_debug_telemetry_pager() -> void:
	if not is_instance_valid(logs):
		return
	logs.threaded = true
	logs.fit_content = false
	logs.scroll_following = false
	var parent := logs.get_parent()
	if parent == null:
		return
	var row := HBoxContainer.new()
	row.name = "TelemetryPager"
	row.add_theme_constant_override("separation", 6)
	parent.add_child(row)
	parent.move_child(row, logs.get_index())
	telemetry_first_button = make_button("FIRST", _telemetry_turn_page.bind("first"), colors.cyan)
	telemetry_previous_button = make_button("PREVIOUS", _telemetry_turn_page.bind("previous"), colors.cyan)
	telemetry_page_label = Label.new()
	telemetry_page_label.text = "Debug telemetry • 0 messages"
	telemetry_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	telemetry_page_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	telemetry_next_button = make_button("NEXT", _telemetry_turn_page.bind("next"), colors.cyan)
	telemetry_last_button = make_button("LATEST", _telemetry_turn_page.bind("last"), colors.cyan)
	row.add_child(telemetry_first_button)
	row.add_child(telemetry_previous_button)
	row.add_child(telemetry_page_label)
	row.add_child(telemetry_next_button)
	row.add_child(telemetry_last_button)
	telemetry_dirty = true


func _telemetry_turn_page(direction: String) -> void:
	var pages := maxi(1, ceili(float(telemetry_entries.size()) / float(TELEMETRY_PAGE_SIZE)))
	match direction:
		"first": telemetry_page = 0
		"previous": telemetry_page = maxi(0, telemetry_page - 1)
		"next": telemetry_page = mini(pages - 1, telemetry_page + 1)
		"last": telemetry_page = pages - 1
	telemetry_follow_latest = telemetry_page >= pages - 1
	telemetry_dirty = true
	telemetry_render_due = 0


func _telemetry_clear() -> void:
	telemetry_entries.clear()
	telemetry_page = 0
	telemetry_follow_latest = true
	telemetry_dirty = true
	if is_instance_valid(logs):
		logs.clear()
	update_debug_telemetry_ui(true)


func _telemetry_plain_text() -> String:
	var lines: Array[String] = []
	for entry_value in telemetry_entries:
		var entry: Dictionary = entry_value
		var repeat := int(entry.get("repeat", 1))
		var suffix := " ×%d" % repeat if repeat > 1 else ""
		lines.append("%s [%s] %s%s" % [str(entry.get("time", "")), str(entry.get("kind", "")), str(entry.get("message", "")), suffix])
	return "\n".join(lines)


func update_debug_telemetry_ui(force: bool = false) -> void:
	if not telemetry_dirty or not is_instance_valid(logs):
		return
	var now := Time.get_ticks_msec()
	if not force and now < telemetry_render_due:
		return
	telemetry_render_due = now + 120
	var pages := maxi(1, ceili(float(telemetry_entries.size()) / float(TELEMETRY_PAGE_SIZE)))
	if telemetry_follow_latest:
		telemetry_page = pages - 1
	telemetry_page = clampi(telemetry_page, 0, pages - 1)
	var start := telemetry_page * TELEMETRY_PAGE_SIZE
	var finish := mini(start + TELEMETRY_PAGE_SIZE, telemetry_entries.size())
	var parts: Array[String] = []
	parts.append("[color=#8292ad]50 messages per page • repeated identical events are collapsed instead of flooding the UI[/color]\n\n")
	for index in range(start, finish):
		var entry: Dictionary = telemetry_entries[index]
		var repeat := int(entry.get("repeat", 1))
		var suffix := " [color=#f9c74f]×%d[/color]" % repeat if repeat > 1 else ""
		parts.append("[color=#8292ad]%s[/color] [color=#4deeea][%s][/color]%s %s\n" % [escape_bbcode(str(entry.get("time", ""))), escape_bbcode(str(entry.get("kind", ""))), suffix, escape_bbcode(str(entry.get("message", "")))])
	logs.text = "".join(parts)
	if is_instance_valid(telemetry_page_label):
		telemetry_page_label.text = "Page %d / %d • %d–%d of %d messages" % [telemetry_page + 1, pages, start + 1 if not telemetry_entries.is_empty() else 0, finish, telemetry_entries.size()]
	if is_instance_valid(telemetry_first_button):
		telemetry_first_button.disabled = telemetry_page == 0
	if is_instance_valid(telemetry_previous_button):
		telemetry_previous_button.disabled = telemetry_page == 0
	if is_instance_valid(telemetry_next_button):
		telemetry_next_button.disabled = telemetry_page >= pages - 1
	if is_instance_valid(telemetry_last_button):
		telemetry_last_button.disabled = telemetry_page >= pages - 1
	telemetry_dirty = false


func copy_logs() -> void:
	DisplayServer.clipboard_set(_telemetry_plain_text())
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

func setup_privacy_indicator() -> void:
	if is_instance_valid(privacy_button):
		return
	var header := status_label.get_parent() as HBoxContainer
	if header == null:
		return
	var original_index := status_dot.get_index()
	var status_stack := VBoxContainer.new()
	status_stack.name = "PrivacyStatusStack"
	status_stack.add_theme_constant_override("separation", 1)
	header.add_child(status_stack)
	header.move_child(status_stack, original_index)
	var model_row := HBoxContainer.new()
	model_row.alignment = BoxContainer.ALIGNMENT_END
	status_stack.add_child(model_row)
	status_dot.reparent(model_row)
	status_label.reparent(model_row)
	var privacy_row := HBoxContainer.new()
	privacy_row.alignment = BoxContainer.ALIGNMENT_END
	privacy_row.add_theme_constant_override("separation", 8)
	status_stack.add_child(privacy_row)
	privacy_button = MenuButton.new()
	privacy_button.flat = true
	privacy_button.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	privacy_button.tooltip_text = "Open the privacy and network activity report"
	privacy_button.add_theme_font_size_override("font_size", 13)
	privacy_row.add_child(privacy_button)
	pc_commands_button = MenuButton.new()
	pc_commands_button.flat = true
	pc_commands_button.add_theme_font_size_override("font_size", 13)
	pc_commands_button.get_popup().id_pressed.connect(_on_pc_commands_menu)
	privacy_row.add_child(pc_commands_button)
	network_guard_header_button = Button.new()
	network_guard_header_button.flat = true
	network_guard_header_button.add_theme_font_size_override("font_size", 13)
	network_guard_header_button.tooltip_text = "Open SAM Network Guard"
	network_guard_header_button.pressed.connect(open_network_guard_tab)
	privacy_row.add_child(network_guard_header_button)
	knowledge_discovery_button = Button.new()
	knowledge_discovery_button.flat = true
	knowledge_discovery_button.text = "✦ DISCOVERIES"
	knowledge_discovery_button.tooltip_text = "Open locally selected KnowledgeVault discoveries"
	knowledge_discovery_button.add_theme_font_size_override("font_size", 13)
	knowledge_discovery_button.pressed.connect(open_knowledge_discoveries)
	privacy_row.add_child(knowledge_discovery_button)
	microphone_privacy_button = Button.new()
	microphone_privacy_button.flat = true
	microphone_privacy_button.tooltip_text = "Mute or enable all SAM microphone capture"
	microphone_privacy_button.add_theme_font_size_override("font_size", 13)
	microphone_privacy_button.pressed.connect(toggle_microphone_privacy)
	privacy_row.add_child(microphone_privacy_button)
	set_privacy_activity(false)
	refresh_pc_commands_indicator()
	refresh_network_guard_header()
	refresh_knowledge_discovery_indicator()
	refresh_microphone_privacy_indicator()

func refresh_network_guard_header() -> void:
	if not is_instance_valid(network_guard_header_button):
		return
	var enabled := bool(settings.get("network_guard_enabled", false))
	network_guard_header_button.visible = enabled
	network_guard_header_button.text = "🛡 GUARD %d BLOCKED" % security_blocked_rules
	network_guard_header_button.add_theme_color_override("font_color", colors.green)

func open_network_guard_tab() -> void:
	var tab := $Page/Tabs.get_node_or_null("Security Center")
	if tab != null:
		$Page/Tabs.current_tab = tab.get_index()
		refresh_security_snapshot()

func toggle_microphone_privacy() -> void:
	var muting := not bool(settings.get("microphone_muted", false))
	settings.microphone_muted = muting
	save_json(SETTINGS_FILE, settings)
	if muting:
		if live_voice_enabled:
			stop_live_voice_mode("Live Voice stopped because the microphone was muted")
		if recording_voice:
			recording_voice = false
			request_external_voice_stop()
			if is_instance_valid(microphone_button):
				microphone_button.text = "🎙 START TALKING"
		if knowledge_recording and str(settings.get("knowledge_source_mode", "Microphone")) != "PC output (loopback input)":
			toggle_knowledge_recording()
		if is_instance_valid(microphone_player):
			microphone_player.stop()
		set_voice_status("VOICE • MICROPHONE MUTED", colors.muted)
		show_toast("Microphone muted • active microphone capture stopped")
	else:
		call_deferred("_restore_saved_audio_input_after_unmute")
		set_voice_status("VOICE • READY", colors.cyan)
		show_toast("Microphone enabled • use START TALKING or LIVE VOICE when you want SAM to listen")
	refresh_microphone_privacy_indicator()

func refresh_microphone_privacy_indicator() -> void:
	if not is_instance_valid(microphone_privacy_button):
		return
	var muted := bool(settings.get("microphone_muted", false))
	var knowledge_uses_mic := knowledge_recording and str(settings.get("knowledge_source_mode", "Microphone")) != "PC output (loopback input)"
	var live := recording_voice or live_voice_enabled or knowledge_uses_mic
	if muted:
		microphone_privacy_button.text = "🔇 MIC OFF"
		microphone_privacy_button.add_theme_color_override("font_color", colors.muted)
		microphone_privacy_button.tooltip_text = "Microphone access is disabled. Click to enable it."
	elif live:
		microphone_privacy_button.text = "● MIC LIVE"
		microphone_privacy_button.add_theme_color_override("font_color", colors.red)
		microphone_privacy_button.tooltip_text = "SAM is actively capturing microphone audio. Click to mute and stop."
	else:
		microphone_privacy_button.text = "🎙 MIC READY"
		microphone_privacy_button.add_theme_color_override("font_color", colors.green)
		microphone_privacy_button.tooltip_text = "Microphone is enabled but SAM is not recording. Click to mute it."
	_update_live_voice_button()

func set_privacy_activity(active: bool, title := "No internet access", destination := "None", reason := "SAM is running its model and tools locally on this computer.", score := 10, detail := "Localhost traffic stays on this PC and is not internet access.", reset_after_ms := 0) -> void:
	privacy_activity_active = active
	privacy_activity_title = title
	privacy_activity_destination = destination
	privacy_activity_reason = reason
	privacy_safety_score = clampi(score, 1, 10)
	privacy_activity_detail = detail
	privacy_reset_at_msec = Time.get_ticks_msec() + reset_after_ms if active and reset_after_ms > 0 else 0
	if not is_instance_valid(privacy_button):
		return
	privacy_button.text = "▼  INTERNET ACTIVE • DETAILS" if active else "▼  🔒 INTERNET NOT IN USE • LOCAL AI"
	privacy_button.add_theme_color_override("font_color", colors.amber if active else colors.green)
	privacy_button.add_theme_color_override("font_hover_color", colors.cyan)
	var popup := privacy_button.get_popup()
	popup.clear()
	add_privacy_info_item(popup, "NETWORK & PRIVACY ACTIVITY")
	popup.add_separator()
	add_privacy_info_item(popup, ("● INTERNET ACTIVE" if active else "● INTERNET NOT IN USE"))
	add_privacy_info_item(popup, "Activity: " + privacy_activity_title)
	add_privacy_info_item(popup, "Destination: " + privacy_activity_destination)
	add_privacy_info_item(popup, "Why: " + privacy_activity_reason)
	add_privacy_info_item(popup, "Safety estimate: %d/10" % privacy_safety_score)
	popup.add_separator()
	add_privacy_info_item(popup, privacy_activity_detail)
	add_privacy_info_item(popup, "MemoryCore, chats, and KnowledgeVault remain local.")
	add_privacy_info_item(popup, "Score is SAM's plain-language risk estimate, not a security guarantee.")

func add_privacy_info_item(popup: PopupMenu, text_value: String) -> void:
	popup.add_item(text_value)
	popup.set_item_disabled(popup.item_count - 1, true)

func command_workspace_dir() -> String:
	var configured := str(settings.get("command_workspace_path", "")).strip_edges()
	if not configured.is_empty():
		return configured
	return OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).path_join("SAM-AI Playground")

func playground_trash_dir() -> String:
	return command_workspace_dir().path_join(".sam_trash")

func setup_command_center() -> void:
	var tabs: TabContainer = $Page/Tabs
	var page := VBoxContainer.new()
	page.name = "Command Center"
	page.add_theme_constant_override("separation", 8)
	tabs.add_child(page)
	var header := HBoxContainer.new()
	page.add_child(header)
	var title := Label.new()
	title.text = "COMMAND CENTER  //  PLAN • RUN • AUTOMATE • REVIEW"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", colors.cyan)
	header.add_child(title)
	header.add_child(make_button("📂 OPEN WORKSPACE", func(): DirAccess.make_dir_recursive_absolute(command_workspace_dir()); OS.shell_open(command_workspace_dir()), colors.cyan))
	header.add_child(make_button("↺ SAFE DEFAULTS", command_center_reset_safe_defaults, colors.green))
	var help := Label.new()
	help.text = "A Codex-style local automation desk. Type normal English and press Enter: SAM plans/reviews it before anything can run. Shift+Enter adds a new line. Attach source plus multiple screenshots for visual debugging; the vision model diagnoses what is visible, then the primary coder fixes the current working file and saves a new corrected COPY. SAFE PREVIEW never executes. Remembered Regular/Admin chooses the run level after a plan, but administrator execution still requires Windows UAC each time. Risky/system-changing commands always get an extra review."
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.add_theme_color_override("font_color", colors.muted)
	page.add_child(help)
	var permission_row := HBoxContainer.new()
	permission_row.add_theme_constant_override("separation", 8)
	page.add_child(permission_row)
	var permission_label := Label.new()
	permission_label.text = "PERMISSION MODE"
	permission_row.add_child(permission_label)
	command_center_mode_selector = OptionButton.new()
	command_center_mode_selector.add_item("🛡 SAFE PREVIEW — NEVER EXECUTE")
	command_center_mode_selector.add_item("📁 WORKSPACE — CONFIRMED RUNS")
	command_center_mode_selector.add_item("⚠ FULL PC — CONFIRMED ANYWHERE")
	var saved_mode := str(settings.get("command_center_mode", "safe"))
	command_center_mode_selector.select(0 if saved_mode == "safe" else (1 if saved_mode == "workspace" else 2))
	command_center_mode_selector.item_selected.connect(command_center_mode_changed)
	permission_row.add_child(command_center_mode_selector)
	var shell_label := Label.new()
	shell_label.text = "SHELL"
	permission_row.add_child(shell_label)
	command_center_shell_selector = OptionButton.new()
	command_center_shell_selector.add_item("PowerShell")
	command_center_shell_selector.add_item("CMD")
	command_center_shell_selector.select(1 if str(settings.get("command_center_shell", "PowerShell")) == "CMD" else 0)
	command_center_shell_selector.item_selected.connect(command_center_shell_changed)
	permission_row.add_child(command_center_shell_selector)
	permission_row.add_child(make_button("🔓 REVIEW / ENABLE PC TOOLS", show_enable_pc_commands_confirmation, colors.amber))
	permission_row.add_child(make_button("🔒 LOCK NOW", lock_pc_commands, colors.green))
	command_center_status = Label.new()
	command_center_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	command_center_status.add_theme_color_override("font_color", colors.muted)
	page.add_child(command_center_status)
	var run_pref_row := HBoxContainer.new()
	run_pref_row.add_theme_constant_override("separation", 10)
	page.add_child(run_pref_row)
	var run_pref_label := Label.new()
	run_pref_label.text = "AFTER SAM PREPARES A PLAN"
	run_pref_row.add_child(run_pref_label)
	command_center_run_regular_check = CheckButton.new()
	command_center_run_regular_check.text = "ALWAYS REGULAR"
	command_center_run_regular_check.tooltip_text = "Skip the Regular/Admin chooser and run prepared non-sensitive plans as the current Windows user."
	command_center_run_regular_check.toggled.connect(_command_center_regular_default_toggled)
	run_pref_row.add_child(command_center_run_regular_check)
	command_center_run_admin_check = CheckButton.new()
	command_center_run_admin_check.text = "ALWAYS ADMIN (UAC)"
	command_center_run_admin_check.tooltip_text = "Skip the app's run-level chooser, but Windows UAC still appears for every administrator run."
	command_center_run_admin_check.toggled.connect(_command_center_admin_default_toggled)
	run_pref_row.add_child(command_center_run_admin_check)
	run_pref_row.add_child(make_button("RESET RUN CHOICE", command_center_reset_run_choice, colors.muted))
	_command_center_apply_run_preference_ui()
	var split := HSplitContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.split_offset = 530
	page.add_child(split)
	var left := VBoxContainer.new()
	left.add_theme_constant_override("separation", 6)
	split.add_child(left)
	var task_title := Label.new()
	task_title.text = "TASK / COMMAND / FILE REVIEW"
	task_title.add_theme_color_override("font_color", colors.cyan)
	left.add_child(task_title)
	var attachment_row := HBoxContainer.new()
	attachment_row.add_theme_constant_override("separation", 7)
	left.add_child(attachment_row)
	command_center_attachment_label = Label.new()
	command_center_attachment_label.text = "No Command Center file attached • drag a source/text file here or use ATTACH FILE"
	command_center_attachment_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	command_center_attachment_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	command_center_attachment_label.add_theme_color_override("font_color", colors.muted)
	attachment_row.add_child(command_center_attachment_label)
	attachment_row.add_child(make_button("📎 ATTACH FILE", command_center_choose_attachment, colors.cyan))
	attachment_row.add_child(make_button("✕ CLEAR FILE", command_center_clear_attachment, colors.muted))
	var image_row := HBoxContainer.new()
	image_row.add_theme_constant_override("separation", 7)
	left.add_child(image_row)
	command_center_image_label = Label.new()
	command_center_image_label.text = "🖼 VISUAL EVIDENCE • 0 / 6 screenshots"
	command_center_image_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	command_center_image_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	command_center_image_label.add_theme_color_override("font_color", colors.muted)
	image_row.add_child(command_center_image_label)
	image_row.add_child(make_button("🖼 ADD IMAGE(S)", command_center_choose_images, colors.cyan))
	image_row.add_child(make_button("✕ CLEAR IMAGES", command_center_clear_images, colors.muted))
	command_center_input = TextEdit.new()
	command_center_input.placeholder_text = "Tell SAM what you want done…  Enter sends • Shift+Enter adds a line\nExample: Search E:\\ for movie files and let me choose one to open."
	command_center_input.custom_minimum_size = Vector2(460, 260)
	command_center_input.size_flags_vertical = Control.SIZE_EXPAND_FILL
	command_center_input.gui_input.connect(_on_command_center_input_gui)
	left.add_child(command_center_input)
	var run_actions := HBoxContainer.new()
	run_actions.add_theme_constant_override("separation", 7)
	left.add_child(run_actions)
	run_actions.add_child(make_button("✦ ASK SAM / REVIEW", command_center_plan_with_sam, colors.cyan))
	run_actions.add_child(make_button("▶ RUN", func(): command_center_run(false), colors.green))
	run_actions.add_child(make_button("🛡 RUN AS ADMIN…", func(): command_center_run(true), colors.red))
	run_actions.add_child(make_button("■ STOP", command_center_stop_all, colors.amber))
	var secondary_actions := HBoxContainer.new()
	secondary_actions.add_theme_constant_override("separation", 7)
	left.add_child(secondary_actions)
	secondary_actions.add_child(make_button("📁 CHOOSE WORKSPACE", choose_command_workspace, colors.cyan))
	secondary_actions.add_child(make_button("📄 OPEN LAST RESULT", command_center_open_last_result, colors.green))
	secondary_actions.add_child(make_button("🧠 LEARN LAST SUCCESS", command_center_learn_last_success, colors.amber))
	secondary_actions.add_child(make_button("CLEAR TASK", func(): command_center_input.clear(), colors.muted))
	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 6)
	split.add_child(right)
	var result_title := Label.new()
	result_title.text = "FILE RESULT / REVIEW"
	result_title.add_theme_color_override("font_color", colors.green)
	right.add_child(result_title)
	command_center_result_panel = RichTextLabel.new()
	command_center_result_panel.bbcode_enabled = true
	command_center_result_panel.selection_enabled = true
	command_center_result_panel.threaded = true
	command_center_result_panel.custom_minimum_size = Vector2(0, 145)
	command_center_result_panel.append_text("[color=#8292ad]Attach source code and, when useful, up to 6 screenshots. SAM can visually diagnose the screenshots, pass that diagnosis to the primary coding model, then save a new corrected working copy with an exact before/after report. File review never needs administrator access.[/color]")
	right.add_child(command_center_result_panel)
	var result_actions := HBoxContainer.new()
	result_actions.add_theme_constant_override("separation", 7)
	right.add_child(result_actions)
	result_actions.add_child(make_button("💾 SAVE / EXPORT RESULT…", command_center_save_result_as, colors.green))
	result_actions.add_child(make_button("🔁 CONTINUE RESULT", command_center_continue_last_result, colors.amber))
	result_actions.add_child(make_button("📂 RESULT FOLDER", command_center_open_result_folder, colors.cyan))
	result_actions.add_child(make_button("📋 COPY RESULT PATH", command_center_copy_result_path, colors.muted))
	var console_title := Label.new()
	console_title.text = "PLAN / LIVE CONSOLE"
	console_title.add_theme_color_override("font_color", colors.cyan)
	right.add_child(console_title)
	command_center_output = RichTextLabel.new()
	command_center_output.bbcode_enabled = true
	command_center_output.selection_enabled = true
	command_center_output.threaded = true
	command_center_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	command_center_output.append_text("[color=#8292ad]Ready. Nothing runs until you choose a non-preview permission mode, unlock PC Tools, and approve the individual run.[/color]\n")
	right.add_child(command_center_output)
	var console_actions := HBoxContainer.new()
	right.add_child(console_actions)
	console_actions.add_child(make_button("COPY CONSOLE", func(): DisplayServer.clipboard_set(command_center_output.get_parsed_text()), colors.cyan))
	console_actions.add_child(make_button("CLEAR CONSOLE", func(): command_center_output.clear(), colors.muted))
	_command_center_refresh_status()


func _command_center_apply_run_preference_ui() -> void:
	var preference := str(settings.get("command_center_run_preference", "ask"))
	if is_instance_valid(command_center_run_regular_check):
		command_center_run_regular_check.set_pressed_no_signal(preference == "regular")
	if is_instance_valid(command_center_run_admin_check):
		command_center_run_admin_check.set_pressed_no_signal(preference == "admin")

func _command_center_regular_default_toggled(enabled: bool) -> void:
	if enabled:
		settings.command_center_run_preference = "regular"
		if is_instance_valid(command_center_run_admin_check):
			command_center_run_admin_check.set_pressed_no_signal(false)
	elif str(settings.get("command_center_run_preference", "ask")) == "regular":
		settings.command_center_run_preference = "ask"
	save_json(SETTINGS_FILE, settings)
	_command_center_refresh_status()

func _command_center_admin_default_toggled(enabled: bool) -> void:
	if enabled:
		settings.command_center_run_preference = "admin"
		if is_instance_valid(command_center_run_regular_check):
			command_center_run_regular_check.set_pressed_no_signal(false)
	elif str(settings.get("command_center_run_preference", "ask")) == "admin":
		settings.command_center_run_preference = "ask"
	save_json(SETTINGS_FILE, settings)
	_command_center_refresh_status()

func command_center_reset_run_choice() -> void:
	settings.command_center_run_preference = "ask"
	_command_center_apply_run_preference_ui()
	save_json(SETTINGS_FILE, settings)
	_command_center_refresh_status()
	show_toast("Command Center will ask Regular or Admin after each executable plan")

func _on_command_center_input_gui(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_ENTER and not event.shift_pressed:
		get_viewport().set_input_as_handled()
		call_deferred("_command_center_submit_from_enter")

func _command_center_submit_from_enter() -> void:
	if not is_instance_valid(command_center_input):
		return
	if command_center_request_active or generating or request_preparing:
		show_toast("SAM is already working on this Command Center request")
		return
	var task := command_center_input.text.strip_edges()
	if task.is_empty() and command_center_attachment_path.is_empty() and command_center_image_paths.is_empty():
		return
	if command_center_looks_executable(task) and not command_center_last_plan_script.is_empty() and task == command_center_last_plan_script.strip_edges():
		_command_center_offer_run_after_plan()
	else:
		command_center_plan_with_sam()

func command_center_mode_changed(index: int) -> void:
	settings.command_center_mode = "safe" if index == 0 else ("workspace" if index == 1 else "full")
	save_json(SETTINGS_FILE, settings)
	_command_center_refresh_status()

func command_center_shell_changed(index: int) -> void:
	settings.command_center_shell = "CMD" if index == 1 else "PowerShell"
	save_json(SETTINGS_FILE, settings)
	_command_center_refresh_status()

func _command_center_refresh_status() -> void:
	if not is_instance_valid(command_center_status):
		return
	var mode := str(settings.get("command_center_mode", "safe"))
	var permission := "PC TOOLS UNLOCKED" if bool(settings.get("pc_commands_enabled", false)) else "PC TOOLS LOCKED"
	var detail := "SAFE PREVIEW: scripts can be planned and inspected, never executed."
	if mode == "workspace":
		detail = "WORKSPACE: confirmed commands start in %s. This working-directory mode is not a Windows security sandbox." % command_workspace_dir()
	elif mode == "full":
		detail = "FULL PC: confirmed commands may target locations outside the Playground. Admin still requires a separate one-run UAC prompt."
	var run_preference := str(settings.get("command_center_run_preference", "ask"))
	var run_note := "ASK REGULAR / ADMIN" if run_preference == "ask" else ("AUTO REGULAR" if run_preference == "regular" else "AUTO ADMIN • UAC EACH RUN")
	command_center_status.text = "%s • %s • %s • %s" % [permission, str(settings.get("command_center_shell", "PowerShell")), run_note, detail]
	command_center_status.add_theme_color_override("font_color", colors.green if mode == "safe" or not bool(settings.get("pc_commands_enabled", false)) else (colors.amber if mode == "workspace" else colors.red))

func command_center_append(text_value: String, color := "#d8e7ff") -> void:
	if not is_instance_valid(command_center_output):
		return
	command_center_output.append_text("[color=%s]%s[/color]\n" % [color, escape_bbcode(text_value)])
	command_center_output.scroll_to_line(maxi(0, command_center_output.get_line_count() - 1))

func command_center_is_active() -> bool:
	var tabs := get_node_or_null("Page/Tabs") as TabContainer
	if tabs == null or tabs.current_tab < 0 or tabs.current_tab >= tabs.get_child_count():
		return false
	var current := tabs.get_child(tabs.current_tab)
	return current != null and str(current.name) == "Command Center"

func command_center_choose_attachment() -> void:
	var dialog := FileDialog.new()
	dialog.title = "Attach a file to Command Center"
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.add_filter("*.py,*.gd,*.gdshader,*.js,*.ts,*.tsx,*.jsx,*.cs,*.cpp,*.c,*.h,*.hpp,*.java,*.rs,*.go,*.html,*.css,*.scss,*.sql,*.sh,*.ps1,*.bat", "Source code")
	dialog.add_filter("*.png,*.jpg,*.jpeg,*.webp,*.bmp", "Screenshot / image")
	dialog.add_filter("*.txt,*.md,*.log,*.json,*.jsonl,*.csv,*.xml,*.yaml,*.yml,*.ini,*.cfg,*.toml", "Text and data")
	dialog.add_filter("*.*", "All files")
	dialog.file_selected.connect(func(path: String): command_center_attach_file(path); dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered_ratio(0.75)


func command_center_choose_images() -> void:
	var dialog := FileDialog.new()
	dialog.title = "Add screenshots / visual evidence"
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.add_filter("*.png,*.jpg,*.jpeg,*.webp,*.bmp", "Images")
	dialog.files_selected.connect(func(paths: PackedStringArray):
		for path in paths:
			command_center_add_image(path)
		dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered_ratio(0.75)

func _command_center_update_image_label() -> void:
	if not is_instance_valid(command_center_image_label):
		return
	if command_center_image_paths.is_empty():
		command_center_image_label.text = "🖼 VISUAL EVIDENCE • 0 / 6 screenshots"
		command_center_image_label.add_theme_color_override("font_color", colors.muted)
		return
	var names: Array[String] = []
	for path in command_center_image_paths:
		names.append(path.get_file().left(30))
	var shown_names := names.slice(0, mini(3, names.size()))
	var name_text := ", ".join(shown_names)
	if names.size() > shown_names.size():
		name_text += " +%d more" % (names.size() - shown_names.size())
	var vision_ready := FileAccess.file_exists(str(settings.vision_model_path)) and FileAccess.file_exists(str(settings.vision_mmproj_path))
	command_center_image_label.text = "🖼 VISUAL EVIDENCE • %d / 6 • %s • %s" % [command_center_image_paths.size(), name_text, "vision ready" if vision_ready else "VISION MODEL NOT CONFIGURED"]
	command_center_image_label.add_theme_color_override("font_color", colors.cyan if vision_ready else colors.amber)

func command_center_clear_images() -> void:
	command_center_image_paths.clear()
	command_center_vision_notes = ""
	_command_center_update_image_label()
	show_toast("Command Center screenshots cleared")

func _command_center_use_last_result_as_working_source() -> bool:
	if command_center_last_result_path.is_empty() or not FileAccess.file_exists(command_center_last_result_path):
		return false
	if not command_center_attachment_path.is_empty() and command_center_attachment_path != command_center_last_result_source_path and command_center_attachment_path != command_center_last_result_path:
		return false
	var raw_text := FileAccess.get_file_as_string(command_center_last_result_path)
	command_center_attachment_path = command_center_last_result_path
	command_center_attachment_text = raw_text.left(22000)
	if raw_text.length() > 22000:
		command_center_attachment_text += "\n\n[COMMAND CENTER NOTE: current working copy truncated after 22,000 characters for the local context window.]"
	command_center_attachment_kind = "code"
	command_center_attachment_hash = raw_text.sha256_text()
	if is_instance_valid(command_center_attachment_label):
		command_center_attachment_label.text = "🔁 CURRENT WORKING COPY • %s • screenshot follow-up" % command_center_last_result_path.get_file()
		command_center_attachment_label.add_theme_color_override("font_color", colors.green)
	command_center_append("ITERATIVE FIX • using the last corrected result as the new working source; the earlier copy remains preserved.", "#76f7a6")
	return true

func command_center_add_image(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var extension := path.get_extension().to_lower()
	if extension not in ["png", "jpg", "jpeg", "webp", "bmp"]:
		return false
	if path in command_center_image_paths:
		show_toast("That screenshot is already attached")
		return true
	if command_center_image_paths.size() >= 6:
		show_toast("Command Center supports up to 6 screenshots per visual-debug pass")
		return false
	var image := Image.load_from_file(path)
	if image.is_empty():
		show_toast("That screenshot could not be decoded")
		return false
	_command_center_use_last_result_as_working_source()
	command_center_image_paths.append(path)
	_command_center_update_image_label()
	if is_instance_valid(command_center_input):
		var current := command_center_input.text.strip_edges()
		if current.is_empty() or command_center_looks_executable(current) or current == command_center_last_plan_script.strip_edges():
			if not command_center_attachment_path.is_empty():
				command_center_input.text = "Use the attached screenshot(s) as visual evidence of what is wrong with the current working source. Explain why the previous result failed or looks wrong, fix the actual cause, and return the complete corrected file as a new copy."
			else:
				command_center_input.text = "Analyze the attached screenshot(s), explain exactly what is going wrong, and prepare the safest concrete fix or automation for it."
	command_center_append("VISUAL EVIDENCE ATTACHED • %s • %dx%d" % [path.get_file(), image.get_width(), image.get_height()], "#4deeea")
	show_toast("Screenshot added • %d / 6" % command_center_image_paths.size())
	return true

func command_center_attach_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		show_toast("Command Center could not find that file")
		return
	if path.get_extension().to_lower() in ["png", "jpg", "jpeg", "webp", "bmp"]:
		command_center_add_image(path)
		return
	var source := FileAccess.open(path, FileAccess.READ)
	if source == null:
		show_toast("Command Center could not read that file")
		return
	var byte_count := source.get_length()
	if byte_count > 1048576:
		show_toast("That file is larger than 1 MB • attach a smaller source file or excerpt")
		return
	var extension := path.get_extension().to_lower()
	var code_extensions := ["gd", "gdshader", "tscn", "tres", "godot", "glsl", "hlsl", "shader", "compute", "inc", "py", "js", "ts", "tsx", "jsx", "cs", "cpp", "c", "h", "hpp", "java", "rs", "go", "html", "css", "scss", "sql", "sh", "ps1", "bat"]
	var text_extensions := ["txt", "md", "log", "json", "jsonl", "csv", "tsv", "xml", "yaml", "yml", "ini", "cfg", "conf", "toml", "env", "gitignore", "dockerfile", "license", "manifest"]
	command_center_attachment_path = path
	command_center_attachment_kind = "code" if extension in code_extensions else ("text" if extension in text_extensions else "unknown")
	var raw_text := source.get_as_text()
	command_center_attachment_hash = raw_text.sha256_text()
	var context_cap := 22000
	command_center_attachment_text = raw_text.left(context_cap)
	var truncated := raw_text.length() > context_cap
	if truncated:
		command_center_attachment_text += "\n\n[COMMAND CENTER NOTE: attachment truncated after %d characters for the local context window. Do not claim to have produced a complete-file rewrite from this partial view.]" % context_cap
	if is_instance_valid(command_center_attachment_label):
		command_center_attachment_label.text = "📎 %s • %.1f KB • %s%s" % [path.get_file(), float(byte_count) / 1024.0, "source ready" if command_center_attachment_kind == "code" else "text ready", " • PARTIAL VIEW" if truncated else ""]
		command_center_attachment_label.add_theme_color_override("font_color", colors.amber if truncated or command_center_attachment_kind == "unknown" else colors.cyan)
	if command_center_last_result_source_path != path or command_center_last_result_source_hash != command_center_attachment_hash:
		command_center_last_result_path = ""
		command_center_last_review_report = ""
		_command_center_render_result_panel("", "", "")
	if is_instance_valid(command_center_input) and command_center_input.text.strip_edges().is_empty():
		command_center_input.text = "Review this attached file. Fix only real errors, explain every change and why, and save a complete corrected copy without overwriting the original."
	command_center_append("ATTACHED • %s • %.1f KB%s" % [path, float(byte_count) / 1024.0, " • partial context only" if truncated else ""], "#4deeea")
	command_center_append("FILE REVIEW READY • press ASK SAM / REVIEW. RUN and RUN AS ADMIN are for executable shell plans; source-file review itself does not need UAC or administrator access.", "#8292ad")
	show_toast("Command Center attached %s • ready for local AI review" % path.get_file())

func command_center_clear_attachment() -> void:
	command_center_attachment_path = ""
	command_center_attachment_text = ""
	command_center_attachment_kind = ""
	command_center_attachment_hash = ""
	if is_instance_valid(command_center_attachment_label):
		command_center_attachment_label.text = "No Command Center file attached • drag a source/text file here or use ATTACH FILE"
		command_center_attachment_label.add_theme_color_override("font_color", colors.muted)
	show_toast("Command Center attachment cleared")

func command_center_open_last_result() -> void:
	if command_center_last_result_path.is_empty() or not FileAccess.file_exists(command_center_last_result_path):
		show_toast("No Command Center result file is available yet")
		return
	OS.shell_open(command_center_last_result_path)

func command_center_continue_last_result() -> void:
	if not _command_center_use_last_result_as_working_source():
		show_toast("No corrected result is available to continue yet")
		return
	if is_instance_valid(command_center_input):
		command_center_input.text = "Continue from this corrected working copy. Review it again using any attached screenshots or new instructions, explain what still needs fixing, and return another complete corrected copy without overwriting this version."
	show_toast("Last result is now the current working source")

func command_center_open_result_folder() -> void:
	if command_center_last_result_path.is_empty() or not FileAccess.file_exists(command_center_last_result_path):
		show_toast("No Command Center result file is available yet")
		return
	OS.shell_open(command_center_last_result_path.get_base_dir())

func command_center_copy_result_path() -> void:
	if command_center_last_result_path.is_empty() or not FileAccess.file_exists(command_center_last_result_path):
		show_toast("No Command Center result file is available yet")
		return
	DisplayServer.clipboard_set(command_center_last_result_path)
	show_toast("Corrected file path copied")

func command_center_save_result_as() -> void:
	if command_center_last_result_path.is_empty() or not FileAccess.file_exists(command_center_last_result_path):
		show_toast("No corrected result is ready to save yet")
		return
	var dialog := FileDialog.new()
	dialog.title = "Save corrected Command Center result"
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.current_file = command_center_last_result_path.get_file()
	dialog.file_selected.connect(func(path: String):
		var bytes := FileAccess.get_file_as_bytes(command_center_last_result_path)
		var output := FileAccess.open(path, FileAccess.WRITE)
		if output == null:
			show_toast("Could not save the corrected file there")
		else:
			output.store_buffer(bytes)
			output.close()
			command_center_append("RESULT EXPORTED • %s" % path, "#76f7a6")
			show_toast("Corrected file saved • %s" % path.get_file())
		dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered_ratio(0.75)

func command_center_review_attached_file() -> void:
	if command_center_attachment_path.is_empty():
		show_toast("Attach a source file first")
		return
	if is_instance_valid(command_center_input) and not _command_center_file_edit_requested(command_center_input.text):
		command_center_input.text = "Review this attached file. Fix only real errors, explain every change and why, and save a complete corrected copy without overwriting the original."
	command_center_plan_with_sam()

func _command_center_file_edit_requested(task: String) -> bool:
	var lower := task.to_lower()
	for marker in ["fix", "repair", "edit", "modify", "change", "update", "refactor", "rewrite", "correct", "error", "bug", "send back", "full file", "complete file"]:
		if lower.contains(marker):
			return true
	return false

func _command_center_language_for_extension(extension: String) -> String:
	match extension.to_lower():
		"py": return "python"
		"gd", "gdshader": return "gdscript"
		"js", "jsx": return "javascript"
		"ts", "tsx": return "typescript"
		"cs": return "csharp"
		"cpp", "cc", "cxx", "h", "hpp": return "cpp"
		"c": return "c"
		"java": return "java"
		"rs": return "rust"
		"go": return "go"
		"html": return "html"
		"css", "scss": return "css"
		"sql": return "sql"
		"sh": return "bash"
		"ps1": return "powershell"
		"bat", "cmd": return "batch"
		"json", "jsonl": return "json"
		"yaml", "yml": return "yaml"
		_: return extension.to_lower() if not extension.is_empty() else "text"

func command_center_plan_with_sam() -> void:
	if not is_instance_valid(command_center_input):
		return
	var task := command_center_input.text.strip_edges()
	if task.is_empty() and not command_center_attachment_path.is_empty():
		task = "Review this attached file. Fix only real errors, explain every change and why, and save a complete corrected copy without overwriting the original."
		command_center_input.text = task
	elif task.is_empty() and not command_center_image_paths.is_empty():
		task = "Analyze the attached screenshots, explain exactly what is going wrong, and prepare the safest concrete fix."
		command_center_input.text = task
	if task.is_empty():
		show_toast("Describe what you want SAM to do first")
		return
	if generating or request_preparing or command_center_request_active:
		show_toast("SAM is already working on this request")
		return
	var file_edit := not command_center_attachment_path.is_empty() and _command_center_file_edit_requested(task)
	var has_visuals := not command_center_image_paths.is_empty()
	# Common local-PC questions/actions do not need a 14B model turn at all.
	# Building the deterministic plan here avoids model/context stalls and makes
	# Command Center feel immediate while preserving the same run permissions.
	if not file_edit and not has_visuals and _command_center_try_builtin_request(task):
		return
	if has_visuals and (not FileAccess.file_exists(str(settings.vision_model_path)) or not FileAccess.file_exists(str(settings.vision_mmproj_path))):
		command_center_append("VISUAL DEBUG NEEDS THE VISION MODULE • configure the Vision GGUF + matching MMPROJ in Modules/EngineSetup. No screenshots were guessed from text alone.", "#ff8095")
		show_toast("Vision model + MMPROJ are required for Command Center screenshots")
		return
	command_center_request_active = true
	command_center_file_review_active = file_edit
	command_center_plan_started_ms = Time.get_ticks_msec()
	command_center_plan_retry_count = 0
	command_center_plan_last_stream_chars = 0
	command_center_plan_last_progress_ms = command_center_plan_started_ms
	command_center_watchdog_abort = false
	command_center_history_checkpoint = history.size()
	command_center_original_task = task
	command_center_last_plan_script = ""
	command_center_vision_notes = ""
	command_center_pending_primary_followup = false
	command_center_append("YOU → SAM: " + task, "#4deeea")
	if has_visuals:
		command_center_stage = "vision_diagnose"
		command_center_append("VISION PASS • analyzing %d screenshot%s with the local vision model first…" % [command_center_image_paths.size(), "" if command_center_image_paths.size() == 1 else "s"], "#8292ad")
		var image_names: Array[String] = []
		for image_path in command_center_image_paths:
			image_names.append(image_path.get_file())
		var vision_prompt := "COMMAND CENTER VISUAL DEBUG PASS\n\nUSER TASK:\n%s\n\nSCREENSHOTS: %s\n\nInspect every attached screenshot as evidence. Transcribe visible error text/status text when relevant. Describe the exact visible symptom, what in the UI/output proves it, and the most likely technical cause(s). If multiple screenshots show a sequence, connect them in order. Do NOT write replacement code in this pass and do not pretend to have inspected source that is not visible. Return a concise VISUAL DIAGNOSIS that the primary coding model can act on next." % [task, ", ".join(image_names)]
		input_box.text = vision_prompt
		set_status("COMMAND CENTER • VISION DIAGNOSIS", colors.cyan)
		send_message()
		return
	command_center_stage = "coder"
	command_center_append("SAM is reviewing the attached source locally…" if file_edit else "SAM is interpreting the request with the local model…", "#8292ad")
	input_box.text = _command_center_build_coder_prompt(task, file_edit, "")
	set_status("COMMAND CENTER • REVIEWING FILE" if file_edit else "COMMAND CENTER • PLANNING", colors.green)
	send_message()

func _command_center_build_coder_prompt(task: String, file_edit: bool, visual_notes: String) -> String:
	var mode := str(settings.get("command_center_mode", "safe"))
	var shell := str(settings.get("command_center_shell", "PowerShell"))
	var workspace := command_workspace_dir()
	var visual_section := ""
	if not visual_notes.strip_edges().is_empty():
		visual_section = "\n\nVISUAL DIAGNOSIS FROM THE LOCAL VISION MODEL:\n%s\n\nUse this as evidence, not as infallible truth. Reconcile it against the actual source/task before changing code." % visual_notes.left(14000)
	if file_edit:
		var extension := command_center_attachment_path.get_extension().to_lower()
		var language := _command_center_language_for_extension(extension)
		return "COMMAND CENTER FILE REVIEW\n\nUSER TASK:\n%s%s\n\nCURRENT WORKING SOURCE\nPath: %s\nName: %s\nLanguage/type: %s\n\n--- BEGIN FILE ---\n%s\n--- END FILE ---\n\nFILE-REVIEW CONTRACT: Work from the current source plus any visual diagnosis. Do not produce a generic plan. First write a section titled FIX REPORT with one bullet for every actual change you made. Each bullet must state the line/area, what was wrong, what you changed, and why it fixes the observed problem. Explicitly explain why a previous result failed when the visual evidence shows that. Do not invent changes. Then return exactly one COMPLETE corrected source file in one ```%s code block. Preserve every working feature unless the user explicitly asked otherwise. Do not return a diff, placeholders, TODOs, omitted sections, PowerShell, or CMD. SAM-AI saves a new copy; the current working source remains untouched. File review does not require administrator access and nothing is executed." % [task, visual_section, command_center_attachment_path, command_center_attachment_path.get_file(), language, command_center_attachment_text, language]
	var prompt := "COMMAND CENTER INTENT REQUEST\n\nUSER TASK:\n%s%s\n\nEnvironment: Windows. Selected shell: %s. Permission mode: %s. Playground working directory: %s.\n\nIMPORTANT: The TASK above is natural-language intent unless it is obviously already shell code. Translate intent into a real result. Never place the user's English sentence directly into a .ps1/.cmd file. Nothing has executed yet. Ordinary file searches, app launches, media browsing, and user-file operations should run as the regular user unless protected system access is truly required. For long scans/searches, emit a short Write-Output progress message before each major phase so Command Center never looks frozen. Avoid administrator elevation for Out-GridView or other interactive desktop UI unless absolutely necessary.\n\nACTION CONTRACT: Return a short plan followed by exactly one complete ```%s code block containing the actual executable command/script. Use Windows-native commands for simple actions. Do not merely restate the English request inside the code block. Prefer safe, reversible commands and regular-user execution." % [task, visual_section, shell, mode.to_upper(), workspace, "powershell" if shell == "PowerShell" else "cmd"]
	if not command_center_attachment_path.is_empty():
		prompt += "\n\nATTACHMENT CONTEXT\nPath: %s\nName: %s\n\n--- BEGIN FILE ---\n%s\n--- END FILE ---\nQuote the attached path correctly if the executable action uses it." % [command_center_attachment_path, command_center_attachment_path.get_file(), command_center_attachment_text]
	return prompt

func _command_center_continue_after_vision() -> void:
	if not command_center_pending_primary_followup:
		return
	if engine_mode != "primary" or not server_ready or generating or request_preparing:
		return
	command_center_pending_primary_followup = false
	var task := command_center_original_task
	var file_edit := not command_center_attachment_path.is_empty() and _command_center_file_edit_requested(task)
	command_center_request_active = true
	command_center_file_review_active = file_edit
	command_center_stage = "coder_after_vision"
	command_center_plan_started_ms = Time.get_ticks_msec()
	command_center_plan_retry_count = 0
	command_center_plan_last_stream_chars = 0
	command_center_plan_last_progress_ms = command_center_plan_started_ms
	command_center_watchdog_abort = false
	command_center_history_checkpoint = history.size()
	command_center_append("CODER PASS • visual diagnosis complete; passing it to the primary coding model with the current working source…", "#4deeea")
	input_box.text = _command_center_build_coder_prompt(task, file_edit, command_center_vision_notes)
	set_status("COMMAND CENTER • APPLYING VISUAL FIX", colors.green)
	send_message()

func _command_center_extract_fenced(reply: String, labels: Array) -> String:
	var lower := reply.to_lower()
	for label in labels:
		var fence := "```" + str(label).to_lower()
		var start := lower.find(fence)
		if start < 0:
			continue
		var body_start := reply.find("\n", start)
		if body_start < 0:
			continue
		var finish := reply.find("```", body_start + 1)
		if finish > body_start:
			return reply.substr(body_start + 1, finish - body_start - 1).strip_edges()
	return ""

func _command_center_extract_script(reply: String) -> String:
	var shell := str(settings.get("command_center_shell", "PowerShell"))
	var script := _command_center_extract_fenced(reply, ["powershell", "ps1"] if shell == "PowerShell" else ["cmd", "bat", "batch"])
	return _command_center_harden_generated_script(script)

func _command_center_harden_generated_script(script: String) -> String:
	if script.strip_edges().is_empty():
		return script
	if str(settings.get("command_center_shell", "PowerShell")) != "PowerShell":
		return script
	var lower := script.to_lower()
	if lower.contains("get-childitem") and lower.contains("-recurse"):
		var lines := script.split("\n")
		var changed := false
		for index in range(lines.size()):
			var line := str(lines[index])
			var line_lower := line.to_lower()
			if line_lower.contains("get-childitem") and line_lower.contains("-recurse") and not line_lower.contains("-erroraction"):
				var recurse_at := line_lower.find("-recurse")
				if recurse_at >= 0:
					line = line.insert(recurse_at, "-ErrorAction SilentlyContinue ")
					lines[index] = line
					changed = true
		var prefix := "Write-Output 'SAM-AI: starting recursive scan; large drives may take several minutes.'\n"
		if not lower.contains("write-output"):
			script = prefix + "\n".join(lines)
			changed = true
		else:
			script = "\n".join(lines)
		if changed:
			command_center_append("PLAN HARDENED • added recursive-scan progress plus access-denied tolerance so a large drive search does not look frozen or abort on one protected folder.", "#8292ad")
	return script

func _command_center_builtin_intent_fallback(task: String) -> String:
	# The local model is the primary planner. These tiny fallbacks make common app
	# launch requests reliable even if a model replies conversationally without a
	# fenced script. They still go through normal preview/confirmation before run.
	var lower := task.to_lower()
	var launch_requested := lower.contains("open") or lower.contains("launch") or lower.contains("start") or lower.contains("run")
	if not launch_requested:
		return ""
	var executable := ""
	if lower.contains("paint"):
		executable = "mspaint.exe"
	elif lower.contains("edge") or lower.contains("microsoft edge"):
		executable = "msedge.exe"
	elif lower.contains("notepad"):
		executable = "notepad.exe"
	elif lower.contains("calculator") or lower.contains("calc"):
		executable = "calc.exe"
	elif lower.contains("file explorer") or lower.contains("windows explorer"):
		executable = "explorer.exe"
	if executable.is_empty():
		return ""
	return "Start-Process %s" % executable if str(settings.get("command_center_shell", "PowerShell")) == "PowerShell" else "start \"\" %s" % executable

func _command_center_extract_drive_root(task: String) -> String:
	var upper := task.to_upper()
	for index in range(maxi(0, upper.length() - 1)):
		if upper.substr(index + 1, 1) != ":":
			continue
		var code := upper.unicode_at(index)
		if code >= 65 and code <= 90:
			return upper.substr(index, 1) + ":\\"
	return ""

func _command_center_publish_builtin_plan(task: String, script: String, label: String) -> void:
	command_center_original_task = task
	command_center_last_plan_script = script.strip_edges()
	command_center_input.text = command_center_last_plan_script
	command_center_append("LOCAL FAST PLAN • %s • no model wait was needed." % label, "#76f7a6")
	command_center_append("EXECUTABLE PLAN READY • copied into TASK / COMMAND for inspection. It has NOT run.", "#f9c74f")
	set_status("COMMAND CENTER • FAST PLAN READY", colors.green)
	call_deferred("_command_center_offer_run_after_plan")

func _command_center_try_builtin_request(task: String) -> bool:
	var lower := task.to_lower().strip_edges()
	if lower in ["help", "help me", "command center help", "what can you do", "what can this do"]:
		command_center_append("COMMAND CENTER HELP\n• Type normal English and press Enter.\n• Common local tasks (time, disk space, app launch, movie search) prepare instantly without waiting for the model.\n• Source-file fixes use the coding model; screenshots use Vision first, then the coder.\n• SAFE PREVIEW never executes. WORKSPACE/FULL PC plus PC Tools control execution.\n• ALWAYS REGULAR / ALWAYS ADMIN remembers the run level; RESET RUN CHOICE returns to asking.\n• STOP cancels planning or tracked runs.", "#d8e7ff")
		set_status("COMMAND CENTER • HELP", colors.cyan)
		return true
	if lower.contains("what time") or lower == "time" or lower.contains("current time"):
		command_center_append("LOCAL CLOCK • %s on %s" % [Time.get_time_string_from_system(), Time.get_date_string_from_system()], "#76f7a6")
		set_status("COMMAND CENTER • LOCAL CLOCK", colors.green)
		return true
	if lower.contains("what date") or lower == "date" or lower.contains("today's date") or lower.contains("todays date"):
		command_center_append("LOCAL DATE • %s" % Time.get_date_string_from_system(), "#76f7a6")
		set_status("COMMAND CENTER • LOCAL DATE", colors.green)
		return true
	var drive := _command_center_extract_drive_root(task)
	var shell := str(settings.get("command_center_shell", "PowerShell"))
	if not drive.is_empty() and (lower.contains("disk space") or lower.contains("free space") or lower.contains("space left") or lower.contains("space for")):
		# Reading free space is safe metadata and does not need PowerShell, PC Tools,
		# administrator access, or the language model.
		var drive_dir := DirAccess.open(drive.replace("\\", "/"))
		if drive_dir != null:
			var free_bytes := drive_dir.get_space_left()
			command_center_append("LOCAL DISK CHECK • %s has %.2f GB free (%.0f bytes)." % [drive.left(2), float(free_bytes) / 1073741824.0, float(free_bytes)], "#76f7a6")
			set_status("COMMAND CENTER • LOCAL DISK CHECK", colors.green)
			return true
		var name := drive.left(1)
		var ps := "$d = Get-PSDrive -Name '%s' -PSProvider FileSystem -ErrorAction Stop\n$total = [double]$d.Used + [double]$d.Free\n[pscustomobject]@{ Drive='%s'; FreeGB=[math]::Round([double]$d.Free/1GB,2); UsedGB=[math]::Round([double]$d.Used/1GB,2); TotalGB=[math]::Round($total/1GB,2); FreePercent=if($total -gt 0){[math]::Round(([double]$d.Free/$total)*100,1)}else{0} } | Format-List" % [name, drive.left(2)]
		var script := ps if shell == "PowerShell" else "powershell.exe -NoProfile -Command \"%s\"" % ps.replace("\"", "\\\"").replace("\n", "; ")
		_command_center_publish_builtin_plan(task, script, "read disk usage for %s" % drive.left(2))
		return true
	var asks_movies := lower.contains("movie") or lower.contains("movies") or lower.contains("video files")
	var asks_search := lower.contains("search") or lower.contains("find") or lower.contains("list") or lower.contains("show")
	if not drive.is_empty() and asks_movies and asks_search:
		var ps := "$root = '%s'\n$extensions = @('.mp4','.mkv','.avi','.mov','.wmv','.flv','.m4v','.webm','.mpg','.mpeg','.ts')\nWrite-Output ('SAM-AI: scanning ' + $root + ' for movie files...')\n$movies = @(Get-ChildItem -LiteralPath $root -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $extensions -contains $_.Extension.ToLowerInvariant() })\nWrite-Output ('SAM-AI: found {0} movie file(s).' -f $movies.Count)\nif ($movies.Count -eq 0) { Write-Output 'No movie files found.'; exit 0 }\n$choice = $movies | Sort-Object FullName | Select-Object Name,DirectoryName,FullName,@{N='SizeGB';E={[math]::Round($_.Length/1GB,2)}},LastWriteTime | Out-GridView -Title 'Select a movie to open' -PassThru\nif ($choice) { Start-Process -FilePath $choice.FullName }" % drive.replace("'", "''")
		var script := ps if shell == "PowerShell" else "powershell.exe -NoProfile -Command \"%s\"" % ps.replace("\"", "\\\"").replace("\n", "; ")
		_command_center_publish_builtin_plan(task, script, "movie search for %s" % drive)
		return true
	var launcher := _command_center_builtin_intent_fallback(task)
	if not launcher.is_empty():
		_command_center_publish_builtin_plan(task, launcher, "common Windows app launch")
		return true
	return false

func _command_center_extract_result_file(reply: String) -> String:
	if command_center_attachment_path.is_empty():
		return ""
	var extension := command_center_attachment_path.get_extension().to_lower()
	var language := _command_center_language_for_extension(extension)
	var labels: Array[String] = [language]
	if extension == "py": labels.append("py")
	elif extension in ["gd", "gdshader"]: labels.append("gd")
	elif extension in ["js", "jsx"]: labels.append("js")
	elif extension in ["ts", "tsx"]: labels.append("ts")
	elif extension == "cs": labels.append("cs")
	elif extension in ["cpp", "h", "hpp"]: labels.append("c++")
	var result := _command_center_extract_fenced(reply, labels)
	if not result.is_empty():
		return result
	# Accept one generic fenced block only when this was explicitly a file-edit
	# request and the model omitted the language label.
	var first := reply.find("```")
	if first >= 0:
		var body_start := reply.find("\n", first)
		var finish := reply.find("```", body_start + 1) if body_start >= 0 else -1
		if body_start >= 0 and finish > body_start and reply.find("```", finish + 3) < 0:
			return reply.substr(body_start + 1, finish - body_start - 1).strip_edges()
	return ""

func _command_center_extract_review_notes(reply: String) -> String:
	var fence := reply.find("```")
	var notes := reply.substr(0, fence).strip_edges() if fence >= 0 else reply.strip_edges()
	if notes.length() > 3500:
		notes = notes.left(3500).strip_edges() + "\n…"
	return notes

func _command_center_change_reason(before: String, after: String) -> String:
	var old_text := before.strip_edges()
	var new_text := after.strip_edges()
	if old_text.begins_with(new_text) and old_text.length() == new_text.length() + 1:
		return "Removed one stray trailing character that changed or broke the statement."
	if new_text.begins_with(old_text) and new_text.length() == old_text.length() + 1:
		return "Added one missing character needed by the corrected statement."
	if old_text.contains("print(") and new_text.contains("print("):
		return "Corrected content inside an output statement; the exact before/after text is shown."
	if old_text.get_slice("=", 0).strip_edges() == new_text.get_slice("=", 0).strip_edges() and old_text.contains("=") and new_text.contains("="):
		return "Corrected the value/expression while preserving the same assignment target."
	return "SAM changed this line. The exact local before/after comparison is shown so the user can verify the reason against the source."

func _command_center_build_change_report(original: String, corrected: String) -> String:
	var old_lines := original.replace("\r\n", "\n").replace("\r", "\n").split("\n", true)
	var new_lines := corrected.replace("\r\n", "\n").replace("\r", "\n").split("\n", true)
	var i := 0
	var j := 0
	var changes: Array[String] = []
	var max_changes := 24
	while (i < old_lines.size() or j < new_lines.size()) and changes.size() < max_changes:
		if i < old_lines.size() and j < new_lines.size() and str(old_lines[i]) == str(new_lines[j]):
			i += 1
			j += 1
			continue
		var remove_count := -1
		var add_count := -1
		for look in range(1, 6):
			if remove_count < 0 and i + look < old_lines.size() and j < new_lines.size() and str(old_lines[i + look]) == str(new_lines[j]):
				remove_count = look
			if add_count < 0 and j + look < new_lines.size() and i < old_lines.size() and str(new_lines[j + look]) == str(old_lines[i]):
				add_count = look
		if remove_count > 0 and (add_count < 0 or remove_count <= add_count):
			for offset in range(remove_count):
				changes.append("REMOVED original line %d: %s\n  Why: this line was removed by the corrected copy; review it before replacing the original." % [i + offset + 1, str(old_lines[i + offset]).strip_edges()])
			i += remove_count
			continue
		if add_count > 0:
			for offset in range(add_count):
				changes.append("ADDED corrected line %d: %s\n  Why: this line was added by the corrected copy; review it before replacing the original." % [j + offset + 1, str(new_lines[j + offset]).strip_edges()])
			j += add_count
			continue
		if i < old_lines.size() and j < new_lines.size():
			var before := str(old_lines[i])
			var after := str(new_lines[j])
			changes.append("CHANGED line %d\n  Before: %s\n  After:  %s\n  Why: %s" % [i + 1, before.strip_edges(), after.strip_edges(), _command_center_change_reason(before, after)])
			i += 1
			j += 1
		elif i < old_lines.size():
			changes.append("REMOVED original line %d: %s" % [i + 1, str(old_lines[i]).strip_edges()])
			i += 1
		elif j < new_lines.size():
			changes.append("ADDED corrected line %d: %s" % [j + 1, str(new_lines[j]).strip_edges()])
			j += 1
	if changes.is_empty():
		return "No line-level differences were found between the attached source and the returned copy."
	var suffix := ""
	if i < old_lines.size() or j < new_lines.size():
		suffix = "\n\nMore changes exist; open the corrected copy for the complete file."
	var joined_changes := ""
	for change_index in range(changes.size()):
		if change_index > 0:
			joined_changes += "\n\n"
		joined_changes += changes[change_index]
	return "%d local change(s) shown:\n\n%s%s" % [changes.size(), joined_changes, suffix]

func _command_center_render_result_panel(model_notes: String, change_report: String, result_path: String) -> void:
	if not is_instance_valid(command_center_result_panel):
		return
	command_center_result_panel.clear()
	if result_path.is_empty():
		command_center_result_panel.append_text("[color=#8292ad]No corrected result is ready for the currently attached file yet. File review runs through SAM locally and does not need RUN, RUN AS ADMIN, PC Tools, or UAC.[/color]")
		return
	var text := "[font_size=18][color=#76f7a6][b]✓ CORRECTED FILE READY[/b][/color][/font_size]\n[color=#4deeea]%s[/color]\n[color=#8292ad]Original preserved • source was not executed[/color]\n" % escape_bbcode(result_path)
	if not model_notes.is_empty():
		text += "\n[color=#f9c74f][b]SAM'S FIX NOTES[/b][/color]\n%s\n" % escape_bbcode(model_notes)
	if not change_report.is_empty():
		text += "\n[color=#76f7a6][b]EXACT LOCAL BEFORE / AFTER CHECK[/b][/color]\n%s" % escape_bbcode(change_report)
	command_center_result_panel.append_text(text)
	command_center_result_panel.scroll_to_line(0)

func _command_center_save_review_report(result_path: String, model_notes: String, change_report: String) -> void:
	if result_path.is_empty():
		return
	var report_path := result_path.get_basename() + ".review.txt"
	var report := FileAccess.open(report_path, FileAccess.WRITE)
	if report == null:
		return
	report.store_string("SAM-AI COMMAND CENTER FILE REVIEW\n\nOriginal: %s\nCorrected: %s\nOriginal preserved: yes\nCorrected source executed: no\n\nSAM FIX NOTES\n%s\n\nEXACT LOCAL BEFORE / AFTER CHECK\n%s\n" % [command_center_last_result_source_path, result_path, model_notes, change_report])
	report.close()

func _command_center_save_result_file(content: String) -> String:
	if command_center_attachment_path.is_empty() or content.strip_edges().is_empty():
		return ""
	var stamp := Time.get_datetime_string_from_system().replace(":", "-") + "-%d" % Time.get_ticks_msec()
	var folder := command_workspace_dir().path_join("CommandCenter").path_join("AIResults").path_join(stamp)
	DirAccess.make_dir_recursive_absolute(folder)
	var result_path := folder.path_join("fixed_" + command_center_attachment_path.get_file())
	var output := FileAccess.open(result_path, FileAccess.WRITE)
	if output == null:
		return ""
	output.store_string(content + ("\n" if not content.ends_with("\n") else ""))
	output.close()
	command_center_last_result_path = result_path
	command_center_last_result_source_path = command_center_attachment_path
	command_center_last_result_source_hash = command_center_attachment_hash
	return result_path

func command_center_receive_sam_reply(reply: String) -> void:
	if not command_center_request_active:
		return
	if command_center_stage == "vision_diagnose":
		command_center_request_active = false
		command_center_file_review_active = false
		command_center_plan_started_ms = 0
		command_center_plan_retry_count = 0
		command_center_plan_last_stream_chars = 0
		command_center_plan_last_progress_ms = 0
		command_center_watchdog_abort = false
		command_center_vision_notes = reply.strip_edges().left(14000)
		command_center_pending_primary_followup = true
		command_center_stage = "waiting_primary"
		command_center_append("VISION DIAGNOSIS COMPLETE:", "#76f7a6")
		command_center_append(command_center_vision_notes, "#d8e7ff")
		command_center_append("Restoring the primary coding model so it can apply the diagnosis to the actual task/source…", "#f9c74f")
		set_status("COMMAND CENTER • RESTORING CODER", colors.amber)
		return
	var was_file_review := command_center_file_review_active and not command_center_attachment_path.is_empty() and _command_center_file_edit_requested(command_center_original_task)
	command_center_request_active = false
	command_center_file_review_active = false
	command_center_plan_started_ms = 0
	command_center_plan_retry_count = 0
	command_center_plan_last_stream_chars = 0
	command_center_plan_last_progress_ms = 0
	command_center_watchdog_abort = false
	command_center_stage = ""
	var handled := false
	if was_file_review:
		var corrected := _command_center_extract_result_file(reply)
		var model_notes := _command_center_extract_review_notes(reply)
		if not corrected.is_empty():
			var original_text := FileAccess.get_file_as_string(command_center_attachment_path) if FileAccess.file_exists(command_center_attachment_path) else command_center_attachment_text
			var result_path := _command_center_save_result_file(corrected)
			if not result_path.is_empty():
				handled = true
				var change_report := _command_center_build_change_report(original_text, corrected)
				var visual_note := "\n\nVISUAL EVIDENCE USED: %d screenshot%s" % [command_center_image_paths.size(), "" if command_center_image_paths.size() == 1 else "s"] if not command_center_image_paths.is_empty() else ""
				command_center_last_review_report = "SAM'S FIX NOTES\n%s\n\nEXACT LOCAL BEFORE / AFTER CHECK\n%s%s" % [model_notes, change_report, visual_note]
				_command_center_save_review_report(result_path, model_notes, change_report + visual_note)
				command_center_append("FILE REVIEW COMPLETE • corrected copy saved without overwriting the working source.", "#76f7a6")
				if not model_notes.is_empty():
					command_center_append("SAM'S FIX NOTES:\n" + model_notes, "#d8e7ff")
				command_center_append("EXACT LOCAL CHANGE CHECK:\n" + change_report, "#8292ad")
				command_center_append("CORRECTED COPY • %s" % result_path, "#76f7a6")
				command_center_append("Use OPEN LAST RESULT, SAVE / EXPORT RESULT, or RESULT FOLDER. Drop another screenshot to continue fixing this new working copy.", "#f9c74f")
				_command_center_render_result_panel(model_notes + visual_note, change_report, result_path)
				if is_instance_valid(command_center_attachment_label):
					command_center_attachment_label.text = "✅ REVIEW COMPLETE • %s • drop screenshots for another pass" % result_path.get_file()
					command_center_attachment_label.add_theme_color_override("font_color", colors.green)
		else:
			command_center_append("SAM did not return one complete corrected-file code block, so no result file was created. Nothing was executed.", "#ff8095")
			_command_center_render_result_panel(model_notes, "No corrected code block was returned.", "")
	else:
		command_center_append("SAM PLAN / RESULT:", "#76f7a6")
		command_center_append(reply, "#d8e7ff")
		var script := _command_center_extract_script(reply)
		if script.is_empty():
			script = _command_center_builtin_intent_fallback(command_center_original_task)
			if not script.is_empty():
				command_center_append("SAM's prose did not include a runnable fence, so Command Center used its built-in safe launcher translation for this common request.", "#8292ad")
		if not script.is_empty() and is_instance_valid(command_center_input):
			handled = true
			command_center_last_plan_script = script
			command_center_input.text = script
			command_center_append("EXECUTABLE PLAN READY • copied into TASK / COMMAND for inspection. It has NOT run.", "#f9c74f")
			call_deferred("_command_center_offer_run_after_plan")
	if not handled:
		command_center_append("Nothing executable or exportable was prepared. Review SAM's explanation above or press ASK SAM / REVIEW again with a more specific request.", "#f9c74f")
	_command_center_refresh_status()

func _command_center_line_looks_executable(line: String) -> bool:
	var text := line.strip_edges()
	if text.is_empty() or text.begins_with("#") or text.begins_with("REM ") or text.begins_with("::"):
		return false
	var lower := text.to_lower()
	for prefix in ["$", "& ", ".\\", "./", "if ", "foreach ", "for ", "while ", "try", "function ", "param(", "[cmdletbinding", "set-strictmode", "throw ", "exit ", "get-", "set-", "new-", "remove-", "start-", "stop-", "invoke-", "write-", "test-", "copy-", "move-", "rename-", "import-", "export-", "select-", "where-", "out-", "add-", "clear-"]:
		if lower.begins_with(prefix):
			return true
	var first := lower.get_slice(" ", 0)
	if first in ["powershell", "powershell.exe", "pwsh", "cmd", "cmd.exe", "python", "python.exe", "py", "node", "node.exe", "git", "code", "code.exe", "godot", "godot.exe", "explorer", "explorer.exe", "mspaint", "mspaint.exe", "notepad", "notepad.exe", "start", "dir", "echo", "mkdir", "md", "copy", "xcopy", "robocopy", "move", "del", "erase", "ren", "rename", "type", "where", "tasklist", "taskkill", "schtasks", "reg"]:
		return true
	return false

func command_center_looks_executable(command_text: String) -> bool:
	var trimmed := command_text.strip_edges()
	if trimmed.is_empty():
		return false
	if not command_center_last_plan_script.is_empty() and trimmed == command_center_last_plan_script.strip_edges():
		return true
	for line in trimmed.split("\n"):
		if _command_center_line_looks_executable(str(line)):
			return true
	return false


func _command_center_offer_run_after_plan() -> void:
	if command_center_last_plan_script.is_empty() or not is_instance_valid(command_center_input):
		return
	if command_center_input.text.strip_edges() != command_center_last_plan_script.strip_edges():
		return
	var mode := str(settings.get("command_center_mode", "safe"))
	if mode == "safe":
		command_center_append("PLAN READY • SAFE PREVIEW is active, so it will stay inspect-only until you change Permission Mode.", "#8292ad")
		return
	if not bool(settings.get("pc_commands_enabled", false)):
		command_center_append("PLAN READY • unlock PC Tools when you want to execute it.", "#8292ad")
		return
	var preference := str(settings.get("command_center_run_preference", "ask"))
	if preference == "regular":
		command_center_append("RUN DEFAULT • regular user selected; starting the prepared plan without the app run-level chooser.", "#76f7a6")
		command_center_run(false, true)
		return
	if preference == "admin":
		if mode != "full":
			command_center_append("AUTO ADMIN is selected, but administrator runs require FULL PC mode. Choose FULL PC or reset the run choice.", "#f9c74f")
			return
		command_center_append("RUN DEFAULT • administrator selected; requesting Windows UAC for this run. UAC cannot be bypassed or remembered by SAM-AI.", "#f9c74f")
		command_center_run(true, true)
		return
	_command_center_show_run_level_dialog()

func _command_center_show_run_level_dialog() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "HOW SHOULD THIS PLAN RUN?"
	dialog.dialog_text = "SAM prepared the script shown in TASK / COMMAND.\n\nRUN REGULAR is recommended for ordinary file searches, opening apps, media browsing, and user-file work.\n\nRUN AS ADMIN is only for protected system changes and still triggers Windows UAC.\n\nCheck REMEMBER MY CHOICE to skip this chooser next time. SAFE DEFAULTS or RESET RUN CHOICE restores ASK mode."
	dialog.ok_button_text = "RUN REGULAR"
	dialog.add_button("RUN AS ADMIN", true, "admin")
	var remember := CheckButton.new()
	remember.text = "REMEMBER MY CHOICE"
	remember.tooltip_text = "Stores only Regular vs Admin preference. Windows UAC is never bypassed or remembered."
	var dialog_content := dialog.get_label().get_parent()
	if dialog_content is Container:
		(dialog_content as Container).add_child(remember)
	else:
		dialog.add_child(remember)
	dialog.confirmed.connect(func():
		if remember.button_pressed:
			settings.command_center_run_preference = "regular"
			_command_center_apply_run_preference_ui()
			save_json(SETTINGS_FILE, settings)
		dialog.queue_free()
		command_center_run(false, true))
	dialog.custom_action.connect(func(action: StringName):
		if action == "admin":
			if remember.button_pressed:
				settings.command_center_run_preference = "admin"
				_command_center_apply_run_preference_ui()
				save_json(SETTINGS_FILE, settings)
			dialog.queue_free()
			command_center_run(true, true))
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, colors.cyan)
	dialog.popup_centered(Vector2i(760, 470))

func _command_center_command_is_sensitive(command_text: String) -> bool:
	var lower := command_text.to_lower()
	for marker in ["remove-item", "clear-disk", "format ", "diskpart", "bcdedit", "reg delete", "reg add", "del /s", "rd /s", "rmdir /s", "shutdown ", "restart-computer", "stop-computer", "set-executionpolicy", "disable-windows", "enable-windowsoptionalfeature", "winget install", "choco install", "invoke-webrequest", "curl http", "curl.exe http"]:
		if lower.contains(marker):
			return true
	return false

func _command_center_start_job(job: Dictionary, elevated: bool) -> void:
	job.elevated = elevated
	job.started = Time.get_ticks_msec()
	job.last_progress_note = 0
	var lower_command := str(job.get("command", "")).to_lower()
	if lower_command.contains("get-childitem") and lower_command.contains("-recurse"):
		command_center_append("LONG SCAN DETECTED • recursive drive/folder searches can take several minutes. Command Center will keep showing elapsed time even if PowerShell produces no output yet.", "#f9c74f")
	if lower_command.contains("out-gridview") and elevated:
		command_center_append("INTERACTIVE UI NOTE • Out-GridView normally works best as the regular Windows user. If no picker appears after the scan, rerun this plan as REGULAR rather than ADMIN.", "#f9c74f")
	if elevated:
		_command_center_launch_admin_job(job)
		return
	var pid := OS.create_process("cmd.exe", PackedStringArray(["/d", "/c", str(job.runner)]), false)
	if pid <= 0:
		command_center_append("Could not start the command runner.", "#ff8095")
		return
	job.pid = pid
	job.phase = "running"
	command_process_pids.append(pid)
	command_center_jobs.append(job)
	command_center_append("RUNNING AS REGULAR USER • %s" % str(job.script), "#76f7a6")
	_command_center_refresh_status()

func _command_center_launch_admin_job(job: Dictionary) -> void:
	if OS.get_name() != "Windows":
		show_toast("Administrator run is available only on Windows")
		return
	var folder := str(job.folder)
	admin_status_path = folder.path_join("admin_status.json")
	if FileAccess.file_exists(admin_status_path):
		DirAccess.remove_absolute(admin_status_path)
	var entry_path := folder.path_join("admin_entry.ps1")
	var helper_path := folder.path_join("request_admin.pyw")
	var ps_status := admin_status_path.replace("'", "''")
	var ps_runner := str(job.runner).replace("'", "''")
	var ps_folder := folder.replace("'", "''")
	var entry := FileAccess.open(entry_path, FileAccess.WRITE)
	if entry == null:
		command_center_append("Could not prepare the hidden administrator entry script.", "#ff8095")
		return
	var entry_text := "$ErrorActionPreference = 'Stop'\n$status = '%s'\n$runner = '%s'\n$work = '%s'\ntry {\n    @{ state = 'accepted'; pid = $PID } | ConvertTo-Json -Compress | Set-Content -LiteralPath $status -Encoding ASCII\n    $arg = '/d /c \"' + $runner + '\"'\n    $p = Start-Process -FilePath 'cmd.exe' -ArgumentList $arg -WorkingDirectory $work -WindowStyle Hidden -PassThru\n    $p.WaitForExit()\n    exit $p.ExitCode\n} catch {\n    @{ state = 'failed'; pid = $PID; error = $_.Exception.Message } | ConvertTo-Json -Compress | Set-Content -LiteralPath $status -Encoding ASCII\n    exit 1\n}\n" % [ps_status, ps_runner, ps_folder]
	entry.store_string(entry_text)
	entry.close()
	var helper := FileAccess.open(helper_path, FileAccess.WRITE)
	if helper == null:
		command_center_append("Could not prepare the hidden Windows UAC helper.", "#ff8095")
		return
	var helper_text := "import ctypes, json, os, sys, time\nentry, work, status = sys.argv[1:4]\nshell = ctypes.windll.shell32.ShellExecuteW\nshell.restype = ctypes.c_void_p\nparams = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File \\\"' + entry + '\\\"'\nrc = int(shell(None, 'runas', 'powershell.exe', params, work, 0) or 0)\nif rc <= 32:\n    with open(status, 'w', encoding='utf-8') as f:\n        json.dump({'state':'denied','code':rc}, f)\nelse:\n    for _ in range(100):\n        if os.path.exists(status):\n            break\n        time.sleep(0.1)\n"
	helper.store_string(helper_text)
	helper.close()
	var pythonw := str(settings.voice_python_path).replace("python.exe", "pythonw.exe")
	if not FileAccess.file_exists(pythonw):
		command_center_append("Pythonw is missing, so the hidden UAC helper could not start.", "#ff8095")
		admin_status_path = ""
		return
	pc_admin_request_active = true
	job.phase = "uac"
	command_center_jobs.append(job)
	admin_helper_pid = OS.create_process(pythonw, PackedStringArray([helper_path, entry_path, folder, admin_status_path]), false)
	if admin_helper_pid <= 0:
		pc_admin_request_active = false
		admin_status_path = ""
		command_center_jobs.pop_back()
		command_center_append("Could not start the hidden Windows UAC helper.", "#ff8095")
		return
	refresh_pc_commands_indicator()
	command_center_append("WAITING FOR WINDOWS UAC • administrator access applies to this run only. The elevated runner stays hidden; progress/output remain here in Command Center.", "#f9c74f")
	_command_center_refresh_status()

func command_center_requires_full_pc(command_text: String) -> bool:
	var lower := command_text.to_lower().replace("/", "\\")
	for marker in ["diskpart", "bcdedit", "reg delete", "format ", "clear-disk", "remove-partition", "shutdown ", "restart-computer", "stop-computer", "remove-item -recurse c:\\", "del /s c:\\", "rd /s c:\\"]:
		if lower.contains(marker):
			return true
	return false

func _command_center_write_job(command_text: String) -> Dictionary:
	var stamp := Time.get_datetime_string_from_system().replace(":", "-") + "-%d" % Time.get_ticks_msec()
	var folder := command_workspace_dir().path_join("CommandCenter").path_join(stamp)
	DirAccess.make_dir_recursive_absolute(folder)
	var shell := str(settings.get("command_center_shell", "PowerShell"))
	var extension := "ps1" if shell == "PowerShell" else "cmd"
	var script_path := folder.path_join("task." + extension)
	var output_path := folder.path_join("output.log")
	var exit_path := folder.path_join("exit.txt")
	var runner_path := folder.path_join("run.cmd")
	var script := FileAccess.open(script_path, FileAccess.WRITE)
	if script == null:
		return {}
	script.store_string(command_text + ("\n" if not command_text.ends_with("\n") else ""))
	script.close()
	var run_command := ""
	if shell == "PowerShell":
		var wrapper_path := folder.path_join("invoke_task.ps1")
		var wrapper := FileAccess.open(wrapper_path, FileAccess.WRITE)
		if wrapper == null:
			return {}
		var escaped_script := script_path.replace("'", "''")
		wrapper.store_string("$ErrorActionPreference = 'Continue'\ntry {\n    & '%s'\n    if ($LASTEXITCODE -is [int] -and $LASTEXITCODE -ne 0) { exit $LASTEXITCODE }\n    if (-not $?) { exit 1 }\n    exit 0\n} catch {\n    Write-Error ($_ | Out-String)\n    exit 1\n}\n" % escaped_script)
		wrapper.close()
		run_command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"%s\"" % wrapper_path.replace("/", "\\")
	else:
		run_command = "call \"%s\"" % script_path.replace("/", "\\")
	var runner_text := "@echo off\r\ncd /d \"%s\"\r\n%s > \"%s\" 2>&1\r\nset SAM_EXIT=%%ERRORLEVEL%%\r\n>\"%s\" echo %%SAM_EXIT%%\r\nexit /b %%SAM_EXIT%%\r\n" % [command_workspace_dir().replace("/", "\\"), run_command, output_path.replace("/", "\\"), exit_path.replace("/", "\\")]
	var runner := FileAccess.open(runner_path, FileAccess.WRITE)
	if runner == null:
		return {}
	runner.store_string(runner_text)
	runner.close()
	return {"task": command_center_original_task, "command": command_text, "shell": shell, "folder": folder, "script": script_path, "runner": runner_path, "output": output_path, "exit": exit_path, "seen": 0, "pid": -1, "elevated": false, "started": Time.get_ticks_msec()}

func command_center_run(elevated: bool = false, skip_app_confirmation: bool = false) -> void:
	if not is_instance_valid(command_center_input):
		return
	var command_text := command_center_input.text.strip_edges()
	if command_text.is_empty():
		show_toast("There is no command or task to run")
		return
	if not command_center_attachment_path.is_empty() and _command_center_file_edit_requested(command_text):
		if command_center_request_active or generating or request_preparing:
			show_toast("SAM is already reviewing this file")
			return
		if command_center_last_result_source_path == command_center_attachment_path and command_center_last_result_source_hash == command_center_attachment_hash and not command_center_last_result_path.is_empty() and FileAccess.file_exists(command_center_last_result_path):
			command_center_append("FILE REVIEW ALREADY COMPLETE • RUN / ADMIN do not apply to a corrected source copy. Drop a screenshot for another visual-debug pass or use OPEN LAST RESULT.", "#76f7a6")
			return
		command_center_append("FILE REVIEW MODE • source review is an AI transformation, not a shell/admin command. Starting review instead; nothing executed.", "#4deeea")
		command_center_plan_with_sam()
		return
	if not command_center_looks_executable(command_text):
		command_center_append("INTENT DETECTED • this is plain English, not executable shell. Asking SAM to translate it first; nothing ran.", "#f9c74f")
		command_center_plan_with_sam()
		return
	var mode := str(settings.get("command_center_mode", "safe"))
	if mode == "safe":
		command_center_append("SAFE PREVIEW blocked execution. Change Permission Mode only if you want to run this command.", "#f9c74f")
		show_toast("Safe Preview is active • nothing ran")
		return
	if not bool(settings.get("pc_commands_enabled", false)):
		show_enable_pc_commands_confirmation()
		return
	if elevated and OS.get_name() != "Windows":
		show_toast("Administrator run is available only on Windows")
		return
	if elevated and mode != "full":
		show_toast("Administrator runs require FULL PC mode plus Windows UAC")
		return
	if mode == "workspace" and command_center_requires_full_pc(command_text):
		command_center_append("Blocked in WORKSPACE mode because the command contains system-level/destructive markers. Review it and use FULL PC only if that is truly intended.", "#ff8095")
		show_toast("Command requires Full PC mode")
		return
	if elevated and pc_admin_request_active:
		show_toast("Another administrator request/run is already active")
		return
	var job := _command_center_write_job(command_text)
	if job.is_empty():
		show_toast("Could not prepare the Command Center job")
		return
	var sensitive := _command_center_command_is_sensitive(command_text) or command_center_requires_full_pc(command_text)
	if skip_app_confirmation and not sensitive:
		_command_center_start_job(job, elevated)
		return
	var dialog := ConfirmationDialog.new()
	dialog.title = "RUN SENSITIVE COMMAND AS ADMINISTRATOR?" if elevated else ("RUN SENSITIVE COMMAND?" if sensitive else "RUN COMMAND?")
	var warning := "Windows UAC will appear. Administrator permission applies to this one run only." if elevated else "This run uses the current Windows user."
	dialog.dialog_text = "Mode: %s\nShell: %s\n%s\n\nWorking directory:\n%s\n\nScript:\n%s\n\nReview before continuing:\n\n%s" % [mode.to_upper(), str(job.shell), warning, command_workspace_dir(), str(job.script), command_text.left(3000)]
	dialog.ok_button_text = "REQUEST UAC + RUN" if elevated else "RUN THIS ONCE"
	dialog.confirmed.connect(func(): dialog.queue_free(); _command_center_start_job(job, elevated))
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, colors.red if elevated or sensitive else colors.cyan)
	dialog.popup_centered(Vector2i(820, 560))

func poll_command_center_jobs() -> void:
	var now := Time.get_ticks_msec()
	if command_center_request_active and is_instance_valid(command_center_status):
		var frame := int(now / 250) % 4
		var elapsed_ms := maxi(0, now - command_center_plan_started_ms) if command_center_plan_started_ms > 0 else 0
		var elapsed_seconds := float(elapsed_ms) / 1000.0
		var phase := "SAM IS ANALYZING SCREENSHOTS" if command_center_stage == "vision_diagnose" else ("SAM IS REVIEWING / FIXING" if command_center_file_review_active else "SAM IS PLANNING")
		var transport := "checking context" if request_preparing else ("connecting" if not bool(get_meta("request_sent", false)) else ("waiting for first token" if response_text.is_empty() else "streaming %d chars" % response_text.length()))
		command_center_status.text = "%s %s • %.1fs • %s" % [phase, "•".repeat(frame + 1), elapsed_seconds, transport]
		if response_text.length() != command_center_plan_last_stream_chars:
			command_center_plan_last_stream_chars = response_text.length()
			command_center_plan_last_progress_ms = now
		if response_text.is_empty() and not request_preparing and not context_reload_pending:
			if not bool(get_meta("request_sent", false)) and elapsed_ms >= COMMAND_CENTER_CONNECT_RECOVERY_MS and command_center_plan_retry_count == 0:
				command_center_plan_retry_count = 1
				command_center_append("PLANNER CONNECTION RECOVERY • the request never reached the model; reconnecting once…", "#f9c74f")
				retry_stream_request(ERR_TIMEOUT, 250)
			elif bool(get_meta("request_sent", false)) and elapsed_ms >= COMMAND_CENTER_FIRST_TOKEN_RECOVERY_MS and command_center_plan_retry_count < 2:
				command_center_plan_retry_count = 2
				command_center_append("PLANNER FIRST-TOKEN RECOVERY • the local model accepted the request but returned nothing; retrying the same plan once…", "#f9c74f")
				retry_stream_request(ERR_TIMEOUT, 250)
		var hard_timeout := COMMAND_CENTER_REVIEW_HARD_TIMEOUT_MS if command_center_file_review_active or command_center_stage == "vision_diagnose" or command_center_stage == "coder_after_vision" else COMMAND_CENTER_PLAN_HARD_TIMEOUT_MS
		var stalled_after_output := not response_text.is_empty() and command_center_plan_last_progress_ms > 0 and now - command_center_plan_last_progress_ms >= 90000
		if elapsed_ms >= hard_timeout or stalled_after_output:
			command_center_append("PLANNER WATCHDOG • the local model stopped making progress. Resetting this request instead of leaving Command Center frozen.", "#ff8095")
			command_center_watchdog_abort = true
			stop_generation()
			set_status("COMMAND CENTER • PLANNER RESET", colors.amber)
			show_toast("Planner reset • nothing executed • try again or use a local fast task")
			return
	if now - command_center_last_status_ms < 120:
		return
	command_center_last_status_ms = now
	for index in range(command_center_jobs.size() - 1, -1, -1):
		var job: Dictionary = command_center_jobs[index]
		var output_path := str(job.get("output", ""))
		var output_length := 0
		if FileAccess.file_exists(output_path):
			var output := FileAccess.get_file_as_string(output_path)
			output_length = output.length()
			var seen := int(job.get("seen", 0))
			if output.length() > seen:
				var fresh := output.substr(seen).right(12000)
				command_center_append(fresh.strip_edges(false, true), "#d8e7ff")
				job.seen = output.length()
		var exit_path := str(job.get("exit", ""))
		if FileAccess.file_exists(exit_path):
			var exit_code := int(FileAccess.get_file_as_string(exit_path).strip_edges())
			command_center_append("FINISHED • exit code %d • %s" % [exit_code, str(job.get("folder", ""))], "#76f7a6" if exit_code == 0 else "#ff8095")
			if exit_code == 0:
				set_meta("command_center_last_success", job.duplicate(true))
			command_center_jobs.remove_at(index)
			_command_center_refresh_status()
			continue
		var elapsed_ms := now - int(job.get("started", now))
		if bool(job.get("elevated", false)) and str(job.get("phase", "")) == "uac" and admin_status_path.is_empty() and admin_console_pid > 0:
			job.phase = "running"
		var phase := "WAITING FOR UAC" if bool(job.get("elevated", false)) and str(job.get("phase", "")) == "uac" else ("RUNNING AS ADMIN" if bool(job.get("elevated", false)) else "RUNNING")
		if is_instance_valid(command_center_status) and not command_center_request_active:
			command_center_status.text = "%s • %.1fs • %s" % [phase, float(elapsed_ms) / 1000.0, "waiting for first output" if output_length == 0 else "output streaming"]
		var last_note := int(job.get("last_progress_note", 0))
		if elapsed_ms >= 6000 and now - last_note >= 10000:
			command_center_append("%s • %.0fs elapsed • %s" % [phase, float(elapsed_ms) / 1000.0, "still working; this command has not produced output yet" if output_length == 0 else "still working"], "#8292ad")
			job.last_progress_note = now
		command_center_jobs[index] = job
		if bool(job.get("elevated", false)) and elapsed_ms > 5000 and not pc_admin_request_active and admin_status_path.is_empty():
			command_center_append("Administrator run was canceled or did not start.", "#ff8095")
			command_center_jobs.remove_at(index)

func command_center_stop_all() -> void:
	var stopped_planning := command_center_request_active or (generating and command_center_is_active())
	if stopped_planning:
		stop_generation()
	command_center_stop_runs()
	if stopped_planning:
		show_toast("SAM review/planning stopped")

func command_center_stop_runs() -> void:
	var stopped := 0
	for pid in command_process_pids:
		if pid <= 0 or not OS.is_process_running(pid):
			continue
		if OS.get_name() == "Windows":
			OS.create_process("taskkill.exe", PackedStringArray(["/PID", str(pid), "/T", "/F"]), false)
		else:
			OS.kill(pid)
		stopped += 1
	command_process_pids.clear()
	var had_elevated := false
	for index in range(command_center_jobs.size() - 1, -1, -1):
		if bool(command_center_jobs[index].get("elevated", false)):
			had_elevated = true
		else:
			command_center_jobs.remove_at(index)
	if had_elevated and admin_console_pid > 0 and OS.is_process_running(admin_console_pid):
		_command_center_request_stop_elevated()
	elif had_elevated and admin_helper_pid > 0:
		if OS.is_process_running(admin_helper_pid):
			OS.kill(admin_helper_pid)
		admin_helper_pid = -1
		admin_status_path = ""
		pc_admin_request_active = false
		for index in range(command_center_jobs.size() - 1, -1, -1):
			if bool(command_center_jobs[index].get("elevated", false)):
				command_center_jobs.remove_at(index)
		refresh_pc_commands_indicator()
		command_center_append("Canceled the pending administrator helper before the run started.", "#f9c74f")
	else:
		command_center_append("Stopped %d tracked regular run(s)." % stopped, "#f9c74f")
	show_toast("Command Center stop requested")

func _command_center_request_stop_elevated() -> void:
	if OS.get_name() != "Windows" or admin_console_pid <= 0:
		return
	var stop_folder := command_workspace_dir().path_join("CommandCenter")
	DirAccess.make_dir_recursive_absolute(stop_folder)
	var helper_path := stop_folder.path_join("stop_elevated_%d.pyw" % Time.get_ticks_msec())
	var helper := FileAccess.open(helper_path, FileAccess.WRITE)
	if helper == null:
		command_center_append("Could not prepare the administrator stop helper.", "#ff8095")
		return
	var helper_text := "import ctypes, sys\npid = sys.argv[1]\nparams = '/PID ' + pid + ' /T /F'\nctypes.windll.shell32.ShellExecuteW(None, 'runas', 'taskkill.exe', params, None, 0)\n"
	helper.store_string(helper_text)
	helper.close()
	var pythonw := str(settings.voice_python_path).replace("python.exe", "pythonw.exe")
	if not FileAccess.file_exists(pythonw):
		command_center_append("Pythonw is missing, so the elevated run cannot be stopped from SAM-AI automatically.", "#ff8095")
		return
	OS.create_process(pythonw, PackedStringArray([helper_path, str(admin_console_pid)]), false)
	for index in range(command_center_jobs.size() - 1, -1, -1):
		if bool(command_center_jobs[index].get("elevated", false)):
			command_center_jobs.remove_at(index)
	command_center_append("STOP ADMIN RUN • Windows UAC will ask permission to terminate the elevated process tree. The administrator grant is not retained.", "#f9c74f")

func command_center_reset_safe_defaults() -> void:
	settings.command_center_mode = "safe"
	settings.command_center_shell = "PowerShell"
	settings.command_center_run_preference = "ask"
	if is_instance_valid(command_center_mode_selector): command_center_mode_selector.select(0)
	if is_instance_valid(command_center_shell_selector): command_center_shell_selector.select(0)
	_command_center_apply_run_preference_ui()
	lock_pc_commands()
	save_json(SETTINGS_FILE, settings)
	_command_center_refresh_status()
	command_center_append("Safe defaults restored • execution locked.", "#76f7a6")

func command_center_learn_last_success() -> void:
	var value = get_meta("command_center_last_success", null)
	if not value is Dictionary:
		show_toast("No successful Command Center run is waiting to be learned")
		return
	var job: Dictionary = value
	var transcript := "Successful local automation. Task: %s\nShell: %s\nCommand/script:\n%s" % [str(job.get("task", "manual command")), str(job.get("shell", "")), str(job.get("command", "")).left(10000)]
	var entry := {"id": "command-center-%d" % Time.get_ticks_usec(), "session": "CommandCenter", "chunk": 1, "created": Time.get_datetime_string_from_system(), "category": "Programming", "confidence": "successful local automation run; user chose to retain it for future reference", "source_mode": "Command Center", "source_name": "Command Center successful run", "summary": knowledge_summary(transcript), "transcript": transcript, "audio_path": "", "pinned": true, "user_verified": false}
	_vault_prepare_incoming(entry)
	_vault_add_entry(entry)
	_vault_mark_changed()
	set_meta("command_center_last_success", null)
	show_toast("Successful automation queued for KnowledgeVault study")
	command_center_append("Saved this successful automation to KnowledgeVault for future retrieval.", "#76f7a6")

func setup_playground_manager() -> void:
	var page := VBoxContainer.new()
	page.name = "Playground"
	page.add_theme_constant_override("separation", 10)
	var title := Label.new()
	title.text = "PLAYGROUND  //  GENERATED PROJECTS • 30-DAY SAFE TRASH"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", colors.cyan)
	page.add_child(title)
	var help := Label.new()
	help.text = "Projects are moved to SAM Trash first. Restore them, keep them 30 more days, or send them to the Windows Recycle Bin as a second safety layer."
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	help.add_theme_color_override("font_color", colors.muted)
	page.add_child(help)
	var toolbar := HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 8)
	toolbar.add_child(make_button("↻ REFRESH", refresh_playground_manager, colors.cyan))
	toolbar.add_child(make_button("📂 OPEN PLAYGROUND", func(): DirAccess.make_dir_recursive_absolute(command_workspace_dir()); OS.shell_open(command_workspace_dir()), colors.cyan))
	toolbar.add_child(make_button("🗑 CLEAR SAM TRASH…", request_clear_playground_trash, colors.red))
	page.add_child(toolbar)
	playground_status = Label.new()
	playground_status.add_theme_color_override("font_color", colors.muted)
	page.add_child(playground_status)
	playground_list = ItemList.new()
	playground_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	playground_list.select_mode = ItemList.SELECT_SINGLE
	playground_list.add_theme_font_size_override("font_size", 16)
	page.add_child(playground_list)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	actions.add_child(make_button("🗑 MOVE PROJECT TO SAM TRASH", request_trash_selected_project, colors.amber))
	actions.add_child(make_button("↩ RESTORE", restore_selected_playground_item, colors.green))
	actions.add_child(make_button("＋ KEEP 30 MORE DAYS", extend_selected_playground_item, colors.cyan))
	actions.add_child(make_button("♻ SEND TO WINDOWS RECYCLE BIN…", request_recycle_selected_item, colors.red))
	page.add_child(actions)
	$Page/Tabs.add_child(page)
	refresh_playground_manager()

func refresh_playground_manager() -> void:
	if not is_instance_valid(playground_list):
		return
	DirAccess.make_dir_recursive_absolute(command_workspace_dir())
	DirAccess.make_dir_recursive_absolute(playground_trash_dir())
	playground_entries.clear()
	playground_list.clear()
	var active_count := 0
	var trash_count := 0
	var root := DirAccess.open(command_workspace_dir())
	if root:
		for folder in root.get_directories():
			if folder == ".sam_trash":
				continue
			var path := command_workspace_dir().path_join(folder)
			playground_entries.append({"state": "active", "name": folder, "path": path})
			playground_list.add_item("● PROJECT   %s" % folder)
			active_count += 1
	var trash := DirAccess.open(playground_trash_dir())
	var now := int(Time.get_unix_time_from_system())
	var expired_paths: Array[String] = []
	if trash:
		for folder in trash.get_directories():
			var path := playground_trash_dir().path_join(folder)
			var info = load_json(path.path_join(".sam_trash_info.json"))
			if not info is Dictionary:
				info = {"original_path": command_workspace_dir().path_join(folder), "name": folder, "deleted_at": now}
			var expires := int(info.get("deleted_at", now)) + 30 * 86400
			if expires <= now:
				expired_paths.append(path)
				continue
			var days := maxi(0, int(ceil(float(expires - now) / 86400.0)))
			playground_entries.append({"state": "trash", "name": str(info.get("name", folder)), "path": path, "original_path": str(info.get("original_path", "")), "deleted_at": int(info.get("deleted_at", now))})
			playground_list.add_item("🗑 SAM TRASH   %s   • %d days remaining" % [str(info.get("name", folder)), days])
			trash_count += 1
	playground_status.text = "%d generated projects • %d items in SAM Trash • location: %s" % [active_count, trash_count, command_workspace_dir()]
	if not expired_paths.is_empty():
		send_paths_to_windows_recycle(expired_paths)

func selected_playground_entry() -> Dictionary:
	if not is_instance_valid(playground_list):
		return {}
	var selected := playground_list.get_selected_items()
	if selected.is_empty() or selected[0] < 0 or selected[0] >= playground_entries.size():
		show_toast("Select a Playground project first")
		return {}
	return playground_entries[selected[0]]

func request_trash_selected_project() -> void:
	var entry := selected_playground_entry()
	if entry.is_empty() or str(entry.get("state", "")) != "active":
		show_toast("Select an active project to move to SAM Trash")
		return
	show_typed_delete_confirmation("MOVE PROJECT TO SAM TRASH?", "This keeps the project for 30 days. Type the exact project folder name to confirm:", str(entry.name), func(): move_project_to_sam_trash(entry), colors.amber)

func move_project_to_sam_trash(entry: Dictionary) -> void:
	var source := str(entry.path)
	var destination := playground_trash_dir().path_join(str(entry.name) + "_" + str(int(Time.get_unix_time_from_system())))
	var error := DirAccess.rename_absolute(source, destination)
	if error != OK:
		show_toast("Could not move that project to SAM Trash")
		return
	save_json(destination.path_join(".sam_trash_info.json"), {"name": str(entry.name), "original_path": source, "deleted_at": int(Time.get_unix_time_from_system())})
	show_toast("Project moved to SAM Trash • retained for 30 days")
	refresh_playground_manager()

func restore_selected_playground_item() -> void:
	var entry := selected_playground_entry()
	if entry.is_empty() or str(entry.get("state", "")) != "trash":
		show_toast("Select an item in SAM Trash to restore")
		return
	var destination := str(entry.original_path)
	if DirAccess.dir_exists_absolute(destination):
		show_toast("Restore blocked • a folder with that name already exists")
		return
	var error := DirAccess.rename_absolute(str(entry.path), destination)
	show_toast("Project restored" if error == OK else "Could not restore that project")
	refresh_playground_manager()

func extend_selected_playground_item() -> void:
	var entry := selected_playground_entry()
	if entry.is_empty() or str(entry.get("state", "")) != "trash":
		show_toast("Select an item in SAM Trash first")
		return
	save_json(str(entry.path).path_join(".sam_trash_info.json"), {"name": str(entry.name), "original_path": str(entry.original_path), "deleted_at": int(Time.get_unix_time_from_system())})
	show_toast("Retention extended for 30 more days")
	refresh_playground_manager()

func request_recycle_selected_item() -> void:
	var entry := selected_playground_entry()
	if entry.is_empty() or str(entry.get("state", "")) != "trash":
		show_toast("Move the project to SAM Trash before second-stage deletion")
		return
	show_typed_delete_confirmation("SEND TO WINDOWS RECYCLE BIN?", "This removes the item from SAM Trash but keeps Windows Recycle Bin as a final recovery option. Type the exact project name:", str(entry.name), func(): send_paths_to_windows_recycle([str(entry.path)]), colors.red)

func request_clear_playground_trash() -> void:
	var paths: Array[String] = []
	for entry in playground_entries:
		if str(entry.get("state", "")) == "trash":
			paths.append(str(entry.path))
	if paths.is_empty():
		show_toast("SAM Trash is already empty")
		return
	var words: Array[String] = ["ORBIT", "PURPLE", "ANCHOR", "COMET", "SAFETY", "NEBULA"]
	var challenge: String = words[randi() % words.size()]
	show_typed_delete_confirmation("CLEAR ALL SAM TRASH?", "Every SAM Trash item will be moved to the Windows Recycle Bin. Type this safety word exactly:  %s" % challenge, challenge, func(): send_paths_to_windows_recycle(paths), colors.red)

func send_paths_to_windows_recycle(paths: Array[String]) -> void:
	var helper := ProjectSettings.globalize_path("res://tools/sam_recycle.pyw")
	var pythonw := str(settings.voice_python_path).replace("python.exe", "pythonw.exe")
	var arguments := PackedStringArray([helper])
	for path in paths:
		arguments.append(path)
	var pid := OS.create_process(pythonw, arguments, false)
	show_toast("Sent to Windows Recycle Bin • final recovery remains available" if pid > 0 else "Could not start Windows Recycle Bin transfer")
	get_tree().create_timer(1.5).timeout.connect(refresh_playground_manager)

func show_typed_delete_confirmation(title: String, explanation: String, expected: String, action: Callable, accent: Color) -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = title
	dialog.dialog_text = explanation
	dialog.ok_button_text = "CONFIRM"
	dialog.get_ok_button().disabled = true
	var field := LineEdit.new()
	field.placeholder_text = "Type: " + expected
	field.custom_minimum_size = Vector2(600, 46)
	field.text_changed.connect(func(value: String): dialog.get_ok_button().disabled = value != expected)
	dialog.add_child(field)
	dialog.confirmed.connect(func(): dialog.queue_free(); action.call())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, accent)
	dialog.popup_centered(Vector2i(720, 360))
	field.grab_focus()

func path_is_in_command_workspace(path: String) -> bool:
	var root := command_workspace_dir().simplify_path().replace("\\", "/").trim_suffix("/").to_lower()
	var candidate := path.simplify_path().replace("\\", "/").to_lower()
	return candidate.begins_with(root + "/")

func refresh_pc_commands_indicator() -> void:
	if not is_instance_valid(pc_commands_button):
		return
	var enabled := bool(settings.get("pc_commands_enabled", false))
	if pc_admin_request_active:
		pc_commands_button.text = "🛡 ADMIN REQUEST • ONE RUN"
		pc_commands_button.add_theme_color_override("font_color", colors.red)
	elif enabled:
		pc_commands_button.text = "● PC TOOLS ON"
		pc_commands_button.add_theme_color_override("font_color", colors.green)
	else:
		pc_commands_button.text = "🔒 PC COMMANDS LOCKED"
		pc_commands_button.add_theme_color_override("font_color", colors.green)
	pc_commands_button.tooltip_text = "Workspace commands enabled • click to review or lock" if enabled else "SAM cannot execute generated PC commands"
	var popup := pc_commands_button.get_popup()
	popup.clear()
	popup.add_item("🔒 LOCK AND REVOKE NOW", 1)
	popup.set_item_disabled(0, not enabled)
	popup.add_item("⚠ ENABLE WORKSPACE TOOLS…", 2)
	popup.set_item_disabled(1, enabled)
	popup.add_separator()
	popup.add_item("📁 CHOOSE PLAYGROUND FOLDER…", 3)
	popup.add_item("↗ OPEN PLAYGROUND FOLDER", 4)
	popup.add_separator()
	add_privacy_info_item(popup, "Allowed: save/view files and confirmed Python or PowerShell runs")
	add_privacy_info_item(popup, "Default boundary: " + command_workspace_dir())
	add_privacy_info_item(popup, "Administrator access: never remembered; Windows UAC required per action")
	add_privacy_info_item(popup, "Lock stops tracked normal runs; elevated processes must be closed in Windows")
	add_privacy_info_item(popup, "Every execution requires a visible confirmation")
	_command_center_refresh_status()

func _on_pc_commands_menu(action_id: int) -> void:
	match action_id:
		1:
			lock_pc_commands()
		2:
			show_enable_pc_commands_confirmation()
		3:
			choose_command_workspace()
		4:
			DirAccess.make_dir_recursive_absolute(command_workspace_dir())
			OS.shell_open(command_workspace_dir())

func lock_pc_commands() -> void:
	settings.pc_commands_enabled = false
	for process_id in command_process_pids:
		if process_id > 0 and OS.is_process_running(process_id):
			OS.kill(process_id)
	command_process_pids.clear()
	for index in range(command_center_jobs.size() - 1, -1, -1):
		if not bool(command_center_jobs[index].get("elevated", false)):
			command_center_jobs.remove_at(index)
	save_json(SETTINGS_FILE, settings)
	refresh_pc_commands_indicator()
	show_toast("PC commands locked • normal tool processes stopped and permission revoked")

func show_enable_pc_commands_confirmation() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "ENABLE SAM-AI WORKSPACE TOOLS?"
	dialog.dialog_text = "This permits SAM-AI to save generated files and launch confirmed Python, PowerShell, or Godot projects inside:\n\n%s\n\nGenerated code can delete files, access the network, or run other programs. Read the code and confirmation before every run. Missing dependency installation is never automatic: SAM-AI shows the exact package and asks before temporarily using the internet. Administrator permission is never stored and requires a separate Windows UAC prompt.\n\nThe top lock can revoke this permission immediately." % command_workspace_dir()
	dialog.ok_button_text = "ENABLE WORKSPACE TOOLS"
	dialog.confirmed.connect(func():
		settings.pc_commands_enabled = true
		DirAccess.make_dir_recursive_absolute(command_workspace_dir())
		save_json(SETTINGS_FILE, settings)
		refresh_pc_commands_indicator()
		show_toast("Workspace tools enabled • commands still require confirmation")
		dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	style_security_dialog(dialog, colors.cyan)
	dialog.popup_centered(Vector2i(760, 430))

func style_security_dialog(dialog: AcceptDialog, accent: Color) -> void:
	dialog.min_size = Vector2i(680, 350)
	var label := dialog.get_label()
	if label:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", Color("#d8e7ff"))
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("#08111f")
	panel.border_color = accent
	panel.set_border_width_all(2)
	panel.set_corner_radius_all(14)
	panel.content_margin_left = 24
	panel.content_margin_right = 24
	panel.content_margin_top = 20
	panel.content_margin_bottom = 20
	panel.shadow_color = Color(0, 0, 0, 0.65)
	panel.shadow_size = 18
	dialog.add_theme_stylebox_override("panel", panel)
	dialog.add_theme_color_override("title_color", accent)
	style_dialog_controls(dialog, accent)

func style_dialog_controls(node: Node, accent: Color) -> void:
	for child in node.get_children():
		if child is Button:
			var button := child as Button
			button.custom_minimum_size.y = 42
			button.add_theme_font_size_override("font_size", 14)
			button.add_theme_color_override("font_color", Color("#d8e7ff"))
			button.add_theme_color_override("font_hover_color", Color.WHITE)
			var normal := StyleBoxFlat.new()
			normal.bg_color = Color("#111d2d")
			normal.border_color = Color("#36506c")
			normal.set_border_width_all(1)
			normal.set_corner_radius_all(8)
			normal.content_margin_left = 16
			normal.content_margin_right = 16
			var hover := normal.duplicate() as StyleBoxFlat
			hover.bg_color = Color("#183149")
			hover.border_color = accent
			var pressed := normal.duplicate() as StyleBoxFlat
			pressed.bg_color = Color("#0b2733")
			pressed.border_color = accent
			button.add_theme_stylebox_override("normal", normal)
			button.add_theme_stylebox_override("hover", hover)
			button.add_theme_stylebox_override("pressed", pressed)
			button.add_theme_stylebox_override("focus", hover)
		style_dialog_controls(child, accent)

func choose_command_workspace() -> void:
	var dialog := FileDialog.new()
	dialog.title = "Choose SAM-AI Playground Folder"
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.dir_selected.connect(func(path: String): settings.command_workspace_path = path; save_json(SETTINGS_FILE, settings); refresh_pc_commands_indicator(); _command_center_refresh_status(); show_toast("Playground folder changed"); dialog.queue_free())
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered_ratio(0.75)

func log_line(kind: String, message: String) -> void:
	var now_text := Time.get_time_string_from_system()
	if not telemetry_entries.is_empty():
		var last: Dictionary = telemetry_entries[-1]
		if str(last.get("kind", "")) == kind and str(last.get("message", "")) == message:
			last.repeat = int(last.get("repeat", 1)) + 1
			last.time = now_text
			telemetry_entries[-1] = last
			telemetry_dirty = true
			return
	telemetry_entries.append({"time": now_text, "kind": kind, "message": message, "repeat": 1})
	while telemetry_entries.size() > TELEMETRY_MAX_ENTRIES:
		telemetry_entries.pop_front()
	var pages := maxi(1, ceili(float(telemetry_entries.size()) / float(TELEMETRY_PAGE_SIZE)))
	if telemetry_follow_latest:
		telemetry_page = pages - 1
	telemetry_dirty = true

func load_settings() -> void:
	var loaded = load_json(SETTINGS_FILE)
	if loaded is Dictionary:
		settings.merge(loaded, true)
		# Knowledge capture is transcript-only by default. This one-time migration
		# corrects builds that briefly defaulted to retaining every source recording.
		if not bool(loaded.get("knowledge_transcript_only_migrated", false)):
			settings.knowledge_keep_audio = false
			settings.knowledge_transcript_only_migrated = true
			save_json(SETTINGS_FILE, settings)
		# Earlier builds capped Qwen Coder at 1,024 tokens (about 3,800 chars),
		# which routinely truncated complete source files. Upgrade that legacy value
		# once while preserving any newer/custom output limit chosen by the user.
		if not bool(loaded.get("long_output_limit_migrated", false)) and int(settings.max_tokens) <= 1024:
			settings.max_tokens = 4096
			settings.long_output_limit_migrated = true
			save_json(SETTINGS_FILE, settings)
	settings.auto_context_max = clampi(int(settings.get("auto_context_max", AUTO_CONTEXT_DEFAULT_MAX)), 2048, AUTO_CONTEXT_HARD_MAX)
	settings.live_voice_silence_seconds = clampf(float(settings.get("live_voice_silence_seconds", 4.0)), 1.5, 8.0)
	settings.live_voice_vad_threshold_db = clampf(float(settings.get("live_voice_vad_threshold_db", -46.0)), -60.0, -15.0)
	if not bool(settings.get("live_voice_duplex_v2_migrated", false)):
		# -30 dB was too insensitive for normal speech on many USB microphones.
		# Adaptive echo guarding still raises the threshold while SAM's speakers play.
		if absf(float(settings.get("live_voice_barge_threshold_db", -30.0)) - (-30.0)) < 0.1:
			settings.live_voice_barge_threshold_db = -44.0
		settings.live_voice_duplex_v2_migrated = true
	settings.live_voice_barge_threshold_db = clampf(float(settings.get("live_voice_barge_threshold_db", -44.0)), -55.0, -10.0)
	# Privacy and execution authority are session-only. Every launch fails closed,
	# regardless of how the previous session ended. Device selection is preserved.
	settings.pc_commands_enabled = false
	# Execution authority is session-only. Every launch returns Command Center to safe preview.
	settings.command_center_mode = "safe"
	settings.microphone_muted = true
	pc_admin_request_active = false
	recording_voice = false
	knowledge_recording = false
	save_json(SETTINGS_FILE, settings)

func session_history_path(id: String) -> String:
	return SESSION_DATA_DIR.path_join(id.validate_filename() + ".json")

func load_session_index() -> void:
	DirAccess.make_dir_recursive_absolute(SESSION_DATA_DIR)
	var loaded = load_json(SESSION_INDEX_FILE)
	if loaded is Dictionary:
		var loaded_sessions = loaded.get("sessions", [])
		if loaded_sessions is Array:
			for value in loaded_sessions:
				if value is Dictionary:
					sessions.append(value)
		session_id = str(loaded.get("active", ""))
	if sessions.is_empty():
		session_id = create_session_record("Recovered session", false)
		var legacy = load_json(HISTORY_FILE)
		if legacy is Array:
			save_json(session_history_path(session_id), legacy)
	if session_id.is_empty() or find_session_index(session_id) < 0:
		session_id = str(sessions[0].get("id", ""))
	save_session_index()

func create_session_record(title := "New session", activate := true) -> String:
	var id := Time.get_datetime_string_from_system().replace(":", "-") + "-%04d" % (Time.get_ticks_msec() % 10000)
	var now := Time.get_datetime_string_from_system()
	sessions.push_front({"id": id, "title": title, "created": now, "updated": now, "archived": false, "complete": false})
	save_json(session_history_path(id), [])
	if activate:
		session_id = id
	save_session_index()
	return id

func find_session_index(id: String) -> int:
	for index in range(sessions.size()):
		if str(sessions[index].get("id", "")) == id:
			return index
	return -1

func save_session_index() -> void:
	DirAccess.make_dir_recursive_absolute(SESSION_DATA_DIR)
	save_json(SESSION_INDEX_FILE, {"active": session_id, "sessions": sessions})

func load_history() -> void:
	var loaded = load_json(session_history_path(session_id))
	if loaded is Array:
		history = loaded
		# Repair responses saved by the old JSON-null streaming bug.
		for item in history:
			if item is Dictionary and item.get("content", "") is String:
				item.content = str(item.content).replace("<null>", "")

func save_history(include_archive: bool = true) -> void:
	save_json(session_history_path(session_id), history)
	# Keep the legacy file as an emergency compatibility copy of the active session.
	save_json(HISTORY_FILE, history)
	var metadata_index := find_session_index(session_id)
	if metadata_index >= 0:
		var metadata: Dictionary = sessions[metadata_index]
		metadata.updated = Time.get_datetime_string_from_system()
		if str(metadata.get("title", "New session")) in ["New session", "Recovered session"]:
			for item in history:
				if item is Dictionary and str(item.get("role", "")) == "user":
					metadata.title = make_session_title(str(item.get("content", "")))
					break
		sessions[metadata_index] = metadata
		save_session_index()
	if include_archive:
		save_history_archive_only()

func save_history_archive_only() -> void:
	# Archive formatting is intentionally deferred after live generation. It can
	# become large over long sessions, but it does not need to block token display.
	refresh_session_sidebar()
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

func make_session_title(text: String) -> String:
	var clean := " ".join(text.replace("\n", " ").split(" ", false)).strip_edges()
	if clean.is_empty():
		return "New session"
	return clean.left(48) + ("…" if clean.length() > 48 else "")

func save_json(path: String, data: Variant) -> void:
	if path == knowledge_index_file() and data is Array:
		_vault_mark_changed()
		return
	# Other UI settings can be saved while a larger engine is still loading.
	# Persist the last working context until /health confirms the new allocation.
	if path == SETTINGS_FILE and context_reload_pending and data is Dictionary:
		data = data.duplicate(true)
		data["context_size"] = context_previous_size
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
		begin_shutdown()

func begin_shutdown() -> void:
	if shutdown_started:
		return
	shutdown_started = true
	if knowledge_recording:
		request_external_capture_stop()
		knowledge_recording = false
	if knowledge_capture_pid > 0 and OS.is_process_running(knowledge_capture_pid):
		OS.kill(knowledge_capture_pid)
	knowledge_capture_pid = -1
	if voice_capture_pid > 0 and OS.is_process_running(voice_capture_pid):
		OS.kill(voice_capture_pid)
	voice_capture_pid = -1
	if knowledge_process_pid > 0 and OS.is_process_running(knowledge_process_pid):
		OS.kill(knowledge_process_pid)
	knowledge_process_pid = -1
	if spellcheck_pid > 0 and OS.is_process_running(spellcheck_pid):
		OS.kill(spellcheck_pid)
	spellcheck_pid = -1
	for command_pid in command_process_pids:
		if command_pid > 0 and OS.is_process_running(command_pid):
			OS.kill(command_pid)
	command_process_pids.clear()
	var vault_flushed: bool = await _vault_flush_for_shutdown()
	if not vault_flushed:
		shutdown_started = false
		show_toast("Close cancelled: Knowledge Vault could not save. Check Debug Telemetry and retry.")
		return
	generating = false
	request_preparing = false
	set_process(false)
	stream_client.close()
	health_client.close()
	if is_instance_valid(voice_player):
		voice_player.stop()
	if is_instance_valid(microphone_player):
		microphone_player.stop()
	# History is already saved when a user message is accepted and when a reply
	# completes. Avoid a large synchronous JSON/archive rewrite in the close event.
	stop_engine()
	if voice_daemon_pid > 0 and OS.is_process_running(voice_daemon_pid):
		OS.kill(voice_daemon_pid)
	voice_daemon_pid = -1
	if FileAccess.file_exists(VOICE_DAEMON_PID_FILE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(VOICE_DAEMON_PID_FILE))
	# Give Windows one short event-loop turn to observe the child-process exit
	# before the Godot rendering device/window begins its own teardown.
	await get_tree().process_frame
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()



# A worker owns its job data and result. It never reads Control/SceneTree state.
# Results are read only after the main thread reaps the completed pool task.
class VaultWorker extends RefCounted:
	const REVIEW_VERSION := 2
	const CATEGORIES := ["Godot Project", "Godot Code", "Programming", "Hardware & Electronics", "3D & Design", "AI & Machine Learning", "Technology", "Science", "Music", "Gaming", "Politics & Society", "Education", "Finance & Business", "Comedy", "Document", "Inbox", "Video", "Movie & TV", "News", "Tutorial", "Conversation", "Commercial", "Unknown"]
	var result: Dictionary = {}

	func run(job: Dictionary) -> void:
		match str(job.get("kind", "")):
			"study":
				var entry: Dictionary = job.entry
				var final_pass := bool(job.get("final_pass", false))
				enrich_knowledge_entry(entry)
				var decision := decide(entry, job.get("links", []), str(job.get("duplicate_id", "")), final_pass)
				entry.study_status = "relevant" if bool(decision.relevant) else ("archived" if final_pass else "rejected")
				entry.study_reason = str(decision.reason)
				entry.study_score = int(decision.score)
				entry.linked_to = str(decision.linked)
				entry.study_reviewed = Time.get_datetime_string_from_system()
				if final_pass:
					entry.final_reviewed = entry.study_reviewed
				entry.review_version = REVIEW_VERSION
				apply_interest(entry, job.get("interests", []))
				result = {"ok": true, "entry": entry}
			"save":
				result = write_snapshot(str(job.path), job.entries)
			"load":
				result = read_snapshot(str(job.path))
			"profile":
				var text := str(job.get("text", ""))
				var path := str(job.get("memory_path", ""))
				if FileAccess.file_exists(path):
					var file := FileAccess.open(path, FileAccess.READ)
					if file:
						# Profile terms are a bounded cache, not the MemoryCore itself.
						text += " " + file.get_buffer(mini(file.get_length(), 524288)).get_string_from_utf8()
						file.close()
				result = {"ok": true, "terms": rank_terms(text, 50)}
			"stats":
				result = {"ok": true, "bytes": directory_bytes(str(job.path)), "memory_bytes": 0, "audio_count": 0}
				var dir := DirAccess.open(str(job.path))
				if dir:
					for filename in dir.get_files():
						if filename.ends_with(".wav") or filename.ends_with(".flac"):
							result.audio_count = int(result.audio_count) + 1
				var file := FileAccess.open(str(job.get("memory_path", "")), FileAccess.READ)
				if file:
					result.memory_bytes = file.get_length()
					file.close()
			"audio_scan":
				var paths: Array[String] = []
				var known: Dictionary = {}
				for known_value in job.get("known", []):
					known[str(known_value)] = true
				var dir := DirAccess.open(str(job.path))
				if dir:
					for filename in dir.get_files():
						if filename.ends_with(".wav") or filename.ends_with(".flac"):
							var candidate := str(job.path).path_join(filename)
							if not known.has(candidate):
								paths.append(candidate)
				paths.sort()
				paths.reverse()
				var total := paths.size()
				var limit := clampi(int(job.get("limit", 64)), 1, 256)
				if paths.size() > limit:
					paths.resize(limit)
				result = {"ok": true, "paths": paths, "total": total}
			"cleanup":
				var failed: Array[String] = []
				for path in job.get("paths", []):
					if FileAccess.file_exists(str(path)) and DirAccess.remove_absolute(str(path)) != OK:
						failed.append(str(path))
				result = {"ok": failed.is_empty(), "failed": failed}
			_:
				result = {"ok": false, "error": "Unknown vault job"}

	static func fingerprint(value: String) -> String:
		# Exact content, full length. Preserve code punctuation and letter case.
		return value.replace("\r\n", "\n").replace("\r", "\n").strip_edges().sha256_text()

	static func word_text(value: String) -> String:
		var re := RegEx.new()
		re.compile("[^\\p{L}\\p{N}_+#]+")
		return " " + re.sub(value.to_lower(), " ", true).strip_edges() + " "

	static func has_term(padded: String, term: String) -> bool:
		var normalized_term := term.to_lower()
		for separator in ["-", ":", "/", "'", "."]:
			normalized_term = normalized_term.replace(separator, " ")
		while normalized_term.contains("  "):
			normalized_term = normalized_term.replace("  ", " ")
		return padded.contains(" " + normalized_term.strip_edges() + " ")

	static func evidence(text: String) -> Dictionary:
		var padded := word_text(text)
		# Strong domain phrases carry 3 points; ambiguous single words need company.
		var strong := {
			"Godot Code": ["godot", "gdscript", "characterbody2d", "node2d", "scenetree", "_physics_process", "_ready", "res://"],
			"Programming": ["python", "javascript", "typescript", "c++", "c#", "compiler", "source code", "github", "git push", "pull request", "refactor", "data structure", "backend", "frontend", "stack trace", "syntax error", "unit test", "sql", "html", "css"],
			"Hardware & Electronics": ["esp32", "microcontroller", "arduino", "raspberry pi", "gpio", "i2s", "circuit", "soldering", "pinout", "schematic", "breadboard", "baud rate", "firmware", "capacitor", "resistor"],
			"3D & Design": ["3d print", "3d printing", "blender", "stl file", "shader", "glsl", "mixamo", "3d model", "uv unwrap", "extruder", "filament", "3d design"],
			"AI & Machine Learning": ["ai", "artificial intelligence", "machine learning", "neural network", "language model", "openai", "llama", "qwen", "gguf", "pytorch", "huggingface", "fine tuning", "quantization", "prompt engineering"],
			"Technology": ["operating system", "computer network", "cybersecurity", "encryption", "motherboard", "solid state drive", "wifi", "ethernet", "linux", "windows", "computer"],
			"Science": ["scientist", "physics", "biology", "chemistry", "quantum", "astronomy", "galaxy", "telescope", "molecule", "gravity", "solar system", "earth", "orbits"],
			"Politics & Society": ["president", "congress", "government", "election", "political", "white house", "parliament", "legislation", "senate", "civil rights"],
			"Gaming": ["video game", "gameplay", "gaming", "retro game", "snes", "emulator", "dayz", "playthrough", "speedrun", "arcade"],
			"Music": ["piano", "guitar", "song", "music", "melody", "rhythm", "tempo", "chord", "vocals", "lyrics", "synthesizer"],
			"Finance & Business": ["investment", "finance", "revenue", "profit", "stock market", "cash flow", "interest rate", "cryptocurrency", "business plan"],
			"Education": ["student", "teacher", "school", "education", "university", "lecture", "curriculum"],
			"Comedy": ["standup", "stand up comedy", "comedy", "comedian", "punchline", "satire", "improv", "parody"],
			"Movie & TV": ["episode", "previously on", "directed by", "starring", "movie", "cinema", "box office", "television"]
		}
		var weak := {
			"Programming": ["function", "variable", "api", "script", "class", "import", "rust", "debug"],
			"AI & Machine Learning": ["vram", "gpu offload", "model", "inference", "token", "transformer"],
			"3D & Design": ["mesh", "texture", "render", "slicer", "cad"],
			"Science": ["research", "experiment", "brain", "space", "planet", "energy", "evidence"],
			"Politics & Society": ["policy", "regulation", "court", "police", "law"],
			"Gaming": ["player", "level", "boss", "controller", "fps", "mods"],
			"Music": ["pitch", "album", "track"],
			"Education": ["learn", "course", "study", "lesson"],
			"Finance & Business": ["stock", "crypto", "budget", "market", "business", "startup"],
			"Comedy": ["joke", "funny", "humor", "laugh"]
		}
		var scores: Dictionary = {}
		var matches: Dictionary = {}
		for category in strong:
			var score := 0
			var cues: Array[String] = []
			for term in strong[category]:
				if has_term(padded, str(term)):
					score += 3
					cues.append(str(term))
			for term in weak.get(category, []):
				if has_term(padded, str(term)):
					score += 1
					cues.append(str(term))
			scores[category] = score
			matches[category] = cues
		var ranked: Array = scores.keys()
		ranked.sort_custom(func(a: Variant, b: Variant):
			if int(scores[a]) == int(scores[b]):
				return CATEGORIES.find(str(a)) < CATEGORIES.find(str(b))
			return int(scores[a]) > int(scores[b]))
		var best := str(ranked[0])
		var score := int(scores[best])
		var runner_up := int(scores[ranked[1]])
		var why := ", ".join(matches[best] as Array)
		if score < 3 or (score == runner_up and score < 6):
			best = "Unknown"
			why = "No clear subject; manual review is available."
		# A generic media introduction never overrides a stronger subject.
		if best == "Unknown" and score < 3:
			var formats := {
				"Commercial": ["buy now", "limited time offer", "call now", "order today", "sale ends", "discount code", "check out our sponsor"],
				"News": ["breaking news", "reporting live", "weather forecast", "press conference"],
				"Tutorial": ["step one", "tutorial", "how to", "follow these steps", "walkthrough"],
				"Video": ["in this video", "like and subscribe", "welcome back to my channel"],
				"Conversation": ["hello", "what do you think", "nice to meet you", "how are you", "yeah"]
			}
			for format_name in formats:
				for cue in formats[format_name]:
					if has_term(padded, str(cue)):
						best = str(format_name)
						why = "Format cue: " + str(cue)
						break
				if best != "Unknown":
					break
		return {"category": best, "score": score, "reason": why, "ambiguous": best == "Unknown"}

	static func detect_speaker_info(text_value: String) -> Dictionary:
		# Transcript text cannot identify voices, age or gender. Only preserve an
		# explicit self-introduction, and label it as a claim, not identification.
		var re := RegEx.new()
		re.compile("(?i:\\bmy name is)\\s+([A-Z][a-z]{1,30}(?:[ -][A-Z][a-z]{1,30})?)\\b")
		var found := re.search(text_value)
		return {"speaker": found.get_string(1) if found else "Unknown Speaker", "speaker_gender": "Unknown", "speaker_basis": "self-introduction in transcript (unverified)" if found else "unknown"}

	static func rank_terms(text: String, limit: int = 18) -> Array[String]:
		var counts: Dictionary = {}
		var ignored := knowledge_stop_words()
		for word in word_text(text).split(" ", false):
			if word.length() >= 3 and not ignored.has(word) and not word.is_valid_int():
				counts[word] = int(counts.get(word, 0)) + 1
		var ranked: Array = counts.keys()
		ranked.sort_custom(func(a: Variant, b: Variant):
			return str(a) < str(b) if int(counts[a]) == int(counts[b]) else int(counts[a]) > int(counts[b]))
		var terms: Array[String] = []
		for i in range(mini(limit, ranked.size())):
			terms.append(str(ranked[i]))
		return terms

	static func linked_summary(entry: Dictionary, candidates: Array) -> String:
		var keywords: Array = entry.get("keywords", [])
		for candidate in candidates:
			if candidate is not Dictionary or str(candidate.get("id", "")) == str(entry.get("id", "")):
				continue
			if str(candidate.get("category", "")) != str(entry.get("category", "")):
				continue
			var overlap := 0
			for keyword in keywords:
				if (candidate.get("keywords", []) as Array).has(keyword):
					overlap += 1
			if overlap >= 3:
				return str(candidate.get("summary", "related note")).left(120)
		return ""

	static func decide(entry: Dictionary, candidates: Array = [], duplicate_id: String = "", final_pass: bool = false) -> Dictionary:
		var text := str(entry.get("transcript", "")).strip_edges()
		var padded := word_text(text)
		var explicit_keep := bool(entry.get("pinned", false)) or bool(entry.get("user_verified", false))
		if explicit_keep and not text.is_empty():
			return {"relevant": true, "score": 10, "reason": "Kept by your pin/verification; automatic review does not override it.", "linked": ""}
		if not duplicate_id.is_empty() and duplicate_id != str(entry.get("id", "")):
			return {"relevant": false, "score": 0, "reason": "Duplicate of saved entry " + duplicate_id + "; transcript preserved for review.", "linked": ""}
		var imported := str(entry.get("confidence", "")).contains("user-") or str(entry.get("source_mode", "")) in ["Pasted text", "File import", "Godot project", "Godot project import"]
		var code := str(entry.get("content_type", "")) == "code" or str(entry.get("category", "")).begins_with("Godot")
		var explanation := 0
		for cue in ["because", "therefore", "means that", "works by", "is defined as", "causes", "results in", "for example", "solution", "to fix", "step one", "evidence", "orbits", "equals", "consists of", "freezes at", "boils at", "is measured in", "is located in", "is the process of", "refers to"]:
			if has_term(padded, cue):
				explanation += 1
		var filler := false
		for cue in ["like and subscribe", "thanks for watching", "we'll be right back", "commercial break", "you know what i mean", "buy now", "order today"]:
			filler = filler or has_term(padded, cue)
		var linked := linked_summary(entry, candidates)
		var score := 0
		if text.length() >= 75:
			score += 1
		if text.length() >= 180:
			score += 1
		if str(entry.get("category", "Unknown")) not in ["Unknown", "Conversation", "Commercial", "Video"]:
			score += 1
		score += mini(6, explanation * 3)
		if code:
			score += 5
		if imported:
			score += 6
		if not linked.is_empty():
			score += 1
		if filler and explanation == 0 and not code and not imported:
			score -= 6
		var relevant := not text.is_empty() and (imported or (code and text.length() >= 8) or (text.length() >= 15 and score >= 4 and explanation > 0))
		var reason := "Contains a reusable explanation; source remains unverified."
		if imported:
			reason = "User-supplied reference; retained without claiming independent verification."
		elif code:
			reason = "Contains code/technical reference material; not automatically runtime-tested."
		if not relevant and final_pass and not filler:
			# A final pass rescues substantial topic-specific observations even when a
			# 10-second chunk boundary removed an explicit teaching phrase.
			if text.length() >= 120 and score >= 2 and int(entry.get("category_score", 0)) >= 3:
				relevant = true
				reason = "Final background pass retained a substantial topic-specific note; source remains unverified."
		if not relevant:
			reason = "Needs review: insufficient self-contained explanation; original transcript is preserved."
			if text.length() < 75 and not code:
				reason = "Needs review: short fragment with limited context; transcript preserved."
			if filler:
				reason = "Needs review: promotional/filler wording without enough reusable detail."
			if final_pass:
				reason = "Final background pass archived this low-information fragment outside chat retrieval; transcript is still preserved."
		return {"relevant": relevant, "score": score, "reason": reason, "linked": linked}

	static func apply_interest(entry: Dictionary, terms: Array) -> void:
		var previous := bool(entry.get("for_you", false))
		var was_unread := bool(entry.get("unread_discovery", false))
		entry.for_you = false
		entry.unread_discovery = false
		entry.interest_score = 0
		entry.interest_reason = ""
		if str(entry.get("study_status", "pending")) != "relevant" or str(entry.get("user_interest_feedback", "")) == "not_for_me":
			return
		var padded := word_text(str(entry.get("transcript", "")))
		var matches: Array[String] = []
		for term in terms:
			if has_term(padded, str(term)):
				matches.append(str(term))
			if matches.size() >= 5:
				break
		entry.interest_score = mini(10, matches.size() * 2)
		if int(entry.interest_score) >= 6:
			entry.for_you = true
			entry.unread_discovery = was_unread if previous else true
			entry.interest_reason = "Matches your saved interest terms: " + ", ".join(matches) + ". Not a fact check."

	static func read_snapshot(path: String) -> Dictionary:
		var recovered_backup := false
		if not FileAccess.file_exists(path):
			if FileAccess.file_exists(path + ".bak"):
				path += ".bak"
				recovered_backup = true
			else:
				return {"ok": true, "entries": []}
		var parser := JSON.new()
		var error := parser.parse(FileAccess.get_file_as_string(path))
		if error != OK or parser.data is not Array:
			return {"ok": false, "error": "Knowledge index is unreadable. Original was not overwritten: " + path}
		var backup_path := path.get_base_dir().path_join("index.pre-smooth-v1.backup.json")
		if not FileAccess.file_exists(backup_path):
			var backup_error := DirAccess.copy_absolute(path, backup_path)
			if backup_error != OK:
				return {"ok": false, "error": "Could not make the pre-upgrade backup (error %d). Original untouched." % backup_error}
		var entries: Array = parser.data
		var seen: Dictionary = {}
		var changed := recovered_backup
		for i in range(entries.size()):
			if entries[i] is not Dictionary:
				return {"ok": false, "error": "Non-object entry at row %d. Original index preserved for repair." % i}
			var entry: Dictionary = entries[i]
			var entry_id := str(entry.get("id", ""))
			if entry_id.is_empty() or seen.has(entry_id):
				entry.id = "recovered-%d-%s" % [i, str(entry.get("transcript", "")).sha256_text().left(16)]
				changed = true
			seen[str(entry.id)] = true
		return {"ok": true, "entries": entries, "changed": changed}

	static func write_snapshot(path: String, entries: Array) -> Dictionary:
		var err := DirAccess.make_dir_recursive_absolute(path.get_base_dir())
		if err != OK:
			return {"ok": false, "error": "Cannot create vault directory: %d" % err}
		var temporary := path + ".tmp"
		var file := FileAccess.open(temporary, FileAccess.WRITE)
		if file == null:
			return {"ok": false, "error": "Cannot open temporary knowledge index: %d" % FileAccess.get_open_error()}
		file.store_string(JSON.stringify(entries))
		file.flush()
		err = file.get_error()
		file.close()
		if err != OK:
			return {"ok": false, "error": "Knowledge index write failed: %d" % err}
		if FileAccess.file_exists(path):
			err = DirAccess.copy_absolute(path, path + ".bak.tmp")
			if err == OK:
				err = DirAccess.rename_absolute(path + ".bak.tmp", path + ".bak")
			if err != OK:
				return {"ok": false, "error": "Could not rotate knowledge backup: %d; original preserved." % err}
		err = DirAccess.rename_absolute(temporary, path)
		return {"ok": err == OK, "error": "Could not replace knowledge index: %d; original preserved." % err}

	static func directory_bytes(path: String) -> int:
		var dir := DirAccess.open(path)
		if dir == null:
			return 0
		var size := 0
		for name in dir.get_files():
			var file := FileAccess.open(path.path_join(name), FileAccess.READ)
			if file:
				size += file.get_length()
				file.close()
		for child in dir.get_directories():
			# Do not follow directory links/junctions into cycles or unrelated disks.
			if not dir.is_link(child):
				size += directory_bytes(path.path_join(child))
		return size

	static func normalize_retrieval_text(value: String) -> String:
		var normalized := value.to_lower()
		for punctuation in ["`", "\"", "'", "(", ")", "[", "]", "{", "}", ":", ";", ",", ".", "!", "?", "\n", "\r", "\t", "/", "\\", "-", "_", "“", "”"]:
			normalized = normalized.replace(punctuation, " ")
		while normalized.contains("  "):
			normalized = normalized.replace("  ", " ")
		return normalized.strip_edges()

	static func knowledge_stop_words() -> Array[String]:
		return ["this", "that", "with", "from", "have", "your", "what", "when", "where", "which", "there", "their", "about", "would", "could", "should", "into", "just", "they", "them", "then", "than", "been", "were", "will", "also", "some", "more", "like", "does", "dont", "the", "and", "for", "are", "was", "you", "its", "not", "but", "can", "how", "who", "user", "assistant", "system", "memory", "sam", "using", "want", "need", "make", "please", "really", "going", "okay", "hello"]

	static func knowledge_summary(text_value: String) -> String:
		var useful: Array[String] = []
		for sentence_value in text_value.replace("?", ".").replace("!", ".").split(".", false):
			var sentence := str(sentence_value).strip_edges()
			if sentence.length() >= 30 and not contains_any(sentence.to_lower(), ["subscribe", "commercial break"]):
				useful.append(sentence.left(260))
			if useful.size() >= 3:
				break
		return (". ".join(useful) if not useful.is_empty() else text_value.left(600)).left(850)

	static func enrich_knowledge_entry(entry: Dictionary) -> void:
		var text_value := str(entry.get("transcript", ""))
		var keywords := rank_terms(text_value, 18)

		var entities: Array[String] = []
		var entity_regex := RegEx.new()
		entity_regex.compile("\\b[A-Z][A-Za-z0-9.+#_-]+(?:\\s+[A-Z][A-Za-z0-9.+#_-]+){0,3}\\b")
		for match_value in entity_regex.search_all(text_value):
			var entity := str(match_value.get_string()).strip_edges()
			if entity.length() >= 3 and not entities.has(entity):
				entities.append(entity)
			if entities.size() >= 16:
				break
			
		var identifiers: Array[String] = []
		var identifier_regex := RegEx.new()
		identifier_regex.compile("\\b[A-Za-z_][A-Za-z0-9_]{2,}\\s*\\(")
		for match_value in identifier_regex.search_all(text_value):
			var identifier := str(match_value.get_string()).trim_suffix("(").strip_edges()
			if not identifiers.has(identifier):
				identifiers.append(identifier)
			if identifiers.size() >= 20:
				break
			
		var urls: Array[String] = []
		var url_regex := RegEx.new()
		url_regex.compile("https?://[^\\s)>\\]]+")
		for match_value in url_regex.search_all(text_value):
			var url := str(match_value.get_string()).trim_suffix(".").trim_suffix(",")
			if not urls.has(url):
				urls.append(url)
			
		# Never infer a speaker's age/gender or identity from people they mention.
		var speaker_info := detect_speaker_info(text_value)
		if not bool(entry.get("speaker_locked", false)):
			entry.speaker = speaker_info.speaker
			entry.speaker_gender = "Unknown"
			entry.speaker_basis = speaker_info.speaker_basis
		var category_evidence := evidence(text_value)
		var original_category := str(entry.get("category", "Unknown"))
		if not entry.has("source_kind"):
			entry.source_kind = "Document" if original_category == "Document" else str(entry.get("source_mode", "captured media"))
		var explicit_project := original_category in ["Godot Project", "Godot Code"] and (str(entry.get("source_mode", "")).begins_with("Godot") or entry.has("project_root") or str(entry.get("source_path", "")).ends_with(".gd"))
		if not bool(entry.get("category_locked", false)) and not explicit_project:
			entry.category = str(category_evidence.category)
			if str(entry.category) == "Unknown" and str(entry.get("source_kind", "")) == "Document":
				entry.category = "Document"
			entry.category_reason = str(category_evidence.reason)
		elif not entry.has("category_reason"):
			entry.category_reason = "Preserved explicit project/manual category."
		entry.category_score = int(category_evidence.score)
		entry.classifier_version = REVIEW_VERSION

		entry.schema_version = 4
		entry.keywords = keywords
		entry.entities = entities
		entry.code_identifiers = identifiers
		entry.source_urls = urls
		var code_re := RegEx.new()
		code_re.compile("(?m)^(?:\\s*(?:func|def|class|var|const)\\s+\\w+|\\s*#include\\s*[<\"])" )
		entry.content_type = "code" if text_value.contains("```") or identifiers.size() >= 3 or code_re.search(text_value) != null else "prose"
		entry.facts = knowledge_summary(text_value).split(". ", false)
		entry.fingerprint = fingerprint(text_value)
	
		if not entry.has("pinned"):
			entry.pinned = false
		if not entry.has("user_verified"):
			entry.user_verified = false
		if not entry.has("study_status"):
			entry.study_status = "pending"
		if not entry.has("study_reason"):
			entry.study_reason = "Waiting for Meow Meow to review this capture."
		if not entry.has("linked_to"):
			entry.linked_to = ""
		
		var quality := 5
		if text_value.length() >= 180:
			quality += 1
		if text_value.length() >= 600:
			quality += 1
		if not entities.is_empty() or not identifiers.is_empty():
			quality += 1
		if str(entry.get("confidence", "")).contains("user-"):
			quality += 1
		if str(entry.get("category", "")) == "Commercial" or text_value.length() < 45:
			quality -= 3
		entry.quality_score = clampi(quality, 1, 10)
	
		var confidence_score := 35
		var confidence_text := str(entry.get("confidence", "")).to_lower()
		if confidence_text.contains("user-provided") or confidence_text.contains("user-imported"):
			confidence_score = 50
		if confidence_text.contains("working script") and not bool(entry.get("user_verified", false)):
			confidence_score = 50
			entry.confidence = "local source-code reference; runtime behavior not independently verified"
		if bool(entry.get("user_verified", false)):
			confidence_score = 95
		entry.confidence_score = confidence_score
	
		entry.search_text = normalize_retrieval_text(str(entry.get("source_name", "")) + " " + str(entry.get("category", "")) + " " + str(entry.get("speaker", "")) + " " + " ".join(keywords) + " " + " ".join(entities) + " " + text_value)
	
		if str(entry.get("source_mode", "")).contains("Microphone") or str(entry.get("source_mode", "")).contains("output"):
			var chunk_index := maxi(0, int(entry.get("chunk", 1)) - 1)
			entry.start_seconds = chunk_index * 10
			entry.end_seconds = (chunk_index + 1) * 10

	static func contains_any(text: String, needles: Array) -> bool:
		for needle in needles:
			if text.contains(str(needle)):
				return true
		return false


# KnowledgeVault smooth pipeline: main-thread UI, isolated jobs, bounded work.
const VAULT_FRAME_BUDGET_US := 2000
const VAULT_PAGE_SIZE := 20
const VAULT_ACTIVITY_LIMIT := 120
var vault_jobs: Dictionary = {}
var vault_loading := true
var vault_write_blocked := false
var vault_revision := 0
var vault_saved_revision := 0
var vault_save_due := 0
var vault_save_snapshot: Array = []
var vault_save_cursor := -1
var vault_save_revision := 0
var vault_cleanup: Array[Dictionary] = []
var vault_index: Dictionary = {}
var vault_fingerprints: Dictionary = {}
var vault_known_audio: Dictionary = {}
var vault_unread_count := 0
var vault_build_unread := 0
var vault_counts := {"pending": 0, "relevant": 0, "rejected": 0, "archived": 0}
var vault_pending_ids: Array[String] = []
var vault_pending_head := 0
var vault_recheck_all := false
var vault_recheck_generation := 0
var vault_recheck_done: Dictionary = {}
var vault_links: Array[Dictionary] = []
var vault_cache_dirty := true
var vault_cache_cursor := -1
var vault_cache_revision := 0
var vault_build_index: Dictionary = {}
var vault_build_fingerprints: Dictionary = {}
var vault_term_index: Dictionary = {}
var vault_build_term_index: Dictionary = {}
var vault_build_counts: Dictionary = {}
var vault_build_queue: Array[String] = []
var vault_build_rejected_ids: Array[String] = []
var vault_final_review_ids: Array[String] = []
var vault_final_review_head := 0
var vault_build_links: Array[Dictionary] = []
var vault_views: Dictionary = {}
var vault_status_filter: OptionButton
var vault_activity_lines: Array[String] = []
var vault_activity_dirty := false
var vault_interest_cache: Array[String] = []
var vault_profile_due := 0
var vault_stats_due := 0
var vault_stats := {"bytes": 0, "memory_bytes": 0, "audio_count": 0}
var vault_stats_ready := false
var vault_audio_scan_due := 0
var vault_audio_backlog_count := 0
var vault_audio_paths: Array = []
var vault_audio_cursor := 0
var vault_capture_poll_due := 0
var vault_seen_capture_chunks := -1
var vault_ui_due := 0
var vault_review_paused := false
var vault_pause_button: Button
var vault_maintenance_button: Button
var vault_maintenance_due := 0
var vault_save_error := ""

func _vault_start_job(kind: String, data: Dictionary, metadata: Dictionary = {}) -> void:
	if vault_jobs.has(kind):
		return
	data.kind = kind
	var worker := VaultWorker.new()
	var task_id := WorkerThreadPool.add_task(worker.run.bind(data), false, "SAM Vault " + kind)
	vault_jobs[kind] = {"task": task_id, "worker": worker, "meta": metadata}

func _vault_mark_changed(reindex: bool = true) -> void:
	vault_revision += 1
	if reindex:
		vault_cache_dirty = true
	if vault_save_due == 0:
		vault_save_due = Time.get_ticks_msec() + 1500
	# A changed record invalidates an in-progress snapshot, never the durable file.
	if vault_save_cursor >= 0:
		vault_save_cursor = -1
		vault_save_snapshot.clear()
	for kind in vault_views:
		vault_views[kind].dirty = true

func _vault_entry_signature(entry: Dictionary) -> String:
	return JSON.stringify([entry.get("transcript", ""), entry.get("category", ""), entry.get("category_locked", false), entry.get("pinned", false), entry.get("user_verified", false), entry.get("confidence", ""), entry.get("user_interest_feedback", ""), entry.get("for_you", false), entry.get("unread_discovery", false)]).sha256_text()

func _vault_poll_jobs() -> void:
	for kind_value in vault_jobs.keys():
		var kind := str(kind_value)
		var job: Dictionary = vault_jobs[kind]
		if not WorkerThreadPool.is_task_completed(int(job.task)):
			continue
		# Do not mutate entries while assembling a consistent save snapshot.
		if kind == "study" and vault_save_cursor >= 0:
			continue
		WorkerThreadPool.wait_for_task_completion(int(job.task))
		var worker: VaultWorker = job.worker
		var result: Dictionary = worker.result
		vault_jobs.erase(kind)
		if kind == "load":
			vault_loading = false
			if not bool(result.get("ok", false)):
				vault_write_blocked = true
				vault_save_error = str(result.get("error", "Vault load failed"))
				log_line("KNOWLEDGE ERROR", vault_save_error)
				show_toast(vault_save_error)
				continue
			knowledge_entries = result.get("entries", [])
			vault_cache_dirty = true
			if bool(result.get("changed", false)):
				_vault_mark_changed()
			refresh_knowledge_report()
			refresh_knowledge_discoveries()
			_vault_invalidate_view("transcripts")
		elif kind == "study":
			var entry_id := str(job.meta.get("id", ""))
			var existing := find_knowledge_entry(entry_id)
			if existing.is_empty() or _vault_entry_signature(existing) != str(job.meta.get("signature", "")):
				# A pin, manual category change, deletion or import won the race.
				is_processing_batch = false
				study_animation_state = "idle"
				study_worker_done = false
				study_pending_worker_result.clear()
				vault_cache_dirty = true
				continue
			if vault_recheck_all and int(job.meta.get("recheck_generation", -1)) == vault_recheck_generation:
				vault_recheck_done[entry_id] = true
			var index := int(vault_index.get(entry_id, -1))
			if index < 0 or index >= knowledge_entries.size() or str(knowledge_entries[index].get("id", "")) != entry_id:
				is_processing_batch = false
				study_animation_state = "idle"
				vault_cache_dirty = true
				continue
			var processed: Dictionary
			if bool(result.get("ok", false)):
				processed = result.get("entry", existing.duplicate(true))
			else:
				# A worker runtime error must not silently strand a queue item.
				processed = existing.duplicate(true)
				processed.study_status = "relevant" if bool(processed.get("pinned", false)) or bool(processed.get("user_verified", false)) else "rejected"
				processed.study_reason = "Review worker returned no usable result; source kept. Use RECHECK SAVED NOTES to retry; see Debug Telemetry."
				processed.review_version = VaultWorker.REVIEW_VERSION
			if _study_live_visuals_active():
				# Hold the completed result for the visible desk animation. This delay is
				# presentation-only; the worker is already finished and the UI stays live.
				study_pending_worker_result = {"index": index, "entry": processed}
				study_worker_done = true
			else:
				_on_batch_processing_complete(index, processed)
		elif kind == "save":
			if bool(result.get("ok", false)):
				vault_saved_revision = int(job.meta.get("revision", vault_saved_revision))
				vault_save_error = ""
			else:
				vault_save_error = str(result.get("error", "Vault save failed"))
				log_line("KNOWLEDGE ERROR", vault_save_error)
				show_toast("Vault save failed • originals kept • see Debug Telemetry")
			vault_save_due = Time.get_ticks_msec() + (1500 if bool(result.get("ok", false)) else 10000) if vault_revision > vault_saved_revision else 0
		elif kind == "profile":
			vault_interest_cache.assign(result.get("terms", []))
		elif kind == "stats":
			vault_stats = result
			vault_stats_ready = true
			_vault_render_storage_stats()
		elif kind == "audio_scan":
			vault_audio_paths = result.get("paths", [])
			vault_audio_cursor = 0
			vault_audio_backlog_count = int(result.get("total", vault_audio_paths.size()))
		elif kind == "cleanup" and not bool(result.get("ok", false)):
			log_line("KNOWLEDGE", "Could not remove some temporary audio/text files; saved transcript is safe.")

func _vault_step_cache(deadline: int) -> void:
	if not vault_cache_dirty and vault_cache_cursor < 0:
		return
	if vault_cache_cursor < 0:
		vault_cache_cursor = 0
		vault_cache_revision = vault_revision
		vault_build_index = {}
		vault_build_fingerprints = {}
		vault_build_term_index = {}
		vault_build_counts = {"pending": 0, "relevant": 0, "rejected": 0, "archived": 0}
		vault_build_unread = 0
		vault_build_queue = []
		vault_build_rejected_ids = []
		vault_build_links = []
	while vault_cache_cursor < knowledge_entries.size() and Time.get_ticks_usec() < deadline:
		var index := vault_cache_cursor
		vault_cache_cursor += 1
		if knowledge_entries[index] is not Dictionary:
			continue
		var entry: Dictionary = knowledge_entries[index]
		var entry_id := str(entry.get("id", ""))
		vault_build_index[entry_id] = index
		var status := str(entry.get("study_status", "pending"))
		vault_build_counts[status] = int(vault_build_counts.get(status, 0)) + 1
		if status == "pending" or int(entry.get("review_version", 0)) < VaultWorker.REVIEW_VERSION or (vault_recheck_all and not vault_recheck_done.has(entry_id)):
			vault_build_queue.append(entry_id)
		if status == "rejected":
			vault_build_rejected_ids.append(entry_id)
		var fingerprint := str(entry.get("fingerprint", ""))
		if not fingerprint.is_empty() and not vault_build_fingerprints.has(fingerprint):
			vault_build_fingerprints[fingerprint] = entry_id
		for key in ["audio_path", "capture_audio_source"]:
			var path := str(entry.get(key, ""))
			if not path.is_empty():
				vault_known_audio[ProjectSettings.globalize_path(path)] = true
		if status == "relevant" and bool(entry.get("unread_discovery", false)):
			vault_build_unread += 1
		if status == "relevant":
			vault_build_links.append(_vault_link_record(entry))
			if vault_build_links.size() > 64:
				vault_build_links.pop_front()
			# Build a compact inverted term index while the cache already walks the
			# library. Chat retrieval can then score a few candidates instead of
			# normalizing/scanning every retained transcript on every message.
			var index_text := str(entry.get("search_text", ""))
			if index_text.is_empty():
				index_text = normalize_retrieval_text(str(entry.get("source_name", "")) + " " + str(entry.get("category", "")) + " " + str(entry.get("summary", "")) + " " + str(entry.get("transcript", "")))
			var seen_terms: Dictionary = {}
			var indexed_terms := 0
			var stop_words := knowledge_stop_words()
			for raw_term in index_text.split(" ", false):
				var term := str(raw_term).strip_edges()
				if term.length() < 3 or stop_words.has(term) or seen_terms.has(term):
					continue
				seen_terms[term] = true
				if not vault_build_term_index.has(term):
					vault_build_term_index[term] = []
				(vault_build_term_index[term] as Array).append(entry_id)
				indexed_terms += 1
				if indexed_terms >= 180:
					break
	if vault_cache_cursor >= knowledge_entries.size():
		vault_index = vault_build_index
		vault_fingerprints = vault_build_fingerprints
		vault_term_index = vault_build_term_index
		vault_counts = vault_build_counts
		vault_unread_count = vault_build_unread
		vault_pending_ids = vault_build_queue
		vault_pending_head = 0
		var overflow := maxi(0, vault_build_rejected_ids.size() - KNOWLEDGE_REVIEW_LATER_LIMIT)
		vault_final_review_ids.clear()
		for rejected_index in range(overflow):
			vault_final_review_ids.append(vault_build_rejected_ids[rejected_index])
		vault_final_review_head = 0
		vault_links = vault_build_links
		vault_cache_cursor = -1
		vault_cache_dirty = vault_cache_revision != vault_revision

func _vault_add_entry_to_term_index(entry: Dictionary) -> void:
	if str(entry.get("study_status", "")) != "relevant":
		return
	var entry_id := str(entry.get("id", ""))
	var index_text := str(entry.get("search_text", ""))
	if index_text.is_empty():
		index_text = normalize_retrieval_text(str(entry.get("source_name", "")) + " " + str(entry.get("category", "")) + " " + str(entry.get("summary", "")) + " " + str(entry.get("transcript", "")))
	var seen: Dictionary = {}
	var stop_words := knowledge_stop_words()
	var count := 0
	for raw_term in index_text.split(" ", false):
		var term := str(raw_term).strip_edges()
		if term.length() < 3 or stop_words.has(term) or seen.has(term):
			continue
		seen[term] = true
		if not vault_term_index.has(term):
			vault_term_index[term] = []
		var ids: Array = vault_term_index[term]
		if not ids.has(entry_id):
			ids.append(entry_id)
			vault_term_index[term] = ids
		count += 1
		if count >= 180:
			break

func _vault_link_record(entry: Dictionary) -> Dictionary:
	return {"id": str(entry.get("id", "")), "category": str(entry.get("category", "Unknown")), "summary": str(entry.get("summary", "")).left(120), "keywords": (entry.get("keywords", []) as Array).duplicate()}

func _vault_step_save(deadline: int, force: bool = false) -> void:
	if vault_loading or vault_write_blocked or vault_jobs.has("save") or vault_revision <= vault_saved_revision:
		return
	if not force and (vault_save_due == 0 or Time.get_ticks_msec() < vault_save_due):
		return
	if vault_save_cursor < 0:
		vault_save_cursor = 0
		vault_save_revision = vault_revision
		vault_save_snapshot = []
	while vault_save_cursor < knowledge_entries.size() and Time.get_ticks_usec() < deadline:
		var value: Variant = knowledge_entries[vault_save_cursor]
		vault_save_snapshot.append(value.duplicate(true) if value is Dictionary else value)
		vault_save_cursor += 1
	if vault_save_cursor >= knowledge_entries.size():
		var snapshot := vault_save_snapshot
		vault_save_snapshot = []
		vault_save_cursor = -1
		_vault_start_job("save", {"path": ProjectSettings.globalize_path(knowledge_index_file()), "entries": snapshot}, {"revision": vault_save_revision})

func _vault_cleanup_after_save() -> void:
	if vault_jobs.has("cleanup") or vault_cleanup.is_empty():
		return
	var paths: Array[String] = []
	var retained: Array[Dictionary] = []
	for item in vault_cleanup:
		if int(item.revision) <= vault_saved_revision:
			for path in item.paths:
				paths.append(str(path))
		else:
			retained.append(item)
	vault_cleanup = retained
	if not paths.is_empty():
		_vault_start_job("cleanup", {"paths": paths})

func _vault_run_safe_maintenance(manual: bool = false) -> void:
	if vault_loading or vault_cache_cursor >= 0 or vault_save_cursor >= 0 or vault_jobs.has("study"):
		if manual:
			show_toast("Vault is busy • try maintenance after the current job finishes")
		return
	var seen: Dictionary = {}
	var duplicates_archived := 0
	for index in range(knowledge_entries.size()):
		if not knowledge_entries[index] is Dictionary:
			continue
		var entry: Dictionary = knowledge_entries[index]
		if str(entry.get("study_status", "")) != "relevant":
			continue
		var fingerprint := str(entry.get("fingerprint", ""))
		if fingerprint.is_empty():
			fingerprint = VaultWorker.fingerprint(str(entry.get("transcript", "")))
			entry.fingerprint = fingerprint
		if fingerprint.is_empty():
			continue
		if not seen.has(fingerprint):
			seen[fingerprint] = str(entry.get("id", ""))
			continue
		if bool(entry.get("pinned", false)) or bool(entry.get("user_verified", false)):
			continue
		entry.study_status = "archived"
		entry.study_reason = "Safe maintenance archived an exact duplicate of retained note %s. Transcript preserved outside normal chat retrieval." % str(seen[fingerprint])
		entry.review_version = VaultWorker.REVIEW_VERSION
		duplicates_archived += 1
	settings.vault_last_maintenance_date = Time.get_date_string_from_system()
	save_json(SETTINGS_FILE, settings)
	vault_audio_scan_due = 0
	vault_cache_dirty = true
	if duplicates_archived > 0:
		_vault_mark_changed()
	else:
		for kind in vault_views:
			vault_views[kind].dirty = true
	if manual:
		show_toast("Safe maintenance complete • %d exact duplicate note(s) archived • nothing important auto-deleted" % duplicates_archived)
	log_line("KNOWLEDGE", "Safe maintenance: %d exact duplicate notes archived; Review Later cap %d" % [duplicates_archived, KNOWLEDGE_REVIEW_LATER_LIMIT])

func _vault_tick(_delta: float) -> void:
	_vault_poll_jobs()
	if vault_loading or shutdown_started:
		return
	var now := Time.get_ticks_msec()
	var deadline := Time.get_ticks_usec() + VAULT_FRAME_BUDGET_US
	_vault_step_save(deadline)
	_vault_step_cache(deadline)
	_vault_step_views(deadline)
	_vault_step_audio_paths(deadline)
	_vault_cleanup_after_save()
	if now >= vault_audio_scan_due:
		discover_unprocessed_knowledge_audio()
	if now >= vault_profile_due and not vault_jobs.has("profile"):
		vault_profile_due = now + 30000
		var profile := " ".join(settings.get("discovery_interest_terms", []) as Array)
		for index in range(maxi(0, history.size() - 40), history.size()):
			var message: Variant = history[index]
			if message is Dictionary and str(message.get("role", "")) == "user":
				profile += " " + str(message.get("content", "")).left(2000)
		_vault_start_job("profile", {"memory_path": str(settings.memory_path), "text": profile})
	if now >= vault_maintenance_due:
		vault_maintenance_due = now + 60000
		if bool(settings.get("vault_auto_maintenance", true)) and str(settings.get("vault_last_maintenance_date", "")) != Time.get_date_string_from_system() and not generating and not knowledge_recording and not is_processing_batch:
			_vault_run_safe_maintenance(false)
	if now >= vault_stats_due and not vault_jobs.has("stats"):
		vault_stats_due = now + 15000
		_vault_start_job("stats", {"path": ProjectSettings.globalize_path(knowledge_storage_dir()), "memory_path": str(settings.memory_path)})
	if now >= vault_ui_due:
		vault_ui_due = now + 250
		if vault_activity_dirty and is_instance_valid(study_activity) and study_activity.is_visible_in_tree():
			study_activity.text = "[color=#8292ad]LATEST 120 DECISIONS • full reasons are saved with each note[/color]\n" + "\n".join(vault_activity_lines)
			study_activity.scroll_to_line(maxi(0, study_activity.get_line_count() - 1))
			vault_activity_dirty = false
		update_knowledge_status()
		if vault_pending_head >= vault_pending_ids.size() or is_processing_batch:
			refresh_knowledge_discovery_indicator()

func _vault_append_activity(line: String) -> void:
	vault_activity_lines.append(line)
	while vault_activity_lines.size() > VAULT_ACTIVITY_LIMIT:
		vault_activity_lines.pop_front()
	vault_activity_dirty = true

func _vault_decision_activity(entry: Dictionary) -> void:
	var status := str(entry.get("study_status", ""))
	var relevant := status == "relevant"
	var label := "RETAINED" if relevant else ("ARCHIVED • SAVED, NOT DELETED" if status == "archived" else "NEEDS REVIEW")
	var color := "#76f7a6" if relevant else ("#8292ad" if status == "archived" else "#ff8095")
	_vault_append_activity("[color=%s][b]%s[/b][/color] • %s\n[color=#8292ad]%s[/color]" % [color, label, escape_bbcode(str(entry.get("summary", "")).left(180)), escape_bbcode(str(entry.get("study_reason", "")).left(350))])

func _vault_toggle_pause() -> void:
	vault_review_paused = not vault_review_paused
	vault_pause_button.text = "RESUME STUDY" if vault_review_paused else "PAUSE STUDY"

func _vault_request_recheck() -> void:
	if vault_loading or vault_cache_dirty or vault_cache_cursor >= 0:
		show_toast("Vault is preparing its index • try again shortly")
		return
	# Queue stable IDs; do not clear categories/pins or delete rejected material.
	vault_recheck_all = true
	vault_recheck_generation += 1
	vault_recheck_done.clear()
	vault_pending_ids.assign(vault_index.keys())
	vault_pending_head = 0
	vault_review_paused = false
	if is_instance_valid(vault_pause_button):
		vault_pause_button.text = "PAUSE STUDY"
	show_toast("Saved notes queued for background review • originals and manual choices preserved")

func _vault_flush_for_shutdown() -> bool:
	vault_review_paused = true
	while not vault_jobs.is_empty() or vault_save_cursor >= 0 or vault_revision > vault_saved_revision or not vault_cleanup.is_empty():
		_vault_poll_jobs()
		if vault_write_blocked or (not vault_save_error.is_empty() and not vault_jobs.has("save")):
			return false
		_vault_step_save(Time.get_ticks_usec() + VAULT_FRAME_BUDGET_US, true)
		_vault_cleanup_after_save()
		await get_tree().process_frame
	return true

func _vault_render_storage_stats() -> void:
	if not is_instance_valid(knowledge_storage_stats):
		return
	var limit := maxf(0.01, float(settings.get("knowledge_limit_gb", 10.0)))
	var used := float(vault_stats.get("bytes", 0)) / 1073741824.0
	knowledge_storage_path_label.text = "Vault location: %s\nMemoryCore: %s" % [ProjectSettings.globalize_path(knowledge_storage_dir()), str(settings.memory_path)]
	knowledge_storage_stats.text = "[color=#76f7a6][font_size=20]STORAGE REPORT[/font_size][/color]\n\nKnowledge Vault: %.3f GB / %.2f GB (%.1f%%)\nSaved entries: %d • source audio files: %d\nMemoryCore: %.2f KB\n\n[color=#8292ad]Disk totals are scanned off the UI thread and cached for up to 15 seconds. Temporary audio is removed only after its transcript is saved successfully. Review Later is capped at 100; older uncertain notes receive a final pass and low-value fragments are archived but preserved. Daily safe maintenance can archive exact duplicate retained notes, rebuild indexes, and rescan temporary audio; it never auto-deletes retained/pinned/verified notes. Original index backup: index.pre-smooth-v1.backup.json[/color]" % [used, limit, minf(100.0, used / limit * 100.0), knowledge_entries.size(), int(vault_stats.get("audio_count", 0)), float(vault_stats.get("memory_bytes", 0)) / 1024.0]


func _vault_install_pager(parent: Control, kind: String, report: RichTextLabel) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	parent.add_child(row)
	parent.move_child(row, report.get_index())
	var first := make_button("FIRST", _vault_turn_page.bind(kind, "first"), colors.cyan)
	var previous := make_button("PREVIOUS", _vault_turn_page.bind(kind, "previous"), colors.cyan)
	var next := make_button("NEXT", _vault_turn_page.bind(kind, "next"), colors.cyan)
	var last := make_button("LATEST / LAST", _vault_turn_page.bind(kind, "last"), colors.cyan)
	last.text = "LAST"
	row.add_child(first)
	row.add_child(previous)
	var label := Label.new()
	label.text = "Preparing saved notes…"
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(label)
	row.add_child(next)
	row.add_child(last)
	var sizes := OptionButton.new()
	for count in [10, 20, 50]:
		sizes.add_item("%d / page" % count, count)
	sizes.select(1)
	sizes.item_selected.connect(_vault_page_size_changed.bind(kind))
	row.add_child(sizes)
	report.threaded = true
	report.fit_content = false
	report.scroll_following = false
	vault_views[kind] = {"report": report, "label": label, "first": first, "previous": previous, "next": next, "last": last, "sizes": sizes, "page": 0, "size": VAULT_PAGE_SIZE, "ids": [], "scan_ids": [], "scan_seen": {}, "scan": -1, "dirty": true, "due": 0, "revision": -1, "filter": "", "anchor": "", "reset_scroll": true}

func _vault_invalidate_view(kind: String, reset_page: bool = false) -> void:
	if not vault_views.has(kind):
		return
	var view: Dictionary = vault_views[kind]
	view.dirty = true
	if reset_page:
		view.page = 0
		view.anchor = ""
		view.scan = -1
		view.reset_scroll = true
		view.due = Time.get_ticks_msec() + 250

func _vault_filter_changed() -> void:
	_vault_invalidate_view("notes", true)

func _vault_page_size_changed(index: int, kind: String) -> void:
	var view: Dictionary = vault_views[kind]
	view.size = (view.sizes as OptionButton).get_item_id(index)
	view.page = 0
	view.anchor = ""
	view.reset_scroll = true
	_vault_render_page(kind)

func _vault_turn_page(kind: String, direction: String) -> void:
	var view: Dictionary = vault_views[kind]
	var pages := maxi(1, ceili(float((view.ids as Array).size()) / float(view.size)))
	match direction:
		"first": view.page = 0
		"previous": view.page = maxi(0, int(view.page) - 1)
		"next": view.page = mini(pages - 1, int(view.page) + 1)
		"last": view.page = pages - 1
	view.reset_scroll = true
	_vault_render_page(kind)

func _vault_filter_values(kind: String) -> Dictionary:
	var values := {"query": "", "category": "All", "status": "All saved"}
	if kind == "notes":
		values.query = normalize_retrieval_text(knowledge_search.text.strip_edges()) if is_instance_valid(knowledge_search) else ""
		values.category = knowledge_category.get_item_text(knowledge_category.selected) if is_instance_valid(knowledge_category) and knowledge_category.selected >= 0 else "All"
		values.status = vault_status_filter.get_item_text(vault_status_filter.selected) if is_instance_valid(vault_status_filter) else "Retained"
	return values

func _vault_entry_matches(entry: Dictionary, kind: String, filter_values: Dictionary) -> bool:
	var status := str(entry.get("study_status", "pending"))
	if kind == "discoveries":
		return status == "relevant" and bool(entry.get("for_you", false))
	if kind == "transcripts":
		var source := str(entry.get("source_mode", ""))
		return entry.has("capture_audio_source") or source.contains("Microphone") or source.contains("output")
	var wanted := str(filter_values.status)
	if wanted == "Retained" and status != "relevant":
		return false
	if wanted == "Needs review" and status != "rejected":
		return false
	if wanted == "Pending" and status != "pending":
		return false
	if wanted == "Archived low-value" and status != "archived":
		return false
	if str(filter_values.category) != "All" and str(entry.get("category", "Unknown")) != str(filter_values.category):
		return false
	var query := str(filter_values.query)
	if not query.is_empty():
		var searchable := str(entry.get("search_text", ""))
		if searchable.is_empty():
			searchable = normalize_retrieval_text(str(entry.get("source_name", "")) + " " + str(entry.get("summary", "")) + " " + str(entry.get("transcript", "")))
		# Include the extracted notes too, not just the visible preview.
		searchable += " " + normalize_retrieval_text(str(entry.get("notes", [])))
		if not searchable.contains(query):
			return false
	return true

func _vault_step_views(deadline: int) -> void:
	if vault_loading or vault_cache_dirty or vault_cache_cursor >= 0:
		return
	for kind_value in vault_views:
		var kind := str(kind_value)
		var view: Dictionary = vault_views[kind]
		var report: RichTextLabel = view.report
		if not report.is_visible_in_tree():
			continue
		var values := _vault_filter_values(kind)
		var signature := JSON.stringify(values)
		if str(view.filter) != signature:
			view.filter = signature
			view.scan = -1
			view.dirty = true
			view.page = 0
			view.anchor = ""
			view.reset_scroll = true
			view.due = Time.get_ticks_msec() + 250
		if int(view.scan) < 0:
			if not bool(view.dirty) or Time.get_ticks_msec() < int(view.due):
				continue
			view.scan = knowledge_entries.size() - 1
			view.scan_ids = []
			view.scan_seen = {}
			view.revision = vault_revision
			view.dirty = false
		while int(view.scan) >= 0 and Time.get_ticks_usec() < deadline:
			var index := int(view.scan)
			view.scan = index - 1
			if index >= knowledge_entries.size() or knowledge_entries[index] is not Dictionary:
				continue
			var entry: Dictionary = knowledge_entries[index]
			var entry_id := str(entry.get("id", ""))
			if not (view.scan_seen as Dictionary).has(entry_id) and _vault_entry_matches(entry, kind, values):
				(view.scan_seen as Dictionary)[entry_id] = true
				(view.scan_ids as Array).append(entry_id)
		if int(view.scan) < 0:
			view.ids = view.scan_ids
			view.scan_ids = []
			view.scan_seen = {}
			# Stay on the page containing the user's old anchor when new notes arrive.
			if int(view.page) > 0 and not str(view.anchor).is_empty():
				var anchor_at := (view.ids as Array).find(str(view.anchor))
				if anchor_at >= 0:
					view.page = floori(float(anchor_at) / float(view.size))
			view.dirty = int(view.revision) != vault_revision
			view.due = Time.get_ticks_msec() + 750
			_vault_render_page(kind)
		if Time.get_ticks_usec() >= deadline:
			return

func _vault_render_page(kind: String) -> void:
	if not vault_views.has(kind):
		return
	var view: Dictionary = vault_views[kind]
	var report: RichTextLabel = view.report
	var ids: Array = view.ids
	var size := int(view.size)
	var pages := maxi(1, ceili(float(ids.size()) / float(size)))
	view.page = clampi(int(view.page), 0, pages - 1)
	var start := int(view.page) * size
	var finish := mini(start + size, ids.size())
	var title := "SAVED TRANSCRIPTS" if kind == "transcripts" else ("DISCOVERIES" if kind == "discoveries" else "SAVED STUDY NOTES")
	var parts: Array[String] = []
	parts.append("[font_size=18][color=#76f7a6]%s[/color][/font_size]\n[color=#8292ad]%d matching entries • %d retained / %d pending / %d review later / %d archived (saved / excluded). Media remains unverified. Open a note for its full transcript.[/color]\n" % [title, ids.size(), int(vault_counts.get("relevant", 0)), int(vault_counts.get("pending", 0)), int(vault_counts.get("rejected", 0)), int(vault_counts.get("archived", 0))])
	for index in range(start, finish):
		var entry := find_knowledge_entry(str(ids[index]))
		if entry.is_empty():
			continue
		var url_id := str(entry.get("id", "")).uri_encode()
		var preview := str(entry.get("summary", entry.get("transcript", ""))).left(500)
		if kind != "notes":
			preview = str(entry.get("transcript", "")).left(600)
		var status := str(entry.get("study_status", "pending"))
		parts.append("\n[color=#4deeea][b]%s[/b][/color]  [color=#f9c74f]%s[/color]%s\n[color=#8292ad]%s • chunk %d • %s[/color]\n%s\n[color=#76f7a6]REVIEW[/color] %s\n" % [escape_bbcode(str(entry.get("created", ""))), escape_bbcode(str(entry.get("category", "Unknown"))), "  ★ PINNED" if bool(entry.get("pinned", false)) else "", escape_bbcode(str(entry.get("source_name", entry.get("session", ""))).left(120)), int(entry.get("chunk", 0)), "needs review" if status == "rejected" else ("archived • saved / excluded" if status == "archived" else status), escape_bbcode(preview), escape_bbcode(str(entry.get("study_reason", "Queued for review.")).left(350))])
		parts.append("[color=#8292ad]Source: %s[/color]\n" % escape_bbcode(str(entry.get("confidence", "unverified observation")).left(150)))
		parts.append("[url=knowledge_open:%s]OPEN / CATEGORY[/url]    [url=knowledge_pin:%s]%s[/url]    [url=knowledge_verify:%s]VERIFY[/url]    [url=knowledge_forget:%s]FORGET[/url]\n" % [url_id, url_id, "UNPIN" if bool(entry.get("pinned", false)) else "PIN + RETAIN", url_id, url_id])
		if kind == "discoveries":
			parts.append("[color=#8292ad]%s[/color]\n[url=discovery_speak:%s]READ ALOUD[/url]    [url=discovery_more:%s]MORE LIKE THIS[/url]    [url=discovery_hide:%s]NOT FOR ME[/url]\n" % [escape_bbcode(str(entry.get("interest_reason", "")).left(250)), url_id, url_id, url_id])
			if not str(entry.get("audio_path", "")).is_empty():
				parts.append("[url=discovery_audio:%s]PLAY ORIGINAL[/url]\n" % url_id)
	if ids.is_empty():
		parts.append("\nNo entries match this view. Select All saved to inspect captured material, including notes awaiting review.")
	var scroll_value := report.get_v_scroll_bar().value
	report.text = "".join(parts)
	if bool(view.reset_scroll):
		report.get_v_scroll_bar().value = 0
		view.reset_scroll = false
	else:
		report.get_v_scroll_bar().value = scroll_value
	(view.label as Label).text = "Page %d / %d • %d–%d of %d" % [int(view.page) + 1, pages, start + 1 if not ids.is_empty() else 0, finish, ids.size()]
	(view.first as Button).disabled = int(view.page) == 0
	(view.previous as Button).disabled = int(view.page) == 0
	(view.next as Button).disabled = int(view.page) >= pages - 1
	(view.last as Button).disabled = int(view.page) >= pages - 1
	view.anchor = str(ids[start]) if start < ids.size() else ""

func _vault_open_entry(entry_id: String) -> void:
	var entry := find_knowledge_entry(entry_id)
	if entry.is_empty():
		return
	var dialog := AcceptDialog.new()
	dialog.title = "Saved knowledge • full transcript and category"
	dialog.min_size = Vector2i(660, 460)
	dialog.ok_button_text = "CLOSE"
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(640, 420)
	dialog.add_child(box)
	var info := Label.new()
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.text = "%s\n%s\nCategory evidence: %s\nSource: %s" % [str(entry.get("source_name", entry.get("session", ""))), str(entry.get("study_reason", "Pending review")), str(entry.get("category_reason", "Legacy category; queued for background review.")), str(entry.get("confidence", "unverified observation"))]
	box.add_child(info)
	var category_row := HBoxContainer.new()
	box.add_child(category_row)
	var chooser := OptionButton.new()
	for name in VaultWorker.CATEGORIES:
		chooser.add_item(str(name))
		if str(name) == str(entry.get("category", "Unknown")):
			chooser.select(chooser.item_count - 1)
	category_row.add_child(chooser)
	category_row.add_child(make_button("SAVE MANUAL CATEGORY", func():
		var current := find_knowledge_entry(entry_id)
		if not current.is_empty():
			current.category = chooser.get_item_text(chooser.selected)
			current.category_locked = true
			current.category_reason = "Manually selected by user."
			current.review_version = 0
			_vault_mark_changed()
			show_toast("Manual category saved • automatic review will preserve it")
		dialog.queue_free(), colors.cyan))
	category_row.add_child(make_button("AUTO CATEGORY", func():
		var current := find_knowledge_entry(entry_id)
		if not current.is_empty():
			current.category_locked = false
			current.review_version = 0
			_vault_mark_changed()
		dialog.queue_free(), colors.amber))
	var transcript := TextEdit.new()
	transcript.editable = false
	transcript.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	transcript.size_flags_vertical = Control.SIZE_EXPAND_FILL
	transcript.text = str(entry.get("transcript", ""))
	box.add_child(transcript)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	apply_theme_recursive(dialog)
	dialog.popup_centered_ratio(0.8)

func _exit_tree() -> void:
	# Editor Stop/forced scene teardown does not necessarily run begin_shutdown().
	# Stop native helpers here too, otherwise an orphan recorder can keep writing
	# 10-second files for hours after the Godot window has disappeared.
	knowledge_recording = false
	if not knowledge_capture_stop_path.is_empty():
		var stop_file := FileAccess.open(knowledge_capture_stop_path, FileAccess.WRITE)
		if stop_file:
			stop_file.store_string("stop")
			stop_file.close()
	if knowledge_capture_pid > 0 and OS.is_process_running(knowledge_capture_pid):
		OS.kill(knowledge_capture_pid)
	knowledge_capture_pid = -1
	if knowledge_process_pid > 0 and OS.is_process_running(knowledge_process_pid):
		OS.kill(knowledge_process_pid)
	knowledge_process_pid = -1
	for job in vault_jobs.values():
		WorkerThreadPool.wait_for_task_completion(int(job.task))
	vault_jobs.clear()

func _vault_prepare_incoming(entry: Dictionary) -> void:
	entry.study_status = "pending"
	entry.study_reason = "Queued for background study."
	entry.fingerprint = VaultWorker.fingerprint(str(entry.get("transcript", "")))

func _vault_add_entry(entry: Dictionary) -> void:
	var entry_id := str(entry.get("id", ""))
	if entry_id.is_empty() or (vault_index.has(entry_id) and not find_knowledge_entry(entry_id).is_empty()):
		entry_id = "%s-%d-%d" % [entry_id if not entry_id.is_empty() else "capture", Time.get_ticks_usec(), knowledge_entries.size()]
		entry.id = entry_id
	knowledge_entries.append(entry)
	vault_index[entry_id] = knowledge_entries.size() - 1
	var fingerprint := str(entry.get("fingerprint", ""))
	var existing_id := str(vault_fingerprints.get(fingerprint, ""))
	if not fingerprint.is_empty() and (existing_id.is_empty() or find_knowledge_entry(existing_id).is_empty()):
		vault_fingerprints[fingerprint] = entry_id

func _vault_step_audio_paths(deadline: int) -> void:
	while vault_audio_cursor < vault_audio_paths.size() and knowledge_queue.size() < KNOWLEDGE_QUEUE_LIMIT and Time.get_ticks_usec() < deadline:
		var audio_path := str(vault_audio_paths[vault_audio_cursor])
		vault_audio_cursor += 1
		if vault_known_audio.has(audio_path):
			continue
		var base := audio_path.get_file().get_basename().trim_prefix("chunk_")
		var separator := base.rfind("_")
		if separator <= 0 or not base.substr(separator + 1).is_valid_int():
			continue
		var audio_session := base.left(separator)
		if knowledge_recording and not knowledge_session_id.is_empty() and audio_session != knowledge_session_id.validate_filename():
			continue
		vault_known_audio[audio_path] = true
		knowledge_queue.append({"audio": audio_path, "session": audio_session, "chunk": int(base.substr(separator + 1))})
	if vault_audio_cursor >= vault_audio_paths.size():
		vault_audio_paths = []
		vault_audio_cursor = 0
