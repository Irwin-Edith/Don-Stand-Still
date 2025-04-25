extends CharacterBody3D

# 移动参数
@export var move_speed : float = 5.0
@export var sprint_speed : float = 8.0
@export var jump_force : float = 4.5
@export var mouse_sensitivity : float = 0.2

# 节点引用
@onready var camera_pivot : Node3D = $CameraPivot
@onready var camera : Camera3D = $CameraPivot/Camera3D

# ---audio--- #
@onready var footsteps: AudioStreamPlayer3D = $Footsteps
var walking = false
# ---audio--- #

var current_speed : float = move_speed
var vertical_velocity : float = 0.0

# ---add--- #
@onready var collider: Area3D = $Collider
signal orb_collected
# ---add--- #
func _ready():
	# 锁定鼠标到游戏窗口
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# 确保摄像机初始化正确
	if not camera_pivot or not camera:
		push_error("Camera setup is missing! Check scene tree structure.")
	# ---add orb--- #	
	#collider.connect("area_entered",self,"on_area_entered")
	collider.area_entered.connect(_on_area_entered)
	# ---add orb--- #

func _input(event):
	# 鼠标视角控制
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# 水平旋转（Y轴，左右转头）
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		# 垂直旋转（X轴，上下看）
		var vertical_rotation = deg_to_rad(-event.relative.y * mouse_sensitivity)
		camera_pivot.rotate_x(vertical_rotation)
		# 限制俯仰角度（-70°到70°比±90°更安全）
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-60), deg_to_rad(60))

	
	# 按ESC释放鼠标
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	# 重置水平速度
	var horizontal_velocity = Vector2(velocity.x, velocity.z)
	# 冲刺
	current_speed = sprint_speed if Input.is_action_pressed("sprint") else move_speed
	
	# 获取输入方向
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	#print("Input direction: ", input_dir)  # 移动时观察控制台输出
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Input.is_action_just_pressed("toggle_flashlight"):
		$CameraPivot/SpotLight3D.visible = not $CameraPivot/SpotLight3D.visible
	
	# ---audio--- #
	#var is_moving = input_dir.length() > 0.1  # 添加阈值避免微小输入
	var is_moving = input_dir != Vector2.ZERO
	#print(is_moving,is_on_floor())
	#更新 walking 状态
	if is_moving :  # 只有在地面上移动才播放and is_on_floor()
		if not walking:
			walking = true
			footsteps.play()
	elif walking:  # 停止移动或离开地面
		walking = false
		footsteps.stop()
	# 冲刺音效调整（可选）
	if Input.is_action_pressed("sprint") and is_moving:
		footsteps.pitch_scale = 1.2  # 加快音调
	else:
		footsteps.pitch_scale = 1.0
	# ---audio--- #
	
	# 计算水平速度
	if direction:
		horizontal_velocity = horizontal_velocity.lerp(
			Vector2(direction.x, direction.z) * current_speed, 
			1.0
		)
	else:
		horizontal_velocity = horizontal_velocity.lerp(Vector2.ZERO, 1.0)
	
	# 组合最终速度
	velocity = Vector3(horizontal_velocity.x, vertical_velocity, horizontal_velocity.y)
	
	# 移动角色
	move_and_slide()
	
	# 摄像机跟随地面角度
	if is_on_floor():
		var floor_normal = get_floor_normal()
		camera_pivot.rotation.x = lerp_angle(
			camera_pivot.rotation.x,
			atan2(floor_normal.y, floor_normal.length()) * 0.5,
			delta * 5.0
		)

# ---add orb--- #
func _on_area_entered(area):
	if area.is_in_group("Orb"):
		area.queue_free( )
		orb_collected.emit()
		#print("Just Hit an orb!")
# ---add orb--- #
