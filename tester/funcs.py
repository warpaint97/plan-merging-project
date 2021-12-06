from files import WriteFile, ReadFile
import glob

def getBenchmarkFiles(bm_dir,ext=".lp"):
    instance = glob.glob("{}/instance/*{}".format(bm_dir,ext))
    plans = glob.glob("{}/plans/plan_r*{}".format(bm_dir,ext))
    return instance + plans


def getBenchmarkProgram(bm_dir,new_occurs="occurs_"):
        return "".join([ReadFile(file).replace("occurs",new_occurs) for file in getBenchmarkFiles(bm_dir)])


def getAllBenchmarks(directory="benchmarks"):
    return glob.glob("{}/*/".format(directory))