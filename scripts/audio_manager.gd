class_name AudioManager extends Node

static var _anim_player: AnimationPlayer
static var _menu_music: AudioStreamPlayer
static var _game_music: AudioStreamPlayer

# Sound effects
static var _click_sound: Resource = preload('res://assets/sfx/click.ogg')
static var _dong_sound: Resource = preload('res://assets/sfx/dong.ogg')
static var _brush_sound: Resource = preload('res://assets/sfx/brush.wav')
static var _tick_sound: Resource = preload('res://assets/sfx/tick.ogg')
static var _beep_sound: Resource = preload('res://assets/sfx/beep.ogg')

static var _playback: AudioStreamPlaybackPolyphonic


func _enter_tree() -> void:
	# Create an audio player
	var player = AudioStreamPlayer.new()
	add_child(player)

	# Create a polyphonic stream so we can play sounds directly from it
	var stream = AudioStreamPolyphonic.new()
	stream.polyphony = 32
	player.stream = stream
	player.play()

	# Get the polyphonic _playback stream to play sounds
	_playback = player.get_stream_playback()

	get_tree().node_added.connect(_on_node_added)


func _ready() -> void:
	_anim_player = $AnimationPlayer
	_menu_music = $MenuMusic
	_game_music = $GameMusic


func _on_node_added(node: Node) -> void:
	if node is Button:
		# If the added node is a button we connect to its mouse_entered and pressed signals
		# and play a sound
		node.mouse_entered.connect(_play_hover)
		node.pressed.connect(_play_pressed)


func _play_hover() -> void:
	#_playback.play_stream(preload('res://beep_short.wav'), 0, 0, randf_range(0.9, 1.1))
	pass


func _play_pressed() -> void:
	_playback.play_stream(_click_sound, 0, 0, randf_range(0.9, 1.1))


static func play_dong() -> void:
	_playback.play_stream(_dong_sound, 0, 0, randf_range(0.9, 1.1))


static func play_brush() -> void:
	_playback.play_stream(_brush_sound, 0, 5.0, randf_range(0.9, 1.1))


static func play_tick() -> void:
	_playback.play_stream(_tick_sound, 0, -5.0, randf_range(0.8, 0.85))


static func play_beep() -> void:
	_playback.play_stream(_beep_sound, 0, 0, randf_range(0.9, 1.1))
