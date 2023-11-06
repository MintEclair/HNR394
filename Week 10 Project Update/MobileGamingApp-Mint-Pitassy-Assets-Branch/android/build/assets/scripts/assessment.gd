extends Node2D

@onready var lbl_question = $question_ui/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/lbl_question
@onready var slider = $question_ui/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/slider

func _ready():
	$question_ui.hide()


func _process(delta):
	pass


func _on_btn_temp_pressed():
	ask_question("Your question here")


func ask_question(question: String):
	lbl_question.parse_bbcode("[center]" + question)
	$question_ui.show()


func _on_btn_ok_pressed():
	print(slider.value)
	# TODO: Handle answer
	$question_ui.hide()
	# TODO: Continue application flow
