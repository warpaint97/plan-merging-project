from iclingo import Clingo
import funcs
import matplotlib.pyplot as plt
import numpy as np

# ENTER PATHS (with cwd ./plan-merging-project)
#################################################################################
merger = "encodings/merger_plan_switching_greedy3.lp"
benchmark_id = 14
#################################################################################

# main program
if __name__ == "__main__":
    # init
    benchmarks = funcs.getAllBenchmarks()
    bm_program = funcs.getBenchmarkProgram(benchmarks[benchmark_id - 1])
    bm_program = bm_program.replace("occurs","occurs_")
    clg = Clingo()
    # WRITE YOUR CODE HERE
    #################################################################################
    # run clingo
    #m, s, t = clg.solve(bm_program, merger)

    #m = m.replace("occurs","occurs_")
    #m, s, t = clg.solve(m, "encodings/merger_waiting_choice_rules_improved3.lp")

    #m = m.replace("occurs","occurs_")
    #m, s, t = clg.solve(m, "encodings/merger_plan_switching+wait.lp")

    #m, s, t = clg.solve(m, "encodings/validity_checker.lp")

    # run clingo incrementally
    #m = m.replace("occurs","occurs_")
    m, s, t, ts = clg.isolve(bm_program, "encodings/merger_waiting_choice_rules_improved3.lp", "max_waits", lambda x: 1*(x+1), 50, True)
    plt.plot(list(range(len(ts))),ts)
    plt.show()

    # load model into vizalizer
    clg.load_viz(m)
    #################################################################################