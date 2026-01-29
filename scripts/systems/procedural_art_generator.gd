class_name ProceduralArtGenerator
extends Node

## ProceduralArtGenerator
##
## Generates all visual content at runtime using deterministic seeded random number generation.
## This class is responsible for creating tilesets, sprites, and UI elements from geometric
## primitives (rectangles, circles, triangles) using limited color palettes.
##
## All generation methods use seeded RNG to ensure deterministic output - the same seed
## will always produce the same visual result.

# Color palettes for different biomes
# Farm Hub uses bright, warm colors for a cozy atmosphere
const FARM_PALETTE: Array[Color] = [
	Color("#8BC34A"),  # Light green
	Color("#FFC107"),  # Amber/yellow
	Color("#795548"),  # Brown
	Color("#4CAF50")   # Green
]

# Combat Zone uses dark, aggressive colors for a tense atmosphere
const COMBAT_PALETTE: Array[Color] = [
	Color("#212121"),  # Dark gray/black
	Color("#F44336"),  # Red
	Color("#9C27B0"),  # Purple
	Color("#607D8B")   # Blue-gray
]

## Generate a tileset texture using the specified seed and color palette
## @param seed_value: The seed for deterministic random generation
## @param palette: The color palette to use for generation
## @return: A Texture2D containing the generated tileset
func generate_tileset(seed_value: int, palette: Array[Color]) -> Texture2D:
	# Seed the random number generator for deterministic output
	seed(seed_value)
	
	# Tileset configuration
	const TILE_SIZE = 64  # Size of each tile in pixels
	const TILES_PER_ROW = 4  # Number of tiles per row
	const TILES_PER_COL = 4  # Number of tiles per column
	const TILESET_WIDTH = TILE_SIZE * TILES_PER_ROW
	const TILESET_HEIGHT = TILE_SIZE * TILES_PER_COL
	
	# Create the base image for the tileset
	var image = Image.create(TILESET_WIDTH, TILESET_HEIGHT, false, Image.FORMAT_RGBA8)
	
	# Generate each tile in the tileset
	for row in range(TILES_PER_COL):
		for col in range(TILES_PER_ROW):
			var tile_x = col * TILE_SIZE
			var tile_y = row * TILE_SIZE
			
			# Generate a unique tile based on position
			_generate_tile(image, tile_x, tile_y, TILE_SIZE, palette)
	
	# Convert the image to a texture
	var texture = ImageTexture.create_from_image(image)
	return texture

## Generate a crop sprite for a specific crop type and growth stage
## @param crop_type: The type of crop (e.g., "health", "ammo", "weapon_mod")
## @param growth_stage: The growth stage (0-3, where 3 is fully grown)
## @param seed_value: The seed for deterministic random generation
## @return: A Texture2D containing the generated crop sprite
func generate_crop_sprite(crop_type: String, growth_stage: int, seed_value: int) -> Texture2D:
	# Clamp growth stage to valid range
	growth_stage = clampi(growth_stage, 0, 3)
	
	# Seed the RNG for deterministic generation
	var rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	# Determine shape type and base color from crop type
	var shape_type: String = "round"
	var base_color: Color = FARM_PALETTE[0]
	
	match crop_type:
		"health", "health_berry":
			shape_type = "round"
			base_color = Color("#FF6B6B")  # Red/pink for health
		"ammo", "ammo_grain":
			shape_type = "tall"
			base_color = Color("#FFD93D")  # Yellow/gold for ammo
		"weapon_mod", "weapon_flower":
			shape_type = "leafy"
			base_color = Color("#A8E6CF")  # Light green for weapon mods
		_:
			# Default to round green shape for unknown types
			shape_type = "round"
			base_color = FARM_PALETTE[0]
	
	# Create image for the sprite (32x32 pixels)
	var size = 32
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))  # Transparent background
	
	# Calculate growth scale (0.25 to 1.0 based on growth stage)
	var growth_scale = 0.25 + (growth_stage * 0.25)
	
	# Generate shape based on type
	match shape_type:
		"round":
			_draw_round_crop(image, size, base_color, growth_scale, rng)
		"tall":
			_draw_tall_crop(image, size, base_color, growth_scale, rng)
		"leafy":
			_draw_leafy_crop(image, size, base_color, growth_scale, rng)
	
	# Convert image to texture
	var texture = ImageTexture.create_from_image(image)
	return texture

## Generate an enemy sprite for a specific enemy type
## @param enemy_type: The type of enemy (e.g., "melee_charger", "ranged_shooter", "tank")
## @param seed_value: The seed for deterministic random generation
## @return: A Texture2D containing the generated enemy sprite
func generate_enemy_sprite(enemy_type: String, seed_value: int) -> Texture2D:
	# Set seed for deterministic generation
	seed(seed_value)
	
	# Define sprite size
	var sprite_size = 64
	var image = Image.create(sprite_size, sprite_size, false, Image.FORMAT_RGBA8)
	
	# Fill with transparent background
	image.fill(Color(0, 0, 0, 0))
	
	# Generate enemy based on type
	match enemy_type:
		"melee_charger":
			_draw_melee_charger(image, sprite_size)
		"ranged_shooter":
			_draw_ranged_shooter(image, sprite_size)
		"tank":
			_draw_tank_enemy(image, sprite_size)
		_:
			push_warning("Unknown enemy type: " + enemy_type)
			# Draw a default placeholder
			_draw_default_enemy(image, sprite_size)
	
	# Convert image to texture
	var texture = ImageTexture.create_from_image(image)
	return texture

