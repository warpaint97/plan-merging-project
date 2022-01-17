from iclingo import Clingo
import funcs
import matplotlib.pyplot as plt
import numpy as np

# ENTER PATHS (with cwd ./plan-merging-project)
#################################################################################
benchmark_id = 14
#################################################################################

# main program
if __name__ == "__main__":
    # init
    benchmarks = funcs.getAllBenchmarks()
    bm_program = funcs.getBenchmarkProgram(benchmarks[benchmark_id - 1])
    clg = Clingo()
    #################################################################################
    # read paths
    m, s, t = clg.solve(bm_program, "encodings/sequential/input_seq.lp")
    # switch plans
    
    for i in range(4):
        m, s, t = clg.solve(m, "encodings/sequential/merger_ps_rec.lp")
        m = m.replace("position_","position")
        #m = m.replace("final_edge_collision","edge_collision")

    print(m)

    #m = m.replace("occurs","occurs_")
    #m, s, t = clg.solve(m, "encodings/plan_switching/other/merger_ps+1w.lp")
    #print(m)

    #m, s, t = clg.solve(m, "encodings/other/validity_checker.lp")

    # run clingo incrementally
    #m = m.replace("occurs","occurs_")
    #m, s, t, ts = clg.isolve(bm_program, "encodings/merger_waiting_choice_rules_improved3.lp", "max_waits", lambda x: 2*(x+1), 10)
    #plt.plot(list(range(len(ts))),ts)
    #plt.show()

    # load model into vizalizer
    #clg.load_viz(m)
    #################################################################################