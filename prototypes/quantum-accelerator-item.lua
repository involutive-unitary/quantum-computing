if mods["space-age"] and mods["quality"] then
	data:extend{
		{
			type = "item",
			name = "quantum-accelerator",
			icon = data.raw["assembling-machine"]["electromagnetic-plant"].icon,
			subgroup = "quantum-special-buildings",
			place_result = "quantum-accelerator",
			stack_size = 50
		}
	}
end

