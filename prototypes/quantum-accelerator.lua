if mods["space-age"] and mods["quality"] then
	local quantum_accelerator = util.table.deepcopy(data.raw["assembling-machine"]["electromagnetic-plant"])
	quantum_accelerator.name = "quantum-accelerator"
	quantum_accelerator.crafting_categories = {"quantum-accelerator"}
	quantum_accelerator.minable.result = "quantum-accelerator"
	data:extend{quantum_accelerator}
end
