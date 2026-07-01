--The number of ticks the quantum gate queue is spread across
local queue_ticks = 60

local science_packs = {
	"automation-science-pack",
	"logistic-science-pack",
	"chemical-science-pack",
	"military-science-pack",
	"production-science-pack",
	"utility-science-pack",
	"space-science-pack",
	"metallurgic-science-pack",
	"agricultural-science-pack",
	"electromagnetic-science-pack",
	"cryogenic-science-pack",
	"promethium-science-pack"
}

--Avoids placing the gate in the given index
local function place_gate_in_queue(entity, index)
	if storage.queue_count + 1 == index then storage.queue_count = (storage.queue_count + 1)%queue_ticks end
	storage.gates[entity].queue_place = storage.queue_count + 1
	storage.tick_queue[storage.queue_count + 1][entity] = entity
	storage.queue_count = (storage.queue_count + 1)%queue_ticks
end

local function update_entity_circuit_networks(entity)
	local red_network = entity.get_circuit_network(defines.wire_connector_id.circuit_red)
	local red_network_id

	if red_network ~= nil then
		red_network_id = red_network.network_id
	else
		red_network_id = -1
	end

	local green_network = entity.get_circuit_network(defines.wire_connector_id.circuit_green)
	local green_network_id

	if green_network ~= nil then
		green_network_id = green_network.network_id
	else
		green_network_id = -1
	end

	if storage.network_ids[entity] and storage.network_ids[entity][1] == red_network_id and storage.network_ids[entity][2] == green_network_id then return end

	if storage.network_ids[entity] ~= nil then
		for j = 1,#(storage.network_ids[entity]) do
			if storage.networks[storage.network_ids[entity][j]] ~= nil then
				storage.networks[storage.network_ids[entity][j]][entity] = nil
				if next(storage.networks[storage.network_ids[entity][j]]) == nil then
					storage.networks[storage.network_ids[entity][j]] = nil
				end
			end
		end
	end

	if red_network_id ~= -1 and storage.networks[red_network_id] == nil then
		storage.networks[red_network_id] = {}
	end

	if green_network_id ~= -1 and storage.networks[green_network_id] == nil then
		storage.networks[green_network_id] = {}
	end

	if red_network_id ~= -1 then storage.networks[red_network_id][entity] = entity end
	if green_network_id ~= -1 then storage.networks[green_network_id][entity] = entity end

	storage.network_ids[entity] = {red_network_id, green_network_id}
end

local function built_quantum_gate(event)
	--Disable the quantum gate right as it is placed
	--This is so that the script can emulate its behavior instead of allowing the recipe to craft
	if event.entity.is_updatable then
		event.entity.disabled_by_script = true
	end
	
	--Add the gate to the list of gates
	storage.gates[event.entity] = {}

	--Add the gate to the tick queue
	place_gate_in_queue(event.entity, -1)
end

local function increment_next_group()
	storage.next_group = storage.next_group + 1

	while storage.groups[storage.next_group] ~= nil do
		storage.next_group = storage.next_group + 1
	end
end

local function increment_next_qubit()
	storage.next_qubit = storage.next_qubit + 1

	while storage.qubits[storage.next_qubit] ~= nil do
		storage.next_qubit = storage.next_qubit + 1
	end
end

local function init()
	if storage.tick_queue == nil then
		storage.tick_queue = {}
	end

	for j = 1,queue_ticks do
		if storage.tick_queue[j] == nil then
			storage.tick_queue[j] = {}
		end
	end

	if storage.gates == nil then
		storage.gates = {}
	end

	if storage.queue_count == nil then
		storage.queue_count = 0
	end

	if storage.groups == nil then
		storage.groups = {}
	end

	if storage.next_group == nil then
		storage.next_group = 0
		increment_next_group()
	end

	if storage.qubits == nil then
		storage.qubits = {}
	end

	if storage.next_qubit == nil then
		storage.next_qubit = 0
		increment_next_qubit()
	end

	if storage.networks == nil then
		storage.networks = {}
	end

	if storage.network_ids == nil then
		storage.network_ids = {}
	end

	if storage.channels == nil then
		storage.channels = {}
	end

	if storage.archaeology == nil then
		storage.archaeology = {}
	end
