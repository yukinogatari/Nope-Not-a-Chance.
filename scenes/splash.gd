extends Control

@onready var splash_animation: AnimationPlayer = $SplashAnimation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	splash_animation.play("Splash")
	splash_animation.animation_finished.connect(func(_anim_name: StringName):
		NotificationManager.clear_all_notifs()
		SceneManager.change_scene_from_file("res://scenes/title_menu.tscn")
	)

var messages = [
	"Stop that.",
	"You can't skip this.",
	"Don't waste your time.",
	"You're just going to wear down your mouse.",
]

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		NotificationManager.queue_notif(messages.pick_random(), 0.5, 0.25)
		accept_event()
