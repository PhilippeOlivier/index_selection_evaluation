from docplex.mp.model import Model
model = Model()
bvars = model.binary_var_list(5)
model.add_constraint(bvars[0] <= bvars[1] - 1)
model.maximize(sum(bvars))
sol = model.solve()
print(sol.get_objective_value())