end

local function initialize_qubit(item_stack)
	local id = item_stack.get_tag("id")
	local next_group = storage.next_group

	if id == nil or storage.qubits[id] == nil then
		id = storage.next_qubit
		item_stack.set_tag("id", id)
		increment_next_qubit()
		storage.qubits[id] = {group = next_group, place = 1}
		local group_data = {}
		group_data.values = {[0] = {real = 1, imaginary = 0}, [1] = {real = 0, imaginary = 0}}
		group_data.size = 1
		group_data.places = {id}

		storage.groups[next_group] = group_data
		increment_next_group()
	end
end

local function complex_multiply(a, b)
	return {real = a.real*b.real - a.imaginary*b.imaginary, imaginary = a.real*b.imaginary + a.imaginary*b.real}
end

local function complex_divide(a, b)
	local norm_b_squared = b.real*b.real + b.imaginary*b.imaginary

	return {real = (a.real*b.real + a.imaginary*b.imaginary)/norm_b_squared, imaginary = (a.imaginary*b.real - a.real*b.imaginary)/norm_b_squared}
end

local function create_group_values(values, size, depth)
	if depth < size then
		for j = 0,1 do
			values[j] = {}
			create_group_values(values[j], size, depth + 1)
		end
	else
		for j = 0,1 do
			values[j] = {real = 0, imaginary = 0}
		end
	end
end

local function squared_magnitude_recursive(values, size, depth)
	if depth > size then
		return values.real*values.real + values.imaginary*values.imaginary
	else
		return squared_magnitude_recursive(values[0], size, depth + 1) + squared_magnitude_recursive(values[1], size, depth + 1)
	end
end

local function divide_values_recursive(values, size, depth, factor)
	if depth == size then
		values[0].real = values[0].real/factor
		values[0].imaginary = values[0].imaginary/factor
		values[1].real = values[1].real/factor
		values[1].imaginary = values[1].imaginary/factor
	else
		divide_values_recursive(values[0], size, depth + 1, factor)
		divide_values_recursive(values[1], size, depth + 1, factor)
	end
end

local function normalize_values(values, size)
	local squared_magnitude = squared_magnitude_recursive(values, size, 1)
	local magnitude = math.sqrt(squared_magnitude)

	divide_values_recursive(values, size, 1, magnitude)
end

local function combine_groups_recursive(next_values, size0, size1, values0, values1, depth)
	if depth > size0 + size1 then
		return complex_multiply(values0, values1)
	elseif depth > size0 and depth < size0 + size1 then
		for j = 0,1 do
			combine_groups_recursive(next_values[j], size0, size1, values0, values1[j], depth + 1)
		end
	elseif depth <= size0 then
		for j = 0,1 do
			combine_groups_recursive(next_values[j], size0, size1, values0[j], values1, depth + 1)
		end
	else
		--If we are at the final depth, then next_places[j] will be passed by value
		--So in order to change next_places[j], we must do it at the second to final depth
		local result0 = combine_groups_recursive(next_values[0], size0, size1, values0, values1[0], depth + 1)
		local result1 = combine_groups_recursive(next_values[1], size0, size1, values0, values1[1], depth + 1)

		next_values[0] = result0
		next_values[1] = result1
	end
end

local function combine_groups(group0, group1)
	local group_data0 = storage.groups[group0]
	local group_data1 = storage.groups[group1]

	local next_group_data = {size = group_data0.size + group_data1.size, values = {}, places = {}}
	local next_group_id = storage.next_group

	--Choose the next tensor positions for the qubits
	for j = 1,next_group_data.size do
		if j <= group_data0.size then
			next_group_data.places[j] = group_data0.places[j]
		else
			next_group_data.places[j] = group_data1.places[j - group_data0.size]
		end
	end

	--Update the place for each qubit in the new group
	for j = 1,next_group_data.size do
		storage.qubits[next_group_data.places[j]].place = j
		storage.qubits[next_group_data.places[j]].group = next_group_id
	end

	create_group_values(next_group_data.values, next_group_data.size, 1)
	combine_groups_recursive(next_group_data.values , group_data0.size, group_data1.size, group_data0.values, group_data1.values, 1)

	storage.groups[next_group_id] = next_group_data
	storage.groups[group0] = nil
	storage.groups[group1] = nil
	increment_next_group()