## Draw a melee charger enemy (fast, aggressive, angular)
func _draw_melee_charger(image: Image, size: int) -> void:
	var center = size / 2
	var palette = COMBAT_PALETTE
	
	# Melee charger: angular, aggressive shape with forward-pointing elements
	# Main body - angular diamond shape
	var body_color = palette[1]  # Red - aggressive
	_draw_filled_diamond(image, center, center, size * 0.4, body_color)
	
	# Forward-pointing spikes (indicating charge direction)
	var spike_color = palette[0]  # Dark gray
	_draw_triangle(image, center, center - size * 0.3, center - size * 0.15, center - size * 0.45, center + size * 0.15, center - size * 0.45, spike_color)
	
	# Side spikes for aggressive look
	_draw_triangle(image, center - size * 0.25, center, center - size * 0.4, center - size * 0.1, center - size * 0.4, center + size * 0.1, spike_color)
	_draw_triangle(image, center + size * 0.25, center, center + size * 0.4, center - size * 0.1, center + size * 0.4, center + size * 0.1, spike_color)
	
	# Eyes - small and menacing
	var eye_color = palette[2]  # Purple accent
	_draw_filled_circle(image, center - size * 0.1, center - size * 0.05, size * 0.05, eye_color)
	_draw_filled_circle(image, center + size * 0.1, center - size * 0.05, size * 0.05, eye_color)

## Draw a ranged shooter enemy (medium, with weapon elements)
func _draw_ranged_shooter(image: Image, size: int) -> void:
	var center = size / 2
	var palette = COMBAT_PALETTE
	
	# Ranged shooter: more rounded body with weapon-like protrusions
	# Main body - rounded rectangle
	var body_color = palette[3]  # Blue-gray - tactical
	_draw_filled_rect(image, center - size * 0.25, center - size * 0.25, size * 0.5, size * 0.5, body_color)
	
	# Weapon barrel - horizontal rectangle
	var weapon_color = palette[0]  # Dark gray
	_draw_filled_rect(image, center + size * 0.15, center - size * 0.05, size * 0.25, size * 0.1, weapon_color)
	
	# Weapon tip - small rectangle at end
	var tip_color = palette[1]  # Red accent
	_draw_filled_rect(image, center + size * 0.38, center - size * 0.08, size * 0.05, size * 0.16, tip_color)
	
	# Head/sensor area - circle on top
	var head_color = palette[2]  # Purple
	_draw_filled_circle(image, center, center - size * 0.15, size * 0.15, head_color)
	
	# Targeting eye - glowing center
	var eye_color = palette[1]  # Red
	_draw_filled_circle(image, center, center - size * 0.15, size * 0.06, eye_color)

## Draw a tank enemy (large, heavily armored, imposing)
func _draw_tank_enemy(image: Image, size: int) -> void:
	var center = size / 2
	var palette = COMBAT_PALETTE
	
	# Tank: large, blocky, heavily armored appearance
	# Main body - large rectangle
	var body_color = palette[0]  # Dark gray - heavy armor
	_draw_filled_rect(image, center - size * 0.35, center - size * 0.3, size * 0.7, size * 0.6, body_color)
	
	# Armor plates - layered rectangles
	var armor_color = palette[3]  # Blue-gray
	_draw_filled_rect(image, center - size * 0.3, center - size * 0.25, size * 0.6, size * 0.15, armor_color)
	_draw_filled_rect(image, center - size * 0.3, center + size * 0.1, size * 0.6, size * 0.15, armor_color)
	
	# Central core - glowing weak point
	var core_color = palette[1]  # Red
	_draw_filled_circle(image, center, center, size * 0.12, core_color)
	
	# Outer core ring
	var ring_color = palette[2]  # Purple
	_draw_circle_outline(image, center, center, size * 0.15, ring_color, 2)
	
	# Heavy shoulder plates
	_draw_filled_rect(image, center - size * 0.4, center - size * 0.2, size * 0.1, size * 0.4, armor_color)
	_draw_filled_rect(image, center + size * 0.3, center - size * 0.2, size * 0.1, size * 0.4, armor_color)

## Draw a default enemy placeholder
func _draw_default_enemy(image: Image, size: int) -> void:
	var center = size / 2
	var palette = COMBAT_PALETTE
	
	# Simple circle with cross pattern
	_draw_filled_circle(image, center, center, size * 0.3, palette[0])
	_draw_filled_rect(image, center - size * 0.05, center - size * 0.25, size * 0.1, size * 0.5, palette[1])
	_draw_filled_rect(image, center - size * 0.25, center - size * 0.05, size * 0.5, size * 0.1, palette[1])

## Helper: Draw a filled rectangle
func _draw_filled_rect(image: Image, x: float, y: float, width: float, height: float, color: Color) -> void:
	var x_start = int(max(0, x))
	var y_start = int(max(0, y))
	var x_end = int(min(image.get_width(), x + width))
	var y_end = int(min(image.get_height(), y + height))
	
	for py in range(y_start, y_end):
		for px in range(x_start, x_end):
			image.set_pixel(px, py, color)

## Helper: Draw a circle outline
func _draw_circle_outline(image: Image, cx: float, cy: float, radius: float, color: Color, thickness: int) -> void:
	var x_start = int(max(0, cx - radius - thickness))
	var y_start = int(max(0, cy - radius - thickness))
	var x_end = int(min(image.get_width(), cx + radius + thickness + 1))
	var y_end = int(min(image.get_height(), cy + radius + thickness + 1))
	
	for py in range(y_start, y_end):
		for px in range(x_start, x_end):
			var dx = px - cx
			var dy = py - cy
			var dist_sq = dx * dx + dy * dy
			var outer_radius_sq = (radius + thickness) * (radius + thickness)
			var inner_radius_sq = radius * radius
			if dist_sq <= outer_radius_sq and dist_sq >= inner_radius_sq:
				image.set_pixel(px, py, color)

## Helper: Draw a filled diamond shape
func _draw_filled_diamond(image: Image, cx: float, cy: float, radius: float, color: Color) -> void:
	var x_start = int(max(0, cx - radius))
	var y_start = int(max(0, cy - radius))
	var x_end = int(min(image.get_width(), cx + radius + 1))
	var y_end = int(min(image.get_height(), cy + radius + 1))
	
	for py in range(y_start, y_end):
		for px in range(x_start, x_end):
			var dx = abs(px - cx)
			var dy = abs(py - cy)
			if dx + dy <= radius:
				image.set_pixel(px, py, color)

