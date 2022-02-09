from iclingo import Clingo, Model
import funcs
from funcs import BMDataFormat, AccumulatedStats
import matplotlib.pyplot as plt
import numpy as np
import os
import files

# ENTER PATHS (with cwd ./plan-merging-project)
#################################################################################
path = "encodings/sequential/"
bm_data_path = "benchmark_data"

inputter = path + "input.lp"
plan_switcher = path + "merger_ps_rec3_small.lp"
waiter = path + "merger_w_inc2.lp"
outputter = path + "output.lp"

benchmark_id = 14
benchmarks = funcs.getAllBenchmarks()
#################################################################################

def merger(bm_id):
    # init
    bm_init, bm_occurs = funcs.getBenchmarkProgram(benchmarks[bm_id - 1])
    clg = Clingo()
    acc_stats = AccumulatedStats()
    # SEQUENTIAL PLAN MERGING
    #################################################################################
    # INPUT
    #################################################################################
    # read paths
    m = clg.solve(bm_init+bm_occurs, inputter)
    acc_stats.add(m)

    #################################################################################
    # PLAN SWITCHING
    #################################################################################
    #parsing
    n_robots = max(funcs.parse(m.model, 'position(robot({}),({},{}),{}).', 0))

    # switch plans iteratively
    last_cost = []
    for i in range(n_robots):
        print("Plan switching iteration number: {}/{}".format(i+1,n_robots))
        m = clg.solve(m.model, plan_switcher)
        acc_stats.add(m)
        m.model = m.model.replace("position_","position")
        print(m.cost)
        #termination criterion
        if (m.cost == last_cost):
            break
        
        last_cost = m.cost

    #################################################################################
    # WAITING
    #################################################################################
    #parsing
    max_path_len = max(funcs.parse(m.model, 'position(robot({}),({},{}),{}).', 3))

    # waiting iteratively
    last_cost = []
    for i in range(max_path_len):
        print("Waiting iteration number: {}/{}".format(i+1,max_path_len))
        m = clg.solve(m.model, waiter)
        acc_stats.add(m)
        m.model = m.model.replace("position_","position")
        print(m.cost)

        #termination criterion
        if (m.cost == last_cost):
            break
        
        last_cost = m.cost
                
    #################################################################################
    # OUTPUT
    #################################################################################
    #convert model to asprilo format for the visualizer
    m = clg.solve(bm_init+m.model, outputter)
    acc_stats.add(m)

    #prepare benchmark data format
    head, tail = os.path.split(benchmarks[bm_id-1][0:-1])
    print("FINAL STATISTICS:\nBenchmark: {}\nTotal time: {}\nGrounding time: {}\nSolving time: {}\n".format(tail,acc_stats.total,acc_stats.groundingTime,acc_stats.solvingTime))
    m_data = BMDataFormat(m, acc_stats)
    m_data.data["instance"] = tail
    m_data.save(os.path.join(bm_data_path, tail +".json"))

    #check validity
    m = clg.solve(m.model, "encodings/other/validity_checker.lp")

    # load model into vizalizer
    clg.load_viz(m.model)
    #################################################################################


# main program
if __name__ == "__main__":
    merger(23)
    #for bm_id in range(len(benchmarks)):
    #    if bm_id+1 in [22,23]:
    #        continue
    #    try:
    #        merger(bm_id+1)
    #    except:
    #        pass
    