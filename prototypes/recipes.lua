local quantum_computing_icon
local enable_recipes

if mods["space-age"] and mods["quality"] then
	quantum_computing_icon = "__space-age__/graphics/icons/quantum-processor.png"
	enable_recipes = false
else
	quantum_computing_icon = "__base__/graphics/icons/signal/signal-radioactivity.png"
	enable_recipes = true
end

data:extend{
	{
		type = "recipe-category",
		name = "quantum-computing"
	},
	{
		type = "recipe-category",
		name = "quantum-channel"
	},
	{
		type = "recipe-category",
		name = "quantum-accelerator"
	},
	{
		type = "item-group",
		name = "quantum-computing",
		icon = quantum_computing_icon
	},
	{
		type = "item-subgroup",
		name = "quantum-qubits",
		group = "quantum-computing"
	},
	{
		type = "item-subgroup",
		name = "quantum-gates",
		group = "quantum-computing"
	},
	{
		type = "item-subgroup",
		name = "quantum-special-buildings",
		group = "quantum-computing"
	},
	{
		type = "recipe",
		name = "quantum-not",
		categories = {"quantum-computing"},
		ingredients = {{type = "item", name = "qubit", amount = 1}},
		results = {{type = "item", name = "qubit", amount = 1}},
		icon = "__base__/graphics/icons/signal/signal_X.png",
		subgroup = "quantum-gates",
		hide_from_stats = true,
		hide_from_player_crafting = true,
		allow_decomposition = false,
		hide_from_signal_gui = true,
		auto_recycle = false,
		enabled = enable_recipes,
		order = "1"
	},
	{
		type = "recipe",
		name = "quantum-hadamard",
		categories = {"quantum-computing"},
		ingredients = {{type = "item", name = "qubit", amount = 1}},
		results = {{type = "item", name = "qubit", amount = 1}},
		icon = "__base__/graphics/icons/signal/signal_H.png",
		subgroup = "quantum-gates",
		hide_from_stats = true,
		hide_from_player_crafting = true,
		allow_decomposition = false,
		hide_from_signal_gui = true,
		auto_recycle = false,
		enabled = enable_recipes,
		order = "4"
	},
	{
		type = "recipe",
		name = "quantum-control",
		categories = {"quantum-computing"},
		ingredients = {{type = "item", name = "qubit", amount = 1}},
		results = {{type = "item", name = "qubit", amount = 1}},
		icon = "__base__/graphics/icons/signal/signal_C.png",
		subgroup = "quantum-gates",
		hide_from_stats = true,
		hide_from_player_crafting = true,
		allow_decomposition = false,
		hide_from_signal_gui = true,
		auto_recycle = false,
		enabled = enable_recipes,
		order = "6"
	},
	{
		type = "recipe",
		name = "quantum-measure",
		categories = {"quantum-computing"},
		ingredients = {{type = "item", name = "qubit", amount = 1}},
		results = {{type = "item", name = "qubit", amount = 1}},
		icon = "__base__/graphics/icons/signal/signal_M.png",
		subgroup = "quantum-gates",
		hide_from_stats = true,
		hide_from_player_crafting = true,
		allow_decomposition = false,
		hide_from_signal_gui = true,
		auto_recycle = false,
		enabled = enable_recipes,
		order = "7"
	},
	{
		type = "recipe",
		name = "quantum-delete",
		categories = {"quantum-computing"},
		ingredients = {{type = "item", name = "qubit", amount = 1}},
		results = {},
		icon = "__base__/graphics/icons/signal/signal-trash-bin.png",
		subgroup = "quantum-gates",
		hide_from_stats = true,
		hide_from_player_crafting = true,
		allow_decomposition = false,
		hide_from_signal_gui = true,
		auto_recycle = false,
		enabled = enable_recipes,
		order = "8"
	},
	{
		type = "recipe",
		name = "quantum-phase",
		categories = {"quantum-computing"},
		ingredients = {{type = "item", name = "qubit", amount = 1}},
		results = {{type = "item", name = "qubit", amount = 1}},
		icon = "__base__/graphics/icons/signal/signal_P.png",
		subgroup = "quantum-gates",
		hide_from_stats = true,
		hide_from_player_crafting = true,
		allow_decomposition = false,
		hide_from_signal_gui = true,
		auto_recycle = false,
		enabled = enable_recipes,
		order = "5"
	},
	{
		type = "recipe",
		name = "quantum-pauli-Y",
		categories = {"quantum-computing"},
		ingredients = {{type = "item", name = "qubit", amount = 1}},
		results = {{type = "item", name = "qubit", amount = 1}},
		icon = "__base__/graphics/icons/signal/signal_Y.png",
		subgroup = "quantum-gates",
		hide_from_stats = true,
		hide_from_player_crafting = true,
		allow_decomposition = false,
		hide_from_signal_gui = true,
		auto_recycle = false,
		enabled = enable_recipes,
		order = "2"
	},
	{
		type = "recipe",
		name = "quantum-pauli-Z",
		categories = {"quantum-computing"},
		ingredients = {{type = "item", name = "qubit", amount = 1}},
		results = {{type = "item", name = "qubit", amount = 1}},
		icon = "__base__/graphics/icons/signal/signal_Z.png",
		subgroup = "quantum-gates",
		hide_from_stats = true,
		hide_from_player_crafting = true,
		allow_decomposition = false,
		hide_from_signal_gui = true,
		auto_recycle = false,
		enabled = enable_recipes,
		order = "3"
	},
	{
		type = "recipe",
		name = "quantum-channel-noisy",
		categories = {"quantum-channel"},
		ingredients = {{type = "item", name = "qubit", amount = 1}},
		results = {{type = "item", name = "qubit", amount = 1}},
		icon = "__base__/graphics/icons/arrows/signal-upwards-downwards-arrow.png",
		subgroup = "quantum-special-buildings",
		hide_from_stats = true,
		hide_from_player_crafting = true,
		allow_decomposition = false,
		hide_from_signal_gui = true,
		auto_recycle = false,
		enabled = enable_recipes
	}
}