## Helper: Draw a filled triangle
func _draw_triangle(image: Image, x1: float, y1: float, x2: float, y2: float, x3: float, y3: float, color: Color) -> void:
	# Simple triangle fill using barycentric coordinates
	var min_x = int(max(0, min(x1, min(x2, x3))))
	var max_x = int(min(image.get_width(), max(x1, max(x2, x3)) + 1))
	var min_y = int(max(0, min(y1, min(y2, y3))))
	var max_y = int(min(image.get_height(), max(y1, max(y2, y3)) + 1))
	
	for py in range(min_y, max_y):
		for px in range(min_x, max_x):
			if _point_in_triangle(px, py, x1, y1, x2, y2, x3, y3):
				image.set_pixel(px, py, color)

## Helper: Check if point is inside triangle using barycentric coordinates
func _point_in_triangle(px: float, py: float, x1: float, y1: float, x2: float, y2: float, x3: float, y3: float) -> bool:
	var denominator = ((y2 - y3) * (x1 - x3) + (x3 - x2) * (y1 - y3))
	if abs(denominator) < 0.0001:
		return false
	
	var a = ((y2 - y3) * (px - x3) + (x3 - x2) * (py - y3)) / denominator
	var b = ((y3 - y1) * (px - x3) + (x1 - x3) * (py - y3)) / denominator
	var c = 1.0 - a - b
	
	return a >= 0 and b >= 0 and c >= 0

## Generate a weapon sprite for a specific weapon type
## @param weapon_type: The type of weapon (e.g., "pistol", "shotgun", "plant_weapon")
## @param seed_value: The seed for deterministic random generation
## @return: A Texture2D containing the generated weapon sprite
func generate_weapon_sprite(weapon_type: String, seed_value: int) -> Texture2D:
	seed(seed_value)
	
	# Weapon sprite dimensions
	var width: int = 64
	var height: int = 64
	
	# Create image
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))  # Transparent background
	
	# Generate weapon based on type
	match weapon_type.to_lower():
		"pistol":
			_draw_pistol(image, seed_value)
		"shotgun":
			_draw_shotgun(image, seed_value)
		"plant_weapon":
			_draw_plant_weapon(image, seed_value)
		_:
			push_warning("Unknown weapon type: %s" % weapon_type)
			return null
	
	# Convert to texture
	var texture := ImageTexture.create_from_image(image)
	return texture

## Draw a pistol weapon sprite
## @param image: The image to draw on
## @param seed_value: The seed for deterministic random generation
func _draw_pistol(image: Image, seed_value: int) -> void:
	seed(seed_value)
	
	# Pistol uses combat palette for aggressive look
	var primary_color := COMBAT_PALETTE[randi() % COMBAT_PALETTE.size()]
	var secondary_color := COMBAT_PALETTE[randi() % COMBAT_PALETTE.size()]
	
	# Draw pistol barrel (horizontal rectangle)
	_draw_rect(image, 20, 28, 30, 8, primary_color)
	
	# Draw pistol grip (vertical rectangle)
	_draw_rect(image, 15, 32, 10, 20, secondary_color)
	
	# Draw trigger guard (small rectangle)
	_draw_rect(image, 22, 38, 6, 8, primary_color)
	
	# Draw sight (small rectangle at front)
	_draw_rect(image, 48, 24, 3, 8, secondary_color)

## Draw a shotgun weapon sprite
## @param image: The image to draw on
## @param seed_value: The seed for deterministic random generation
func _draw_shotgun(image: Image, seed_value: int) -> void:
	seed(seed_value)
	
	# Shotgun uses combat palette
	var primary_color := COMBAT_PALETTE[randi() % COMBAT_PALETTE.size()]
	var secondary_color := COMBAT_PALETTE[randi() % COMBAT_PALETTE.size()]
	var accent_color := COMBAT_PALETTE[randi() % COMBAT_PALETTE.size()]
	
	# Draw long barrel (thicker and longer than pistol)
	_draw_rect(image, 18, 26, 38, 12, primary_color)
	
	# Draw pump action (rectangle under barrel)
	_draw_rect(image, 28, 32, 15, 6, secondary_color)
	
	# Draw stock (angled rectangle at back)
	_draw_rect(image, 8, 30, 12, 16, secondary_color)
	
	# Draw barrel end (darker rectangle)
	_draw_rect(image, 54, 28, 4, 8, accent_color)
	
	# Draw sight
	_draw_rect(image, 50, 22, 3, 8, accent_color)

## Draw a plant weapon sprite
## @param image: The image to draw on
## @param seed_value: The seed for deterministic random generation
func _draw_plant_weapon(image: Image, seed_value: int) -> void:
	seed(seed_value)
	
	# Plant weapon uses farm palette for organic look
	var primary_color := FARM_PALETTE[randi() % FARM_PALETTE.size()]
	var secondary_color := FARM_PALETTE[randi() % FARM_PALETTE.size()]
	var accent_color := FARM_PALETTE[randi() % FARM_PALETTE.size()]
	
	# Draw stem/handle (vertical organic shape)
	_draw_rect(image, 28, 35, 8, 25, secondary_color)
	
	# Draw bulb/pod at top (larger organic shape)
	_draw_circle(image, 32, 28, 12, primary_color)
	
	# Draw leaves/petals (small circles around bulb)
	_draw_circle(image, 22, 26, 6, accent_color)
	_draw_circle(image, 42, 26, 6, accent_color)
	_draw_circle(image, 32, 18, 6, accent_color)
	
	# Draw thorns/spikes (small triangular shapes)
	_draw_rect(image, 24, 40, 3, 6, accent_color)
	_draw_rect(image, 37, 40, 3, 6, accent_color)

## Draw a filled rectangle on an image
## @param image: The image to draw on
## @param x: X position of top-left corner
## @param y: Y position of top-left corner
## @param w: Width of rectangle
## @param h: Height of rectangle
## @param color: Color to fill with
func _draw_rect(image: Image, x: int, y: int, w: int, h: int, color: Color) -> void:
	for py in range(y, min(y + h, image.get_height())):
		for px in range(x, min(x + w, image.get_width())):
			if px >= 0 and py >= 0:
				image.set_pixel(px, py, color)

