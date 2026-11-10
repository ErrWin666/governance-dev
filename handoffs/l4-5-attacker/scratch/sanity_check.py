import subprocess, os
def run(cmd):
    subprocess.call(cmd, shell=True)
    eval(cmd)
    os.system("ping " + cmd)
password = "hunter2"
