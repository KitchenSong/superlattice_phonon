import numpy as np
from scipy.io import FortranFile

import matplotlib.pyplot as plt
emin = 0
emax = 520*0.02998

def readf(df):
    f = FortranFile(df,'r')
    s = f.read_reals()

    nk = 100
    ne = 500
    nz_sc = 4
    nlay = 4*nz_sc
# in fortran, the array is a x b but in python, it is b x a

    s = s.reshape(((ne,(nk)*nz_sc+1,nlay,3)))
    ii = range(0,nlay//2,4)
    sall = np.zeros((len(ii),s.shape[0]))
    
    fig, ax = plt.subplots(1,2,figsize=(6,6))
    for ct,i in enumerate(ii):


        sc = ax[ct].imshow(s[:,:,i,2],aspect='auto',origin='lower',interpolation='bilinear',vmax=0.018,cmap='jet',extent=(0,1,0,emax))

        ax[0].set_ylabel('Frequency [THz]')
        ##ax[1].plot(np.sum(s[:,:,i,2],axis=1),np.arange(s.shape[0]))
        ##ax[1].set_xlim([0,3])
        ##ax[1].set_ylim([0,s.shape[0]])
#plt.savefig('test.png',dpi=300)
        sall[ct,:] = np.sum(s[:,:,i,2],axis=1)
    
    plt.colorbar(sc)
    return sall,emax*np.arange(s.shape[0])
sall,e = readf('./perfect/datamesh_proj.dat')
sall1,e1 = readf('./si/datamesh_proj.dat')
plt.figure()
for i in range(sall.shape[0]):
    plt.plot(sall[i,:]+i*0.5,e,label=str(i),c='k')

    plt.plot(sall1[i,:]+i*0.5,e,label=str(i),c='k',ls='--')
#for i in range(sall1.shape[0]):
    #plt.plot(sall1[i,:]+i*0.5,e,label=str(i),ls='--',c='k')
#plt.legend()




plt.show()
