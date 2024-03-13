extends Control
class_name OptionsMenu

signal option_selected(int)

@onready var anchor: Control = $Anchor
@onready var container: Control = $Container

@export var Y_SPACING: int = 0

var option_template: PackedScene = preload("res://scenes/gui/option.tscn")
var options: Array[Option]
var active: bool = false


func set_options(items: Array[String]):
	options.clear()
	for child in container.get_children():
		child.queue_free()
	
	for i in len(items):
		var option: Option = option_template.instantiate()
		var text: String = items[i]
		
		var total_h: int = (option.size.y + Y_SPACING) * len(items)
		var xpos: int = anchor.position.x - (option.size.x / 2)
		var ypos: int = anchor.position.y - (total_h / 2) + (option.size.y + Y_SPACING) * i
		
		container.add_child(option)
		options.append(option)
		
		option.text = text
		option.active = false
		option.clicked.connect(option_clicked.bind(i))
		option.position = Vector2i(-option.size.x * 1.1, ypos)
		
		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_interval((i + 1) * 0.333)
		tween.tween_property(option, "position:x", xpos, 1.0)
		
		# If this is our final option, enable the entire menu.
		if i == len(items) - 1:
			tween.tween_callback(set_active.bind(true))


func option_clicked(selection: int) -> void:
	if active:
		active = false
		var selected: Option = options.pop_at(selection)
		
		# Send away the options that weren't chosen.
		for i in len(options):
			var tween: Tween = create_tween()
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.set_ease(Tween.EASE_OUT)
			
			var other: Option = options[i]
			other.active = false
			tween.tween_property(other, "scale", Vector2(0.75, 0.75), 0.5)
			tween.parallel().tween_property(other, "modulate:a", 0.0, 0.5)
			tween.tween_callback(other.queue_free)
		
		var tween: Tween = create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(selected, "scale", Vector2(1.25, 1.25), 1.0)
		tween.parallel().tween_property(selected, "modulate:a", 0.0, 1.0)
		tween.tween_callback(selected.queue_free)
		tween.tween_callback(func(): option_selected.emit(selection))
		
		tween.tween_interval(1.0)
		# tween.tween_callback(func(): NotificationManager.queue_notif("You chose option %d! Bitch!" % selection, 3.0))
		
		options.clear()


func set_active(val: bool) -> void:
	active = val
	for option in options:
		option.active = val


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#set_options([
		#"I hate you.",
		#"What's your problem?",
		#"Can I go home yet?",
		## "Die, die, die."
	#])
