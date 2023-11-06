extends CanvasLayer

signal back

func _ready():
	pass


func _process(delta):
	pass


func _on_btn_back_pressed():
	if back.get_connections().size() > 0:
		back.emit()
	else:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
