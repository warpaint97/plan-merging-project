import os
from iclingo import Clingo
import files

__author__ = "Aaron Bishop"

#paths
merger = "encodings/merger.lp"
benchmark = "benchmarks/13_time_performance"
plans = os.path.join(benchmark,"plans/full_plan.lp")
instance = os.path.join(benchmark,"instance/x20_y10_n141_r10_s10_ps0_pr10_u10_o10_N001.lp")
output = "../output.txt"

#main program
if __name__ == "__main__":
    #run clingo
    clg = Clingo()
    s, t = clg.isolve([plans,instance,merger],merger,"max_waits",lambda x: 5*(x+1), 10)
    
    #save model into output.txt
    if len(clg.models) != 0:
        files.WriteFile(output, clg.get_optimal_model())
    
        #open visualizer
        cmd = "viz -t {}".format(output)
        os.system(cmd)