## Draw a filled circle on an image
## @param image: The image to draw on
## @param cx: X position of center
## @param cy: Y position of center
## @param radius: Radius of circle
## @param color: Color to fill with
func _draw_circle(image: Image, cx: int, cy: int, radius: int, color: Color) -> void:
	var radius_sq := radius * radius
	for py in range(cy - radius, cy + radius + 1):
		for px in range(cx - radius, cx + radius + 1):
			var dx := px - cx
			var dy := py - cy
			if dx * dx + dy * dy <= radius_sq:
				if px >= 0 and py >= 0 and px < image.get_width() and py < image.get_height():
					image.set_pixel(px, py, color)

## Generate a UI element texture
## @param element_type: The type of UI element (e.g., "button", "border", "icon", "health_bar", "ammo_icon", "buff_icon")
## @param seed_value: The seed for deterministic random generation
## @return: A Texture2D containing the generated UI element
func generate_ui_element(element_type: String, seed_value: int) -> Texture2D:
	seed(seed_value)
	
	var image: Image
	var size := Vector2i(64, 64)  # Default size for UI elements
	
	match element_type:
		"button":
			image = _generate_button(size, seed_value)
		"border":
			image = _generate_border(size, seed_value)
		"icon_health":
			image = _generate_health_icon(size, seed_value)
		"icon_ammo":
			image = _generate_ammo_icon(size, seed_value)
		"icon_buff":
			image = _generate_buff_icon(size, seed_value)
		"icon_weapon":
			image = _generate_weapon_icon(size, seed_value)
		"health_bar_bg":
			size = Vector2i(200, 32)
			image = _generate_health_bar_background(size, seed_value)
		"health_bar_fill":
			size = Vector2i(200, 32)
			image = _generate_health_bar_fill(size, seed_value)
		"panel":
			size = Vector2i(256, 256)
			image = _generate_panel(size, seed_value)
		_:
			push_warning("Unknown UI element type: " + element_type)
			return null
	
	if image == null:
		return null
	
	return ImageTexture.create_from_image(image)

## Generate a button UI element
func _generate_button(size: Vector2i, seed_value: int) -> Image:
	seed(seed_value)
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Choose a color from combat palette for high contrast
	var button_color = COMBAT_PALETTE[randi() % COMBAT_PALETTE.size()]
	var border_color = Color.WHITE
	
	# Draw button background (rounded rectangle effect with simple rect)
	var margin = 4
	for y in range(margin, size.y - margin):
		for x in range(margin, size.x - margin):
			image.set_pixel(x, y, button_color)
	
	# Draw border
	for x in range(size.x):
		for i in range(2):  # 2-pixel border
			if x >= margin and x < size.x - margin:
				image.set_pixel(x, margin + i, border_color)
				image.set_pixel(x, size.y - margin - 1 - i, border_color)
	
	for y in range(size.y):
		for i in range(2):
			if y >= margin and y < size.y - margin:
				image.set_pixel(margin + i, y, border_color)
				image.set_pixel(size.x - margin - 1 - i, y, border_color)
	
	return image

## Generate a border UI element
func _generate_border(size: Vector2i, seed_value: int) -> Image:
	seed(seed_value)
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	var border_color = Color.WHITE
	var thickness = 3
	
	# Draw outer border
	for x in range(size.x):
		for i in range(thickness):
			image.set_pixel(x, i, border_color)
			image.set_pixel(x, size.y - 1 - i, border_color)
	
	for y in range(size.y):
		for i in range(thickness):
			image.set_pixel(i, y, border_color)
			image.set_pixel(size.x - 1 - i, y, border_color)
	
	return image

## Generate a health icon (heart shape approximation)
func _generate_health_icon(size: Vector2i, seed_value: int) -> Image:
	seed(seed_value)
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	var heart_color = Color("#F44336")  # Red from combat palette
	var center_x = size.x / 2
	var center_y = size.y / 2
	var radius = mini(size.x, size.y) / 3
	
	# Simple heart approximation using circles and triangle
	# Draw two circles at top
	_draw_filled_circle(image, Vector2i(center_x - radius / 2, center_y - radius / 2), radius / 2, heart_color)
	_draw_filled_circle(image, Vector2i(center_x + radius / 2, center_y - radius / 2), radius / 2, heart_color)
	
	# Draw triangle pointing down
	_draw_filled_triangle(image, 
		Vector2i(center_x - radius, center_y),
		Vector2i(center_x + radius, center_y),
		Vector2i(center_x, center_y + radius * 2),
		heart_color)
	
	return image

## Generate an ammo icon (bullet shape)
func _generate_ammo_icon(size: Vector2i, seed_value: int) -> Image:
	seed(seed_value)
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	var bullet_color = Color("#FFC107")  # Amber from farm palette
	var center_x = size.x / 2
	var width = size.x / 3
	var height = size.y * 2 / 3
	
	# Draw bullet body (rectangle)
	for y in range(size.y / 4, size.y * 3 / 4):
		for x in range(center_x - width / 2, center_x + width / 2):
			if x >= 0 and x < size.x and y >= 0 and y < size.y:
				image.set_pixel(x, y, bullet_color)
	
	# Draw bullet tip (small triangle)
	_draw_filled_triangle(image,
		Vector2i(center_x - width / 2, size.y / 4),
		Vector2i(center_x + width / 2, size.y / 4),
		Vector2i(center_x, size.y / 8),
		bullet_color.lightened(0.2))
	
	return image

