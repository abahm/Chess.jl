#!/usr/bin/env python

import sys

tracefile="pytrace.txt"

def pyboard_readline():
  xline = sys.stdin.readline()

  with open(tracefile, "a") as trfile:
    trfile.write(xline)
  trfile.close()

  return xline

def pyboard_writeline(mline):
  sys.stdout.write(str(mline) + '\n')
  sys.stdout.flush()
  with open(tracefile, "a") as trfile:
    trfile.write("\t"+mline+"\n")
  trfile.close()

sys.stdout.flush()
with open(tracefile, "w") as trfile:
  trfile.write("I:\tStart trace:\n")
trfile.close()


pyboard_readline()
pyboard_readline()
pyboard_writeline("\n")
pyboard_writeline("feature usermove=1\n")
pyboard_writeline("feature done=1\n")

pyboard_writeline("\n")
pyboard_readline() # new
pyboard_readline() # random
pyboard_readline() # level 40 5 0
pyboard_readline() # post
pyboard_readline() # hard
pyboard_readline() # time 30000
pyboard_readline() # otim 30000
pyboard_readline() # usermove ....

pyboard_writeline("move a7a6")

pyboard_readline() # time 29990
pyboard_readline() # otim 29851
pyboard_readline() # usermove ....

pyboard_writeline("move b7b6")

pyboard_readline() # time
pyboard_readline() # otim
pyboard_readline() # usermove ....

pyboard_writeline("move c7c6")

pyboard_readline() # time
pyboard_readline() # otim
pyboard_readline() # usermove ....

pyboard_writeline("move d7d6")

pyboard_readline() # time 30000
pyboard_readline() # otim 30000
pyboard_readline() # usermove





