import numpy as np
from scipy.io import FortranFile
f = FortranFile('spectral.dat','r')
s = f.read_reals()
f = FortranFile('emesh.dat','r')
e = f.read_reals()
f = FortranFile('kmeshz.dat','r')
k = f.read_reals()
import matplotlib.pyplot as plt


fig, ax = plt.subplots(figsize=(6,8))
sc= ax.scatter(k,e,c=s,s=1,edgecolor='none')
plt.colorbar(sc)
plt.xlim([-np.pi/5.55,np.pi/5.55])
#from scipy.interpolate import griddata
#xi,yi = np.mgrid[-np.pi/5.55:np.pi/5.55:500j,0:300:500j]
#zi = griddata((k,e),s,(xi,yi),method='nearest')
#ax.imshow(zi,aspect='auto')

plt.show()
