class_name SamBuilderCat
extends Control

var _progress := 0.0
var cat_x := 76.0
var cat_dir := 1
var cat_state := "building"
var state_timer := 0.0
var stalled_timer := 0.0
var last_progress := -1.0
var house_bricks := 0
var is_raining := false
var rain_drops: Array[Vector2] = []

func _ready() -> void:
	custom_minimum_size = Vector2(360, 62)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for index in range(18):
		rain_drops.append(Vector2(fmod(float(index * 47), 360.0), fmod(float(index * 29), 62.0)))
	set_process(true)

func set_progress(value: float) -> void:
	var next_progress := clampf(value, 0.0, 100.0)
	if not is_equal_approx(next_progress, _progress):
		last_progress = _progress
		stalled_timer = 0.0
	_progress = next_progress
	house_bricks = int((_progress / 100.0) * 12.0)
	is_raining = _progress >= 58.0 and _progress < 78.0
	if _progress >= 100.0:
		cat_state = "celebrate"
	queue_redraw()

func _process(delta: float) -> void:
	state_timer += delta
	stalled_timer += delta
	if state_timer > 3.6 and _progress < 100.0:
		state_timer = 0.0
		var cycle := int(Time.get_ticks_msec() / 3600) % 10
		if is_raining:
			cat_state = "rain_dash"
		elif stalled_timer > 8.0:
			cat_state = "coffee"
		elif cycle < 5:
			cat_state = "building"
		elif cycle < 8:
			cat_state = "walking"
		else:
			cat_state = "coffee"
	if cat_state in ["walking", "building"]:
		cat_x += cat_dir * delta * 30.0
		if cat_x > 238.0:
			cat_dir = -1
		elif cat_x < 70.0:
			cat_dir = 1
	elif cat_state == "rain_dash":
		cat_dir = 1
		cat_x = minf(cat_x + delta * 95.0, 320.0)
	elif cat_state == "celebrate":
		cat_x = 278.0 + sin(Time.get_ticks_msec() / 110.0) * 5.0
	if is_raining:
		for index in range(rain_drops.size()):
			var drop := rain_drops[index]
			drop.y += delta * 120.0
			drop.x -= delta * 24.0
			if drop.y > size.y:
				drop.y = 0.0
				drop.x = fmod(float(index * 53 + Time.get_ticks_msec() / 17), maxf(size.x, 1.0))
			rain_drops[index] = drop
	queue_redraw()

func _draw() -> void:
	var rect := get_rect()
	draw_rect(Rect2(Vector2.ZERO, rect.size), Color("#081522"), true)
	draw_line(Vector2(0, rect.size.y - 9), Vector2(rect.size.x, rect.size.y - 9), Color("#244757"), 2.0)
	var site_origin := Vector2(12, rect.size.y - 11)
	for index in range(house_bricks):
		var bx := site_origin.x + float(index % 4) * 11.0
		var by := site_origin.y - float(index / 4) * 8.0 - 7.0
		draw_rect(Rect2(Vector2(bx, by), Vector2(10, 7)), Color("#ad794b"), true)
		draw_rect(Rect2(Vector2(bx, by), Vector2(10, 7)), Color("#53351f"), false, 1.0)
	var house_pos := Vector2(rect.size.x - 48, rect.size.y - 35)
	draw_rect(Rect2(house_pos, Vector2(38, 26)), Color("#8c5935"), true)
	var roof := PackedVector2Array([house_pos + Vector2(-4, 0), house_pos + Vector2(19, -15), house_pos + Vector2(42, 0)])
	draw_colored_polygon(roof, Color("#d84a55"))
	var cat_inside := (is_raining and cat_x >= rect.size.x - 54) or _progress >= 100.0
	draw_rect(Rect2(house_pos + Vector2(13, 11), Vector2(12, 15)), Color("#ffcc5c") if cat_inside else Color("#26150f"), true)
	if is_raining:
		for drop in rain_drops:
			draw_line(drop, drop + Vector2(-3, 7), Color(0.40, 0.68, 0.95, 0.72), 1.0)
	var cat_pos := Vector2(cat_x, rect.size.y - 20)
	if not (is_raining and cat_x >= rect.size.x - 54):
		draw_circle(cat_pos, 7.0, Color("#e69a4c"))
		draw_colored_polygon(PackedVector2Array([cat_pos + Vector2(-6, -4), cat_pos + Vector2(-5, -12), cat_pos + Vector2(-1, -7)]), Color("#e69a4c"))
		draw_colored_polygon(PackedVector2Array([cat_pos + Vector2(6, -4), cat_pos + Vector2(5, -12), cat_pos + Vector2(1, -7)]), Color("#e69a4c"))
		draw_circle(cat_pos + Vector2(-2, -1), 1.0, Color("#17202a"))
		draw_circle(cat_pos + Vector2(2, -1), 1.0, Color("#17202a"))
		if cat_state == "building":
			var swing := -5.0 if int(Time.get_ticks_msec() / 180) % 2 == 0 else 2.0
			draw_line(cat_pos + Vector2(cat_dir * 6, 1), cat_pos + Vector2(cat_dir * 13, swing), Color("#d7e3e8"), 2.0)
		elif cat_state == "coffee":
			draw_rect(Rect2(cat_pos + Vector2(cat_dir * 7, 1), Vector2(5, 5)), Color("#e8f4f6"), true)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(60, 17), "BUILD %d%%" % int(_progress), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	var status := "Building the house…"
	if cat_state == "coffee": status = "Tiny coffee break"
	elif cat_state == "rain_dash": status = "Rain! Running for shelter"
	elif cat_state == "celebrate": status = "Build complete!"
	draw_string(font, Vector2(60, 34), status, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#7feaf2"))
