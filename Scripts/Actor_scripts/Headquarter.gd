extends Structure
class_name HQ

func get_actions() -> Dictionary[String, Dictionary]:
	return {"Activate" = {"callable" = print.bind("HQ activated"), "active" = true}}