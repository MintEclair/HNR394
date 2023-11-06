extends Node

@onready var music_player = $music_player
@onready var effect_player = $effect_player

var audio_cache = {}

var loop_music = false

func _ready():
	pass

func _process(delta):
	pass

func _cacheAudio(file):
	if FileAccess.file_exists(file):
		var stream = load(file)
		audio_cache[file] = stream
		return stream
	return null

func _on_music_player_finished():
	if loop_music:
		music_player.stream_paused = false
		music_player.play()

func _play(player, file):
	var stream = null
	if audio_cache.has(file):
		stream = audio_cache[file]
	else:
		stream = _cacheAudio(file)
	
	if stream == null:
		return
	
	player.stop()
	player.stream = stream
	player.play()

func playMusic(file, loop=false):
	self.loop_music = loop
	_play(music_player, file)

func stopMusic():
	if music_player != null:
		music_player.stop()
	
func playEffect(file):
	_play(effect_player, file)

func stopEffect():
	if effect_player != null:
		effect_player.stop()