if mods["space-age"] and mods["quality"] then
	data:extend{
		{
			type = "recipe",
			name = "quantum-archaeology",
			categories = {"quantum-accelerator"},
			ingredients = {{type = "item", name = "qubit", amount = 1}},
			results = {{type = "item", name = "qubit", amount = 1}},
			icon = "__space-age__/graphics/icons/lightning.png",
			surface_conditions = {{property = "magnetic-field", min = 99, max = 99}},
			subgroup = "quantum-special-buildings",
			hide_from_stats = true,
			hide_from_player_crafting = true,
			allow_decomposition = false,
			hide_from_signal_gui = true,
			auto_recycle = false,
			enabled = false
		},
		{
			type = "recipe",
			name = "quantum-acceleration",
			categories = {"quantum-accelerator"},
			ingredients = {{type = "item", name = "automation-science-pack", amount = 200},
				       {type = "item", name = "logistic-science-pack", amount = 200},
				       {type = "item", name = "chemical-science-pack", amount = 200},
				       {type = "item", name = "military-science-pack", amount = 200},
				       {type = "item", name = "production-science-pack", amount = 200},
				       {type = "item", name = "utility-science-pack", amount = 200},
				       {type = "item", name = "space-science-pack", amount = 200},
				       {type = "item", name = "metallurgic-science-pack", amount = 200},
				       {type = "item", name = "agricultural-science-pack", amount = 200},
				       {type = "item", name = "electromagnetic-science-pack", amount = 200},
				       {type = "item", name = "cryogenic-science-pack", amount = 200},
				       {type = "item", name = "promethium-science-pack", amount = 200},
				       {type = "item", name = "qubit", amount = 1}},
			results = {{type = "item", name = "automation-science-pack", amount = 200, quality_change = 1},
				       {type = "item", name = "logistic-science-pack", amount = 200, quality_change = 1},
				       {type = "item", name = "chemical-science-pack", amount = 200, quality_change = 1},
				       {type = "item", name = "military-science-pack", amount = 200, quality_change = 1},
				       {type = "item", name = "production-science-pack", amount = 200, quality_change = 1},
				       {type = "item", name = "utility-science-pack", amount = 200, quality_change = 1},
				       {type = "item", name = "space-science-pack", amount = 200, quality_change = 1},
				       {type = "item", name = "metallurgic-science-pack", amount = 200, quality_change = 1},
				       {type = "item", name = "agricultural-science-pack", amount = 200, quality_change = 1},
				       {type = "item", name = "electromagnetic-science-pack", amount = 200, quality_change = 1},
				       {type = "item", name = "cryogenic-science-pack", amount = 200, quality_change = 1},
				       {type = "item", name = "promethium-science-pack", amount = 200, quality_change = 1},
				       {type = "item", name = "qubit", amount = 1}},
			icon = "__base__/graphics/icons/signal/signal-item-parameter.png",
			surface_conditions = {{property = "pressure", min = 1000, max = 1000}},
			auto_recycle = false,
			subgroup = "quantum-special-buildings",
			hide_from_stats = true,
			hide_from_player_crafting = true,
			allow_decomposition = false,
			hide_from_signal_gui = true,
			auto_recycle = false,
			enabled = false,
			allow_inserter_overload = false,
			overload_multiplier = 1
		},
		{
			type = "recipe",
			name = "qubit",
			categories = {"electromagnetics"},
			ingredients = {{type = "item", name = "processing-unit", amount = 1},
				       {type = "item", name = "superconductor", amount = 1},
				       {type = "item", name = "lithium-plate", amount = 1},
				       {type = "fluid", name = "fluoroketone-cold", amount = 10, ignored_by_stats = 5}},
			results = {{type = "item", name = "qubit", amount = 1},
				   {type = "fluid", name = "fluoroketone-hot", amount = 5, temperature = 180, ignored_by_stats = 5, ignored_by_productivity = 5}},
			icon = "__base__/graphics/icons/signal/signal-radioactivity.png",
			surface_conditions = {{property = "pressure", min = 1}},
			subgroup = "quantum-qubits",
			hide_from_signal_gui = true,
			auto_recycle = false,
			enabled = false
		},
		{
			type = "recipe",
			name = "quantum-gate",
			categories = {"crafting"},
			ingredients = {{type = "item", name = "quantum-processor", amount = 10},
				       {type = "item", name = "processing-unit", amount = 10},
				       {type = "item", name = "assembling-machine-3", amount = 1}},
			results = {{type = "item", name = "quantum-gate", amount = 1}},
			icon = "__base__/graphics/icons/assembling-machine-3.png",
			subgroup = "quantum-gates",
			hide_from_signal_gui = true,
			enabled = false
		},
		{
			type = "recipe",
			name = "quantum-channel",
			categories = {"crafting"},
			ingredients = {{type = "item", name = "radar", amount = 1},
				       {type = "item", name = "quantum-processor", amount = 50},
				       {type = "item", name = "processing-unit", amount = 10}},
			results = {{type = "item", name = "quantum-channel", amount = 1}},
			icon = "__base__/graphics/icons/radar.png",
			subgroup = "quantum-special-buildings",
			hide_from_signal_gui = true,
			enabled = false
		},
		{
			type = "recipe",
			name = "quantum-accelerator",
			categories = {"electromagnetics"},
			ingredients = {{type = "item", name = "electromagnetic-plant", amount = 1},
				       {type = "item", name = "quantum-processor", amount = 100},
				       {type = "item", name = "processing-unit", amount = 100},
				       {type = "item", name = "holmium-plate", amount = 50},
				       {type = "item", name = "superconductor", amount = 50}},
			results = {{type = "item", name = "quantum-accelerator", amount = 1}},
			icon = "__space-age__/graphics/icons/electromagnetic-plant.png",
			subgroup = "quantum-special-buildings",
			hide_from_signal_gui = true,
			enabled = false
		}
	}
end

