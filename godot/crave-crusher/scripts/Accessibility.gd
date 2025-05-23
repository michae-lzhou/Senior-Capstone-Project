extends VBoxContainer

@export var sprite_on: Texture  # Assign in the Inspector
@export var sprite_off: Texture  # Assign in the Inspector

func _ready() -> void:
	# Recursively find and set up all TextureButtons
	_find_buttons(self)

func _find_buttons(node):
	# Loop through all children recursively
	for child in node.get_children():
		if child is TextureButton:
			child.pressed.connect(func(): _on_button_pressed(child))
			child.texture_normal = sprite_off  # Set default state
		else:
			# If the child is a container, keep searching inside it
			_find_buttons(child)

func _on_button_pressed(button: TextureButton):
	# Toggle texture
	button.texture_normal = sprite_on if button.texture_normal == sprite_off else sprite_off