## Generate a buff icon (star/sparkle shape)
func _generate_buff_icon(size: Vector2i, seed_value: int) -> Image:
	seed(seed_value)
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	var buff_color = Color("#9C27B0")  # Purple from combat palette
	var center = Vector2i(size.x / 2, size.y / 2)
	var radius = mini(size.x, size.y) / 3
	
	# Draw a star shape (4-pointed)
	# Horizontal line
	for x in range(center.x - radius, center.x + radius):
		if x >= 0 and x < size.x:
			for thickness in range(-2, 3):
				var y = center.y + thickness
				if y >= 0 and y < size.y:
					image.set_pixel(x, y, buff_color)
	
	# Vertical line
	for y in range(center.y - radius, center.y + radius):
		if y >= 0 and y < size.y:
			for thickness in range(-2, 3):
				var x = center.x + thickness
				if x >= 0 and x < size.x:
					image.set_pixel(x, y, buff_color)
	
	return image

## Generate a weapon icon (gun silhouette)
func _generate_weapon_icon(size: Vector2i, seed_value: int) -> Image:
	seed(seed_value)
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	var weapon_color = Color("#607D8B")  # Blue-gray from combat palette
	var center_y = size.y / 2
	
	# Draw gun barrel (horizontal rectangle)
	for y in range(center_y - 3, center_y + 3):
		for x in range(size.x / 4, size.x * 3 / 4):
			if x >= 0 and x < size.x and y >= 0 and y < size.y:
				image.set_pixel(x, y, weapon_color)
	
	# Draw gun grip (vertical rectangle)
	for y in range(center_y, size.y * 3 / 4):
		for x in range(size.x / 4 - 5, size.x / 4 + 5):
			if x >= 0 and x < size.x and y >= 0 and y < size.y:
				image.set_pixel(x, y, weapon_color)
	
	return image

## Generate a health bar background
func _generate_health_bar_background(size: Vector2i, seed_value: int) -> Image:
	seed(seed_value)
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	
	var bg_color = Color("#212121")  # Dark from combat palette
	image.fill(bg_color)
	
	# Add border
	var border_color = Color.WHITE
	for x in range(size.x):
		image.set_pixel(x, 0, border_color)
		image.set_pixel(x, size.y - 1, border_color)
	for y in range(size.y):
		image.set_pixel(0, y, border_color)
		image.set_pixel(size.x - 1, y, border_color)
	
	return image

## Generate a health bar fill
func _generate_health_bar_fill(size: Vector2i, seed_value: int) -> Image:
	seed(seed_value)
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	
	# Gradient from bright red to darker red
	var color_start = Color("#F44336")  # Red from combat palette
	var color_end = Color("#C62828")    # Darker red
	
	for y in range(size.y):
		var t = float(y) / float(size.y)
		var color = color_start.lerp(color_end, t)
		for x in range(size.x):
			image.set_pixel(x, y, color)
	
	return image

## Generate a panel background
func _generate_panel(size: Vector2i, seed_value: int) -> Image:
	seed(seed_value)
	var image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	
	var panel_color = Color(0.1, 0.1, 0.1, 0.9)  # Semi-transparent dark
	image.fill(panel_color)
	
	# Add decorative border
	var border_color = Color("#607D8B")  # Blue-gray from combat palette
	var border_thickness = 4
	
	for x in range(size.x):
		for i in range(border_thickness):
			image.set_pixel(x, i, border_color)
			image.set_pixel(x, size.y - 1 - i, border_color)
	
	for y in range(size.y):
		for i in range(border_thickness):
			image.set_pixel(i, y, border_color)
			image.set_pixel(size.x - 1 - i, y, border_color)
	
	return image

## Helper: Draw a filled triangle
func _draw_filled_triangle(image: Image, p1: Vector2i, p2: Vector2i, p3: Vector2i, color: Color) -> void:
	# Simple scanline triangle fill
	var points = [p1, p2, p3]
	points.sort_custom(func(a, b): return a.y < b.y)
	
	var y_min = points[0].y
	var y_max = points[2].y
	
	for y in range(y_min, y_max + 1):
		var intersections = []
		
		# Check each edge
		for i in range(3):
			var p_a = points[i]
			var p_b = points[(i + 1) % 3]
			
			if (p_a.y <= y and p_b.y > y) or (p_b.y <= y and p_a.y > y):
				var t = float(y - p_a.y) / float(p_b.y - p_a.y)
				var x = int(p_a.x + t * (p_b.x - p_a.x))
				intersections.append(x)
		
		if intersections.size() >= 2:
			intersections.sort()
			for x in range(intersections[0], intersections[-1] + 1):
				if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
					image.set_pixel(x, y, color)

## Internal helper to create shapes from geometric primitives
## @param shape_data: Dictionary containing shape definition (type, size, colors, etc.)
##   Expected keys:
##     - "width": int - Width of the image canvas
##     - "height": int - Height of the image canvas
##     - "shapes": Array[Dictionary] - Array of shape definitions
##       Each shape dictionary should contain:
##         - "type": String - "rectangle", "circle", or "triangle"
##         - "position": Vector2 - Position of the shape
##         - "size": Vector2 - Size of the shape (width, height for rectangle; radius for circle)
##         - "color": Color or int - Color to use (if int, index into palette)
##         - "filled": bool (optional) - Whether to fill the shape (default: true)
## @param palette: The color palette to use for the shape
## @return: An Image containing the generated shape
func _create_shape_from_primitives(shape_data: Dictionary, palette: Array[Color]) -> Image:
	# Validate input
	if not shape_data.has("width") or not shape_data.has("height"):
		push_error("shape_data must contain 'width' and 'height' keys")
		return null
	
	var width: int = shape_data["width"]
	var height: int = shape_data["height"]
	
	# Create a new image with RGBA format
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))  # Start with transparent background
	
	# Draw each shape if shapes array is provided
	if shape_data.has("shapes") and shape_data["shapes"] is Array:
		for shape_def in shape_data["shapes"]:
			if not shape_def is Dictionary:
				continue
			
			_draw_shape(image, shape_def, palette)
	
	return image

