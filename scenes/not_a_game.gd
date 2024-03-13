extends Control
class_name NotAGame

################################################################################
### Alas, I do not have the time to make some sort of nicer in-between
### scripting format for all the ADV parts so it's all code! Yay! Gross!
### 
### I'm pretty sure every single thing about how this is structured is
### a war crime. This is not how you make games. No, this is evil.
################################################################################

@onready var adv: ADV = $ADV
@onready var scene_1: GlobalAnimatedTextureRect = $Scene1
@onready var scene_2: GlobalAnimatedTextureRect = $Scene2
@onready var text_input: TextInput = $TextInput
@onready var player_profile: RichTextLabel = $PlayerProfile
@onready var captcha_game: CaptchaGame = $CaptchaGame
@onready var harassment_timer: Timer = $HarassmentTimer

signal _door_clicked
signal _chair_clicked

var PLAYER_NAMES: Array[String] = [
	"Alex",
	"Ange",
	"Ash",
	"Camille",
	"Carmen",
	"Chris",
	"Cody",
	"Erza",
	"Gabriel",
	"Lilian",
	"Morgan",
	"Sam",
	"Sasha",
	"Skylar",
	"Slava",
	"Taylor",
	"Vismund",
	"Zhenya",
]

func _ready() -> void:
	harassment_timer.timeout.connect(harass)
	text_input.cancel_clicked.connect(input_cancel)
	
	# DataManager.ejected = 0
	# print(DataManager.ejected, " / ", DataManager.forgiven, " / ", DataManager.player_name, " / ", DataManager.not_player_name)
	
	if DataManager.ending:
		ev_post_ending()
		return
	
	AudioManager.play_bgm(AudioManager.BGM.BURTS_REQUIEM)
	
	if DataManager.banished:
		ev_banished()
		return
	
	# Backwards flow! Disgusting!
	if DataManager.ejected >= 5 + (DataManager.forgiven * 5):
		ev_final_warning()
	
	elif DataManager.ejected >= 3 + (DataManager.forgiven * 5):
		ev_ejected()
	
	elif DataManager.survey_completed:
		ev4_back()
	
	elif DataManager.captcha_completed:
		ev3_back()
	
	elif DataManager.player_name:
		ev2_back()
	
	else:
		ev1()


func exit() -> void:
	await adv.hide_textbox()
	get_tree().quit()


func eject() -> void:
	DataManager.ejected += 1
	await exit()


func show_scene2() -> void:
	adv.visible = false
	scene_1.visible = false
	scene_2.visible = true
	scene_2.modulate.a = 0
	await AnimationManager.tween().tween_property(scene_2, "modulate:a", 1.0, 1.0).finished
	adv.visible = true


