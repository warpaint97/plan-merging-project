def WriteFile(path, content):
    f = open(path,"w")
    f.write(content)
    f.close()

def ReadFile(path):
    f = open(path,"r")
    content = f.read()
    f.close()
    return content