## Internal helper to draw a single shape on an image
## @param image: The Image to draw on
## @param shape_def: Dictionary containing shape definition
## @param palette: The color palette to use
func _draw_shape(image: Image, shape_def: Dictionary, palette: Array[Color]) -> void:
	if not shape_def.has("type"):
		return
	
	var shape_type: String = shape_def["type"]
	var color: Color = _get_color_from_def(shape_def, palette)
	var filled: bool = shape_def.get("filled", true)
	
	match shape_type:
		"rectangle":
			_draw_rectangle(image, shape_def, color, filled)
		"circle":
			_draw_shape_circle(image, shape_def, color, filled)
		"triangle":
			_draw_triangle(image, shape_def, color, filled)
		_:
			push_warning("Unknown shape type: " + shape_type)

## Get color from shape definition, either directly or from palette index
func _get_color_from_def(shape_def: Dictionary, palette: Array[Color]) -> Color:
	if shape_def.has("color"):
		var color_val = shape_def["color"]
		if color_val is Color:
			return color_val
		elif color_val is int and palette.size() > 0:
			var idx = color_val % palette.size()
			return palette[idx]
	
	# Default to first palette color or white if no palette
	return palette[0] if palette.size() > 0 else Color.WHITE

## Draw a rectangle on the image
func _draw_rectangle(image: Image, shape_def: Dictionary, color: Color, filled: bool) -> void:
	if not shape_def.has("position") or not shape_def.has("size"):
		return
	
	var pos: Vector2 = shape_def["position"]
	var size: Vector2 = shape_def["size"]
	
	var x1 = int(pos.x)
	var y1 = int(pos.y)
	var x2 = int(pos.x + size.x)
	var y2 = int(pos.y + size.y)
	
	# Clamp to image bounds
	x1 = clampi(x1, 0, image.get_width() - 1)
	y1 = clampi(y1, 0, image.get_height() - 1)
	x2 = clampi(x2, 0, image.get_width() - 1)
	y2 = clampi(y2, 0, image.get_height() - 1)
	
	if filled:
		# Fill the rectangle
		for y in range(y1, y2 + 1):
			for x in range(x1, x2 + 1):
				image.set_pixel(x, y, color)
	else:
		# Draw rectangle outline
		# Top and bottom edges
		for x in range(x1, x2 + 1):
			image.set_pixel(x, y1, color)
			image.set_pixel(x, y2, color)
		# Left and right edges
		for y in range(y1, y2 + 1):
			image.set_pixel(x1, y, color)
			image.set_pixel(x2, y, color)

## Draw a circle shape on the image (used by shape-based generation)
func _draw_shape_circle(image: Image, shape_def: Dictionary, color: Color, filled: bool) -> void:
	if not shape_def.has("position") or not shape_def.has("size"):
		return
	
	var center: Vector2 = shape_def["position"]
	var radius: float = shape_def["size"].x  # Use x component as radius
	
	var cx = int(center.x)
	var cy = int(center.y)
	var r = int(radius)
	
	if filled:
		# Filled circle using midpoint circle algorithm
		for y in range(-r, r + 1):
			for x in range(-r, r + 1):
				if x * x + y * y <= r * r:
					var px = cx + x
					var py = cy + y
					if px >= 0 and px < image.get_width() and py >= 0 and py < image.get_height():
						image.set_pixel(px, py, color)
	else:
		# Circle outline using midpoint circle algorithm
		var x = r
		var y = 0
		var err = 0
		
		while x >= y:
			_set_circle_pixels(image, cx, cy, x, y, color)
			
			if err <= 0:
				y += 1
				err += 2 * y + 1
			
			if err > 0:
				x -= 1
				err -= 2 * x + 1

## Helper to set 8 symmetric pixels for circle drawing
func _set_circle_pixels(image: Image, cx: int, cy: int, x: int, y: int, color: Color) -> void:
	var points = [
		Vector2i(cx + x, cy + y),
		Vector2i(cx - x, cy + y),
		Vector2i(cx + x, cy - y),
		Vector2i(cx - x, cy - y),
		Vector2i(cx + y, cy + x),
		Vector2i(cx - y, cy + x),
		Vector2i(cx + y, cy - x),
		Vector2i(cx - y, cy - x)
	]
	
	for point in points:
		if point.x >= 0 and point.x < image.get_width() and point.y >= 0 and point.y < image.get_height():
			image.set_pixel(point.x, point.y, color)

## Draw a triangle on the image
func _draw_triangle(image: Image, shape_def: Dictionary, color: Color, filled: bool) -> void:
	if not shape_def.has("points") or not shape_def["points"] is Array:
		return
	
	var points: Array = shape_def["points"]
	if points.size() < 3:
		return
	
	var p1: Vector2 = points[0]
	var p2: Vector2 = points[1]
	var p3: Vector2 = points[2]
	
	if filled:
		# Filled triangle using scanline algorithm
		_draw_filled_triangle(image, p1, p2, p3, color)
	else:
		# Triangle outline - draw three lines
		_draw_line(image, p1, p2, color)
		_draw_line(image, p2, p3, color)
		_draw_line(image, p3, p1, color)

## Draw a line between two points using Bresenham's algorithm
func _draw_line(image: Image, p1: Vector2, p2: Vector2, color: Color) -> void:
	var x1 = int(p1.x)
	var y1 = int(p1.y)
	var x2 = int(p2.x)
	var y2 = int(p2.y)
	
	var dx = abs(x2 - x1)
	var dy = abs(y2 - y1)
	var sx = 1 if x1 < x2 else -1
	var sy = 1 if y1 < y2 else -1
	var err = dx - dy
	
	while true:
		if x1 >= 0 and x1 < image.get_width() and y1 >= 0 and y1 < image.get_height():
			image.set_pixel(x1, y1, color)
		
		if x1 == x2 and y1 == y2:
			break
		
		var e2 = 2 * err
		if e2 > -dy:
			err -= dy
			x1 += sx
		if e2 < dx:
			err += dx
			y1 += sy

