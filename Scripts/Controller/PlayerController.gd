extends Node2D

class_name PlayerController

var player: Player
var maze_finished = false
var target = Vector2.ZERO

func _init(player_data):
	self.player = player_data

# Called when the node enters the scene tree for the first time.
func _ready():
	# player = Player.new()
	# add_child(player)
	# player = get_node("/root/Nivel1/Jugador/Player")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	await get_tree().physics_frame
	#if !maze_finished:
		#print(target)
		


#### Registrar movimiento manual
func _input(event):
	print("muevo")
	if event.is_action_pressed("ui_right"):
		target.x = player.position.x + 32
		target.y = player.position.y
		print("muevo")
		player.move(target)
			
	if event.is_action_pressed("ui_left"):
		target.x = player.position.x - 32
		target.y = player.position.y
		print("muevo")
		player.move(target)
		
	if event.is_action_pressed("ui_up"):
		target.x = player.position.x 
		target.y = player.position.y - 32
		print("muevo")
		player.move(target)
		
	if event.is_action_pressed("ui_down"):
		target.x = player.position.x
		target.y = player.position.y + 32
		print("muevo")
		player.move(target)

	
