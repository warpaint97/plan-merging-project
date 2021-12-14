from iclingo import Clingo
import funcs

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
    m, s, t = clg.solve(bm_program, merger)

    m = m.replace("occurs","occurs_")
    m, s, t = clg.solve(m, "encodings/merger_waiting_choice_rules_improved3.lp")

    m = m.replace("occurs","occurs_")
    m, s, t = clg.solve(m, "encodings/merger_plan_switching+wait.lp")

    m, s, t = clg.solve(m, "encodings/validity_checker.lp")

    # run clingo incrementally
    #m, s, t = clg.isolve(bm_program, merger, "max_waits", lambda x: 10*(x+1), 10)

    # load model into vizalizer
    clg.load_viz(m)
    #################################################################################