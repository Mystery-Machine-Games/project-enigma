class_name OptionsMenu
extends PanelContainer

signal options_close_requested

const ConfigPath: Dictionary[String, String] = {
	"DEFAULT": "test"
}

var config: ConfigFile = null

func _ready() -> void:
	pass

func _load_config() -> ConfigFile:
	return null

func _on_return_pressed() -> void:
	options_close_requested.emit()
