#!/usr/bin/env python

import sys
import numpy as np

## We need matplotlib:
## $ apt-get install python-matplotlib
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt



def make_plot(x_Axis,ipc_Axis,mpki_Axis,settings):
    print(len(x_Axis))
    fig, ax1 = plt.subplots()
    ax1.grid(True)
    ax1.set_xlabel(settings['x_label'])

    xAx = np.arange(len(x_Axis))
    ax1.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
    ax1.set_xticklabels(["{:.2e}".format(long(val)) for val in x_Axis], rotation=45)
    ax1.set_xlim(-0.5, len(x_Axis) - 0.5)
    ax1.set_ylim(min(ipc_Axis) - 0.05 * min(ipc_Axis), max(ipc_Axis) + 0.05 * max(ipc_Axis))
    ax1.set_ylabel(settings['y_label_ax1'])
    ax1.xaxis.set_major_locator(plt.MaxNLocator(20))
    ax1.yaxis.set_major_locator(plt.MaxNLocator(20))
    line1 = ax1.plot(ipc_Axis, label=settings['line1_label'], color="red",marker='x')

    ax2 = ax1.twinx()
    ax2.xaxis.set_ticks(np.arange(0, len(x_Axis), 1))
    ax2.set_xticklabels(["{:.2e}".format(long(val)) for val in x_Axis], rotation=45)
    ax2.set_xlim(-0.5, len(x_Axis) - 0.5)
    ax2.set_ylim(min(mpki_Axis) - 0.05 * min(mpki_Axis), max(mpki_Axis) + 0.05 * max(mpki_Axis))
    ax2.set_ylabel(settings['y_label_ax2'])
    ax2.xaxis.set_major_locator(plt.MaxNLocator(20))
    ax2.yaxis.set_major_locator(plt.MaxNLocator(20))

    line2 = ax2.plot(mpki_Axis, label=settings['line2_label'], color="green",marker='o')

    lns = line1 + line2
    labs = [l.get_label() for l in lns]

    plt.title(settings['title'])
    lgd = plt.legend(lns, labs)
    lgd.draw_frame(False)
    metric = '_' + settings['line2_label'].split('_')[0]

    plt.savefig(sys.argv[1]+ metric + '.png',bbox_inches="tight")



x_Axis = []
ipc_Axis = []
mpki_Axis = [[],[],[]] #tlb,l1,l2

curr_instructions = 0

if __name__ == "__main__":
    try:
        with open(sys.argv[2],'r') as log:
            for line in log:
                tokens = line.split()
                if "instructions" in line.lower():
                    tokens = line.split(':')
                    curr_instructions += long(tokens[1])
                elif (line.startswith("IPC:")):
                    ipc = float(tokens[1])
                    ipc_Axis.append(ipc)
                elif (line.startswith("Tlb-Total-Misses:")):
                    tlb_total_misses = long(tokens[1])
                    tlb_miss_rate = float(tokens[2].split('%')[0])
                    mpki_tlb = tlb_total_misses / (curr_instructions / 1000.0)
                    mpki_Axis[0].append(mpki_tlb)
                elif (line.startswith("L1-Total-Misses")):
                    l1_total_misses = long(tokens[1])
                    l1_miss_rate = float(tokens[2].split('%')[0])
                    mpki_l1 = l1_total_misses / (curr_instructions / 1000.0)
                    mpki_Axis[1].append(mpki_l1)
                elif (line.startswith("L2-Total-Misses")):
                    l2_total_misses = long(tokens[1])
                    l2_miss_rate = float(tokens[2].split('%')[0])
                    mpki_l2 = l2_total_misses / (curr_instructions / 1000.0)
                    mpki_Axis[2].append(mpki_l2)
                    x_Axis.append(str(curr_instructions))

                
    except Exception as e:
        print(e)



    settings = {
    "x_label": "Instructions executed", 
    "y_label_ax1": "$IPC$",
    "y_label_ax2": "$MPKI$",
    "line1_label": "ipc",
    "line2_label": "tlb_mpki",
    "title": "IPC vs MPKI"
    }
    make_plot(x_Axis,ipc_Axis,mpki_Axis[0],settings)

    settings['line2_label'] = "l1_mpki"
    make_plot(x_Axis,ipc_Axis,mpki_Axis[1],settings)


    settings['line2_label'] = "l2_mpki"
    make_plot(x_Axis,ipc_Axis,mpki_Axis[2],settings)  

