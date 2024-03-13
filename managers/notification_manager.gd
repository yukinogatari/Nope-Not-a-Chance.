extends Node

signal window_changed(NotificationWindow)

var window: NotificationWindow
var cur_scene: Node


func set_window(new_window: NotificationWindow) -> void:
	window = new_window
	window_changed.emit(window)


func queue_notif(text: String, time: float = 2.0, fade_time: float = 0.25) -> void:
	if window:
		window.queue_notif(text, time, fade_time)
	else:
		print("Notification: ", text)


func kill_notif() -> void:
	if window:
		window.kill_notif()


func clear_all_notifs() -> void:
	if window:
		window.clear_all_notifs()
