extends Node3D

@onready var start_button: Button = $CanvasLayer/Fader/Control/VBoxContainer/CenterContainer/VBoxContainer/StartButton
@onready var quit_button: Button = $CanvasLayer/Fader/Control/VBoxContainer/CenterContainer/VBoxContainer/QuitButton
@onready var fader: ColorRect = $CanvasLayer/Fader

@export var game_scene: PackedScene = null

func _ready() -> void:
	start_button.pressed.connect(on_start_pressed)
	quit_button.pressed.connect(on_quit_pressed)
	# 连接 Fader 的动画完成信号（注意信号名需与 fader.gd 一致）
	fader.fade_finished.connect(on_fade_finished)
	
func _input(event):
	# 按ESC释放鼠标
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func on_start_pressed():
	fader.fade_out()  # 触发淡入动画，完成后会自动调用 on_fade_finished

func on_quit_pressed():
	get_tree().quit()

func on_fade_finished():
	if game_scene:
		get_tree().change_scene_to_packed(game_scene)
	else:
		push_error("未分配 game_scene！请在编辑器中设置目标场景。")
