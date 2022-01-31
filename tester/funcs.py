from files import WriteFile, ReadFile
import glob
import parse as parser

def getBenchmarkFiles(bm_dir,ext=".lp"):
    instance = glob.glob("{}/instance/*{}".format(bm_dir,ext))
    plans = glob.glob("{}/plans/plan_r*{}".format(bm_dir,ext))
    return instance, plans


def getBenchmarkProgram(bm_dir):
        instance, plans = getBenchmarkFiles(bm_dir)
        return "".join([ReadFile(file) for file in instance]), "".join([ReadFile(file) for file in plans])


def getAllBenchmarks(directory="benchmarks"):
    return sorted(glob.glob("{}/*/".format(directory)))


def parse(model,pattern,index):
    li = []
    for atom in model.split(" "):
        parsed = parser.parse(pattern, atom)
        li.append(int(parsed[index]))
    return li

def addTimes(m, time):
    return [(m.statistics['summary']['times']['total'] - m.statistics['summary']['times']['solve']) + time[0], m.statistics['summary']['times']['solve'] + time[1]]