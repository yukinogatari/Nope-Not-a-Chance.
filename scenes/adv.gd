extends Control
class_name ADV

@export var AUTO_SHOW: bool = true
@export var AUTO_HIDE: bool = false
@export var CPS: int = 30:
	set(val):
		CPS = val
		if textbox: textbox.CPS = val

@onready var textbox: Textbox = %Textbox
@onready var options_menu: OptionsMenu = %OptionsMenu

signal line_finished
signal dialogue_finished

var cur_line: int = -1
var dialogue: Array[String] = []
var animating: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	textbox.visible = false
	options_menu.visible = false
	textbox.finished.connect(func(): line_finished.emit())
	
	if textbox: textbox.CPS = CPS
	
	#show_dialogue(
		#[
		#"Line 1.",
		#"This is a much longer line.",
		#"This is a very, very long line.",
		#"Okay, I lied."
	#])
	#show_options(
		#[
			#"Fuck you.",
			#"Fuck me."
		#], 
		#"[center]What's the plan?[/center]"
	#)


func _gui_input(event: InputEvent) -> void:
	if not textbox.visible or animating:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if textbox.is_typing:
			textbox.finish_typing()
			accept_event()
		
		else:
			next_line()
			accept_event()


func play_dialogue(lines: Array[String]) -> void:
	show_dialogue(lines)
	await dialogue_finished


func show_dialogue(lines: Array[String]) -> void:
	dialogue = lines
	cur_line = -1
	next_line()


func next_line() -> void:
	cur_line += 1
	
	if not textbox.visible and AUTO_SHOW:
		await show_textbox()
	
	if cur_line >= len(dialogue):
		textbox.set_text("")
		if AUTO_HIDE:
			await hide_textbox()
		dialogue_finished.emit()
		return
	
	textbox.set_text(dialogue[cur_line])


func show_options(options: Array[String], message: String = "") -> int:
	if message:
		if AUTO_SHOW:
			await show_textbox()
		
		textbox.set_text(message, false, false)
	
	options_menu.visible = true
	options_menu.set_options(options)
	var selected: int = await options_menu.option_selected
	options_menu.visible = false
	
	if message:
		textbox.set_text("")
		
		if AUTO_HIDE:
			await hide_textbox()
	
	return selected


func hide_textbox() -> void:
	if not textbox.visible:
		return
	
	var tween: Tween = create_tween()
	tween.tween_property(textbox, "modulate:a", 0.0, 0.5)
	tween.tween_property(textbox, "visible", false, 0.0)
	tween.tween_interval(0.5)
	
	animating = true
	await tween.finished
	animating = false


func show_textbox() -> void:
	if textbox.visible:
		return
	
	var tween: Tween = create_tween()
	tween.tween_property(textbox, "visible", true, 0.0)
	tween.tween_property(textbox, "modulate:a", 0.0, 0.0)
	tween.tween_property(textbox, "modulate:a", 1.0, 0.5)
	tween.tween_interval(0.5)
	
	animating = true
	await tween.finished
	animating = false
