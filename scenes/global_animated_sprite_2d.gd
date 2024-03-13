# @tool
extends Sprite2D
class_name GlobalAnimatedSprite2D

@export var frames: Array[Texture2D]
var cur_frame: int = 0


func _ready() -> void:
	AnimationManager.next_frame.connect(next_frame)
	
	if frames:
		texture = frames[cur_frame]


func next_frame() -> void:
	if frames:
		cur_frame = (cur_frame + 1) % len(frames)
		texture = frames[cur_frame]
