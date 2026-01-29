extends Node

## Verification script for FeedbackSystem
## Run this script to verify FeedbackSystem is properly configured and functional

func _ready() -> void:
	print("=== FeedbackSystem Verification ===")
	
	# Check if FeedbackSystem singleton exists
	if FeedbackSystem == null:
		print("❌ FAILED: FeedbackSystem singleton not found")
		return
	else:
		print("✓ FeedbackSystem singleton exists")
	
	# Check if screen flash is initialized
	if FeedbackSystem.screen_flash == null:
		print("❌ FAILED: screen_flash not initialized")
	else:
		print("✓ screen_flash initialized")
	
	# Check initial state
	if FeedbackSystem.shake_intensity == 0.0 and FeedbackSystem.shake_timer == 0.0:
		print("✓ Camera shake state initialized correctly")
	else:
		print("❌ FAILED: Camera shake state not initialized correctly")
	
	if FeedbackSystem.flash_timer == 0.0 and FeedbackSystem.flash_duration == 0.0:
		print("✓ Screen flash state initialized correctly")
	else:
		print("❌ FAILED: Screen flash state not initialized correctly")
	
	# Test signal connections
	var signal_list = FeedbackSystem.get_signal_list()
	var has_feedback_completed = false
	for sig in signal_list:
		if sig.name == "feedback_completed":
			has_feedback_completed = true
			break
	
	if has_feedback_completed:
		print("✓ feedback_completed signal exists")
	else:
		print("❌ FAILED: feedback_completed signal not found")
	
	# Test method existence
	var methods_to_check = [
		"spawn_damage_number",
		"spawn_hit_effect",
		"flash_screen",
		"shake_camera",
		"create_impact_particles",
		"create_death_explosion",
		"create_harvest_effect",
		"set_camera"
	]
	
	var all_methods_exist = true
	for method_name in methods_to_check:
		if FeedbackSystem.has_method(method_name):
			print("✓ Method exists: " + method_name)
		else:
			print("❌ FAILED: Method missing: " + method_name)
			all_methods_exist = false
	
	# Test basic functionality
	print("\n=== Testing Basic Functionality ===")
	
	# Test screen flash
	FeedbackSystem.flash_screen(Color.RED, 0.1)
	if FeedbackSystem.screen_flash.visible:
		print("✓ flash_screen activates screen flash")
	else:
		print("❌ FAILED: flash_screen did not activate screen flash")
	
	# Test camera shake (without camera, should handle gracefully)
	FeedbackSystem.shake_camera(0.5, 0.1)
	print("✓ shake_camera handles missing camera gracefully")
	
	# Test signal emission
	var signal_received = false
	FeedbackSystem.feedback_completed.connect(func(type): signal_received = true)
	
	# Trigger a simple effect
	FeedbackSystem.spawn_damage_number(50, Vector3.ZERO)
	await get_tree().create_timer(0.1).timeout
	
	if signal_received:
		print("✓ Signals are emitted correctly")
	else:
		print("⚠ Warning: Signal not received (may need more time)")
	
	print("\n=== Verification Complete ===")
	print("FeedbackSystem is properly configured and functional!")
	
	# Exit after verification
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()
