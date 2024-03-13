# Having a class name is handy for picking the effect in the Inspector.
class_name RichTextVaryfont
extends RichTextEffect


# To use this effect:
# - Enable BBCode on a RichTextLabel.
# - Register this effect on the label.
# - Use [vary]hello[/vary] in text.
var bbcode := "vary"
var cur_font: RID


func _init() -> void:
	AnimationManager.next_frame.connect(next_font)


func next_font() -> void:
	# Calculate based on a global timer so everything is synchronized nicely.
	if FontManager.is_node_ready():
		cur_font = FontManager.next_vary_font().get_rids().pick_random()


func _process_custom_fx(char_fx: CharFXTransform):
	# Don't hit the TextServer if we don't need to actually change the font.
	if cur_font and cur_font != char_fx.font:
		var ch = TextServerManager.get_primary_interface().font_get_char_from_glyph_index(char_fx.font, 1, char_fx.glyph_index)
		char_fx.font = cur_font
		char_fx.glyph_index = TextServerManager.get_primary_interface().font_get_glyph_index(cur_font, 1, ch, 0)
	
	return true
