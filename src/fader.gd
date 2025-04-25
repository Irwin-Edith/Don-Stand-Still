extends ColorRect

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal fade_finished  # 用于通知外部动画播放完成

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

# 播放淡入动画（假设动画名称为 "fade_in"）
func fade_in():
	animation_player.play("fade_in")

# 播放淡出动画（假设动画名称为 "fade_out"）
func fade_out():
	animation_player.play("fade_out")

# 动画播放完成时触发信号
func _on_animation_finished(anim_name: String):
	if anim_name == "fade_in" or anim_name == "fade_out":
		emit_signal("fade_finished")
