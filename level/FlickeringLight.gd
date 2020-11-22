extends Light2D


"""
used for flickering light of a candle
"""


onready var noise = OpenSimplexNoise.new()
const MAX_VAL = 100000000
var value = 0.0


func _ready() -> void:
	randomize()
	value = randi() % MAX_VAL
	noise.period = 16
	
	
func _physics_process(_delta : float) -> void:
	value += 0.5
	if(value > MAX_VAL):
		value = 0.0
	var alpha = ((noise.get_noise_1d(value) + 1) / 4.0) + 0.5
	self.color = Color(color.r, color.g, color.b, alpha)

