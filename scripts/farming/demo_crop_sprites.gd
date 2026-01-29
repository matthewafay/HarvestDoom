extends Node2D
## Demo script to visualize crop sprite generation
##
## This script creates a visual demonstration of all crop types
## at all growth stages. Useful for manual verification and debugging.
##
## Usage: Attach to a Node2D in a scene and run the scene

var art_generator: ProceduralArtGenerator
var plots: Array[Plot] = []

func _ready() -> void:
	# Create art generator
	art_generator = ProceduralArtGenerator.new()
	
	# Load crop data
	var crops = [
		load("res://resources/crops/health_berry.tres"),
		load("res://resources/crops/ammo_grain.tres"),
		load("res://resources/crops/weapon_flower.tres")
	]
	
	# Create a grid of plots showing all crops at all stages
	var spacing = 64
	var y_offset = 0
	
	for crop in crops:
		if crop == null:
			continue
		
		# Create label for crop name
		var label = Label.new()
		label.text = crop.display_name
		label.position = Vector2(0, y_offset)
		add_child(label)
		
		# Create plots for each growth stage
		for stage in range(1, 4):  # Stages 1-3 (skip 0 as it's empty)
			var plot = Plot.new()
			plot.art_generator = art_generator
			plot.position = Vector2((stage - 1) * spacing + 150, y_offset)
			add_child(plot)
			
			# Initialize and plant
			plot._ready()
			plot.plant(crop)
			
			# Set to specific growth stage
			match stage:
				1:
					plot.growth_progress = 0.0
				2:
					plot.growth_progress = plot.growth_time * 0.5
				3:
					plot.state = Plot.PlotState.HARVESTABLE
					plot.growth_progress = plot.growth_time
			
			plot._update_visual()
			plots.append(plot)
			
			# Add stage label
			var stage_label = Label.new()
			stage_label.text = "Stage %d" % stage
			stage_label.position = Vector2((stage - 1) * spacing + 130, y_offset + 40)
			add_child(stage_label)
		
		y_offset += 100
	
	# Add instructions
	var instructions = Label.new()
	instructions.text = "Crop Sprite Generation Demo\n\nShowing all crop types at growth stages 1-3"
	instructions.position = Vector2(0, y_offset + 20)
	add_child(instructions)
	
	print("Demo initialized with %d plots" % plots.size())
	print("Crops displayed: Health Berry, Ammo Grain, Weapon Flower")
	print("Stages: 1 (early), 2 (mid), 3 (harvestable)")
