local quantum_channel = util.table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"])
quantum_channel.name = "quantum-channel"
quantum_channel.crafting_categories = {"quantum-channel"}
quantum_channel.minable.result = "quantum-channel"
quantum_channel.graphics_set.animation.layers = util.table.deepcopy(data.raw["radar"]["radar"].pictures.layers)

for j=1,2 do
	quantum_channel.graphics_set.animation.layers[j].apply_projection = nil
	quantum_channel.graphics_set.animation.layers[j].direction_count = nil
	quantum_channel.graphics_set.animation.layers[j].frame_count = 64
end

data:extend{quantum_channel}
