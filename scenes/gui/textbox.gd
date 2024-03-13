@tool
extends Control
class_name Textbox

signal finished

@onready var bg: GlobalAnimatedTextureRect = $BG
@onready var border: GlobalAnimatedTextureRect = $Border
@onready var label: RichTextLabel = %Text
@onready var ctc: GlobalAnimatedTextureRect = $CTC

var is_typing: bool = false
var typing_started: float = 0.0
var ctc_visible: bool = true

@export var CPS: float = 20.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = ""
	ctc.visible = false
	
	# set_text("Here's an example of what you can expect to see when working with the textbox. It's kind of gross, huh! But c'est la vie. That's what I'm going for. Four whole lines, even!")
	# set_text("...")
	
	# Inherit our size from the bg texture so we can use it for processing.
	size = bg.size
	pivot_offset = size / 2


func set_text(text: String, slow: bool = true, show_ctc: bool = true, start: bool = true) -> void:
	label.visible_characters = 0
	ctc_visible = show_ctc
	ctc.visible = false
	
	if text:
		label.text = "[vary]%s[/vary]" % text
	
	else:
		label.text = ""
		return
	
	if start:
		if slow:
			start_typing()
		else:
			finish_typing()


func start_typing() -> void:
	label.visible_characters = 0
	typing_started = Time.get_ticks_msec()
	ctc.visible = false
	is_typing = true


func finish_typing() -> void:
	is_typing = false
	label.visible_ratio = 1.0
	ctc.visible = ctc_visible and len(label.text) > 0
	finished.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if is_typing:
		var elapsed: float = (Time.get_ticks_msec() - typing_started) / 1000.
		var chars_visible: int = floor(elapsed * CPS)
		var total_chars: int = label.get_total_character_count()
		label.visible_characters = min(chars_visible, total_chars)
		
		if chars_visible >= total_chars:
			finish_typing()
