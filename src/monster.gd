extends CharacterBody3D

const SPEED = 3.5
var target = null
var nav : NavigationRegion3D = null
var vel = Vector3()

# -----hitbox------ #
@onready var hitbox: Area3D = $HitboxArea

@export var scene: PackedScene = null

func _ready() -> void:
	hitbox.body_entered.connect(on_hit_player)
	scene = load("res://src/menu_components/mainmenu.tscn")
	
func on_hit_player(body: Node3D) -> void:
	print("We just slammed the f out of ", body.name)
	#print(scene)
	if scene:
		print("返回菜单")
		get_tree().change_scene_to_packed(scene)
	else:
		push_error("未分配 game_scene！请在编辑器中设置目标场景。")


func _physics_process(delta: float) -> void:
	if target == null:
		return
		
	var path = calculate_nav_path(target.global_position)
	
	if path.size() > 0:
		move_along_path(path, delta)
		
# 将方法名从get_path_to改为calculate_nav_path以避免与Node类的方法冲突
func calculate_nav_path(target_position: Vector3) -> PackedVector3Array:
	if nav == null:
		return PackedVector3Array()
		
	# 在Godot 4中，需要通过NavigationServer获取路径
	var map_rid = nav.get_navigation_map()
	return NavigationServer3D.map_get_path(
		map_rid,
		global_position,
		target_position,
		true
	)

func move_along_path(path: PackedVector3Array, delta: float):
	if path.size() <= 0:
		return
	
	# 移除已经到达的点
	while path.size() > 1 and global_position.distance_to(path[0]) < 0.1:
		path.remove_at(0)
	
	var target_position = path[0]
	var direction = (target_position - global_position).normalized()
	
	# 使用delta实现帧率无关的移动
	velocity = direction * SPEED * delta * 60  # 假设60FPS为基准
	
	move_and_slide()
	
	# 面向移动方向（使用delta平滑旋转）
	if velocity.length() > 0.1:
		var target_angle = atan2(velocity.x, velocity.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 5.0)

func set_target(new_target):
	target = new_target

func set_nav(new_nav):
	nav = new_nav