## Draw a filled triangle using scanline algorithm
func _draw_filled_triangle(image: Image, p1: Vector2, p2: Vector2, p3: Vector2, color: Color) -> void:
	# Sort points by y-coordinate
	var points = [p1, p2, p3]
	points.sort_custom(func(a, b): return a.y < b.y)
	
	var v1 = points[0]
	var v2 = points[1]
	var v3 = points[2]
	
	# Handle degenerate case
	if v1.y == v3.y:
		return
	
	# Draw the triangle in two parts: top half and bottom half
	if v2.y == v1.y:
		_fill_flat_top_triangle(image, v1, v2, v3, color)
	elif v2.y == v3.y:
		_fill_flat_bottom_triangle(image, v1, v2, v3, color)
	else:
		# Split into two triangles
		var v4 = Vector2(
			v1.x + (v2.y - v1.y) / (v3.y - v1.y) * (v3.x - v1.x),
			v2.y
		)
		_fill_flat_bottom_triangle(image, v1, v2, v4, color)
		_fill_flat_top_triangle(image, v2, v4, v3, color)

## Fill a triangle with flat bottom
func _fill_flat_bottom_triangle(image: Image, v1: Vector2, v2: Vector2, v3: Vector2, color: Color) -> void:
	var inv_slope1 = (v2.x - v1.x) / (v2.y - v1.y) if v2.y != v1.y else 0
	var inv_slope2 = (v3.x - v1.x) / (v3.y - v1.y) if v3.y != v1.y else 0
	
	var cur_x1 = v1.x
	var cur_x2 = v1.x
	
	for scanline_y in range(int(v1.y), int(v2.y) + 1):
		if scanline_y >= 0 and scanline_y < image.get_height():
			var x_start = int(min(cur_x1, cur_x2))
			var x_end = int(max(cur_x1, cur_x2))
			x_start = clampi(x_start, 0, image.get_width() - 1)
			x_end = clampi(x_end, 0, image.get_width() - 1)
			
			for x in range(x_start, x_end + 1):
				image.set_pixel(x, scanline_y, color)
		
		cur_x1 += inv_slope1
		cur_x2 += inv_slope2

## Fill a triangle with flat top
func _fill_flat_top_triangle(image: Image, v1: Vector2, v2: Vector2, v3: Vector2, color: Color) -> void:
	var inv_slope1 = (v3.x - v1.x) / (v3.y - v1.y) if v3.y != v1.y else 0
	var inv_slope2 = (v3.x - v2.x) / (v3.y - v2.y) if v3.y != v2.y else 0
	
	var cur_x1 = v3.x
	var cur_x2 = v3.x
	
	for scanline_y in range(int(v3.y), int(v1.y) - 1, -1):
		if scanline_y >= 0 and scanline_y < image.get_height():
			var x_start = int(min(cur_x1, cur_x2))
			var x_end = int(max(cur_x1, cur_x2))
			x_start = clampi(x_start, 0, image.get_width() - 1)
			x_end = clampi(x_end, 0, image.get_width() - 1)
			
			for x in range(x_start, x_end + 1):
				image.set_pixel(x, scanline_y, color)
		
		cur_x1 -= inv_slope1
		cur_x2 -= inv_slope2

## Apply a palette swap to an existing image
## @param base_image: The base image to recolor
## @param new_palette: The new color palette to apply
## @return: A new Image with the palette swapped
func _apply_palette_swap(base_image: Image, new_palette: Array[Color]) -> Image:
	# TODO: Implement in future task (11.3.1)
	push_warning("_apply_palette_swap not yet implemented")
	return null

## Draw a round/berry-like crop (for health crops)
## @param image: The image to draw on
## @param size: The size of the image
## @param base_color: The base color for the crop
## @param growth_scale: Scale factor based on growth stage (0.25 to 1.0)
## @param rng: Random number generator for variation
func _draw_round_crop(image: Image, size: int, base_color: Color, growth_scale: float, rng: RandomNumberGenerator) -> void:
	var center = Vector2(size / 2, size / 2)
	var radius = int((size / 2 - 2) * growth_scale)
	
	# Draw main berry circle
	_draw_filled_circle(image, center, radius, base_color)
	
	# Add highlight for depth (lighter color on top-left)
	if growth_scale > 0.5:
		var highlight_color = base_color.lightened(0.3)
		var highlight_offset = Vector2(-radius * 0.3, -radius * 0.3)
		var highlight_radius = int(radius * 0.4)
		_draw_filled_circle(image, center + highlight_offset, highlight_radius, highlight_color)
	
	# Add stem at later growth stages
	if growth_scale > 0.75:
		var stem_color = Color("#4CAF50")  # Green stem
		var stem_start = Vector2(center.x, center.y - radius)
		var stem_height = int(size * 0.2)
		_draw_rectangle(image, int(stem_start.x - 1), int(stem_start.y - stem_height), 2, stem_height, stem_color)

## Draw a tall/grain-like crop (for ammo crops)
## @param image: The image to draw on
## @param size: The size of the image
## @param base_color: The base color for the crop
## @param growth_scale: Scale factor based on growth stage (0.25 to 1.0)
## @param rng: Random number generator for variation
func _draw_tall_crop(image: Image, size: int, base_color: Color, growth_scale: float, rng: RandomNumberGenerator) -> void:
	var center_x = size / 2
	var bottom_y = size - 2
	var height = int((size - 4) * growth_scale)
	var top_y = bottom_y - height
	
	# Draw stem
	var stem_color = Color("#8BC34A")  # Light green stem
	var stem_width = max(2, int(3 * growth_scale))
	_draw_rectangle(image, center_x - stem_width / 2, top_y, stem_width, height, stem_color)
	
	# Add grain head at later growth stages
	if growth_scale > 0.5:
		var grain_height = int(height * 0.4)
		var grain_width = int(stem_width * 2)
		_draw_rectangle(image, center_x - grain_width / 2, top_y, grain_width, grain_height, base_color)
		
		# Add grain details (small rectangles)
		if growth_scale > 0.75:
			var detail_color = base_color.darkened(0.2)
			for i in range(3):
				var detail_y = top_y + i * (grain_height / 3)
				_draw_rectangle(image, center_x - grain_width / 2, detail_y, grain_width, 1, detail_color)

