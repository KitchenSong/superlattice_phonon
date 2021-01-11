import numpy as np
from scipy.io import FortranFile

import matplotlib.pyplot as plt
f = FortranFile('datamesh_proj.dat','r')
s = f.read_reals()

nk = 100
ne = 500
nz_sc = 4
nlay = 4*nz_sc
# in fortran, the array is a x b but in python, it is b x a

s = s.reshape(((ne,(nk)*nz_sc+1,nlay,3)))
for i in range(0,nlay,4):
    fig, ax = plt.subplots(figsize=(6,8))

    sc = ax.imshow(s[:,:,i,2],aspect='auto',origin='lower',interpolation='bilinear')
    plt.colorbar(sc)
#plt.savefig('test.png',dpi=300)
plt.show()
