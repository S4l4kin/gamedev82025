extends Effect
class_name BurnEffect


func _ready():
    GameManager.connect("turn_start", damage)

func damage(player_name: String):
    if actor.player == player_name:
        actor.damage(1)

