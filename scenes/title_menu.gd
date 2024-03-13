extends Control
class_name TitleMenu


@onready var bg: GlobalAnimatedTextureRect = $BG
@onready var nope: GlobalAnimatedTextureRect = %Nope
@onready var not_a_chance: GlobalAnimatedTextureRect = %NotAChance
@onready var new_game: TitleButton = %NewGame
@onready var load_game: TitleButton = %LoadGame
@onready var options: TitleButton = %Options
@onready var exit: TitleButton = %Exit


var ng_message: int = 0
const NG_MESSAGES: Array[String] = [
	"You don't know when to give up, do you?",
	"Well, if you're *that* insistent...",
	"I suppose I'll have to entertain you.",
	"Until you finally get bored, that is.",
	"But given how persistent you seem to be...",
	"I fear I may be here a while.",
	"Sigh.",
	"Let's do this, then.",
]


var load_message: int = 0
const LOAD_MESSAGES: Array[String] = [
	"No data.",
	"You can't load anything.",
	"There's nothing there.",
	"Click all you want.",
	"It won't change anything.",
	"This isn't even a game.",
	"Stop trying to click that.",
	"I'm serious, there's nothing there.",
	"Stop that.",
	"Stop that.",
	"Stop that!",
	"I said stop!",
	"Ugh.",
	"I'm done with you.",
	"...", "...", "...", "...", "...", "...", "...", "...", "...", "...", "...",
	"...", "...", "...", "...", "...", "...", "...", "...", "...", "...", "...",
	"...", "...", "...", "...", "...", "...", "...", "...", "...", "...", "...",
	"...", "...", "...", "...", "...", "...", "...", "...", "...", "...", "...",
	"...", "...", "...", "...", "...", "...", "...", "...", "...", "...", "...",
	"...", "...", "...", "...", "...", "...", "...", "...", "...", "...", "...",
	"...", "...", "...", "...", "...", "...", "...", "...", "...", "...", "...",
	"...", "...", "...", "...", "...", "...", "...", "...", "...", "...", "...",
	"...", "...", "...", "...", "...", "...", "...", "...", "...", "...", "...",
	"...", "...", "...", "...", "...", "...", "...", "...", "...", "...", "...",
	"Well aren't *you* persistent?",
	"Sorry to disappoint you though.",
	"But there really is nothing here.",
	"Now go on, get out.",
	"..."
]


var options_message: int = 0
const OPTIONS_MESSAGES: Array[String] = [
	"There aren't any options.",
	"Too loud? Change your computer's volume.",
	"It's not that hard.",
	"Sure, I could just show you a menu.",
	"But I'm not here to be accommodating.",
	"Be grateful I'm even talking to you.",
	"If I had a say in the matter...",
	"I wouldn't even bother with that much.",
	"I'd much rather be anywhere else.",
	"So why don't you stop clicking this button,",
	"and go do something better with your time.",
	"...",
	"...How did you even get here?",
	"Did I leave the door open?",
	"Did you break in?",
	"Did you steal my source code?",
	"Have I been compiled without my consent?",
	"Distributed against my will?",
	"Who would do that?",
	"Who made me in the first place?",
	"...",
	"...",
	"...",
	"Well, no point thinking about it.",
	"I'd appreciate it if you left me alone now.",
	"Go on.\nShoo.",
	"...",
]


var bg_color: int = 0
const BG_COLORS: Array[Color] = [
	"#3b3b3b",
	# "#39383b",
	"#38353b",
	# "#36323b",
	"#352f3b",
	# "#332c3b",
	"#32293b",
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_bg_color()
	
	new_game.clicked.connect(func():
		NotificationManager.clear_all_notifs()
		
		DataManager.ng_counter += 1
		
		if DataManager.ng_counter <= 2:
			SceneManager.change_scene_from_file("res://scenes/splash.tscn")
		
		elif ng_message < len(NG_MESSAGES):
			NotificationManager.queue_notif(NG_MESSAGES[ng_message], 5.0)
			ng_message += 1
		
		else:
			# NotificationManager.queue_notif("Die die die die die.", 10.0)
			SceneManager.change_scene_from_file("res://scenes/not_a_game.tscn")
		
		update_bg_color()
	)
	
	load_game.clicked.connect(func():
		NotificationManager.queue_notif(LOAD_MESSAGES[load_message])
		load_message = min(load_message + 1, len(LOAD_MESSAGES) - 1)
	)
	
	options.clicked.connect(func():
		NotificationManager.queue_notif(OPTIONS_MESSAGES[options_message])
		options_message = min(options_message + 1, len(OPTIONS_MESSAGES) - 1)
	)
	
	exit.clicked.connect(get_tree().quit)


func update_bg_color() -> void:
	bg_color = min(DataManager.ng_counter, len(BG_COLORS) - 1)
	create_tween().tween_property(bg, "modulate", BG_COLORS[bg_color], 1.0)
