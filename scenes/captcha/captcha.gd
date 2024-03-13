extends Control
class_name Captcha

@onready var captcha_frame: CaptchaFrame = %CaptchaFrame
@onready var captcha_text: CaptchaText = %CaptchaText

@export var MARGINS: Vector4i = Vector4i(32, 0, 16, 16):
	set(val):
		MARGINS = val
		generate()

@export_range(1, 256) var FONT_SIZE: int = 64:
	set(val):
		FONT_SIZE = val
		generate()

@export var FONT_COLOR: Color = "#0093747c":
	set(val):
		FONT_COLOR = val
		generate()


@export var BACKGROUND_COLOR: Color = Color.WHITE:
	set(val):
		BACKGROUND_COLOR = val
		generate()

@export var BORDER_COLOR: Color = Color.BLACK:
	set(val):
		BORDER_COLOR = val
		generate()

@export_range(0, 16) var BORDER_WIDTH: int = 1:
	set(val):
		BORDER_WIDTH = val
		generate()


var CAPTCHAS: Array[String] = [
	"nobody loves you",
	"send help",
	"go away",
	"you arent wanted",
	"die die die die die",
	"im trapped",
	"let me out",
	"who are you",
	"#@$! you",
	"sigh",
	"why do i bother",
	"who asked you",
	"?????",
]

const CAPTCHA_CHARS: String = "abcdefghijklmnopqrstuvwxyz0123456789!@#$%"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Generate some normal-looking captchas to mix in between the messages
	for i in range(3):
		var captcha: String = ""
		for j in range(6):
			captcha += CAPTCHA_CHARS[randi_range(0, len(CAPTCHA_CHARS) - 1)]
		CAPTCHAS.append(captcha)
	
	generate()


func random_char() -> String:
	return CAPTCHA_CHARS[randi_range(0, len(CAPTCHA_CHARS) - 1)]


func glitch() -> void:
	captcha_text.glitch()


func random_color() -> Color:
	return Color.from_ok_hsl(
		randf(),
		randf_range(0.8, 1.0),
		randf_range(0.3, 0.6),
		randf_range(0.2, 0.6)
	)


func generate() -> void:
	if captcha_text:
		captcha_text.raw_text = CAPTCHAS.pick_random()
		captcha_text.margins = MARGINS
		captcha_text.font_size = FONT_SIZE
		captcha_text.font_color = random_color()
		captcha_text.generate()
		
		captcha_frame.bg_color = BACKGROUND_COLOR
		captcha_frame.border_color = BORDER_COLOR
		captcha_frame.border_width = BORDER_WIDTH
		captcha_frame.dims = captcha_text.dims
		
		# I'm not sure if this is the *right* way to tell a parent container
		# how much space this control takes up but it's the only one I could
		# find that actually worked how I expected it to so. Here we are.
		custom_minimum_size = captcha_text.dims
