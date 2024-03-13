@tool
extends Control
class_name Option

signal clicked

@export var hover_mask: BitMap
@export var text: String:
	set(val):
		text = val
		update_label()

@onready var bg: GlobalAnimatedTextureRect = $BG
@onready var border: GlobalAnimatedTextureRect = $Border
@onready var label: RichTextLabel = %Text

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
	update_label()
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
	if not border or not bg or not label:
		return
	
	if disabled:
		border.modulate = Color.DARK_GRAY
		bg.modulate = Color.DIM_GRAY
		label.add_theme_color_override("default_color", Color.LIGHT_GRAY)
		
	elif selected:
		border.modulate = "000000"
		bg.modulate = "D0D0D0"
		label.add_theme_color_override("default_color", Color.BLACK)
	
	else:
		border.modulate = "FFFFFF"
		bg.modulate = "303030"
		label.add_theme_color_override("default_color", Color.WHITE)


func update_label() -> void:
	if label:
		label.text = "[center][vary]%s[/vary][/center]" % text


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