end

local function set_value(values, index, value)
	for j = 1,#index - 1 do
		values = values[index[j]]
	end

	values[index[#index]] = {real = value.real, imaginary = value.imaginary}
end

local function get_value(values, index)
	for j = 1,#index do
		values = values[index[j]]
	end

	return {real = values.real, imaginary = values.imaginary}
end

local function apply_gate_group_recursive(values, func, places, next_values, size, parameters, index, depth)
	for j = 0,1 do
		index[depth] = j
		if depth < size then
			apply_gate_group_recursive(values, func, places, next_values, size, parameters, index, depth + 1)
		else
			set_value(next_values, index, func(values, index, places, parameters))
		end
	end
end

--For applying a generic quantum gate to a group
local function apply_gate_group(group, func, places, parameters)
	local size = storage.groups[group].size
	local values = storage.groups[group].values
	local next_values = {}

	create_group_values(next_values, size, 1)
	apply_gate_group_recursive(values, func, places, next_values, size, parameters, {}, 1)
	normalize_values(next_values, size)

	storage.groups[group].values = next_values
end

local function func_Phase(values, index, places, factor)
	local output

	if index[places[1]] == 1 then
		output = complex_multiply(factor, get_value(values, index))
	else
		output = get_value(values, index)
	end

	return output
end

local function func_Pauli_Y(values, index, places, parameters)
	index[places[1]] = 1 - index[places[1]]

	local value = get_value(values, index)

	--Restore the index since tables are passed by reference
	index[places[1]] = 1 - index[places[1]]

	if index[places[1]] == 0 then
		return {real = value.imaginary, imaginary = -value.real}
	else
		return {real = -value.imaginary, imaginary = value.real}
	end
end

local function func_Pauli_Z(values, index, places, parameters)
	local value = get_value(values, index)

	if index[places[1]] == 0 then
		return value
	else
		return {real = -value.real, imaginary = -value.imaginary}
	end
end

local function func_NOT(values, index, places, parameters)
	index[places[1]] = 1 - index[places[1]]

	local output = get_value(values, index)

	--Restore the index since tables are passed by reference
	index[places[1]] = 1 - index[places[1]]

	return output
end

local function func_Hadamard(values, index, places, parameters)
	local index_at_place = index[places[1]]

	index[places[1]] = 0
	local value0 = get_value(values, index)

	index[places[1]] = 1
	local value1 = get_value(values, index)

	index[places[1]] = index_at_place

	local output = {}

	if index_at_place == 0 then
		--No need to divide by sqrt(2) since the state is normalized afterwards anyways
		output.real = value0.real + value1.real
		output.imaginary = value0.imaginary + value1.imaginary
	else
		output.real = value0.real - value1.real
		output.imaginary = value0.imaginary - value1.imaginary
	end

	return output
end

local function perform_controlled_gate(entity, inventory, func, parameters, quality_name, energy_usage)
	local item_stack = inventory.find_item_stack({name = "qubit", quality = quality_name})

	if item_stack == nil or item_stack.valid == false or item_stack.valid_for_read == false then return end

	local crafter_output = entity.get_inventory(defines.inventory.crafter_output)

	if not crafter_output.is_empty() then return end

	local network_ids = storage.network_ids[entity]
	if network_ids == nil then
		network_ids = {-1, -1}
	end

	local control_gates = {}
	local inventories = {}
	local qualities = {}
	local outputs = {}
	local item_stacks = {}
	local qubit_ids = {}
	local places = {}

	for j = 1,2 do
		if network_ids[j] ~= -1 and storage.networks[network_ids[j]] ~= nil then
			for gate, value in pairs(storage.networks[network_ids[j]]) do
				if gate.valid then
					local recipe, quality = gate.get_recipe()
					local inventory = gate.get_inventory(defines.inventory.crafter_input)
					local output_inventory = gate.get_inventory(defines.inventory.crafter_output)

					if recipe ~= nil and recipe.name == "quantum-control" then
						table.insert(control_gates, gate)
						table.insert(inventories, inventory)
						table.insert(outputs, output_inventory)
						table.insert(qualities, quality.name)
					end
				end
			end
		end
	end

	initialize_qubit(item_stack)

	for j = 1,#inventories do
		local item_stack = inventories[j].find_item_stack({name = "qubit", quality = qualities[j]})
		if item_stack == nil or item_stack.valid == false or item_stack.valid_for_read == false then return end
		if not outputs[j].is_empty() then return end
		initialize_qubit(item_stack)
		table.insert(item_stacks, item_stack)
		local qubit_id = item_stack.get_tag("id")
		table.insert(qubit_ids, qubit_id)
	end

	local id = item_stack.get_tag("id")
	local group = storage.qubits[id].group

	for j = 1,#qubit_ids do
		local other_id = qubit_ids[j]
		local other_group = storage.qubits[other_id].group
		if group ~= other_group then
			combine_groups(group, other_group)
		end

		group = storage.qubits[id].group
	end

	places = {storage.qubits[id].place}

	for j = 1,#qubit_ids do
		local other_id = qubit_ids[j]
		places[j + 1] = storage.qubits[other_id].place
	end

	local function func_controlled(values, index, places, parameters)
		local apply_func = true
		local output

		for j = 2,#places do
			if index[places[j]] == 0 then
				apply_func = false
			end
		end

		if apply_func then
			output = func(values, index, {places[1]}, parameters)
		else
			output = get_value(values, index)
		end

		return output
	end

	apply_gate_group(group, func_controlled, places, parameters)

	crafter_output.insert(item_stack)
	inventory.clear()

	for j = 1,#inventories do
		outputs[j].insert(item_stacks[j])
		inventories[j].clear()
	end

	entity.energy = entity.energy - energy_usage
	entity.products_finished = entity.products_finished + 1
end

local function projected_length_squared_recursive(values, size, place, place_value)
	if size == 0 then
		return values.real*values.real + values.imaginary*values.imaginary
	elseif place == 1 then
		return projected_length_squared_recursive(values[place_value], size - 1, place - 1, place_value)
	else
		local result0 = projected_length_squared_recursive(values[0], size - 1, place - 1, place_value)
		local result1 = projected_length_squared_recursive(values[1], size - 1, place - 1, place_value)
		return result0 + result1
	end
end

--Must be called with size > 1
local function project_recursive(values, size, place, place_value, next_values)
	if size == 2 and place == 1 then
		next_values[0] = {real = values[place_value][0].real, imaginary = values[place_value][0].imaginary}
		next_values[1] = {real = values[place_value][1].real, imaginary = values[place_value][1].imaginary}
	elseif size == 2 and place == 2 then
		next_values[0] = {real = values[0][place_value].real, imaginary = values[0][place_value].imaginary}
		next_values[1] = {real = values[1][place_value].real, imaginary = values[1][place_value].imaginary}
	elseif size == 1 then
		next_values[0] = {real = values[0].real, imaginary = values[0].imaginary}
		next_values[1] = {real = values[1].real, imaginary = values[1].imaginary}
	elseif place == 1 then
		project_recursive(values[place_value], size - 1, place - 1, place_value, next_values)
	else
		project_recursive(values[0], size - 1, place - 1, place_value, next_values[0])
		project_recursive(values[1], size - 1, place - 1, place_value, next_values[1])
	end
end

local function measure(group, place)
	local values = storage.groups[group].values
	local size = storage.groups[group].size
	local places = storage.groups[group].places

	local prob0 = projected_length_squared_recursive(values, size, place, 0)
	--prob1 = 1 - prob0
	local output
	local next_group = storage.next_group
	local next_places = {}
	
	--Roll the dice
	if math.random() > prob0 then
		output = 1
	else
		output = 0
	end

	local next_values = {}
	
	if size > 1 then
		create_group_values(next_values, size - 1, 1)
		project_recursive(values, size, place, output, next_values)
		for j = 1,size do
			if j < place then
				next_places[j] = places[j]
			elseif j > place then
				next_places[j - 1] = places[j]
				storage.qubits[next_places[j - 1]].place = j - 1
			end
		end
		normalize_values(next_values, size - 1)
		storage.groups[group].values = next_values
		storage.groups[group].places = next_places
		storage.groups[group].size = size - 1

		storage.groups[next_group] = {values = {[output] = {real = 1, imaginary = 0}, [1 - output] = {real = 0, imaginary = 0}},
					      places = {places[place]},
					      size = 1}
		storage.qubits[places[place]].group = next_group
		storage.qubits[places[place]].place = 1
		increment_next_group()
	else
		values[output] = {real = 1, imaginary = 0}
		values[1 - output] = {real = 0, imaginary = 0}
	end

	return output
end

local function perform_Measure(entity, inventory, quality_name, energy_usage)
	local item_stack = inventory.find_item_stack({name = "qubit", quality = quality_name})

	if item_stack == nil or item_stack.valid == false or item_stack.valid_for_read == false then return end

	local crafter_output = entity.get_inventory(defines.inventory.crafter_output)

	if not crafter_output.is_empty() then return end

	initialize_qubit(item_stack)

	local id = item_stack.get_tag("id")
	local group = storage.qubits[id].group
	local place = storage.qubits[id].place
	local output = 0

	output = measure(group, place)

	crafter_output.insert(item_stack)
	inventory.clear()

	local control_behavior = entity.get_control_behavior()
	if control_behavior ~= nil then
		if output == 1 then
			control_behavior.circuit_read_contents = true
		else
			control_behavior.circuit_read_contents = false
		end
		control_behavior.include_in_crafting = false
		control_behavior.circuit_read_ingredients = false
	end

	entity.energy = entity.energy - energy_usage

	entity.products_finished = entity.products_finished + 1
end

--We need a special recipe to delete qubits so that the mod does not leak memeory
local function perform_Delete(entity, inventory, quality_name, energy_usage)
	local item_stack = inventory.find_item_stack({name = "qubit", quality = quality_name})

	if item_stack == nil or item_stack.valid == false or item_stack.valid_for_read == false then return end

	initialize_qubit(item_stack)

	local id = item_stack.get_tag("id")
	local group = storage.qubits[id].group
	local place = storage.qubits[id].place
	local output = 0

	--After measurement, the qubit belongs to its own group, which can be deleted
	output = measure(group, place)

	group = storage.qubits[id].group
	storage.qubits[id] = nil
	storage.groups[group] = nil

	inventory.clear()

	entity.energy = entity.energy - energy_usage

	entity.products_finished = entity.products_finished + 1
end

local function perform_quantum_channel(entity, inventory, quality_name, energy_usage)
	local entity2 = nil
	local channel_id = entity.get_signal({type = "virtual", name = "signal-C"}, defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green)

	local output = entity.get_inventory(defines.inventory.crafter_output)
	if not output.is_empty() then return end

	if storage.channels == nil then storage.channels = {} end
	if storage.gates[entity].channel ~= nil then
		storage.channels[storage.gates[entity].channel][entity] = nil
		if next(storage.channels[storage.gates[entity].channel]) == nil then
			storage.channels[storage.gates[entity].channel] = nil
		end
	end
	if storage.channels[channel_id] == nil then storage.channels[channel_id] = {} end
	storage.gates[entity].channel = channel_id
	storage.channels[channel_id][entity] = entity

	for other, value in pairs(storage.channels[channel_id]) do
		if other ~= entity then
			entity2 = other
			break
		end
	end

	if entity2 == nil then return end

	local recipe2, quality2 = entity2.get_recipe()
	local inventory2 = entity2.get_inventory(defines.inventory.crafter_input)
	local control_behavior2 = entity2.get_control_behavior()
	local output2 = entity2.get_inventory(defines.inventory.crafter_output)

	if control_behavior2 and control_behavior2.disabled then return end

	local energy_usage2 = entity2.prototype.get_max_energy_usage(quality2.name)/2

	if entity2.energy < energy_usage2 then return end

	if not output2.is_empty() then return end

	local item_stack2 = inventory2.find_item_stack({name = "qubit", quality = quality2.name})

	if recipe2 == nil or recipe2.name ~= "quantum-channel-noisy" or item_stack2 == nil then return end

	local item_stack = inventory.find_item_stack({name = "qubit", quality = quality_name})

	if item_stack == nil or item_stack.valid == false or item_stack.valid_for_read == false then return end
	if item_stack2.valid == false or item_stack2.valid_for_read == false then return end

	initialize_qubit(item_stack)
	initialize_qubit(item_stack2)

	local id = item_stack.get_tag("id")
	local id2 = item_stack2.get_tag("id")

	--Exchange the qubits
	item_stack.set_tag("id", id2)
	item_stack2.set_tag("id", id)

	--Chance each qubit passes through unscathed
	local fidelity = 0.55
	local gate_prob = (1 - fidelity)/3
	local entities = {entity, entity2}
	local inventories = {inventory, inventory2}
	local outputs = {output, output2}
	local item_stacks = {item_stack, item_stack2}
	local quality_names = {quality_name, quality2.name}
	local energy_usages = {energy_usage, energy_usage2}
	for j = 1,2 do
		local rand = math.random()
		--If the qubit gets unlucky, it gets passed through a random pauli gate
		if rand > fidelity and rand <= fidelity + gate_prob then
			perform_controlled_gate(entities[j], inventories[j], func_NOT, nil, quality_names[j], 0)
		elseif rand > fidelity + gate_prob and rand <= fidelity + 2*gate_prob then
			perform_controlled_gate(entities[j], inventories[j], func_Pauli_Y, nil, quality_names[j], 0)
		elseif rand > fidelity + 2*gate_prob then
			perform_controlled_gate(entities[j], inventories[j], func_Pauli_Z, nil, quality_names[j], 0)
		--If the qubit gets lucky, it passes directly through the output
		else
			outputs[j].insert(item_stacks[j])
			inventories[j].clear()
			entities[j].products_finished = entities[j].products_finished + 1
		end
		entities[j].energy = entities[j].energy - energy_usage
	end
end

local function get_random_complex(norm)
	local angle = 2*math.pi*math.random()

	return {real = math.cos(angle)*norm, imaginary = math.sin(angle)*norm}
end

local function perform_quantum_archaeology(entity, inventory, quality_name, energy_usage)
	local output = entity.get_inventory(defines.inventory.crafter_output)
	if not output.is_empty() then return end

	local item_stack = inventory.find_item_stack({name = "qubit", quality = quality_name})

	if item_stack == nil or item_stack.valid == false or item_stack.valid_for_read == false then return end

	initialize_qubit(item_stack)

	local signal_N = entity.get_signal({type = "virtual", name = "signal-N"}, defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green)

	if storage.archaeology == nil then storage.archaeology = {} end
	if storage.archaeology[signal_N] then return end

	local id = item_stack.get_tag("id")
	local group = storage.qubits[id].group
	local place = storage.qubits[id].place

	measure(group, place)

	group = storage.qubits[id].group

	local rand_angle = 2*math.pi*math.random()
	local norm0 = math.cos(rand_angle)
	local norm1 = math.sin(rand_angle)

	local value0 = get_random_complex(norm0)
	local value1 = get_random_complex(norm1)

	storage.archaeology[signal_N] = {[0] = value0, [1] = value1}
	storage.groups[group].values[0] = {real = value0.real, imaginary = value0.imaginary}
	storage.groups[group].values[1] = {real = value1.real, imaginary = value1.imaginary}

	output.insert(item_stack)
	inventory.clear()

	entity.energy = entity.energy - energy_usage

	entity.products_finished = entity.products_finished + 1
end

--Compare single qubit states up to global phase
local function states_equal(a0, a1, b0, b1)
	a0_norm_squared = a0.real*a0.real + a0.imaginary*a0.imaginary
	a1_norm_squared = a1.real*a1.real + a1.imaginary*a1.imaginary

	if a0_norm_squared > a1_norm_squared then
		local phase = complex_divide(b0, a0)
		local c = complex_multiply(a1, phase)

		local dist = (b1.real - c.real)*(b1.real - c.real) + (b1.imaginary - c.imaginary)*(b1.imaginary - c.imaginary)

		return dist < 0.0001
	else
		local phase = complex_divide(b1, a1)
		local c = complex_multiply(a0, phase)

		local dist = (b0.real - c.real)*(b0.real - c.real) + (b0.imaginary - c.imaginary)*(b0.imaginary - c.imaginary)

		return dist < 0.0001
	end
end

local function perform_quantum_acceleration(entity, inventory, quality_name, energy_usage)
	local output = entity.get_inventory(defines.inventory.crafter_output)
	if not output.is_empty() then return end

	local recipe, quality = entity.get_recipe()

	if quality_name == "legendary" then return end

	local qubit_item_stack = inventory.find_item_stack({name = "qubit", quality = quality_name})

	if qubit_item_stack == nil or qubit_item_stack.valid == false or qubit_item_stack.valid_for_read == false then return end

	local science_pack_item_stacks = {}
	for j,science_pack in ipairs(science_packs) do
		science_pack_item_stacks[science_pack] = inventory.find_item_stack({name = science_pack, quality = quality_name})
		if science_pack_item_stacks[science_pack] ~= nil then
			if science_pack_item_stacks[science_pack].valid == false or
			   science_pack_item_stacks[science_pack].valid_for_read == false then
				return
			end
		end
	end

	initialize_qubit(qubit_item_stack)

	local failed = false

	local id = qubit_item_stack.get_tag("id")
	local group = storage.qubits[id].group
	local place = storage.qubits[id].place

	local value0
	local value1

	if storage.groups[group].size ~= 1 then
		failed = true
	else
		value0 = storage.groups[group].values[0]
		value1 = storage.groups[group].values[1]
	end

	local signal_N = entity.get_signal({type = "virtual", name = "signal-N"}, defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green)

	if storage.archaeology == nil then storage.archaeology = {} end

	if storage.archaeology[signal_N] == nil then
		failed = true
	elseif not failed then
		failed = not states_equal(value0, value1, storage.archaeology[signal_N][0], storage.archaeology[signal_N][1])
	end

	measure(group, place)

	storage.archaeology[signal_N] = nil

	if not failed then
		for j,science_pack in ipairs(science_packs) do
			if science_pack_item_stacks[science_pack] then
				local count = science_pack_item_stacks[science_pack].count
				local spoil_percent = science_pack_item_stacks[science_pack].spoil_percent

				items = {name = science_pack, count = count, quality = quality.next.name, spoil_percent = spoil_percent}
				if output.can_insert(items) then
					output.insert(items)
				end
			end
		end

		output.insert(qubit_item_stack)

		inventory.clear()
	else
		output.insert(qubit_item_stack)

		inventory.clear()
	end

	entity.energy = entity.energy - energy_usage

	entity.products_finished = entity.products_finished + 1
end

local function update_gate(entity)
	local recipe, quality = entity.get_recipe()
	local inventory = entity.get_inventory(defines.inventory.crafter_input)
	local control_behavior = entity.get_control_behavior()

	if control_behavior and control_behavior.disabled then return end

	if recipe == nil or inventory.find_item_stack({name = "qubit", quality = quality.name}) == nil then 
		return
	end

	local energy_usage = entity.prototype.get_max_energy_usage(quality.name)/2

	if entity.energy < energy_usage then return end

	if recipe.name == "quantum-not" then
		perform_controlled_gate(entity, inventory, func_NOT, nil, quality.name, energy_usage)
	elseif recipe.name == "quantum-hadamard" then
		perform_controlled_gate(entity, inventory, func_Hadamard, nil, quality.name, energy_usage)
	elseif recipe.name == "quantum-measure" then
		perform_Measure(entity, inventory, quality.name, energy_usage)
	elseif recipe.name == "quantum-delete" then
		perform_Delete(entity, inventory, quality.name, energy_usage)
	elseif recipe.name == "quantum-phase" then
		local signal_P = entity.get_signal({type = "virtual", name = "signal-P"}, defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green)
		local signal_K = entity.get_signal({type = "virtual", name = "signal-K"}, defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green)
		local radians
		if signal_P ~= 0 or (signal_P == 0 and signal_K == 0) then
			--If an angle is not given, then default to 90 degrees (multiplication by i)
			if signal_P == 0 then signal_P = 90 end
			radians = signal_P*math.pi/180
		else
			radians = 2*math.pi/signal_K
		end
		local factor = {real = math.cos(radians), imaginary = math.sin(radians)}
		perform_controlled_gate(entity, inventory, func_Phase, factor, quality.name, energy_usage)
	elseif recipe.name == "quantum-pauli-Y" then
		perform_controlled_gate(entity, inventory, func_Pauli_Y, nil, quality.name, energy_usage)
	elseif recipe.name == "quantum-pauli-Z" then
		perform_controlled_gate(entity, inventory, func_Pauli_Z, nil, quality.name, energy_usage)
	elseif recipe.name == "quantum-channel-noisy" then
		perform_quantum_channel(entity, inventory, quality.name, energy_usage)
	elseif recipe.name == "quantum-archaeology" then
		perform_quantum_archaeology(entity, inventory, quality.name, energy_usage)
	elseif recipe.name == "quantum-acceleration" then
		perform_quantum_acceleration(entity, inventory, quality.name, energy_usage)
	end
end

local function tick(event)
	local index = event.tick%queue_ticks + 1

	for entity, value in pairs(storage.tick_queue[index]) do
		if entity.valid then
			--Update which circuit networks this quantum gate is connected to
			if entity.name == "quantum-gate" then update_entity_circuit_networks(entity) end

			--Remove the gate from the tick queue
			storage.tick_queue[index][entity] = nil

			update_gate(entity)

			--Add the gate back to the tick queue
			--Removing and then adding keeps the tick queue evenly distributed
			--Pass index since placing a gate in that spot will mess with the current for loop
			place_gate_in_queue(entity, index)
		else
			if storage.network_ids[entity] then
				local red_network_id = storage.network_ids[entity][1]
				local green_network_id = storage.network_ids[entity][2]

				if red_network_id ~= -1 then
					storage.networks[red_network_id][entity] = nil
					if next(storage.networks[red_network_id]) == nil then
						storage.networks[red_network_id] = nil
					end
				end

				if green_network_id ~= -1 then
					storage.networks[green_network_id][entity] = nil
					if next(storage.networks[green_network_id]) == nil then
						storage.networks[green_network_id] = nil
					end
				end

				storage.network_ids[entity] = nil
			end

			if storage.gates[entity].channel then
				storage.channels[storage.gates[entity].channel][entity] = nil
				if next(storage.channels[storage.gates[entity].channel]) == nil then
					storage.channels[storage.gates[entity].channel] = nil
				end
			end

			storage.tick_queue[index][entity] = nil
			storage.gates[entity] = nil
		end
	end
end

script.on_init(init)
script.on_configuration_changed(init)
script.on_event(defines.events.on_built_entity, built_quantum_gate, {{filter = "name", name = "quantum-gate"}, {filter = "name", name = "quantum-channel"}, {filter = "name", name = "quantum-accelerator"}})
script.on_event(defines.events.on_robot_built_entity, built_quantum_gate, {{filter = "name", name = "quantum-gate"}, {filter = "name", name = "quantum-channel"}, {filter = "name", name = "quantum-accelerator"}})
script.on_event(defines.events.on_tick, tick)

function quantum_computing_clear_memory()
	for key, value in pairs(storage) do
		if key ~= "gates" and key ~= "tick_queue" then
			storage[key] = nil
		end
	end

	init()
end

