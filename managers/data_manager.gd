extends Node

const SAVE_USER: String = "user://---"
const SAVE_DEV: String = "res://---"
const SAVE_FILE: String = SAVE_USER

const PLAYER_NAME: String = "UExBWUVSIE5BTUU="
const NOT_PLAYER_NAME: String = "UkVKRUNURUQgUExBWUVSIE5BTUU="
const PLAYER_AGE: String = "UExBWUVSIEFHRQ=="
const PLAYER_BIRTHPLACE: String = "UExBWUVSIEJJUlRIUExBQ0U="
const PLAYER_GENDER: String = "UExBWUVSIEdFTkRFUg=="
const PLAYER_PARENTS: String = "UExBWUVSIFBBUkVOVFM="
const PLAYER_SIBLINGS: String = "UExBWUVSIFNJQkxJTkdT"

const NG_COUNTER: String = "TkVXIEdBTUUgQ09VTlRFUg=="
const EJECTED_COUNTER: String = "UExBWUVSIEVKRUNURUQ="
const FORGIVEN_FLAG: String = "UExBWUVSIEZPUkdJVkVO"
const BANNED_FLAG: String = "VVNFUiBQRVJNQU5FTlRMWSBCQU5ORUQ="
const CAPTCHA_COMPLETED: String = "Q0FQVENIQSBDT01QTEVURUQ="
const SURVEY_COMPLETED: String = "U1VSVkVZIENPTVBMRVRFRA=="
const PLAYER_SIN: String = "UExBWUVSJ1MgUEVOQU5DRQ=="
const GAME_ENDING: String = "R0FNRSBFTkRJTkc="

var ng_counter: int:
	set(val): game_data[NG_COUNTER] = val
	get: return game_data.get(NG_COUNTER, 0)


var ejected: int:
	set(val): game_data[EJECTED_COUNTER] = val
	get: return game_data.get(EJECTED_COUNTER, 0)


var banished: bool:
	set(val): game_data[BANNED_FLAG] = val
	get: return game_data.get(BANNED_FLAG, false)


var forgiven: int:
	set(val): game_data[FORGIVEN_FLAG] = val
	get: return game_data.get(FORGIVEN_FLAG, 0)


var player_name: String:
	set(val): game_data[PLAYER_NAME] = val
	get: return game_data.get(PLAYER_NAME, "")


var not_player_name: String:
	set(val): game_data[NOT_PLAYER_NAME] = val
	get: return game_data.get(NOT_PLAYER_NAME, "")


var player_age: int:
	set(val): game_data[PLAYER_AGE] = val
	get: return game_data.get(PLAYER_AGE, null)


var player_gender: String:
	set(val): game_data[PLAYER_GENDER] = val
	get: return game_data.get(PLAYER_GENDER, "")


var player_birthplace: String:
	set(val): game_data[PLAYER_BIRTHPLACE] = val
	get: return game_data.get(PLAYER_BIRTHPLACE, "")


var player_parents: String:
	set(val): game_data[PLAYER_PARENTS] = val
	get: return game_data.get(PLAYER_PARENTS, "")


var player_siblings: String:
	set(val): game_data[PLAYER_SIBLINGS] = val
	get: return game_data.get(PLAYER_SIBLINGS, "")


var captcha_completed: bool:
	set(val): game_data[CAPTCHA_COMPLETED] = val
	get: return game_data.get(CAPTCHA_COMPLETED, false)


var survey_completed: bool:
	set(val): game_data[SURVEY_COMPLETED] = val
	get: return game_data.get(SURVEY_COMPLETED, false)


var player_sin: String:
	set(val): game_data[PLAYER_SIN] = val
	get: return game_data.get(PLAYER_SIN, "")


var ending: bool:
	set(val): game_data[GAME_ENDING] = val
	get: return game_data.get(GAME_ENDING, false)


var game_data: Dictionary

const FAKE_DATA: Array[String] = [
	"S0UgREFUQSBGQUtFIERBVA==",
	"REFUQSBGQUtFIERBVEEgRg==",
	"ZEFUQSBmQUtFIGRBVEEgZg==",
	"YSBmQUtFIGRBVEEgZkFLRQ==",
	"YUtFIGRBVEEgZkFLRSBkQQ==",
	"ZmFrZSBkYXRhIGZha2UgZA==",
	"QVRBIEZBS0UgREFUQSBGQQ==",
	"dGEgZmFrZSBkYXRhIGZhaw==",
	"a0UgZEFUQSBmQUtFIGRBVA==",
	"RSBEQVRBIEZBS0UgREFUQQ==",
	"YWtlIGRhdGEgZmFrZSBkYQ==",
	"dEEgZkFLRSBkQVRBIGZBSw==",
	"QXRhIEZha2UgRGF0YSBGYQ==",
	"ZSBkYXRhIGZha2UgZGF0YQ==",
	"RGF0YSBGYWtlIERhdGEgRg==",
	"VGEgRmFrZSBEYXRhIEZhaw==",
	"YXRhIGZha2UgZGF0YSBmYQ==",
	"RkFLRSBEQVRBIEZBS0UgRA==",
	"ZSBkQVRBIGZBS0UgZEFUQQ==",
	"QWtlIERhdGEgRmFrZSBEYQ==",
	"QSBGYWtlIERhdGEgRmFrZQ==",
	"ZkFLRSBkQVRBIGZBS0UgZA==",
	"QUtFIERBVEEgRkFLRSBEQQ==",
	"YSBmYWtlIGRhdGEgZmFrZQ==",
	"RmFrZSBEYXRhIEZha2UgRA==",
	"VEEgRkFLRSBEQVRBIEZBSw==",
	"QSBGQUtFIERBVEEgRkFLRQ==",
	"YVRBIGZBS0UgZEFUQSBmQQ==",
	"ZGF0YSBmYWtlIGRhdGEgZg==",
	"RSBEYXRhIEZha2UgRGF0YQ==",
	"S2UgRGF0YSBGYWtlIERhdA==",
	"a2UgZGF0YSBmYWtlIGRhdA==",
]


func _ready() -> void:
	load_data()


func _exit_tree() -> void:
	save_data()


func load_data() -> void:
	var fn: String = SAVE_FILE
	
	if not FileAccess.file_exists(fn):
		return
	
	var data: String = FileAccess.get_file_as_string(fn)
	game_data = JSON.parse_string(data)
	
	for fake in FAKE_DATA:
		game_data[fake] = randi_range(-10, 65536)


func save_data() -> void:
	var fn: String = SAVE_FILE
	var data: String = JSON.stringify(game_data)
	var f: FileAccess = FileAccess.open(fn, FileAccess.WRITE)
	f.store_string(data)
