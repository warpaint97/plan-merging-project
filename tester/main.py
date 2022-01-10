from iclingo import Clingo
import funcs
import matplotlib.pyplot as plt
import numpy as np

# ENTER PATHS (with cwd ./plan-merging-project)
#################################################################################
merger = "encodings/plan_switching/choice_rules/greedy/merger_ps_g3.lp"
benchmark_id = 18
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
    #print(m)

    #m = m.replace("occurs","occurs_")
    m, s, t = clg.solve(bm_program, "encodings/waiting/choice_rules/merger_w_cr3.lp")

    m = m.replace("occurs","occurs_")
    m, s, t = clg.solve(m, "encodings/plan_switching/other/merger_ps_g.lp")

    #m, s, t = clg.solve(m, "encodings/other/validity_checker.lp")

    # run clingo incrementally
    #m = m.replace("occurs","occurs_")
    #m, s, t, ts = clg.isolve(bm_program, "encodings/merger_waiting_choice_rules_improved3.lp", "max_waits", lambda x: 2*(x+1), 10)
    #plt.plot(list(range(len(ts))),ts)
    #plt.show()

    # load model into vizalizer
    clg.load_viz(m)
    #################################################################################