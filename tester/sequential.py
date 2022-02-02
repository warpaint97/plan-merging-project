from iclingo import Clingo, Model
import funcs
import matplotlib.pyplot as plt
import numpy as np

# ENTER PATHS (with cwd ./plan-merging-project)
#################################################################################
path = "encodings/sequential/"

inputter = path + "input.lp"
plan_switcher = path + "merger_ps_rec3_big.lp"
waiter = path + "merger_w_seq.lp"
outputter = path + "output.lp"

benchmark_id = 14
benchmarks = funcs.getAllBenchmarks()
#################################################################################

def merger(bm_id):
    # init
    bm_init, bm_occurs = funcs.getBenchmarkProgram(benchmarks[bm_id - 1])
    clg = Clingo()
    time = [0,0]
    # SEQUENTIAL PLAN MERGING
    #################################################################################
    # INPUT
    #################################################################################
    # read paths
    m = clg.solve(bm_init+bm_occurs, inputter)
    time = funcs.addTimes(m, time)

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
        time = funcs.addTimes(m, time)
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
        time = funcs.addTimes(m, time)
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
    time = funcs.addTimes(m, time)

    print("FINAL STATISTICS:\nBenchmark: {}\nTotal time: {}\nGrounding time: {}\nSolving time: {}\n".format(benchmarks[bm_id-1],time[0]+time[1],time[0],time[1]))

    #check validity
    m = clg.solve(m.model, "encodings/other/validity_checker.lp")

    # load model into vizalizer
    clg.load_viz(m.model)
    #################################################################################


# main program
if __name__ == "__main__":
    merger(16)
    #for bm_id in range(len(benchmarks)):
    #    if bm_id+1 in [22,23]:
    #        continue
    #    try:
    #        merger(bm_id+1)
    #    except:
    #        pass
    