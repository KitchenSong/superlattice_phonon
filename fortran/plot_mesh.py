import numpy as np
from scipy.io import FortranFile

import matplotlib.pyplot as plt
f = FortranFile('datamesh.dat','r')
s = f.read_reals()
fig, ax = plt.subplots(figsize=(6,8))

nk = 100
ne = 500
nz_sc = (len(s)-1)//(nk)//ne 
# in fortran, the array is a x b but in python, it is b x a
s = s.reshape(((ne,(nk)*nz_sc+1)))
ax.imshow(s,aspect='auto',origin='lower',interpolation='bilinear')
plt.savefig('test.png',dpi=300)
plt.show()
