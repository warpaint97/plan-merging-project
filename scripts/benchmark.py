import sys, os
import clingo
import time

#paths
merger = "encodings/merger.lp"
benchmark = "benchmarks/13_time_performance"
plans = os.path.join(benchmark,"plans/full_plan.lp")
instance = os.path.join(benchmark,"instance/x20_y10_n141_r10_s10_ps0_pr10_u10_o10_N001.lp")
output = "../output.txt"

#clingo class
class Clingo:
    def __init__(self):
        self.models = []
        self.start = 0
        
    def run(self, files):
        #callbacks
        def on_model(m):
            self.models.append(str(m))
            
        def on_finish(r):
            print("Execution time: {} sec".format(time.time()-self.start))

        ctl = clingo.Control()
        if len(files) > 0:
            for f in files:
                ctl.load(f)
        else:
            ctl.load("-")
        #start timer
        self.start = time.time()
        ctl.ground([("base", [])])
        ctl.solve(on_model=on_model, on_finish=on_finish)
        
def SaveFile(path, content):
    f = open(path,"w")
    f.write(content)
    f.close()

#main program
if __name__ == "__main__":
    #run clingo
    clg = Clingo()
    clg.run([merger,plans,instance])
    
    #save model into output.txt
    if len(clg.models) != 0:
        optimal_model = clg.models[-1].replace(" ",". ")+"."
        SaveFile(output, optimal_model)
    
        #open visualizer
        cmd = "cat {} | viz".format(output)
        os.system(cmd)