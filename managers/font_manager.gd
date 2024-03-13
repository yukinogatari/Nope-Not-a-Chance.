extends Node

# My "grab all fonts" code below doesn't work in release so
# just setting it manually for now
var all_fonts: Array[Font] = [
	preload("res://fonts/Andika-R.ttf"),
	preload("res://fonts/CascadiaMono-Regular.ttf"),
	preload("res://fonts/ComicMono.ttf"),
	preload("res://fonts/Cousine-Regular.ttf"),
	preload("res://fonts/FantasqueSansMono-Bold.ttf"),
	preload("res://fonts/FantasqueSansMono-Regular.ttf"),
	preload("res://fonts/LibreBaskerville-Bold.ttf"),
	preload("res://fonts/LibreBaskerville-Italic.ttf"),
	preload("res://fonts/LibreBaskerville-Regular.ttf"),
	preload("res://fonts/NotoSans-Bold.ttf"),
	preload("res://fonts/NotoSans-Regular.ttf"),
	preload("res://fonts/RecursiveMonoCslSt-Regular.ttf"),
	preload("res://fonts/RecursiveMonoLnrSt-Regular.ttf"),
	preload("res://fonts/RecursiveSansCslSt-Regular.ttf"),
	preload("res://fonts/RecursiveSansLnrSt-Regular.ttf"),
	preload("res://fonts/RobotoSlab-Bold.ttf"),
	preload("res://fonts/RobotoSlab-Regular.ttf"),
	preload("res://fonts/Rosarivo-Italic.ttf"),
	preload("res://fonts/Rosarivo-Regular.ttf"),
	preload("res://fonts/Signika-Bold.ttf"),
	preload("res://fonts/Signika-Regular.ttf"),
]

var vary_fonts: Array[Font] = [
	preload("res://fonts/RecursiveMonoCslSt-Regular.ttf"),
	preload("res://fonts/CascadiaMono-Regular.ttf"),
	preload("res://fonts/RecursiveMonoLnrSt-Regular.ttf"),
	preload("res://fonts/ComicMono.ttf"),
	preload("res://fonts/FantasqueSansMono-Regular.ttf"),
]

var _cur_vary_font: int = 0

@onready var vary_font_rids: Array[RID]:
	get:
		var rids: Array[RID] = []
		for font in vary_fonts:
			rids.append(font.get_rids()[0])
		return rids


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	# Apparently this doesn't work when resources are packed for a release
	# so just manually filling the all_fonts list for now, orz
	#var font_dir = DirAccess.open("res://fonts")
	#
	#for fn in font_dir.get_files():
		#if fn.strip_edges().to_lower().ends_with(".ttf"):
			#all_fonts.append(load("res://fonts/" + fn))


func random_font() -> Font:
	return all_fonts.pick_random()


func cur_vary_font() -> Font:
	return vary_fonts[_cur_vary_font]


func next_vary_font() -> Font:
	_cur_vary_font = (_cur_vary_font + 1) % len(vary_fonts)
	return vary_fonts[_cur_vary_font]


func random_vary_font() -> Font:
	var _next = _cur_vary_font
	while _next == _cur_vary_font:
		_next = randi() % len(vary_fonts)
	_cur_vary_font = _next
	return vary_fonts[_cur_vary_font]