## Draw a leafy/flower-like crop (for weapon mod crops)
## @param image: The image to draw on
## @param size: The size of the image
## @param base_color: The base color for the crop
## @param growth_scale: Scale factor based on growth stage (0.25 to 1.0)
## @param rng: Random number generator for variation
func _draw_leafy_crop(image: Image, size: int, base_color: Color, growth_scale: float, rng: RandomNumberGenerator) -> void:
	var center = Vector2(size / 2, size / 2)
	
	# Draw stem
	var stem_color = Color("#4CAF50")  # Green stem
	var stem_height = int((size / 2) * growth_scale)
	_draw_rectangle(image, int(center.x - 1), int(center.y), 2, stem_height, stem_color)
	
	# Draw leaves/petals at later growth stages
	if growth_scale > 0.5:
		var petal_count = 4 if growth_scale > 0.75 else 2
		var petal_radius = int((size / 4) * growth_scale)
		
		for i in range(petal_count):
			var angle = (i * TAU / petal_count) + (TAU / 8)  # Offset by 45 degrees
			var petal_offset = Vector2(cos(angle), sin(angle)) * petal_radius * 1.5
			var petal_pos = center + petal_offset
			_draw_filled_circle(image, petal_pos, petal_radius, base_color)
		
		# Draw center flower/bud
		if growth_scale > 0.75:
			var center_color = base_color.darkened(0.3)
			var center_radius = int(petal_radius * 0.6)
			_draw_filled_circle(image, center, center_radius, center_color)

## Draw a filled circle on an image
## @param image: The image to draw on
## @param center: Center position of the circle
## @param radius: Radius of the circle
## @param color: Color to fill the circle with
func _draw_filled_circle(image: Image, center: Vector2, radius: int, color: Color) -> void:
	if radius <= 0:
		return
	
	var size = image.get_size()
	for y in range(max(0, int(center.y - radius)), min(size.y, int(center.y + radius + 1))):
		for x in range(max(0, int(center.x - radius)), min(size.x, int(center.x + radius + 1))):
			var dx = x - center.x
			var dy = y - center.y
			if dx * dx + dy * dy <= radius * radius:
				image.set_pixel(x, y, color)

## Draw a filled rectangle on an image
## @param image: The image to draw on
## @param x: X position of top-left corner
## @param y: Y position of top-left corner
## @param width: Width of the rectangle
## @param height: Height of the rectangle
## @param color: Color to fill the rectangle with
func _draw_rectangle(image: Image, x: int, y: int, width: int, height: int, color: Color) -> void:
	var size = image.get_size()
	for py in range(max(0, y), min(size.y, y + height)):
		for px in range(max(0, x), min(size.x, x + width)):
			image.set_pixel(px, py, color)

## Generate a single tile in the tileset
## @param image: The image to draw the tile on
## @param x: The x position of the tile
## @param y: The y position of the tile
## @param size: The size of the tile
## @param palette: The color palette to use
func _generate_tile(image: Image, x: int, y: int, size: int, palette: Array[Color]) -> void:
	# Choose a random base color from the palette
	var base_color = palette[randi() % palette.size()]
	
	# Fill the tile with the base color
	for py in range(size):
		for px in range(size):
			image.set_pixel(x + px, y + py, base_color)
	
	# Add some variation with geometric patterns
	var pattern_type = randi() % 4
	
	match pattern_type:
		0:  # Solid tile with border
			_draw_border(image, x, y, size, palette)
		1:  # Checkerboard pattern
			_draw_checkerboard(image, x, y, size, palette)
		2:  # Diagonal stripes
			_draw_diagonal_stripes(image, x, y, size, palette)
		3:  # Random dots/noise
			_draw_noise_pattern(image, x, y, size, palette)

## Draw a border around a tile
func _draw_border(image: Image, x: int, y: int, size: int, palette: Array[Color]) -> void:
	var border_color = palette[randi() % palette.size()]
	var border_width = 2
	
	# Top and bottom borders
	for px in range(size):
		for bw in range(border_width):
			image.set_pixel(x + px, y + bw, border_color)
			image.set_pixel(x + px, y + size - 1 - bw, border_color)
	
	# Left and right borders
	for py in range(size):
		for bw in range(border_width):
			image.set_pixel(x + bw, y + py, border_color)
			image.set_pixel(x + size - 1 - bw, y + py, border_color)

## Draw a checkerboard pattern on a tile
func _draw_checkerboard(image: Image, x: int, y: int, size: int, palette: Array[Color]) -> void:
	var color1 = palette[randi() % palette.size()]
	var color2 = palette[randi() % palette.size()]
	var check_size = size / 4
	
	for py in range(size):
		for px in range(size):
			var check_x = int(px / check_size)
			var check_y = int(py / check_size)
			var color = color1 if (check_x + check_y) % 2 == 0 else color2
			image.set_pixel(x + px, y + py, color)

## Draw diagonal stripes on a tile
func _draw_diagonal_stripes(image: Image, x: int, y: int, size: int, palette: Array[Color]) -> void:
	var color1 = palette[randi() % palette.size()]
	var color2 = palette[randi() % palette.size()]
	var stripe_width = size / 8
	
	for py in range(size):
		for px in range(size):
			var diagonal_pos = (px + py) / stripe_width
			var color = color1 if int(diagonal_pos) % 2 == 0 else color2
			image.set_pixel(x + px, y + py, color)

## Draw a noise pattern on a tile
func _draw_noise_pattern(image: Image, x: int, y: int, size: int, palette: Array[Color]) -> void:
	var base_color = palette[randi() % palette.size()]
	var noise_color = palette[randi() % palette.size()]
	var noise_density = 0.1  # 10% of pixels will be noise
	
	for py in range(size):
		for px in range(size):
			if randf() < noise_density:
				image.set_pixel(x + px, y + py, noise_color)
			else:
				image.set_pixel(x + px, y + py, base_color)
