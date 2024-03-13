extends Control
class_name NotificationWindow


@onready var notif_template: PackedScene = preload("res://scenes/gui/notification.tscn")
@export_range(0.0, 2.0) var NOTIFICATION_INTERVAL: float = 0.1
@export_range(0, 10) var ACTIVE_NOTIFICATIONS: int = 3

var queued_notifs: Array[Dictionary]
var active_notifications: Array[_Notif]
var last_notif: float = 0.0


class _Notif:
	var notif: Notification
	var tween: Tween
	
	func kill() -> void:
		tween.kill()
		notif.queue_free()


func queue_notif(text: String, time: float = 2.0, fade_time: float = 0.25) -> void:
	queued_notifs.append({text = text, time = time, fade_time = fade_time})


func send_notif() -> void:
	var data: Dictionary = queued_notifs.pop_front()
	
	if not data:
		return
	
	var notif: _Notif = _Notif.new()
	notif.notif = notif_template.instantiate()
	
	add_child(notif.notif)
	notif.notif.set_text(data.text)
	
	notif.tween = create_tween()
	notif.tween.tween_property(notif.notif, "position:y", -notif.notif.window_height, 0.0)
	notif.tween.tween_property(notif.notif, "position:y", 0, 0.5)
	notif.tween.tween_interval(data.time)
	notif.tween.tween_property(notif.notif, "modulate:a", 0, data.fade_time)
	notif.tween.tween_callback(clear_notif.bind(notif))
	
	active_notifications.push_front(notif)
	last_notif = Time.get_ticks_msec() / 1000.
	
	# Keep our active notifications to a reasonable size.
	if len(active_notifications) > ACTIVE_NOTIFICATIONS:
		for i in range(ACTIVE_NOTIFICATIONS, len(active_notifications)):
			active_notifications[i].kill()
	
	active_notifications = active_notifications.slice(0, ACTIVE_NOTIFICATIONS)


func clear_notif(notif: _Notif) -> void:
	if not notif:
		return
	
	notif.kill()
	active_notifications.erase(notif)


func kill_notifs() -> void:
	for notif in active_notifications:
		notif.tween.kill()
		notif.tween = create_tween()
		notif.tween.tween_property(notif.notif, "modulate:a", 0, 0.2)
		notif.tween.tween_callback(clear_notif.bind(notif))


func clear_all_notifs() -> void:
	queued_notifs.clear()
	kill_notifs()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if queued_notifs and Time.get_ticks_msec() / 1000. > last_notif + NOTIFICATION_INTERVAL:
		send_notif()
