import sys
import clingo
import time
import files

__author__ = "Aaron Bishop"

#clingo class
class Clingo:
    def __init__(self):
        self.logic_program = ""
        self.models = []
        
    def solve(self, files):
        #callbacks
        def on_model(m):
            self.models.append(str(m))

        self.models.clear()
        ctl = clingo.Control()
        #load files into clingo
        if len(files) > 0:
            for f in files:
                ctl.load(f)
        else:
            ctl.load("-")
        #start timer and solve
        start = time.perf_counter()
        ctl.ground([("base", [])])
        sr = ctl.solve(on_model=on_model)

        elapsed_time = time.perf_counter()-start
        print("Satisfiable") if sr.satisfiable else print("Unsatisfiable")
        print("Execution time: {} sec".format(elapsed_time))

        #return satisfiability and elapsed time
        return sr.satisfiable, elapsed_time

    def isolve(self, files, file, c_name, f, max_iter):
        start = time.perf_counter()
        #iterate max_iter times
        for i in range(max_iter):
            #current constant value
            c = f(i)
            print("Iteration {} with {}={}".format(i+1,c_name,c))
            self.set_constant(file, c_name, c)
            s, t = self.solve(files)
            #stop if satisfiable
            if s:
                print("\nTotal execution time: {} sec\n".format(time.perf_counter()-start))
                return s, t
        #no model found
        return 0
    
    def set_constant(self, file, name, value):
        lp_mod = ""
        for line in files.ReadFile(file).split("\n"):
            if "#const" in line and name in line:
                # insert value for constant
                line = line[:line.find("=")+1] + str(value) + line[line.find("."):]
            lp_mod += line+"\n"
        files.WriteFile(file, lp_mod)

    def get_optimal_model(self):
        return self.models[-1].replace(" ",". ")+"."