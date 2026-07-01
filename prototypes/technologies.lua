if mods["space-age"] and mods["quality"] then
	data:extend{
		{
			type = "technology",
			name = "quantum-computing",
			icon = "__base__/graphics/icons/signal/signal-radioactivity.png",
			effects = {
				{
					type = "unlock-recipe",
					recipe = "qubit"
				},
				{
					type = "unlock-recipe",
					recipe = "quantum-gate"
				},
				{
					type = "unlock-recipe",
					recipe = "quantum-channel"
				},
				{
					type = "unlock-recipe",
					recipe = "quantum-not"
				},
				{
					type = "unlock-recipe",
					recipe = "quantum-hadamard"
				},
				{
					type = "unlock-recipe",
					recipe = "quantum-control"
				},
				{
					type = "unlock-recipe",
					recipe = "quantum-phase"
				},
				{
					type = "unlock-recipe",
					recipe = "quantum-pauli-Y"
				},
				{
					type = "unlock-recipe",
					recipe = "quantum-pauli-Z"
				},
				{
					type = "unlock-recipe",
					recipe = "quantum-measure"
				},
				{
					type = "unlock-recipe",
					recipe = "quantum-delete"
				},
				{
					type = "unlock-recipe",
					recipe = "quantum-channel-noisy"
				}
			},
			prerequisites = {"quantum-processor"},
			unit = {
				count = 1000,
				ingredients = {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1},
					{"production-science-pack", 1},
					{"utility-science-pack", 1},
					{"space-science-pack", 1},
					{"metallurgic-science-pack", 1},
					{"agricultural-science-pack", 1},
					{"electromagnetic-science-pack", 1},
					{"cryogenic-science-pack", 1}
				},
				time = 60
			}
		},
		{
			type = "technology",
			name = "quantum-archaeology",
			icon = "__base__/graphics/icons/signal/signal-item-parameter.png",
			effects = {
				{
					type = "unlock-recipe",
					recipe = "quantum-accelerator"
				},
				{
					type = "unlock-recipe",
					recipe = "quantum-archaeology"
				},
				{
					type = "unlock-recipe",
					recipe = "quantum-acceleration"
				}
			},
			prerequisites = {"quantum-computing"},
			unit = {
				count = 2000,
				ingredients = {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1},
					{"production-science-pack", 1},
					{"utility-science-pack", 1},
					{"space-science-pack", 1},
					{"metallurgic-science-pack", 1},
					{"agricultural-science-pack", 1},
					{"electromagnetic-science-pack", 1},
					{"cryogenic-science-pack", 1}
				},
				time = 60
			}
		}
	}
end

