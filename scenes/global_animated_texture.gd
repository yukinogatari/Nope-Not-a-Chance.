### THIS DOES NOT WORK

extends Texture2D
class_name GlobalAnimatedTexture

@export var frames: Array[Texture2D]
var cur_frame: int = 0


func _ready() -> void:
	AnimationManager.next_frame.connect(next_frame)



func next_frame() -> void:
	if frames:
		cur_frame = (cur_frame + 1) % len(frames)
		
		# texture = frames[cur_frame]
	
	# if frames:
		# texture = frames[cur_frame]


func _get_rid() -> RID:
	if frames:
		return frames[cur_frame].get_rid()
	
	return get_rid()


func _get_width() -> int:
	if frames:
		return frames[cur_frame].get_width()
	
	return 1


func _get_height() -> int:
	if frames:
		return frames[cur_frame].get_height()
	
	return 1


func _has_alpha() -> bool:
	if frames:
		return frames[cur_frame].has_alpha()
	
	return false


func _get_image() -> Image:
	if frames:
		return frames[cur_frame].get_image()
	
	return null


func _is_pixel_opaque(x: int, y: int) -> bool:
	if frames:
		return frames[cur_frame].is_pixel_opaque(x, y)
	
	return true
