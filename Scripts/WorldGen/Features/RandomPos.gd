extends FeatureGenerator
class_name RandomPositionFeatureGenerator

var feature_to_place : Feature


func _init(feature : Feature, amount: int):
    feature_amount = amount
    feature_to_place = feature

func generate_feature(data : Dictionary[String, Variant]):
    var left_to_place = feature_amount
    var top_left : Vector2i = data.grid_start
    var bottom_right : Vector2i = data.grid_end
    var map_data : Dictionary[Vector2i, Hex] = data.hex_data

    while left_to_place > 0:
        var x = rng.randi_range(top_left.x, bottom_right.x)
        var y = rng.randi_range(top_left.y, bottom_right.y)
        var coord = Vector2i(x, y)
        print (left_to_place)
        if map_data.has(coord):
            if is_instance_of(map_data[coord].feature, NoneFeature) and map_data[coord].biome != Hex.Biome.SEA:
                map_data[coord].feature = feature_to_place
                left_to_place -= 1
                print(coord)