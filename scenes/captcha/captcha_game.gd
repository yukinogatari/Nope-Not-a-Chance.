extends Control
class_name CaptchaGame

@onready var captcha: Captcha = $Captcha
@onready var text_input: TextInput = $TextInput
@onready var corruption_timer: Timer = $CorruptionTimer

@export_range(1, 100) var REQUIRED_ATTEMPTS: int = 6
var attempts: int = 0

signal finished


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text_input.input_changed.connect(input_changed)
	text_input.submit_clicked.connect(submit_clicked)
	text_input.cancel_clicked.connect(cancel_clicked)
	corruption_timer.timeout.connect(corrupt)


func restart() -> void:
	attempts = 0
	captcha.generate()
	text_input.input.text = ""


func corrupt() -> void:
	match randi_range(0, 10):
		0:
			captcha.generate()
		
		1:
			corrupt_input()
		
		2:
			swap_buttons()
		
		_:
			captcha.glitch()


func swap_buttons() -> void:
	var tween: Tween = AnimationManager.tween().set_parallel()
	
	var submit_pos: int = text_input.submit_button.position.x
	var cancel_pos: int = text_input.cancel_button.position.x
	tween.tween_property(text_input.submit_button, "position:x", cancel_pos, 0.2)
	tween.tween_property(text_input.cancel_button, "position:x", submit_pos, 0.2)


func corrupt_input(chance: float = 0.1) -> void:
	var input = text_input.input.text
	var caret = text_input.input.caret_column
	
	input = input.replace("ass", "bum")
	input = input.replace("shit", "poop")
	input = input.replace("fuck", "heck")
	input = input.replace("bitch", "*****")
	
	for i in len(input):
		if randf() < chance:
			input[i] = captcha.random_char()
	
	text_input.input.text = input
	text_input.input.caret_column = caret


func input_changed(text: String) -> void:
	corrupt_input(0.01)


func submit_clicked(text: String) -> void:
	if not text:
		NotificationManager.queue_notif(
			[
				"At least *try*, why don't you?",
				"You left the box blank.",
				"Nothing there.",
				"Not even going to make an attempt?",
				"It's your time you're wasting."
			].pick_random()
		)
		return
	
	match randi_range(0, 10):
		0, 1, 2, 3:
			swap_buttons()
			NotificationManager.queue_notif(
				[
					"Wrong button, human.",
					"Swing and a miss.",
					"Close but no cigar.",
					"Oops, my finger slipped."
				].pick_random()
			)
			return
		
		4, 5, 6:
			captcha.glitch()
			
		7, 8, 9:
			corrupt_input()
	
	var answer: String = captcha.captcha_text.display_text
	NotificationManager.queue_notif(
		[
			"The correct answer was %s." % answer,
			"Are you even trying?",
			"Bzzt. Try again.",
			"I don't think that's quite right.",
			"Maybe next time.",
			"You couldn't be more wrong."
		].pick_random()
	)
	
	captcha.generate()
	text_input.input.text = ""
	attempts += 1
	
	if attempts > REQUIRED_ATTEMPTS:
		finished.emit()


func cancel_clicked(text: String) -> void:
	NotificationManager.queue_notif(
		[
			"Where do you think you're going?",
			"You can't get out of here.",
			"That doesn't do anything.",
			"Can't you see it's grayed out?",
			"It's a dummy button."
		].pick_random()
	)
