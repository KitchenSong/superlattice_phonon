import numpy as np
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401 unused import

import matplotlib.pyplot as plt

f = open('pos_sc.dat','r')
lines = f.readlines()
pos = np.zeros((len(lines),3))
mass = np.zeros((len(lines),))
for i in range(len(lines)):
    for j in range(3):
        pos[i,j] = float(lines[i].split()[j])
    mass[i] = float(lines[i].split()[3])
fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
ax.scatter(pos[:,0], pos[:,1], pos[:,2], s=30,c=mass)
X = pos[:,0]
Y = pos[:,1]
Z = pos[:,2]
max_range = np.array([X.max()-X.min(), Y.max()-Y.min(), Z.max()-Z.min()]).max() / 2.0

mid_x = (X.max()+X.min()) * 0.5
mid_y = (Y.max()+Y.min()) * 0.5
mid_z = (Z.max()+Z.min()) * 0.5
ax.set_xlim(mid_x - max_range, mid_x + max_range)
ax.set_ylim(mid_y - max_range, mid_y + max_range)
ax.set_zlim(mid_z - max_range, mid_z + max_range)
plt.show()