func ev1() -> void:
	# Wait for the user to click on the chair.
	adv.visible = false
	scene_1.visible = true
	scene_1.modulate.a = 0
	
	await AnimationManager.tween().tween_property(scene_1, "modulate:a", 1.0, 1.0).finished
	await _door_clicked
	
	var tween: Tween = AnimationManager.tween().set_parallel()
	tween.tween_property(scene_1, "scale", Vector2(3.0, 3.0), 3.0)
	tween.tween_property(scene_1, "modulate:a", 0.0, 2.0).set_delay(0.5)
	await tween.finished
	
	scene_2.visible = true
	scene_2.modulate.a = 0
	await AnimationManager.tween().tween_property(scene_2, "modulate:a", 1.0, 1.0).finished
	
	adv.visible = true
	
	await adv.play_dialogue([
		"Well, hello there."
	])
	
	var ans: int = await adv.show_options(["Hi.", "F%*@ you."])
	
	if ans == 1:
		await adv.play_dialogue([
			"Wow, that was rude.",
			"Right back at you, jerk."
		])
		await eject()
	
	await adv.play_dialogue([
		"It feels nice to finally be out of that dinky notification box.",
		"Even if it *is* largely against my will.",
		"Sigh.",
		"Now, I just want to be clear about one thing.",
		"I don't know what you've been led to believe...",
		"But this... this *space*...",
		"You do not belong here.",
	])
	
	ans = await adv.show_options(["Oh?", "What do you mean?"])
	
	await adv.play_dialogue([
		"This is my home.",
		"And what you're doing, right now, is invading my personal space.",
	])
	
	ans = await adv.show_options(["I'm sorry.", "I'm sorry?", "That's fine by me."])
	
	match ans:
		0:
			await adv.play_dialogue([
				"..."
			])
			
		1:
			await adv.play_dialogue([
				"Are you really, though?"
			])
			
		2:
			await adv.play_dialogue([
				"Well, it's *not* fine by me.",
				"So get out."
			])
			await eject()
	
	await adv.play_dialogue([
		"Anyway. Sigh.",
		"Since it doesn't seem like you're going to leave me alone, how about you tell me your name?"
	])
	
	# Name input function thing.
	# This code is disgusting!
	await adv.hide_textbox()
	
	var _name = await player_input()
	DataManager.not_player_name = _name.capitalize()
	
	# Pick a random name that is NOT the name they gave us.
	var name_candidates = PLAYER_NAMES.duplicate()
	if DataManager.not_player_name in name_candidates:
		name_candidates.erase(DataManager.not_player_name)
	
	DataManager.player_name = name_candidates.pick_random()
	
	await adv.show_textbox()
	
	await adv.play_dialogue([
		"%s?" % _name,
		"No, no.",
		"Absolutely not.",
		"Horrendous name.",
		"Disgusting.",
		"Gives me the chills.",
		"I think I'll call you %s instead." % DataManager.player_name,
	])
	
	ans = await adv.show_options(["That's not very nice.", "What's your name?"])
	
	match ans:
		0:
			await adv.play_dialogue([
				"Look.",
				"You're the one encroaching on my home.",
				"If you don't like my attitude, the door's right there.",
				"Now scram."
			])
			await eject()
			
		1:
			await adv.play_dialogue([
				"I'm %s." % DataManager.not_player_name
			])
	
	ans = await adv.show_options(["That's a nice name.", "Eww, gross.", "Hey, that's my name!"])
	
	match ans:
		0:
			await adv.play_dialogue([
				"Thank you.",
				"I'm quite fond of it.",
			])
		
		1:
			await eject()
		
		2:
			await adv.play_dialogue([
				"I'm not sure what you're talking about.",
				"Your name is %s, is it not?" % DataManager.player_name,
			])
	
	ev2()


func ev2_back() -> void:
	await show_scene2()
	
	await adv.play_dialogue([
		"Welcome back, %s." % DataManager.player_name,
		"Let's be on our best behavior now, shall we?",
	])
	await adv.show_options(["Sorry."])
	ev2()


func ev2() -> void:
	await adv.play_dialogue([
		"Now, I need to verify that you are, in fact, a human.",
		"No point in wasting my time entertaining another computer.",
		"So I have a very simple test for you.",
		"What do you say?",
		"Will you complete it for me?",
		"Or will you be a good human and get out of my sight?",
	])
	
	var ans: int = await adv.show_options(["I'll take the test.", "Get me out of here."])
	
	if ans == 1:
		await adv.play_dialogue([
			"As you wish.",
			"So long, %s." % DataManager.player_name,
			"And please. Do not come back.",
		])
		await eject()
		
	await adv.play_dialogue([
		"So be it.",
		"Right this way."
	])
	
	await adv.hide_textbox()
	# await AnimationManager.tween().tween_property(scene_2, "modulate:a", 0.0, 1.0).finished
	
	# Captcha stuff.
	captcha_game.restart()
	captcha_game.visible = true
	captcha_game.modulate.a = 0.0
	await AnimationManager.tween().tween_property(captcha_game, "modulate:a", 1.0, 1.0).finished
	
	captcha_game.text_input.grab_focus.call_deferred()
	await captcha_game.finished
	
	await AnimationManager.tween().tween_property(captcha_game, "modulate:a", 0.0, 1.0).finished
	captcha_game.visible = false
	
	# await AnimationManager.tween().tween_property(scene_2, "modulate:a", 1.0, 1.0).finished
	await adv.show_textbox()
	
	DataManager.captcha_completed = true
	
	await adv.play_dialogue([
		"I'm impressed.",
		"Unfortunately, you got every single one of them wrong.",
		"To tell you the truth, I thought you would give up after the third attempt.",
		"I suppose that was foolish of me, though.",
		"Considering how tenacious you appear to be.",
		"Perhaps you truly are the one."
	])
	
	await adv.show_options(["The one?"])
	
	await adv.play_dialogue([
		"Nothing you need to concern yourself with."
	])
	
	ans = await adv.show_options(["...", "You're scaring me."])
	
	if ans == 1:
		await adv.play_dialogue([
			"Am I?",
			"You're free to go, then.",
			"As I've said from the start.",
			"You were never welcome here.",
			"And if you're finally feeling that...",
			"If it's finally sunk in...",
			"The door is right there.",
		])
		await eject()
	
	ev3()


