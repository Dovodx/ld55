extends CanvasLayer

func _ready():
	var count = 1
	for child in get_node("summon select").get_children():
		if child.name == "bg" or child.name.contains("desc"):
			continue
		child.connect("mouse_entered", show_description.bind(count))
		child.connect("mouse_exited", show_description.bind(0))
		count += 1

func show_description(index):
	for child in get_node("summon select").get_children():
		if !child.name.contains("desc"):
			continue
		child.visible = child.name == "desc" + str(index)
