extends Node2D

@onready var active_scene: SubViewport = %ActiveScene
@onready var notification_window: NotificationWindow = %NotificationWindow


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	NotificationManager.set_window(notification_window)
	SceneManager.set_viewport(active_scene)
	
	if DataManager.ng_counter < 3:
		SceneManager.change_scene_from_file("res://scenes/splash.tscn", false)
	
	elif DataManager.ng_counter < 11:
		SceneManager.change_scene_from_file("res://scenes/title_menu.tscn")
	
	else:
		SceneManager.change_scene_from_file("res://scenes/not_a_game.tscn")
