extends Control

const uuid_util = preload('res://scripts/uuid.gd')

@onready var section_password = $section_password
@onready var set_pw = $section_password/PanelContainer/vbox_set_pw
@onready var set_pw_password = $section_password/PanelContainer/vbox_set_pw/edit_password
@onready var set_pw_repeat = $section_password/PanelContainer/vbox_set_pw/edit_password_repeat
@onready var unlock = $section_password/PanelContainer/vbox_unlock
@onready var unlock_password = $section_password/PanelContainer/vbox_unlock/edit_password

@onready var section_list = $section_list
@onready var list_journal = $section_list/ScrollContainer/list_journal
@onready var add_entry = $section_list/btn_add_entry
@onready var section_entry = $section_entry
@onready var journal_entry = $section_entry/journal_entry

const management_file_path = "user://journal_management.json"
var management_data = {}

const journal_file_ending = ".journal"
const key_entries = "entries"
const key_uuid = "uuid"
const key_last_edit = "last_edit"

var current_journal_entry = null
var entry_changed = false

func _ready():
	section_password.hide()
	set_pw.hide()
	unlock.hide()
	section_list.hide()
	section_entry.hide()
	
	if Global.password == null:
		if management_file_exists():
			unlock.show()
		else:
			set_pw.show()
		section_password.show()
	else:
		load_management_file()
		show_list()


func _process(delta):
	pass


func management_file_exists():
	return FileAccess.file_exists(management_file_path)


func load_management_file():
	if FileAccess.file_exists(management_file_path):
		var management_file = FileAccess.open_encrypted_with_pass(management_file_path, 
			FileAccess.READ, Global.password)
		if management_file == null:
			return false
		management_data = JSON.parse_string(management_file.get_as_text())
	else:
		management_data = {}
		return false
	return true


func save_management_file():
	var management_file = FileAccess.open_encrypted_with_pass(management_file_path, 
		FileAccess.WRITE, Global.password)
	var json = JSON.stringify(management_data)
	management_file.store_string(json)
	management_file.close()


func load_entry():
	var file = FileAccess.open_encrypted_with_pass(
		"user://" + current_journal_entry + journal_file_ending, 
		FileAccess.READ, Global.password)
	var text = file.get_as_text()
	file.close()
	
	journal_entry.clear()
	journal_entry.clear_undo_history()
	journal_entry.set_text(text)
	entry_changed = false


func save_entry():
	if not entry_changed:
		return
	entry_changed = false
	
	var entries = management_data.get(key_entries, [])
	if current_journal_entry == null:
		current_journal_entry = uuid_util.v4()
		
		entries.append({
			key_uuid: current_journal_entry,
			key_last_edit: Time.get_unix_time_from_system()
		})
	else:
		for entry in entries:
			if entry[key_uuid] == current_journal_entry:
				entry[key_last_edit] = Time.get_unix_time_from_system()
				break
				
	var file = FileAccess.open_encrypted_with_pass(
		"user://" + current_journal_entry + journal_file_ending, 
		FileAccess.WRITE, Global.password)
	file.store_string(journal_entry.get_text())
	file.close()
	
	entries.sort_custom(func(a, b): 
		return a[key_last_edit] > b[key_last_edit])
	management_data[key_entries] = entries
	save_management_file() 


func delete_entry():
	if current_journal_entry == null:
		return # Nothing to delete
	
	var entries = management_data.get(key_entries, [])
	var index = 0
	var found = false
	for entry in entries:
		if entry[key_uuid] == current_journal_entry:
			found = true
			break
		index += 1
	
	if found:
		if DirAccess.remove_absolute(
				"user://" + entries[index][key_uuid] + journal_file_ending) == OK:
			entries.remove_at(index)
			management_data[key_entries] = entries
			save_management_file()
			entry_changed = false

func _on_btn_set_pressed():
	var pw = set_pw_password.get_text()
	var pw_repeat = set_pw_repeat.get_text()
	if pw.length() > 0 && pw == pw_repeat:
		Global.password = pw
		save_management_file()
		
		section_password.hide()
		show_list()
	else:
		# TODO: Feedback
		pass


func _on_btn_unlock_pressed():
	Global.password = unlock_password.get_text()
	var success = load_management_file()
	if success:
		section_password.hide()
		show_list()
	else:
		# TODO: Feedback
		Global.password = null


func _on_btn_add_entry_pressed():
	section_list.hide()
	journal_entry.clear()
	journal_entry.clear_undo_history()
	section_entry.show()


func _exit_tree():
	save_entry()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST || what == NOTIFICATION_WM_GO_BACK_REQUEST:
		save_entry()


func _on_list_journal_item_clicked(index, at_position, mouse_button_index):
	section_list.hide()
	current_journal_entry = management_data.get(key_entries, [])[index][key_uuid]
	load_entry()
	section_entry.show()


func show_list():
	list_journal.clear()
	var entries = management_data.get(key_entries, [])
	var index = 0
	for entry in entries:
		# TODO: Improve naming
		var timezone_offset = Time.get_time_zone_from_system()["bias"]
		var dt_dict = Time.get_datetime_dict_from_unix_time(int(entry[key_last_edit]))
		
		list_journal.add_item(
			str(dt_dict["year"]) + "-" + 
			str(dt_dict["month"]) + "-" + 
			str(dt_dict["day"]) + " " + 
			str(dt_dict["hour"]) + ":" + 
			str(dt_dict["minute"]) +
			Time.get_offset_string_from_offset_minutes(timezone_offset))
		index += 1
	section_list.show()


func _on_journal_entry_text_changed():
	entry_changed = true


func _on_btn_delete_pressed():
	delete_entry()
	section_entry.hide()
	current_journal_entry = null
	show_list()


func _on_header_back():
	if section_entry.is_visible_in_tree():
		save_entry()
		section_entry.hide()
		current_journal_entry = null
		show_list()
	else:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
