extends Control


func _process(_delta):
	# Update the MouseLight position to match the cursor
	%MouseLight.position = get_local_mouse_position()
