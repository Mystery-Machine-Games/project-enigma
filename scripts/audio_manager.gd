class_name AudioManager 
extends Node

# Sound effects
static var _sound_dictionary: Dictionary[String, AudioStream] = {
	"hover": preload("res://assets/audio/hover.ogg"),
	"select": preload("res://assets/audio/select.ogg"),
	"click": preload("res://assets/audio/click.ogg"),
	"cut": preload("res://assets/audio/cut.ogg"),
	"error": preload("res://assets/audio/error.ogg"),
	"success": preload("res://assets/audio/success.ogg")
}

static var _playback: AudioStreamPlaybackPolyphonic


func _enter_tree() -> void:
	# Create an audio player
	var audio_stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(audio_stream_player)

	# Create a polyphonic stream
	var audio_stream_polyphonic: AudioStreamPolyphonic = AudioStreamPolyphonic.new()
	audio_stream_polyphonic.polyphony = 32
	audio_stream_player.stream = audio_stream_polyphonic
	audio_stream_player.play()

	# Get the polyphonic _playback stream to play sounds
	_playback = audio_stream_player.get_stream_playback()


# Example usage: AudioManager.play_sound("hover")
static func play_sound(sound_key: String) -> void:
	print("sound playing")
	_playback.play_stream(_sound_dictionary[sound_key], 0, -10, randf_range(0.8, 1.2))
