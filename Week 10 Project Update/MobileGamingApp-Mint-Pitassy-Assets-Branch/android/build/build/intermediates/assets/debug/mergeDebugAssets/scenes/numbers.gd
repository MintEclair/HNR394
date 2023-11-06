extends Control

var plugin_name_android = "GodotUniversalIntent"

var dial_plugin_android

func _ready():
	if Engine.has_singleton(plugin_name_android):
		dial_plugin_android = Engine.get_singleton(plugin_name_android)

func _process(delta):
	pass

func dial(number):
	if dial_plugin_android:
		var uri = "tel:" + number
		dial_plugin_android.intent("android.intent.action.DIAL")
		dial_plugin_android.setData(uri)
		dial_plugin_android.startActivityForResult()

func _on_label_2_gui_input(event):
	if event is InputEventMouseButton || event is InputEventScreenTouch:
		dial("00000000")
