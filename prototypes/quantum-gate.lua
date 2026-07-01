local quantum_gate = util.table.deepcopy(data.raw["assembling-machine"]["assembling-machine-3"])
quantum_gate.name = "quantum-gate"
quantum_gate.crafting_categories = {"quantum-computing"}
quantum_gate.minable.result = "quantum-gate"

data:extend{quantum_gate}

