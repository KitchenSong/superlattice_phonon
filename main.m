% setup the superlattice structure here
% each atom layer has thickness of t= 1.3875 A
% The period length d will be integer number of 4t
% d = 4nt
% For example, for a superlattice of 
% GaAsGaAsGaAsGaAs|AlAsAlAs
% should be set via
% sl = [2,1]
close all

sl = [1,1]; % 1 represents 4 atoms
% in-plane unit cell dimensions
nxy = [1,1];
natom = 4;
nb = natom * 3;
nq = 91;
fid = fopen('GaAs.freq','r');
formatSpec = '%f';

A = fscanf(fid,formatSpec);

% lines  = f.readlines()
% nl = int(np.floor(natom*3/6))
% n = len(lines)
% nq = (n-1)//(nl+1)
nl = int32(floor(natom*3/6));
data = zeros(nq,nb);
% 

count = 0;
for i =1:nq
    for k = 1:3
        count = count + 1;
    end
    for j =1:nl
        for k = 1:6
            count = count + 1;
            data(i,(j-1)*6+k) = A(count);
        end
    end
end
%     count = 0
%     for j in range(nl):
%         line = lines[1+(nl+1)*i+1+j].split()
%         for k in range(6):
%             data[i,count] = float(line[k])
%             count += 1
%cm1tThz = 0.02998;

% figure
for i = 1:1
    % fname,dm,rdtype,sdnum,nsc
      kabs =  dyn_sc_save('test',0,2,i,0,sl,nxy,0); 
end
%%  plot the results from ph.x

% for i = 1:nb
%     hold on
%     plot(linspace(0,1,91),data(:,i)) % *cm1tThz
% end