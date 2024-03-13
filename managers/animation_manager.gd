@tool
extends Node

signal next_frame

@onready var timer: Timer = Timer.new()
var fps: float = 4.0


func set_fps(new_fps: float):
	fps = new_fps
	timer.start(1.0 / fps)


func tween() -> Tween:
	return create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(timer)
	
	# idk why you can't pass next_frame.emit directly to timeout.connect
	# but gdscript got mad at me so I guess we're using a lambda.
	timer.timeout.connect(func(): next_frame.emit())
	timer.start(1.0 / fps)
