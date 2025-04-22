extends ParallaxBackground

@export var scroll_speed: float = 150.0

@onready var sprite := $ParallaxLayer/Sprite2D

func _ready():
	if sprite.texture:
		var texture_size = sprite.texture.get_size()

		# Enable sprite region and repeat
		sprite.region_enabled = true
		sprite.region_rect = Rect2(Vector2.ZERO, texture_size * 2)
		sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED

		# This is CRITICAL: motion_mirroring must match exactly the width of one full tile
		$ParallaxLayer.motion_mirroring = Vector2(texture_size.x, 0)

func _process(delta):
	$ParallaxLayer.motion_offset.x += scroll_speed * delta
