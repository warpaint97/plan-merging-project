from iclingo import Clingo
import funcs

# ENTER PATHS (with cwd ./plan-merging-project)
#################################################################################
merger = "encodings/merger.lp"
benchmark_id = 13
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

    # run clingo incrementally
    #m, s, t = clg.isolve(bm_program, merger, "max_waits", lambda x: 10*(x+1), 10)
    clg.load_viz(m)

    #m = m.replace("occurs","occurs_")
    #m, s, t = clg.isolve(m, merger, "max_waits", lambda x: 10*(x+1), 10)

    # load model into vizalizer
    #clg.load_viz(m)
    #################################################################################