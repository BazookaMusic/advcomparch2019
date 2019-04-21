#!/usr/bin/env python

import sys
import numpy as np
import collections

## We need matplotlib:
## $ apt-get install python-matplotlib
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

x_Axis = []
ipc_Axis = []
mpki_Axis = []

results= collections.OrderedDict()
for outFile in sys.argv[2:]:
	fp = open(outFile)
	line = fp.readline()
	while line:
		tokens = line.split()
		if (line.startswith("Total Instructions: ")):
			total_instructions = long(tokens[2])
		elif (line.startswith("IPC:")):
			ipc = float(tokens[1])
		elif (line.startswith("  L2-Data Cache")):
			sizeLine = fp.readline()
			L2_size = sizeLine.split()[1]
			bsizeLine = fp.readline()
			L2_bsize = bsizeLine.split()[2]
			assocLine = fp.readline()
			L2_assoc = assocLine.split()[1]
		elif (line.startswith("L2-Total-Misses")):
			L2_total_misses = long(tokens[1])
			L2_miss_rate = float(tokens[2].split('%')[0])
			mpki = L2_total_misses / (total_instructions / 1000.0)
		elif (line.startswith("L2_prefetching")):
			prefetching = line.split('(')[1].replace(')','')
		

		

		line = fp.readline()


	fp.close()
	
	L2ConfigStr = '{}'.format(prefetching)
	print(L2ConfigStr)
	if L2ConfigStr in results:
		results[L2ConfigStr] = (results[L2ConfigStr][0]*ipc,results[L2ConfigStr][1]*mpki)
	else:
		results[L2ConfigStr] = (ipc,mpki)
	
print(results)
for string in results.keys():
	x_Axis.append(string)
	print(results[string])
	ipc_Axis.append(results[string][0]**0.1)
	mpki_Axis.append(results[string][1]**0.1)

mpki_Axis = [x for _,x in sorted(zip(x_Axis,mpki_Axis),key = lambda pair: pair[0]) ]
#ipc_Axis = [x for _,x in sorted(zip(x_Axis,ipc_Axis),key = lambda pair: pair[0]) ]
x_Axis.sort()


print x_Axis
print ipc_Axis


fig, ax1 = plt.subplots()
ax1.grid(True)
ax1.set_xlabel("# Lines prefetched")

xAx = np.arange(len(x_Axis))
ax1.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
ax1.set_xticklabels(x_Axis, rotation=45)
ax1.set_xlim(-0.5, len(x_Axis) - 0.5)
ax1.set_ylim(min(mpki_Axis) - 0.05 * min(mpki_Axis), max(mpki_Axis) + 0.05 * max(mpki_Axis))
ax1.set_ylabel("$MPKI$")
line1 = ax1.plot(mpki_Axis, label="MPKI", color="green",marker='o')

# ax2 = ax1.twinx()
# ax2.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
# ax2.set_xticklabels(x_Axis, rotation=45)
# ax2.set_xlim(-0.5, len(x_Axis) - 0.5)
# ax2.set_ylim(min(mpki_Axis) - 0.05 * min(mpki_Axis), max(mpki_Axis) + 0.05 * max(mpki_Axis))
# ax2.set_ylabel("$MPKI$")
# line2 = ax2.plot(mpki_Axis, label="L2D_mpki", color="green",marker='o')

lns = line1
labs = [l.get_label() for l in lns]

plt.title("Total:MPKI Geom Mean")
lgd = plt.legend(lns, labs)
lgd.draw_frame(False)
plt.savefig("pref_total"+'.png',bbox_inches="tight")
