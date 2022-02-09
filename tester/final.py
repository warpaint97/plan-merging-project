from merger import Merger
import funcs

# main program
if __name__ == "__main__":
    # init
    benchmarks = funcs.getAllBenchmarks()
    
    # initialize merger
    merger = Merger("encodings/sequential", "benchmark_data")

    benchmark_id = 8
    merger.merge(benchmarks[benchmark_id-1])
    #################################################################################