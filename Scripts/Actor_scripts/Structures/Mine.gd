extends Structure

var generating_resource : GlobalEnums.COST_COLORS

func setup_renderer():
	print("SETUP MINER RENDERER")
	renderer.add_mask(Color.WHITE, color)
	renderer.add_mask(Color.WHITE, GameManager.card_manager.get_resource_color(generating_resource))
	renderer.set_numeric_label_color(color)
	renderer.call_deferred("render_amount", health)


func on_play():
	var hex = GameManager.board_manager.get_hex(x, y)
	if hex.feature is OreFeature:
		generating_resource = hex.feature.color
		hex.feature = null
	print("Mine Placed on X:%s, Y:%s"%[x, y])

func on_turn_start():
	GameManager.player.add_resource(generating_resource, true, 1)