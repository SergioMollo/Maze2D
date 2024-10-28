extends AIController2D

var move = Vector2.ZERO

@onready var enemy: CharacterBody2D = $".."
@onready var agent: CharacterBody2D = $"../../Jugador"
@onready var coin: Node2D = $"../../Moneda"

func get_obs() -> Dictionary:
	var obs := [
		enemy.position.x,
		enemy.position.y,
		agent.position.x,
		agent.position.y,
	]
	return {"obs": obs}

func get_reward() -> float:	
	return reward
	
func get_action_space() -> Dictionary:
	return {
		"move_action" : {
			"size": 2, 
			"action_type": "continuous" },
		}
	
func set_action(action) -> void:	
	move.x = action["move_action"][0]
	move.y = action["move_action"][1]
	
