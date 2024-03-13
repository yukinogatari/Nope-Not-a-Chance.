extends Control
class_name CaptchaFrame

var bg_color: Color = Color.WHITE
var border_color: Color = Color.BLACK
var border_width: int = 0


var dims: Vector2i = Vector2i(100, 100):
	set(val):
		dims = val
		queue_redraw()


func _draw() -> void:
	draw_rect(Rect2i(0, 0, dims.x, dims.y), bg_color)
	if border_width > 0:
		draw_rect(Rect2(border_width / 2.0, border_width / 2.0, dims.x - border_width, dims.y - border_width), border_color, false, border_width)
