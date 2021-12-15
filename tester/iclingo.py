import sys, os
import clingo
import time
from files import ReadFile, WriteFile


#clingo class
class Clingo:
    def __init__(self):
        self.models = []
        

    def solve(self, bm_program, merger):
        #callbacks
        def on_model(m):
            self.models.append(str(m))

        self.models.clear()
        ctl = clingo.Control()
        #load files into clingo
        ctl.add("base", [], bm_program)
        ctl.load(merger)
        #start timer and solve
        start = time.perf_counter()
        ctl.ground([("base", [])])
        sr = ctl.solve(on_model=on_model)

        elapsed_time = time.perf_counter()-start
        print("Satisfiable") if sr.satisfiable else print("Unsatisfiable")
        print("Execution time: {} sec".format(elapsed_time))

        #return model, satisfiability and elapsed time
        return self.get_optimal_model(), sr.satisfiable, elapsed_time


    def isolve(self, files, merger, c_name, f, max_iter, finish=False):
        m, s, t, ts = "", None, 0, []
        start = time.perf_counter()
        #iterate max_iter times
        for i in range(max_iter):
            #current constant value
            c = f(i)
            print("Iteration {} with {}={}".format(i+1,c_name,c))
            self.set_constant(merger, c_name, c)
            m, s, t = self.solve(files, merger)
            ts.append(t)
            #stop if satisfiable
            if s and not finish:
                print("\nTotal execution time: {} sec\n".format(time.perf_counter()-start))
                return m, s, t, ts
        #no model found
        if s:
            return m, s, t, ts
        else:
            return "", None, 0, []
    

    def set_constant(self, file, name, value):
        lp_mod = ""
        for line in ReadFile(file).split("\n"):
            if "#const" in line and name in line:
                # insert value for constant
                line = line[:line.find("=")+1] + str(value) + line[line.find("."):]
            lp_mod += line+"\n"
        WriteFile(file, lp_mod)


    def get_optimal_model(self):
        if len(self.models) != 0:
            return self.models[-1].replace(" ",". ")+"."
        else:
            return None


    def load_viz(self, model, output="../output.txt"):
        #save model into output.txt
        WriteFile(output, model)
        #open visualizer
        cmd = "viz -t {}".format(output)
        os.system(cmd)