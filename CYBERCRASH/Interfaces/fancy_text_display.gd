@tool
class_name FancyTextDisplay
extends Control

enum FancyTextMode
{
	BY_CHARACTER,
	TOTAL_TIME,
}

const MODE_BY_CHARACTER = FancyTextMode.BY_CHARACTER
const MODE_TOTAL_TIME = FancyTextMode.TOTAL_TIME

@export_multiline var text: String
@export var style: LabelSettings
@export var keyboard_skippable := false
## Whether to use special codes. Only working in
## FancyTextMode.BY_CHARACTER. You cannot use blackslash
## notation to prevent special codes. This system barely
## works at all, here is a list of all special codes:
## '|' for a pause of ~0.1 seconds.
## '<' for a pause of ~0.5 seconds.
## '>' to stop the typer, use this at the end of a text.
@export var special_codes := false
@export var mode := FancyTextMode.BY_CHARACTER
@export var caret: String
## Whethe spaces are skipped while text is displaying, only
## works while in FancyTextMode.BY_CHARACTER
@export var skip_spaces := false
## The number of characters displayed that get displayed per
## second. (for FancyTextMode.BY_CHARACTER)
## The modifier of how fast text should display. (for
## FancyTextMode.TOTAL_TIME)
@export var speed := 1.0
## How long it takes, from instantiation, for the entirety of
## the text to display. Only works while in FancyTextMode.TOTAL_TIME
@export var total_time := 1.0

var internal_timer := 0.0
var visible_characters := 0.0
var visible_ratio := 0.0
var running := false
var pausetime := 0.0

func _ready() -> void:
	reload()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		$Text.text = text
		$Text.visible_ratio = 1.0
		$Text.label_settings = style
		return
	
	if not running:
		return
	
	if pausetime > 0.0:
		pausetime -= delta
		return
	
	if keyboard_skippable and Input.is_action_pressed("ui_accept"):
		delta *= 12.0
	
	internal_timer += delta * speed
	visible_characters += delta * speed
	visible_ratio = internal_timer / total_time
	visible_ratio = clampf(visible_ratio, 0.0, 1.0)
	
	if mode == MODE_BY_CHARACTER:
		$Text.visible_characters = visible_characters
		if caret: # Will break SO much stuff when used
			$Text.visible_ratio = 1.0
			$Text.text = text.substr(0, int(visible_characters) - 1)
			$Text.text += caret.substr(randi_range(0, len(caret)) - 1, 1)
		if text.substr(int(visible_characters) - 1, 1) == " ":
			if skip_spaces:
				visible_characters += 1.0
		if special_codes:
			# This is some horrible terrible (not even working) piece of
			# code that proves, without a doubt, that my parents made a
			# mistake creating me.
			match text.substr(int(visible_characters) - 1, 1):
				"|": # What the evilness?
					text = text.erase(int(visible_characters) - 1, 1)
					pausetime += 0.1
				"<":
					text = text.erase(int(visible_characters) - 1, 1)
					pausetime += 0.5
				">":
					text = text.erase(int(visible_characters) - 1, 1)
					if caret:
						$Text.text = $Text.text.substr(0, len($Text.text) - 1)
					stop()
	elif mode == MODE_TOTAL_TIME:
		$Text.visible_ratio = visible_ratio

func reload() -> void:
	$Text.text = text
	if special_codes:
		$Text.text = $Text.text.replace("|", "")
		$Text.text = $Text.text.replace("<", "")
		$Text.text = $Text.text.replace(">", "")
	$Text.label_settings = style
	$Text.visible_characters = 0

func start() -> void:
	running = true
func stop() -> void:
	running = false
func toggle() -> bool:
	running = not running
	return running
