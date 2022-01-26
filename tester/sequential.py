from iclingo import Clingo, Model
import funcs
import matplotlib.pyplot as plt
import numpy as np
import parse

# ENTER PATHS (with cwd ./plan-merging-project)
#################################################################################
path = "encodings/sequential/"

init_lp = path + "inits.lp"
position_lp = path + "positions.lp"
plan_switcher = path + "merger_ps_rec2.lp"
waiter = path + "merger_w_det2.lp"

benchmark_id = 14
#################################################################################

# main program
if __name__ == "__main__":
    # init
    benchmarks = funcs.getAllBenchmarks()
    bm_program = funcs.getBenchmarkProgram(benchmarks[benchmark_id - 1])
    clg = Clingo()
    #################################################################################
    # read instance
    init = clg.solve(bm_program, init_lp)
    # read paths
    m = clg.solve(bm_program, position_lp)
    #print(m.statistics['summary']['times']['total'])

    #parsing
    robots = []
    for atom in m.model.split(" "):
        parsed = parse.parse('position(robot({}),({},{}),{}).', atom)
        robots.append(int(parsed[0]))
    n_robots = max(robots)

    # switch plans
    last_cost = []
    for i in range(n_robots):
        print("Plan switching iteration number: {}/{}".format(i+1,n_robots))
        m = clg.solve(m.model, plan_switcher)
        m.model = m.model.replace("position_","position")
        #m.model = m.model.replace("final_edge_collision","edge_collision")
        print(m.cost)

        #termination criterion
        if (m.cost == last_cost):
            break
        
        last_cost = m.cost


    # waiting
    m = clg.solve(m.model, waiter)

    #check validity
    m = clg.solve(init.model+m.model, "encodings/other/validity_checker.lp")

    # load model into vizalizer
    clg.load_viz(init.model+m.model)
    #################################################################################