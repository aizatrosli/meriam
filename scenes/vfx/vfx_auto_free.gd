## VFXAutoFree – frees its Node2D when the CPUParticles2D child finishes.
## Attach to any one-shot VFX scene that has a CPUParticles2D named "CPUParticles2D".
extends Node2D

func _ready() -> void:
	var particles: CPUParticles2D = $CPUParticles2D
	if particles:
		particles.finished.connect(queue_free)