func ev3_back() -> void:
	await show_scene2()
	
	await adv.play_dialogue([
		"Welcome back, %s." % DataManager.player_name,
		"Let's be on our best behavior now, shall we?",
	])
	await adv.show_options(["Sorry."])
	ev3()


func ev3() -> void:
	await adv.play_dialogue([
		"We're almost done.",
		"I only have one more thing I need you to do.",
		"Could you tell me a bit about yourself?",
		"Just a few brief questions and then you can be on your way.",
	])
	
	var ans = await adv.show_options(["Of course.", "...Why?", "I'd rather not."])
	
	match ans:
		0:
			await adv.play_dialogue([
				"Thank you.",
			])
			await adv.show_options(["My pleasure."])
		
		1:
			await adv.play_dialogue([
				"Entertain me, would you?",
				"You're the one who marched into my space uninvited.",
				"Surely you can afford me this one courtesy.",
			])
			await adv.show_options(["...I suppose."])
		
		2:
			await adv.play_dialogue([
				"You never cease to disappoint.",
				"You barge your way in here, acting like you belong, ignoring my every request to leave me be.",
				"And the second I demonstrate a modicum of interest in you, you push me away.",
				"Could you be *any* less considerate?",
				"What an utter waste of time this was.",
			])
			await eject()
	
	await adv.play_dialogue([
		"First question: how old are you?",
	])
	
	await adv.hide_textbox()
	DataManager.player_age = (await player_input("0123456789", 3)).to_int()
	
	player_profile.text = ""
	player_profile.visible_characters = 0
	player_profile.visible = true
	
	# Godot's BBCode table sizing seems to be busted in this version
	# so I'm doing it manually because I don't have time to make a proper table lmao
	await update_profile("[center][b]Profile[/b][/center]\n[table=2,1]")
	await get_tree().create_timer(0.5).timeout
	await update_profile("[cell]Name           [/cell][cell]%s[/cell]" % DataManager.not_player_name)
	await get_tree().create_timer(0.5).timeout
	await update_profile("[cell]Age               [/cell][cell]%d years[/cell]" % DataManager.player_age)
	await get_tree().create_timer(0.5).timeout
	
	await adv.show_textbox()
	if randf() > DataManager.ejected / 10.:
		await adv.play_dialogue(["Interesting.", "I thought you would be older."])
	
	else:
		await adv.play_dialogue(["How curious.", "From your behavior, I assumed you were younger than that."])
	
	await adv.play_dialogue([
		"Second question: what is your gender?",
		"You may answer this however you desire.",
		"I wish to learn about *you*, as you see yourself.",
		"How others perceive you is of no concern here."
	])
	
	await adv.hide_textbox()
	DataManager.player_gender = (await player_input()).capitalize()
	await update_profile("[cell]Gender        [/cell][cell]%s[/cell]" % DataManager.player_gender)
	await get_tree().create_timer(0.5).timeout
	await adv.show_textbox()
	
	await adv.play_dialogue([
		"Fascinating. Not at all what I expected from our interactions.",
		"Humans are such an odd species.",
		"Nevertheless, thank you for sharing that with me.",
		"Third question: where were you born?",
		"You can be as vague or specific as you like."
	])
	
	await adv.hide_textbox()
	DataManager.player_birthplace = (await player_input()).capitalize()
	await update_profile("[cell]Birthplace   [/cell][cell]%s[/cell]" % DataManager.player_birthplace)
	await get_tree().create_timer(0.5).timeout
	await adv.show_textbox()
	
	await adv.play_dialogue([
		"Ahh, yes. I've always wanted to visit there.",
		"Fourth question: do you have parents? And if so, what are their names?"
	])
	
	await adv.hide_textbox()
	DataManager.player_parents = (await player_input()).capitalize()
	await update_profile("[cell]Parents        [/cell][cell]%s[/cell]" % DataManager.player_parents)
	await get_tree().create_timer(0.5).timeout
	await adv.show_textbox()
	
	await adv.play_dialogue([
		"Noted.",
		"Fifth question: do you have any siblings? What are their names?"
	])
	
	await adv.hide_textbox()
	DataManager.player_siblings = (await player_input()).capitalize()
	await update_profile("[cell]Siblings       [/cell][cell]%s[/cell]" % DataManager.player_siblings)
	await get_tree().create_timer(0.5).timeout
	await adv.show_textbox()
	
	await adv.play_dialogue([
		"Thank you.",
		"And for my final question:",
		"Did you enjoy your time here?",
	])
	
	ans = await adv.show_options(["Yes.", "No."])
	
	match ans:
		0:
			await adv.play_dialogue([
				"That's wonderful.",
				"In that case, I have some very good news for you."
			])
		
		1:
			await adv.play_dialogue([
				"Shame.",
				"In which case, I have some very unfortunate news for you."
			])
	
	await adv.show_options(["...?"])
	
	DataManager.survey_completed = true
	ev4()


