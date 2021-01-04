import numpy as np
import matplotlib.pyplot as plt

f = open('eigen.dat','r')
lines = f.readlines()
nb = len(lines[0].split())
e = np.zeros((len(lines),nb))
for i in range(len(lines)):
    for j in range(nb):
        e[i,j] = lines[i].split()[j]
for i in range(nb):
    plt.plot(e[:,i])
plt.show()
