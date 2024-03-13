extends Control
class_name CaptchaText

@export var GLITCH_CHANCE: float = 0.002
@export var GLITCH_GLITCH_CHANCE: float = 0.01
var cur_glitch_chance: float = 0.0

var margins: Vector4i = Vector4i(16, 16, 16, 16)
var font_size: int = 64
var font_color: Color = "#0093747c"

var num_dots: int = 64
var num_lines: int = 8

var raw_text: String = "nobody loves you"
var display_text: String:
	get:
		var s = ""
		for ch in ch_data:
			s += ch.ch
		return s

var dims: Vector2i
var ch_data: Array[CharacterData] = []
var dot_data: Array[DotData] = []
var line_data: Array[LineData] = []

var substitutions: Dictionary = {
	"a": "4",
	"b": "6",
	"c": "(",
	"e": "3",
	"g": "9",
	"i": "1",
	"o": "0",
	"s": "5",
	"t": "7"
}


class CharacterData:
	var ch: String = ""
	var size: int = 16
	var pos: Vector2
	var rot: int = 0
	var font: Font
	
	var ch_dims: Vector2:
		get:
			return font.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, size)
	
	var origin: Vector2:
		get:
			# Text draws at bottom left, so to rotate around the center, we need to
			# offset our position by half the character dimensions in the positive
			# x and negative y directions. I'm also fudging it by half the font size bc
			# it looks better like that. idk, it's all bullshit.
			return Vector2(ch_dims.x / 2.0, (size - ch_dims.y) / 2.0)
	
	var expanded_dims: Vector2:
		get:
			# This is probably horribly wrong, but we're approximating how much
			# space the rotated character occupies by rotating the rectangle
			# that encloses it around the origin calculated above.
			# Mostly we just need this so we have a rough idea of how big the
			# entire captcha frame is so we can draw the background/borders.
			var rect = Rect2(0, 0, ch_dims.x, ch_dims.y)
			var trans = Transform2D()
			trans.origin = origin
			trans = trans.rotated_local(deg_to_rad(rot))
			rect = rect * trans
			return rect.size


class DotData:
	var pos: Vector2 = Vector2.ZERO
	var size: float = 1.0


class LineData:
	var start: Vector2 = Vector2.ZERO
	var end: Vector2 = Vector2.ZERO
	var size: float = 1.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Make the substitutions go both ways.
	for ch in substitutions:
		var sub = substitutions[ch]
		substitutions[sub] = ch


func _draw() -> void:
	var rid = get_canvas_item()
	for ch in ch_data:
		draw_set_transform(ch.pos + ch.origin, deg_to_rad(ch.rot))
		ch.font.draw_string(rid, -ch.origin, ch.ch, HORIZONTAL_ALIGNMENT_LEFT, -1, ch.size, font_color)
	
	draw_set_transform(Vector2.ZERO)
	for dot in dot_data:
		draw_circle(dot.pos, dot.size, font_color)
	
	for line in line_data:
		draw_line(line.start, line.end, font_color, line.size, true)


func sub_ch(ch: String, chance: float = 0.15) -> String:
	var l_ch = ch.to_lower()
	if l_ch in substitutions and randf() < chance:
		return substitutions[l_ch]
	return ch


func glitch(count: int = 1) -> void:
	for i in count:
		var c = ch_data.pick_random()
		match randi_range(0, 20):
			0:
				c.font = FontManager.random_font()
			1:
				c.size += randi_range(-1, 1)
			2:
				c.rot += randi_range(-5, 5)
			3:
				c.pos.x += randi_range(-3, 3)
				c.pos.y += randi_range(-3, 3)
			_:
				c.ch = sub_ch(c.ch)


func generate() -> void:
	ch_data.clear()
	dot_data.clear()
	line_data.clear()
	
	var width = margins.x
	var height = 0
	for ch in raw_text:
		var cur_ch = CharacterData.new()
		cur_ch.ch = ch.to_upper() if randf() > 0.5 else ch.to_lower()
		cur_ch.font = FontManager.random_font()
		cur_ch.size = max(0, font_size + randi_range(-font_size / 4, font_size / 4))
		cur_ch.rot = randi_range(-45, 45)
		
		var ch_dims = cur_ch.ch_dims
		var x_off = randi_range(-font_size / 4, font_size / 4)
		var y_off = randi_range(-font_size / 4, font_size / 4)
		cur_ch.pos = Vector2(width + x_off, margins.y + y_off + ch_dims.y)
		
		width += cur_ch.ch_dims.x
		height = max(height, cur_ch.expanded_dims.y + y_off)
		
		ch_data.append(cur_ch)
		
	dims.x = width + margins.z
	dims.y = height + margins.y + margins.w
	
	for i in randi_range(num_dots / 2, num_dots):
		var dot = DotData.new()
		dot.pos = Vector2(
			randi_range(0, dims.x),
			randi_range(0, dims.y),
		)
		dot.size = randf_range(1.0, 2.5)
		dot_data.append(dot)
	
	for i in randi_range(num_lines / 2, num_lines):
		var line = LineData.new()
		line.start = Vector2(
			randi_range(0, dims.x),
			randi_range(0, dims.y),
		)
		line.end = Vector2(
			randi_range(0, dims.x),
			randi_range(0, dims.y),
		)
		line.size = randf_range(1.0, 1.5)
		line_data.append(line)
	
	cur_glitch_chance = GLITCH_CHANCE
	glitch(len(raw_text))
	queue_redraw()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if randf() < cur_glitch_chance:
		glitch()
		queue_redraw()
		
		if randf() < GLITCH_GLITCH_CHANCE:
			cur_glitch_chance = min(cur_glitch_chance + GLITCH_CHANCE, 1)
