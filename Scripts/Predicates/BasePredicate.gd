class_name Predicate

func can_play(coord) -> bool:
    if coord:
        return true
    else: 
        return GameManager.game_state != GameManager.GAME_STATE.Setup