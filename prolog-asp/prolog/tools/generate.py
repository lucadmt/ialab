#!/usr/bin/env python3

import sys
import random

"""
    Python script to generate a new configuration for the sliding-blocks puzzle.
    It is a random generation, so there aren't any guarantees
    of solutions.
    The fact that describes a tile is:
        tile(x, y, content)
"""

side = 4
fact = "tile({}, {}, {}),"
configuration = "["

# -----------------------------
output_file = '../configuration.pl'
# -----------------------------

"""
try:
    side = int(input("How many cells for side? [4]: "))
except ValueError as ve:
    side = 4
    print("Incorrect value, taking default of 4")
"""

cells = []
for i in range(1, side + 1):
    for j in range(1, side + 1):
        cells.append((i, j))

for i in range(0, side*side):
    pick = random.randint(0, len(cells)-1)
    xcoord, ycoord = cells[pick]
    cells.remove(cells[pick])
    if i == ((side*side)-1):
        configuration += f"tile({xcoord}, {ycoord}, {i})],"
    else:
        configuration += fact.format(xcoord, ycoord, i)
    
print(configuration)
