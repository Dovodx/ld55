extends GPUParticles2D

func _ready():
	finished.connect(_on_finished)
	restart()

func _on_finished():
	queue_free()
