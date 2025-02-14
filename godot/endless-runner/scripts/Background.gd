extends ParallaxBackground

@export var scroll_speed: float = 300.0

@onready var sprite = $ParallaxLayer/Sprite2D

func _ready():
	if sprite.texture:
		var viewport_size = get_viewport().get_visible_rect().size
		# Make it even bigger (4x viewport) for smoother transition
		sprite.region_enabled = true
		sprite.region_rect = Rect2(0, 0, sprite.texture.get_size().x, viewport_size.y * 4)
		sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		$ParallaxLayer.motion_mirroring = Vector2(0, viewport_size.y * 4)

func _process(delta):
	$ParallaxLayer.motion_offset += Vector2(0, scroll_speed * delta)