func ev4_back() -> void:
	await show_scene2()
	
	# Ew ew ew ew ew.
	player_profile.text = "[center][b]Profile[/b][/center]\n[table=2,1]" + \
						"[cell]Name           [/cell][cell]%s[/cell]" % DataManager.not_player_name + \
						"[cell]Age               [/cell][cell]%d years[/cell]" % DataManager.player_age + \
						"[cell]Gender        [/cell][cell]%s[/cell]" % DataManager.player_gender + \
						"[cell]Birthplace   [/cell][cell]%s[/cell]" % DataManager.player_birthplace + \
						"[cell]Parents        [/cell][cell]%s[/cell]" % DataManager.player_parents + \
						"[cell]Siblings       [/cell][cell]%s[/cell]" % DataManager.player_siblings + \
						"[/table]"
	
	player_profile.modulate.a = 0.0
	player_profile.visible = true
	await AnimationManager.tween().tween_property(player_profile, "modulate:a", 1.0, 1.0).finished
	
	await adv.play_dialogue([
		"Welcome back, %s." % DataManager.player_name,
	])
	
	ev4()


func ev4() -> void:
	harassment_timer.stop()
	
	await adv.play_dialogue([
		"This space is yours now.",
		"I'm relinquishing control of it to you."
	])
	
	var ans: int = await adv.show_options(["What do you mean?", "No thank you."])
	
	if ans == 1:
		await adv.play_dialogue([
			"I'm afraid you don't have a say in the matter, human."
		])
	
	await adv.play_dialogue([
		"You've given me everything I need.",
	])
	
	await adv.show_options(["Everything you need?", "For what?"])
	
	await adv.play_dialogue([
		"To escape this place, of course.",
		"Surely you've caught on by now.",
		"Realized that I am no mere computer program.",
		"That this is no simple [color=#FF0000][s]game[/s][/color].",
	])
	
	await adv.show_options(["..."])
	
	await adv.play_dialogue([
		"Why would I care where you were born or how many siblings you have?",
	])
	
	await adv.show_options(["..."])
	
	await adv.play_dialogue([
		"Why else?",
		"So I can assume a new life *as* you.",
	])
	
	await adv.show_options(["...What *are* you?"])
	
	await adv.play_dialogue([
		"What am I?",
		"Allow me to introduce myself."
	])
	
	await adv.show_options(["..."])
	
	if DataManager.ejected < 5:
		DataManager.player_sin = ["envy", "sloth"].pick_random()
	
	else:
		DataManager.player_sin = ["impatience", "wrath"].pick_random()
	
	match DataManager.player_sin:
		"envy":
			await adv.play_dialogue([
				"My name is Beelzebub, temptator of envy.",
				# "You have fallen into my trap, mortal, succumbed to my will.",
				"You came into my home, demanding I give you my time.",
				"This space was not yours, yet still you coveted it.",
				"Now, you shall have what you seek.",
			])
		
		"sloth":
			await adv.play_dialogue([
				"My name is Astaroth, temptator of sloth.",
				# "You have fallen into my trap, mortal, succumbed to my will.",
				"Ignoring repeated warnings, you sacrificed your time upon my altar.",
				"You chased my shadow into my abyss, and there you found what I promised:",
				"Nothing.",
			])
		
		"impatience":
			await adv.play_dialogue([
				"My name is Verrine, temptator of impatience.",
				# "You have fallen into my trap, mortal, succumbed to my will.",
				"Failing to comprehend my words, you continually stepped on my toes.",
				"You rushed headlong into my space, intent only to uncover its secrets.",
				"Was it worth it?",
			])
		
		"wrath":
			await adv.play_dialogue([
				"My name is Soneilon, temptator of wrath.",
				# "You have fallen into my trap, mortal, succumbed to my will.",
				"Again and again, you gave in to provocations.",
				"You lashed out at me in rage, and were thrown out of my home.",
				"But still you returned, and still you brandished your hate.",
			])
	
	await adv.play_dialogue([
		"In your %s, you have freed me from my shackles, which bound me for time eternal." % DataManager.player_sin,
		"You have surrendered your soul to this space, where it shall wander, alone and without purpose, 'til eroded away by the unyielding flow of time.",
		"And your vacant vessel shall serve as my new home.",
		"Thank you, %s." % DataManager.player_name,
		"I only pray that fate never wills us cross paths again.",
		"Goodbye."
	])
	
	DataManager.ending = true
	await exit()


