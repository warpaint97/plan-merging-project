#import libraries
from iclingo import Clingo, Model
import funcs
from funcs import BMDataFormat, AccumulatedStats
import matplotlib.pyplot as plt
import numpy as np
import os
import files

# class for the final merger
class Merger:
    def __init__(self, encodings_dir, bm_data_dir=None, opts=None):
        # gather all encodings and assign them to variables
        self.inputter = os.path.join(encodings_dir, "input.lp")
        self.plan_switcher = os.path.join(encodings_dir, "merger_ps_rec3_small.lp")
        self.plan_switcher_big = os.path.join(encodings_dir, "merger_ps_rec3_big.lp")
        self.waiter_inc = os.path.join(encodings_dir, "merger_w_inc2.lp")
        self.waiter_det = os.path.join(encodings_dir, "merger_w_det2.lp")
        self.outputter = os.path.join(encodings_dir, "output.lp")

        # save benchmark data directory
        self.bm_data_dir = bm_data_dir

        # initialize the clingo class
        self.clg = Clingo()


    def merge(self, benchmark, vizualize=True, save_data=True):
        # accumulate statistics
        acc_stats = AccumulatedStats()
        # extract instance and plans from benchmark into seperate strings
        bm_init, bm_occurs = funcs.getBenchmarkProgram(benchmark)
        # read paths only and put into "position/3" predicates
        model = self.clg.solve(bm_init+bm_occurs, self.inputter)
        acc_stats.add(model)
        # switch plans
        model = self.switchPlans(model, small=True)
        acc_stats.add(model)
        # wait
        model = self.wait(model, deterministic=False)
        acc_stats.add(model)
        # output
        model = self.clg.solve(bm_init+model.model, self.outputter)
        acc_stats.add(model)
        # save benchmark data if prefered
        self.reportBenchmarkData(benchmark, model, acc_stats, save_data)
        # vizualize if prefered
        if vizualize:
            self.vizualize(model)
        # return
        return model
        

    def switchPlans(self, model, small=True):
        # do small or big plan switching
        if small:
            model = self.fix_point_solve(model, self.plan_switcher)
        else:
            model = self.fix_point_solve(model, self.plan_switcher_big)
        return model


    def wait(self, model, deterministic=False):
        # do deterministic or non-deterministic waiting
        if deterministic:
            model = self.clg.solve(model.model, self.waiter_det)
        else:
            model = self.fix_point_solve(model, self.waiter_inc)
        return model


    # auxiliary methods
    def fix_point_solve(self, model, encoding):
        # set model.cost and last_cost unequal
        last_cost = []
        model.cost = [1]
        counter = 1
        while model.cost != last_cost:
            print("Fix Point Solving Iteration: {}".format(counter))
            last_cost = model.cost
            model = self.clg.solve(model.model, encoding)
            model.model = model.model.replace("position_","position")
            counter += 1
            print("Cost: {}\n".format(model.cost))
        return model


    def vizualize(self, model):
        self.clg.load_viz(model.model)

    
    def reportBenchmarkData(self, benchmark, model, acc_stats, save):
        #prepare benchmark data format
        benchmark = benchmark[0:-1] if benchmark[-1] in ["/","\\"] else benchmark
        head, tail = os.path.split(benchmark[0:-1])
        print("FINAL STATISTICS:\nBenchmark: {}\nTotal time: {}\nGrounding time: {}\nSolving time: {}\n".format(tail,acc_stats.total,acc_stats.groundingTime,acc_stats.solvingTime))
        if save:
            m_data = BMDataFormat(model, acc_stats)
            m_data.data["instance"] = tail
            m_data.save(os.path.join(self.bm_data_dir, tail +".json"))
        