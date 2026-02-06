class_name CostUtil

static func add_costs(cost_a: Dictionary, cost_b: Dictionary) -> Dictionary:
    var new_cost = {}
    new_cost.merge(cost_a)
    new_cost.merge(cost_b)
    
    for a in cost_a.keys():
        for b in cost_b.keys():
            if a == b:
                new_cost.set(a, cost_a[a] + cost_b[b])

    return new_cost