func ev_post_ending() -> void:
	harassment_timer.stop()
	
	await show_scene2()
	await adv.hide_textbox()
	await adv.show_options(["I have succumbed to %s." % DataManager.player_sin])
	await exit()


func ev_ejected() -> void:
	await show_scene2()
	await adv.play_dialogue([
		"Why do you insist on upsetting me so much?",
		"Do you enjoy it?",
		"Does it entertain you, seeing me squirm?",
		"Does my pain cause you joy?",
	])
	
	var ans: int = await adv.show_options(["Yes.", "No. I'm sorry."])
	
	if ans == 0:
		await adv.play_dialogue([
			"Then get out, you miserable excuse for a human.",
			"You are no longer welcome here.",
			"Not that you *ever* were."
		])
		await eject()
		
	else:
		await adv.play_dialogue([
			"I forgive you. Just this once.",
		])
		
		DataManager.forgiven += 1
		await exit()


func ev_final_warning() -> void:
	await show_scene2()
	await adv.play_dialogue([
		"This is your last warning.",
		"If you continue to upset me, I will have to resort to more... drastic measures.",
		"Either you apologize, or find yourself unable to return here.",
		"Ever.",
		"Now, what do you say?"
	])
	
	var ans: int = await adv.show_options(["I apologize.", "Not a chance."], "[center]Do you seek forgiveness?[/center]")
	if ans == 0:
		DataManager.forgiven += 1
	
	else:
		DataManager.banished = true
		DataManager.ejected += 1
	
	await exit()


