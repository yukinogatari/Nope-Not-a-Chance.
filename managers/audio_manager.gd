extends Node


@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer
@onready var voice_player: AudioStreamPlayer = $VoicePlayer

# Requires sfx_player to be playing to work, so make sure it's set to autoplay.
@onready var sfx_playback: AudioStreamPlaybackPolyphonic = sfx_player.get_stream_playback()


enum BGM {
	ASKING_QUESTIONS,
	BURTS_REQUIEM
}


const BGM_INFO: Dictionary = {
	BGM.ASKING_QUESTIONS: {
		filename = "res://audio/music/Asking Questions.mp3",
		title = "Asking Questions",
		composer = "Rafael Krux",
	},
	
	BGM.BURTS_REQUIEM: {
		filename = "res://audio/music/Burt's Requiem.mp3",
		title = "Burt's Requiem",
		composer = "Alexander Nakarada",
	},
}


func set_bgm_vol(vol: float) -> void:
	bgm_player.volume_db = linear_to_db(vol)


func play_bgm(track: BGM, fadein: float = 1.0, fadeout: float = 1.0) -> void:
	if not track in BGM_INFO:
		return
	
	var info = BGM_INFO[track]
	
	# To avoid any hitches/delays, queue up the load before we start our fadeout.
	ResourceLoader.load_threaded_request(info.filename)
	
	if bgm_player.playing:
		await create_tween().tween_method(set_bgm_vol, 1.0, 0.0, fadeout).finished
	
	bgm_player.stream = ResourceLoader.load_threaded_get(info.filename)
	bgm_player.stream.loop = true
	bgm_player.play()
	
	await create_tween().tween_method(set_bgm_vol, 0.0, 1.0, fadeout).finished
	
	NotificationManager.queue_notif("Now Playing\n[color=#99ccff]%s[/color]\nby [color=#99ccff]%s[/color]" % [info.title, info.composer], 5.0)


func play_sfx(fn: String) -> void:
	sfx_playback.play_stream(load(fn))

