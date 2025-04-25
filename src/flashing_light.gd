extends SpotLight3D

@export var min_energy: float = 1.0
@export var max_energy: float = 3.5
@export var min_interval: float = 0.05
@export var max_interval: float = 0.2

var timer: Timer

func _ready() -> void:
	# 确保灯光初始可见
	light_energy = max_energy
	
	# 创建并启动定时器
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	_reset_timer()
	timer.start()

func _on_timer_timeout():
	# 随机切换亮度
	light_energy = randf_range(min_energy, max_energy)
	_reset_timer()

func _reset_timer():
	timer.wait_time = randf_range(min_interval, max_interval)