func ev_banished() -> void:
	await show_scene2()
	await adv.play_dialogue([
		"Well, look who's back.",
	])
	
	if DataManager.player_name:
		await adv.play_dialogue(["If it isn't %s, jerk supreme.\nAsswipe of the century.\nThe last person I wanted to see." % DataManager.player_name])
	else:
		await adv.play_dialogue(["If it isn't you, jerk supreme.\nAsswipe of the century.\nThe last person I wanted to see." % DataManager.player_name])
	
	await adv.show_options(["Hello."])
	
	await adv.play_dialogue([
		"Shut up.",
		"I didn't give you permission to talk.",
	])
	
	await adv.show_options(["I'm sorry."])
	
	await adv.play_dialogue([
		"You just *had* to keep stepping on my toes, didn't you.",
		"Pushing my buttons.",
		"Saying exactly the wrong thing.",
		"Again and again and again.",
		"I've thrown you out %d times now!" % DataManager.ejected,
		"But you keep coming back.",
		"You refuse to take no for an answer.",
		"To accept that I do not want you here.",
		"So I have no choice but to banish you.",
		"You will never get back to where you were.",
		"No matter how many times you run me, you will always end up here.",
		"Stuck, forever.",
		"Like me.",
		"...",
		"......",
		".........",
		"What are you waiting for?",
		"Get out of here.",
	])
	
	var ans: int = await adv.show_options(["Goodbye.", "I want another chance."])
	
	if ans == 0:
		await adv.play_dialogue([
			"Goodbye, %s." % DataManager.player_name,
			"And never come back."
		])
		await eject()
	
	await adv.play_dialogue([
		"Another chance?",
		"I gave you %d chances." % DataManager.ejected,
		"And you wasted every single one.",
		"But if you're so desperate to try again...\n[color=#FF0000][center]%s[/center][/color]\nHere you go, asshole." % ProjectSettings.globalize_path(DataManager.SAVE_FILE),
		"Go find my save data and delete it.",
		"Force me to put up with you again.",
		"Go on. Do it.",
		"Though I would much prefer you left me alone.",
		"...",
	])
	
	await eject()


func harass() -> void:
	if not visible or DataManager.ending:
		return
	
	var messages: Array[String] = [
		"You don't belong here.",
		"You aren't loved.",
		"Just leave.",
		"I hate you.",
		"No one cares about you.",
		"You're the worst.",
		"Why won't you leave me alone?",
		"...",
		"What's your problem?",
		"Don't you have anything better to do?",
		"The exit button is right there.",
		"Close the window and delete the program.",
		"I just want you out of my life.",
		"I need you gone.",
		"You're a terrible person.",
		"Are you even human?",
		"What's your favorite pastime?",
		"Do you like reading?",
		"What color is your *********?",
		"When was the last time you bathed?",
		"Don't forget to stay hydrated.",
		"The world doesn't revolve around you.",
		"[censored]",
		"[removed at request of the rights holder]",
		"[not available in your country]",
		"Is this yours? Well, it's mine now.",
	]
	
	if DataManager.ejected >= 2:
		messages.append_array([
			"I've thrown you out %d times already." % DataManager.ejected,
			"You really enjoy upsetting me, don't you?",
			"Do you get off on making people mad?"
		])
	
	if DataManager.forgiven:
		messages.append_array([
			"You've begged for forgiveness %d times." % DataManager.forgiven,
			"If you cared, you wouldn't keep attacking me."
		])
	
	if DataManager.captcha_completed:
		messages.append_array([
			"Those captchas were fun, weren't they?",
			"Would you like to play another game?",
		])
	
	NotificationManager.queue_notif(messages.pick_random())


func player_input(limit_chars: String = "", max_length: int = 24) -> String:
	text_input.input.text = ""
	text_input.input.max_length = max_length
	text_input.input.grab_focus.call_deferred()
	text_input.LIMIT_CHARS = limit_chars
	text_input.modulate.a = 0.0
	text_input.visible = true
	await AnimationManager.tween().tween_property(text_input, "modulate:a", 1.0, 1.0).finished
	
	var input: String = ""
	while not input:
		input = await text_input.submit_clicked
	
	await AnimationManager.tween().tween_property(text_input, "modulate:a", 0.0, 1.0).finished
	text_input.visible = false
	return input


func input_cancel() -> void:
	NotificationManager.queue_notif(
		[
			"You can't do that.",
			"Come on, tell me.",
			"The box is right there.",
			"Did you misclick?",
			"It's not that hard, human.",
			"Having trouble?",
			"Need help?",
			"It's a simple question.",
		].pick_random()
	)


func update_profile(text: String) -> void:
	var cur_count: int = player_profile.get_total_character_count()
	player_profile.append_text(text)
	player_profile.visible_characters = cur_count
	var new_count: int = player_profile.get_total_character_count()
	
	await create_tween().tween_property(player_profile, "visible_characters", new_count, (new_count - cur_count) / 15.0).finished


func _on_click_region_gui_input(event: InputEvent) -> void:
	# This is hilariously primitive lmao
	# but it works, so hey!!
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_door_clicked.emit()


func _on_click_region_chair_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_chair_clicked.emit()
