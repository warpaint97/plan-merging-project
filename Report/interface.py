from planmerger.merger import Merger
import os

# use this function to run plan merging on a benchmark file and return a json file into a directory
# benchmark.lp --> save_path/benchmark.json
def merge(benchmark, save_dir):
        # initialize merger
        script_dir = os.path.dirname(os.path.realpath(__file__))
        merger = Merger(os.path.join(script_dir, 'planmerger', 'encodings'))
        merger.merge(benchmark, save_dir=save_dir)