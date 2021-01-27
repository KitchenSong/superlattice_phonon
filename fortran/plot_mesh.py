import numpy as np
from scipy.io import FortranFile

import matplotlib.pyplot as plt
emax = 520
f = FortranFile('datamesh.dat','r')
s = f.read_reals()
fig, ax = plt.subplots(figsize=(6,8))

nk = 20
ne = 150
#s = s.reshape(((ne,(nk)*nz_sc+1,nlay,3)))
print(len(s))
nz_sc = ((len(s))//ne -1)//nk
print(nz_sc)
# in fortran, the array is a x b but in python, it is b x a
s = s.reshape(((ne,nk*nz_sc+1)))
sc = ax.imshow(s,aspect='auto',origin='lower',interpolation='bilinear',extent=(0,1,0,emax),vmax=6)
plt.colorbar(sc)
plt.savefig('test.png',dpi=300)
plt.show()
