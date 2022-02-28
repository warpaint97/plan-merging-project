from merger import Merger
import funcs
import os
from files import WriteFile, ReadFile

# main program
if __name__ == "__main__":
    # init
    benchmarks = funcs.getAllBenchmarks()
    
    # initialize merger
    merger = Merger("encodings/sequential", "benchmark_data")

    def merge(benchmark_id):
        benchmark = benchmarks[benchmark_id-1]
        merger.merge(benchmark, vizualize=True, automated=False, save_data=False, deterministic_waiter=False, check_validity=False)

    def mergeAll(exclude=[22,23,25]):
        for i in range(len(benchmarks)):
            benchmark_id = i+1
            benchmark = benchmarks[i]
            if benchmark_id in exclude:
                continue
            merger.merge(benchmark, vizualize=False, save_data=False, automated=True, check_validity=True)

    #merger.vizualize(merger.getBenchmarkModel(benchmarks[22-1]))
    #mergeAll([])

    save_path = 'FinalMergingPackage/Benchmarks/{}.lp'

    #m, _ = merger.switchPlans(merger.getBenchmarkModel(benchmark))
    #m, _ = merger.wait(m)
    #merger.vizualize(m, benchmark)
    #################################################################################