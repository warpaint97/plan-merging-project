from merger import Merger
import funcs

# main program
if __name__ == "__main__":
    # init
    benchmarks = funcs.getAllBenchmarks()
    
    # initialize merger
    merger = Merger("encodings/sequential", "benchmark_data")

    for i in range(1,len(benchmarks)):
        benchmark_id = i-1
        benchmark = benchmarks[benchmark_id]
        if i not in [22,23,25]:
            merger.merge(benchmark, vizualize=True, save_data=True)

    #m, _ = merger.switchPlans(merger.getBenchmarkModel(benchmark))
    #m, _ = merger.wait(m)
    #merger.vizualize(m, benchmark)
    #################################################################################