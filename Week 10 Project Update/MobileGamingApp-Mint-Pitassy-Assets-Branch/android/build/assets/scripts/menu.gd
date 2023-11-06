extends Control


func _ready():
	pass


func _process(delta):
	pass


func _on_btn_tree_pressed():
	get_tree().change_scene_to_file("res://scenes/assessment.tscn")


func _on_btn_resources_pressed():
	get_tree().change_scene_to_file("res://scenes/resources.tscn")


func _on_btn_activities_pressed():
	get_tree().change_scene_to_file("res://scenes/activities.tscn")


func _on_btn_journal_pressed():
	get_tree().change_scene_to_file("res://scenes/journal.tscn")


func _on_btn_survey_pressed():
	get_tree().change_scene_to_file("res://scenes/survey.tscn")


func _on_btn_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/settings.tscn")


func _on_btn_numbers_pressed():
	get_tree().change_scene_to_file("res://scenes/numbers.tscn")
