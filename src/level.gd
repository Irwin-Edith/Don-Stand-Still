extends Node3D

@onready var monster: CharacterBody3D = $NavigationRegion3D/Monster
@onready var player: CharacterBody3D = $NavigationRegion3D/Player
@onready var nav: NavigationRegion3D = $NavigationRegion3D
@onready var orb_container: Node3D = $NavigationRegion3D/GridMap/OrbContainer

@export var scene: PackedScene = null

# +++ orbs +++#
var collected_orbs = 0
var total_orb_count = 0
# +++ orbs +++#

func _ready() -> void:
	scene = load("res://src/menu_components/mainmenu.tscn")
	# 确保所有节点都已加载
	await get_tree().process_frame
	total_orb_count = orb_container.get_child_count()
	
	# +++ orbs +++#
	player.orb_collected.connect(_on_orb_collected)
	# +++ orbs +++#

	# 设置怪物导航和目标
	if monster and nav and player:
		monster.set_nav(nav)
		monster.set_target(player)
	else:
		printerr("Error: Missing required nodes in Level scene")
		
		
# +++ orbs +++#
func _on_orb_collected():
	collected_orbs += 1
	if collected_orbs >= total_orb_count:
		print(("You just won!"))
		if scene:
			print("返回菜单")
			get_tree().change_scene_to_packed(scene)
		else:
			push_error("未分配 game_scene！请在编辑器中设置目标场景。")
# +++ orbs +++#
