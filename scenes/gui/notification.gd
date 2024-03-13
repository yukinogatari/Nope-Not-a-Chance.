extends Control
class_name Notification

const window_height: float = 150

@onready var label: RichTextLabel = %NotifLabel


func _ready() -> void:
	label.text = ""


func set_text(text: String) -> void:
	if text:
		label.text = "[center][vary]%s[/vary][/center]" % text
	
	else:
		label.text = ""
