extends GdUnitTestSuite
## Unit tests for InteractionPrompt
##
## Tests the basic functionality of the interaction prompt UI component.
##
## Validates: Requirements 10.3, 4.5

func test_interaction_prompt_starts_hidden() -> void:
	# Arrange
	var prompt = InteractionPrompt.new()
	add_child(prompt)
	
	# Act & Assert
	assert_bool(prompt.is_showing()).is_false()
	assert_bool(prompt.visible).is_false()
	
	# Cleanup
	prompt.queue_free()

func test_show_prompt_displays_text() -> void:
	# Arrange
	var prompt = InteractionPrompt.new()
	add_child(prompt)
	await get_tree().process_frame
	
	# Act
	prompt.show_prompt("Press E to Plant")
	
	# Assert
	assert_bool(prompt.is_showing()).is_true()
	assert_bool(prompt.visible).is_true()
	if prompt.prompt_label:
		assert_str(prompt.prompt_label.text).is_equal("Press E to Plant")
	
	# Cleanup
	prompt.queue_free()

func test_hide_prompt_hides_display() -> void:
	# Arrange
	var prompt = InteractionPrompt.new()
	add_child(prompt)
	await get_tree().process_frame
	prompt.show_prompt("Test")
	
	# Act
	prompt.hide_prompt()
	
	# Assert
	assert_bool(prompt.is_showing()).is_false()
	assert_bool(prompt.visible).is_false()
	
	# Cleanup
	prompt.queue_free()

func test_set_and_get_target() -> void:
	# Arrange
	var prompt = InteractionPrompt.new()
	add_child(prompt)
	var target_node = Node.new()
	add_child(target_node)
	
	# Act
	prompt.set_target(target_node)
	
	# Assert
	assert_object(prompt.get_target()).is_equal(target_node)
	
	# Cleanup
	prompt.queue_free()
	target_node.queue_free()

func test_hide_prompt_clears_target() -> void:
	# Arrange
	var prompt = InteractionPrompt.new()
	add_child(prompt)
	var target_node = Node.new()
	add_child(target_node)
	prompt.set_target(target_node)
	
	# Act
	prompt.hide_prompt()
	
	# Assert
	assert_object(prompt.get_target()).is_null()
	
	# Cleanup
	prompt.queue_free()
	target_node.queue_free()

func test_show_prompt_with_custom_position() -> void:
	# Arrange
	var prompt = InteractionPrompt.new()
	add_child(prompt)
	await get_tree().process_frame
	var custom_pos = Vector2(100, 200)
	
	# Act
	prompt.show_prompt("Test", custom_pos)
	
	# Assert
	assert_bool(prompt.is_showing()).is_true()
	assert_vector(prompt.position).is_equal(custom_pos)
	
	# Cleanup
	prompt.queue_free()
