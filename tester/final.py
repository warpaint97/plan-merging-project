from merger import Merger
import funcs

# main program
if __name__ == "__main__":
    # init
    benchmarks = funcs.getAllBenchmarks()
    
    # initialize merger
    merger = Merger("encodings/sequential", "benchmark_data")

    def merge(benchmark_id):
        benchmark = benchmarks[benchmark_id-1]
        merger.merge(benchmark, vizualize=True, save_data=True, small_switcher=True, deterministic_waiter=False, check_validity=True)

    def mergeAll(exclude=[22,23,25]):
        for i in range(len(benchmarks)):
            benchmark_id = i+1
            benchmark = benchmarks[i]
            if benchmark_id in exclude:
                continue
            merger.merge(benchmark, vizualize=True, save_data=True, small_switcher=True, deterministic_waiter=False)

    merge(22)

    #m, _ = merger.switchPlans(merger.getBenchmarkModel(benchmark))
    #m, _ = merger.wait(m)
    #merger.vizualize(m, benchmark)
    #################################################################################