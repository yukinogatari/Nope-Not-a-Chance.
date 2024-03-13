###############################################################################
### COPIED ALMOST WHOLESALE FROM OPTION.GD
### BECAUSE I AM LAZY AND CAN'T BE ASSED TO MAKE THIS PROPERLY MODULAR
###############################################################################

@tool
extends Control
class_name TitleButton

signal clicked

@export var hover_mask: BitMap
@export var text_frames: Array[Texture2D]:
	set(val):
		text_frames = val
		if text:
			text.frames = val

@onready var bg: GlobalAnimatedTextureRect = $BG
@onready var border: GlobalAnimatedTextureRect = $Border
@onready var text: GlobalAnimatedTextureRect = $Text


var selected: bool = false:
	set(val):
		selected = val
		update_style()

@export var disabled: bool = false:
	set(val):
		disabled = val
		update_style()


var mouse_held: bool = false
var active: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_text()
	update_style()
	
	# Inherit our size from the bg texture so we can use it for processing.
	size = bg.size
	custom_minimum_size = bg.size
	pivot_offset = size / 2


func mask_test(pos: Vector2) -> bool:
	var in_mask: bool = false
	var mask_size: Vector2i = hover_mask.get_size()
		
	if pos.x > 0 and pos.x < mask_size.x and \
		pos.y > 0 and pos.y < mask_size.y:
			in_mask = hover_mask.get_bitv(pos)
	
	return in_mask


func _gui_input(event: InputEvent) -> void:
	if not active:
		return
	
	if event is InputEventMouse:
		# The input event is relative to the entire control, but we want to
		# process it relative to the underlying graphics, which might have
		# moved around when Godot laid the UI out.
		var adjusted_pos: Vector2i = event.position - bg.position
		var in_mask: bool = mask_test(adjusted_pos)
		
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if in_mask and event.pressed:
				mouse_held = true
			elif mouse_held and in_mask and not event.pressed:
				clicked.emit()
				accept_event()
				mouse_held = false
			else:
				mouse_held = false
		
		selected = in_mask or mouse_held


func update_style() -> void:
	if not border or not bg or not text:
		return
	
	if disabled:
		border.modulate = Color.DARK_GRAY
		bg.modulate = Color.DIM_GRAY
		text.modulate = Color.LIGHT_GRAY
		
	elif selected:
		border.modulate = "000000"
		bg.modulate = "D0D0D0"
		text.modulate = Color.BLACK
	
	else:
		border.modulate = "FFFFFF"
		bg.modulate = "303030"
		text.modulate = Color.WHITE


func update_text() -> void:
	if text:
		text.frames = text_frames


func _process(_delta: float) -> void:
	if selected:
		# For some reason, moving the mouse too fast will result in the control
		# not being told the mouse is no longer there, so we occasionally check
		# in our regular process node whether the mouse is *outside* the hover mask
		# and un-set it if that's the case. Do *not* do anything else bc we
		# otherwise trust Godot's input filtering to make sure we only get
		# inputs we care about.
		# Ahh, the woes of reinventing the wheel for very little benefit.
		# Viewport position -> control position -> BG graphic position.
		var mouse_pos: Vector2 = get_viewport().get_mouse_position() - global_position - bg.position
		
		if not mask_test(mouse_pos):
			selected = false
