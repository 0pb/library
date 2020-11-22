extends Camera2D


onready var top_left = $Limits/TopLeft
onready var bottom_right = $Limits/BottomRight
onready var timer = $Timer
onready var player = get_parent().get_node("Player")


export(OpenSimplexNoise) var noise
export(float) var max_angle = 200
export(float) var max_offset = 300
export(float, 0, 1) var decay = 0.06


var trauma : float = 0
var time_scale = 200
var time = 0


# set the boundaries limit of the camera in the level, the limit has to be placed
# manually in the level with the topleft and bottomright Position2d node
func _ready() -> void:
	limit_top = top_left.position.y
	limit_left = top_left.position.x
	limit_right = bottom_right.position.x
	limit_bottom = bottom_right.position.y


# use a trauma value (trauma€[0.0,1.0]), the higher the trauma the more shake
# for example an explosion simply add + or - 0.2 or 0.5 etc. to the trauma value
# use perlin noise to generate a shake
func _physics_process(delta : float) -> void:
	if trauma:
		var shake = pow(trauma, 2)
		time += delta
		
		# angle doesn't work
		# var angle = max_angle * shake * noise.get_noise_3d(time * time_scale, 0, 0)
		var offset_x = max_offset * shake * noise.get_noise_3d(0, time * time_scale, 0)
		var offset_y = max_offset * shake * noise.get_noise_3d(0, 0, time * time_scale) #-1.0, 1.0
		
		#rotation_degrees = rotation_degrees * angle
		set_offset(Vector2(0.0, 0.0) + Vector2(offset_x, offset_y))


# every 0.1s the trauma is decreased linearly by the decay value, reducing the shake and stopping it
# eventually
func _on_Timer_timeout() -> void:
	trauma = trauma - decay
	trauma = clamp(trauma, 0.0, 1.0)
