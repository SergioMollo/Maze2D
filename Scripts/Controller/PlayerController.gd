extends Node

var player: Player
var maze_finished = false
var target = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	player = Player.new()
	add_child(player)
	#player = get_node("res://Scripts/Model/PlayerData.gd")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	await get_tree().physics_frame
	if !maze_finished:
		print(target)
		player.move(target)


#### Registrar movimiento manual
func _input(event):

	if event.is_action_pressed("ui_right"):
		target.x = player.position.x + 32
		target.y = player.position.y
		
	if event.is_action_pressed("ui_left"):
		target.x = player.position.x - 32
		target.y = player.position.y
		
	if event.is_action_pressed("ui_up"):
		target.x = player.position.x 
		target.y = player.position.y - 32
		
	if event.is_action_pressed("ui_down"):
		target.x = player.position.x
		target.y = player.position.y + 32
