local qubit = {
	type = "item-with-tags",
	name = "qubit",
	stack_size = 1,
	icon = "__base__/graphics/icons/signal/signal-radioactivity.png",
	subgroup = "quantum-qubits",
	flags = {"not-stackable"},
	random_tint_color = {1, 1, 1}
}

--I would like to make qubits unable to be shipped in rockets
--but I don't know the units. So I do this instead.
qubit.weight = data.raw["ammo"]["atomic-bomb"].weight

data:extend{qubit}

