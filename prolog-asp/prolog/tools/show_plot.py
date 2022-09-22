#!/usr/bin/env python3
import os
import ast
import fileinput
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
matplotlib.rcParams.update({'font.size': 22})

filepath = os.path.abspath(os.path.dirname(__file__))

for line in fileinput.input():
    f = line[:-2]

print(f)

data = ast.literal_eval(f.replace('tile', ''))

print(f"data: {data}")

a = np.zeros((4, 4))
for j, i, v in data:
    a[i-1, j-1] = v

[m,n] = np.shape(a)

fig, ax = plt.subplots()

for xcoord, ycoord, value in data:
    if value != 0:
        ax.text(xcoord-1, ycoord-1, value, va='center', ha='center')

ax.matshow(a)
plt.show()