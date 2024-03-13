extends Node

signal viewport_changed(viewport: Viewport)
signal scene_changed(scene: Node)

var viewport: Viewport
var cur_scene: Node


func set_viewport(new_viewport: Viewport, change: bool = false) -> void:
	viewport = new_viewport
	viewport_changed.emit(viewport)
	
	if change:
		await change_scene(cur_scene)


func change_scene_from_file(path: String, transition: bool = true) -> void:
	ResourceLoader.load_threaded_request(path)
	await remove_scene(transition)
	
	var scene = ResourceLoader.load_threaded_get(path).instantiate()
	await change_scene(scene, transition)


func remove_scene(transition: bool = true) -> void:
	if not viewport:
		return
	
	if cur_scene:
		if transition:
			await create_tween().tween_property(cur_scene, "modulate:a", 0, 1.0).finished
		
		for child in viewport.get_children():
			child.queue_free()
		
		cur_scene = null


func change_scene(new_scene: Node, transition: bool = true) -> void:
	if not viewport:
		# print("No viewport to change scene!")
		return
	
	if cur_scene:
		await remove_scene(transition)
	
	cur_scene = new_scene
	cur_scene.modulate.a = 0.0
	viewport.add_child(cur_scene)
	
	if transition:
		var tween: Tween = create_tween()
		tween.tween_interval(0.5)
		tween.tween_property(cur_scene, "modulate:a", 1.0, 1.0)
		tween.tween_callback(func():
			scene_changed.emit(cur_scene)
		)
	
	else:
		cur_scene.modulate.a = 1.0
		scene_changed.emit(cur_scene)
	
