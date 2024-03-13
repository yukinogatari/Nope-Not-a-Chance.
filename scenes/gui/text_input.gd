extends Control
class_name TextInput

@onready var input: LineEdit = $Input
@onready var cancel_button: Option = %CancelButton
@onready var submit_button: Option = %SubmitButton

@export var LIMIT_CHARS: String = ""

signal input_changed(String)
signal cancel_clicked(String)
signal submit_clicked(String)


func _ready() -> void:
	cancel_button.clicked.connect(func(): cancel_clicked.emit(input.text))
	submit_button.clicked.connect(func(): submit_clicked.emit(input.text))
	input.text_submitted.connect(func(text: String): submit_clicked.emit(text))
	input.text_changed.connect(text_changed)


func text_changed(text: String) -> void:
	if LIMIT_CHARS:
		var new_text: String = ""
		for ch in text:
			if ch in LIMIT_CHARS:
				new_text += ch
		
		if text != new_text:
			var caret = input.caret_column - (len(text) - len(new_text))
			input.text = new_text
			input.caret_column = caret
			text = new_text
	
	input_changed.emit(text)
