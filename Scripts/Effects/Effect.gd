extends Node
class_name Effect

var actor : Actor:
    get:
        var parent = get_parent()
        if parent is Actor:
            return parent
        else:
            call_deferred("free")
            return null

