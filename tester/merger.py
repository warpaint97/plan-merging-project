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
        # read paths only and put into position/3 predicates
        model, acc_stats = self.convertToPositions(self.getBenchmarkModel(benchmark), AccumulatedStats())
        # switch plans
        model, acc_stats = self.switchPlans(model, acc_stats, small=True)
        # wait
        model, acc_stats = self.wait(model, acc_stats, deterministic=False)
        # output
        model, acc_stats = self.convertToAsprilo(model, benchmark, acc_stats)
        # save benchmark data if prefered
        self.reportBenchmarkData(benchmark, model, acc_stats, save_data)
        # vizualize if prefered
        if vizualize:
            self.vizualize(model)
        # return
        return model, acc_stats
      
     
    def convertToPositions(self, model, acc_stats=None):
        if not acc_stats:
            acc_stats = AccumulatedStats()
        # read paths only and put into position/3 predicates
        if "occurs" in model.model:
            return self.solve(model.model, self.inputter, acc_stats)
        else:
            return model, acc_stats


    def switchPlans(self, model, acc_stats=None, small=True):
        # transform occurs/3 predicate to position/3 predicates if necessary
        model, acc_stats = self.convertToPositions(model, acc_stats)
        # do small or big plan switching
        if small:
            model, acc_stats = self.fix_point_solve(model, self.plan_switcher, acc_stats)
        else:
            model, acc_stats = self.fix_point_solve(model, self.plan_switcher_big, acc_stats)
        return model, acc_stats


    def wait(self, model, acc_stats=None, deterministic=False):
        # transform occurs/3 predicate to position/3 predicates if necessary
        model, acc_stats = self.convertToPositions(model, acc_stats)
        # do deterministic or non-deterministic waiting
        if deterministic:
            model, acc_stats = self.solve(model.model, self.waiter_det, acc_stats)
        else:
            model, acc_stats = self.fix_point_solve(model, self.waiter_inc, acc_stats)
        return model, acc_stats


    def convertToAsprilo(self, model, benchmark, acc_stats=None):
        # transform occurs/3 predicate to position/3 predicates if necessary
        model, acc_stats = self.convertToPositions(model, acc_stats)
        # extract instance and plans from benchmark into seperate strings
        bm_init, bm_occurs = funcs.getBenchmarkProgram(benchmark)
        # output
        return self.solve(bm_init+model.model, self.outputter, acc_stats)


    # auxiliary methods
    def solve(self, model_string, encoding, acc_stats):
        model = self.clg.solve(model_string, encoding)
        model.model = model.model.replace("position_","position")
        acc_stats.add(model)
        return model, acc_stats


    def fix_point_solve(self, model, encoding, acc_stats):
        # set model.cost and last_cost unequal
        last_cost = []
        model.cost = [1]
        counter = 1
        while model.cost != last_cost:
            print("Fix Point Solving Iteration: {}".format(counter))
            last_cost = model.cost
            model, acc_stats = self.solve(model.model, encoding, acc_stats)
            counter += 1
            print("Cost: {}\n".format(model.cost))
        return model, acc_stats


    def vizualize(self, model, benchmark=None):
        if benchmark:
            model, _ = self.convertToAsprilo(model, benchmark)
        # open the asprilo vizualizer on the given model
        self.clg.load_viz(model.model)


    def getBenchmarkModel(self, benchmark):
        # extract instance and plans from benchmark into seperate strings
        bm_init, bm_occurs = funcs.getBenchmarkProgram(benchmark)
        return Model(bm_init+bm_occurs)

    
    def reportBenchmarkData(self, benchmark, model, acc_stats, save):
        #prepare benchmark data format
        head, tail = os.path.split(benchmark[0:-1])
        print("FINAL STATISTICS:\nBenchmark: {}\nTotal time: {}\nGrounding time: {}\nSolving time: {}\n".format(tail,acc_stats.total,acc_stats.groundingTime,acc_stats.solvingTime))
        if save:
            m_data = BMDataFormat(model, acc_stats)
            m_data.data["instance"] = tail
            m_data.save(os.path.join(self.bm_data_dir, tail +".json"))
        