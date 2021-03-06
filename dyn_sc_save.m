function kabs = dyn_sc_save(fname,dm,rdtype,sdnum,ipolar,sl,nxy,nmix)
% load the harmonic force constant
% fc has six dimensions
% fc(alpha, beta, iatm, jatm, tau_a, tau_b, tau_c)
% for example, fc(2,1,2,1,3,4,1)
% is referring to the interaction between atom # 2 in 
% lattice (0,0,0)  moving in y direction and
% atom # 1 moving in x direction in lattice site (3,4,1)

% nx, ny, nz are the dimensions of grids for the lattice
% ipolar = 1 includes the polar correction for force constant
% note that unfolding algorithm will not work for ipolar = 1
% because the long-range force constant is q dependent.
% ipolar = 0 no polar interaction

[natm,masss,pos,cell,nx,ny,nz,fc,epsilon,born] = read_fc2();

nat = size(pos,1);

nx_sc = nxy(1);
ny_sc = nxy(2);
nz_sc = sum(sl);
mass_sc = view_struct(nx_sc,ny_sc,nz_sc,sl,nmix);
natm_sc = nx_sc*ny_sc*nz_sc*nat;
pos_sc = zeros(natm_sc,3);
idx_sc2pc = zeros(natm_sc,1,'int32');

nscx = ceil(nx./nx_sc);
nscy = ceil(ny./ny_sc);
nscz = ceil(nz./nz_sc);

count = 1;
for i = 1:nx_sc
    for j = 1:ny_sc
        for k = 1:nz_sc
            for iat = 1:nat
                pos_sc(count+iat-1,:) = pos(iat,:) + [i-1,j-1,k-1]*cell;
                idx_sc2pc(count+iat-1) = iat;
    %         plot(pos_sc(count:count+1,1),pos_sc(count:count+1,2),'ko')
            %hold on
            end
            count = count + nat;
        end
    end
end

% axis('equal')
% the supercell

cell_sc_dfpt = zeros(3,3);
cell_sc_dfpt(1,:) = cell(1,:)*nx;
cell_sc_dfpt(2,:) = cell(2,:)*ny;
cell_sc_dfpt(3,:) = cell(3,:)*nz;

cell_sc = zeros(3,3);
cell_sc(1,:) = cell(1,:)*nx_sc;
cell_sc(2,:) = cell(2,:)*ny_sc;
cell_sc(3,:) = cell(3,:)*nz_sc;

% unit cell for reciprocal space
ivcell = inv(cell);
reci_cell = 2*pi*transpose(ivcell);
reci_cell_sc = 2*pi*transpose(inv(cell_sc));

%vol = dot(cell_sc_dfpt(1,:),cross(cell_sc_dfpt(2,:),cell_sc_dfpt(3,:)));
vol = dot(cell_sc(1,:),cross(cell_sc(2,:),cell_sc(3,:)));
%vol = dot(cell(1,:),cross(cell(2,:),cell(3,:)));

% unified atomic mass
uam = 1.66053906660e-27; % kg

% mass for basis
mass = 12.0107*ones(1,natm_sc); % mass
randn('seed',sdnum);
if rdtype == 1
    mass = normrnd(12.0107,dm,[1,natm_sc]); % gaussian
elseif rdtype == 2
    mass = 12.0107+2*dm*(rand(natm_sc,1)-0.5); % uniform 
else
    mass(:) = 12.0107;
end
mass3 = zeros(natm_sc*3,1);
for i = 1:natm_sc
    mass3((i-1)*3+1:(i-1)*3+3) = mass(i);
end

natm = 4;


nk = 21; % number of k points
kpoint1 = [0.0 0.0 0.0]; % k point
kpoint2 = [0.0 0.0 -1/2]; % M point
%kpoint2 = [0.0 0.0 0.0]; % Gamma point
% kpoint2 = [0.3 0.2 0.2];
% kpoint3 = [1/2.0 1/2.0 0.0]; % M point
kpoint3 = [0.0 0.0 1/2.0]; % M point
kps = zeros(nk,3);
kps_short = zeros(nk,3);
kabs = zeros(nk,1);
% point 2 to point to 1 then to point 3
for i = 1:3
   kps(1:(nk-1)/2+1,i) = linspace(kpoint2(i),kpoint1(i),(nk-1)/2+1);
end
for i = 1:(nk-1)/2+1
    kabs(i) = sqrt(dot(kps(i,:)-kpoint2,kps(i,:)-kpoint2));
end

for i = 1:3
   kps((nk-1)/2+1:nk,i) = linspace(kpoint1(i),kpoint3(i),(nk-1)/2+1);
end
for i = 1:(nk-1)/2+1
   kabs(i+(nk-1)/2) = kabs((nk-1)/2+1)+sqrt(dot(kps(i+(nk-1)/2,:)-kpoint1,kps(i+(nk-1)/2,:)-kpoint1));
end

ktemp = zeros(1,3);

for ik = 1:nk
    rmin = 1000;
    for ix1= -2:2
        for iy1= -2:2
            for iz1= -2:2
                ktemp(:) = (kps(ik,:)+[ix1 iy1 iz1])*reci_cell;
                rds = sqrt(sum(ktemp.*ktemp));
                if rds < rmin 
                    rmin = rds;
                    kps_short(ik,:) = ktemp;
                end 
            end
        end
    end 
end 


    
dynmat = zeros(nk,natm_sc*3,natm_sc*3);
dynmat_g = zeros(nk,natm_sc*3,natm_sc*3);
rcut = 60;
omega = zeros(nk,natm_sc*3);


rws = zeros(124,3);
rd = zeros(124,1);
j = 1;
for m1=-2:2
       for m2=-2:2
          for m3=-2:2
             if(m1==0 && m2 == 0 && m3 == 0)
                 continue
             end 
             for i=1:3
                rws(j,i)=cell_sc_dfpt(1,i)*m1+cell_sc_dfpt(2,i)*m2+cell_sc_dfpt(3,i)*m3;
             end 
             rd(j,1)=0.5*dot(rws(j,1:3),rws(j,1:3));
             j=j+1;
          end
       end
end

mass_proton = 1.6726219d-27;
eleVolt = 1.602176634e-19;
% Vacuum permittivity
ep0 = 8.8541878128e-12;

fc_diel = fc;

angbohr = 1.889725989;
cell_g=reci_cell_sc/angbohr ;
gmax=14.;
alpha= (2.*pi/sqrt(dot(cell_sc(1,:),cell_sc(1,:)))/angbohr)^2;
geg=gmax*4.*alpha;
cell_g_len = zeros(1,3);
for i = 1:3
    cell_g_len(i) = sqrt(dot(cell_g(i,:),cell_g(i,:)));
end
ncell_g=int32(sqrt(geg)./cell_g_len)+1;

g = zeros(1,3);
g_old = zeros(1,3);

for m1=-ncell_g(1):ncell_g(1)
  for m2=-ncell_g(2):ncell_g(2)
     for m3=-ncell_g(3):ncell_g(3)
        g(1,:) =double(m1)*cell_g(1,1:3)+...
        double(m2)*cell_g(2,1:3)+double(m3)*cell_g(3,1:3);
        geg=dot(g,epsilon*g');
        if(geg>0.0d0&&geg/alpha/4.0d0<gmax)
            exp_g=exp(-geg/alpha/4.0d0)/geg;
            for iat=1:natm_sc
               zig = g*reshape(born(idx_sc2pc(iat),1:3,1:3),3,3);
               auxi = zeros(1,3);
               for jat=1:natm_sc
                   gr=dot(g,pos_sc(jat,:)-pos_sc(iat,:));
                   zjg = (g*reshape(born(idx_sc2pc(jat),1:3,1:3),3,3));
                   auxi(1:3)=auxi(1:3)+zjg(1:3)*real(exp(-1j*gr*angbohr));
               end
               for ipol=1:3
                 idim=(iat-1)*3+ipol;
                 for jpol=1:3
                    jdim=(iat-1)*3+jpol;
                    dynmat_g(1:nk,idim,jdim)=dynmat_g(1:nk,idim,jdim)-...
                         exp_g*zig(ipol)*auxi(jpol);
                 end 
               end
            end
        end         
        g_old(1,1:3)=g(1,1:3);
        for ik=1:nk
           g(1:3)=g_old(1:3)+kps(ik,1:3)*reci_cell_sc/angbohr;
           geg=dot(g,epsilon*g');
           if (geg>0.0d0&&geg/alpha/4.0d0<gmax)
              exp_g=exp(-geg/alpha/4.0d0)/geg;

              for iat=1:natm_sc
                 zig(1:3)=g*reshape(born(idx_sc2pc(iat),1:3,1:3),3,3);
                 for jat=1:natm_sc
                    gr=dot(g,pos_sc(jat,:)-pos_sc(iat,:));
                    zjg(1:3)=g*reshape(born(idx_sc2pc(jat),1:3,1:3),3,3);
                    for ipol=1:3
                       idim=(iat-1)*3+ipol;
                       for jpol=1:3
                          jdim=(jat-1)*3+jpol;
                          dynmat_g(ik,idim,jdim)=dynmat_g(ik,idim,jdim)+...
                               exp_g*zig(ipol)*zjg(jpol)*exp(-1j*gr*angbohr);
                       end
                    end
                 end
              end
           end 
       end
     end
   end
end

dynmat_g = 8*pi*dynmat_g/vol/angbohr^3; 


for ik = 1:nk
    disp(ik/nk);
    kpoint = kps(ik,:);
    for a = -nscx:nscx % periodic
        for b = -nscy:nscy
            for c = -nscz:nscz
                    %dot(kps_short(ik,:),epsilon*kps_short(ik,:)');
                for i = 1:natm_sc
                    pos_i = pos_sc(i,:);
                    pos_i_pc = pos(idx_sc2pc(i),:);
                    %kps_short(ik,:)*reshape(born(idx_sc2pc(i),:,:),3,3);        
                    for j = 1:natm_sc
                        %kps_short(ik,:)*reshape(born(idx_sc2pc(j),:,:),3,3);
                        pos_j = pos_sc(j,:);
                        pos_j_pc = pos(idx_sc2pc(j),:);
                        total_weight = 0.0d0;

                         g = (kpoint)*reci_cell_sc;

%             for a = 0:0 % periodic
%                 for b = 0:0
%                     for c = 0:0

                        weight = 0;
                        dr = -[a b c]*cell_sc+pos_j-pos_i;
                        ixyz = (dr-(pos_j_pc-pos_i_pc))*ivcell;
                        nreq = 1;
                        jj = 0;
                        for ir = 1:124 
                            df = dot(dr,rws(ir,1:3))-rd(ir,1);
                            if df>1e-5
                                % outside of FWS
                                jj = 1;
                                continue
                            end
                            if abs(df)<1e-5
                                nreq = nreq+1;
                            end
                        end
                        aa = -int32(round(ixyz(1)));
                        bb = -int32(round(ixyz(2)));
                        cc = -int32(round(ixyz(3)));
                        if jj == 0 % within the WS supercell
                            weight = 1.0/nreq;
                        end
                        if weight>0
                             t1=mod(aa+1,nx);
                             if(t1<=0) 
                                 t1=t1+nx;
                             end
                             t2=mod(bb+1,ny);
                             if(t2<=0) 
                                 t2=t2+ny;
                             end
                             t3=mod(cc+1,nz);
                             if(t3<=0) 
                                 t3=t3+nz;
                             end
                             for m = 1:3
                                for n = 1:3
                                        dynmat(ik,(i-1)*3+m,(j-1)*3+n) = ...
                                      dynmat(ik,(i-1)*3+m,(j-1)*3+n) + ...
                                        weight*fc(m,n,idx_sc2pc(i),idx_sc2pc(j),t1,t2,t3)...                    
                                      *exp(1j*dot((dr-(pos_j-pos_i)),kpoint*reci_cell_sc));
                                    
                                        % https://journals.aps.org/prb/pdf/10.1103/PhysRevB.91.094306
                                        % nonanalytical part
                                end
                             end
                         end
                    end
                end
            end

        end
    end
    
end




for ik = 1:nk
    g(1:3)=kps_short(ik,1:3)*reci_cell_sc;
    for iat=1:natm_sc
        mi = mass_sc(iat);
        zig(1:3)=g*reshape(born(idx_sc2pc(iat),1:3,1:3),3,3);
        for jat=1:natm_sc
             mj = mass_sc(jat);
             zjg(1:3)=g*reshape(born(idx_sc2pc(jat),1:3,1:3),3,3);
             geg=dot(g,epsilon*g');
             gr=dot(g,pos_sc(jat,:)-pos_sc(iat,:));
             if (geg>0.0d0&&geg/alpha/4.0d0<gmax)
              exp_g=exp(-geg/alpha/4.0d0)/geg;
             else
                 exp_g= 0;
             end
             for ipol=1:3
                  idim=(iat-1)*3+ipol;
                  for jpol=1:3
                      jdim=(jat-1)*3+jpol;
                      dynmat(ik,idim,jdim)  = (dynmat(ik,idim,jdim)+ipolar*dynmat_g(ik,idim,jdim))/sqrt(mi*mj);
                      %dynmat(ik,idim,jdim)  = (dynmat(ik,idim,jdim)+ exp_g*zig(ipol)*zjg(jpol)*exp(1j*gr)...
                      %    *8*pi/vol/angbohr^3)/sqrt(mi*mj);
                  end
             end
        end
    end
end

% possible reciprocal lattice vectors G
G = zeros(2*nx_sc+1,2*ny_sc+1,2*nz_sc+1,3);
for i = 1:2*nx_sc+1
    for j = 1:2*ny_sc+1
        for k = 1:2*nz_sc+1
            G(i,j,k,:) = [i-nx_sc-1,j-ny_sc-1,k-nz_sc-1]*reci_cell_sc;
        end
    end
end
weightk =  zeros(2*nx_sc+1,2*ny_sc+1,2*nz_sc+1);

% e grid for spectral function
egrid = linspace(0,300,500);
spectral = zeros(2*nx_sc+1,2*ny_sc+1,2*nz_sc+1,nk,length(egrid));
kmeshx =  zeros(2*nx_sc+1,2*ny_sc+1,2*nz_sc+1,nk,length(egrid));
kmeshy =  zeros(2*nx_sc+1,2*ny_sc+1,2*nz_sc+1,nk,length(egrid));
kmeshz =  zeros(2*nx_sc+1,2*ny_sc+1,2*nz_sc+1,nk,length(egrid));
emesh =  zeros(2*nx_sc+1,2*ny_sc+1,2*nz_sc+1,nk,length(egrid));
ktemp = zeros(1,3);
sigma = 1;

for ik = 1:nk
    M = reshape(dynmat(ik,:,:),natm_sc*3,natm_sc*3)...
        *eleVolt/1.0d-20/mass_proton/(1.0d12*2.0d0*pi)^2*33.35641^2*(13.605662285137/0.529177249^2);
    M = (M+M')/2.0;
    [V,D] = eig(M);

    [d,ind] = sort(diag(D));
    D(:,:) = D(ind,ind); % eigenvalues (omega^2)
    V(:,:)  = V(:,ind); % eigenvector (complex number)
    omega(ik,:) = real(sqrt(abs(d)));
    for ib = 1:natm_sc*3
        weightk(:,:,:) = 0.0;
        for ii = 1:2*nx_sc+1
            for jj = 1:2*ny_sc+1
                for kk = 1:2*nz_sc+1
                    for ie=1:length(egrid)
                        ktemp = kps(ik,:)*reci_cell_sc + reshape(G(ii,jj,kk,:),1,3);
                        kmeshx(ii,jj,kk,ik,ie) = ktemp(1);
                        kmeshy(ii,jj,kk,ik,ie) = ktemp(2);
                        kmeshz(ii,jj,kk,ik,ie) = ktemp(3);
                        emesh(ii,jj,kk,ik,ie) = egrid(ie); 
                    end
                    weightk(ii,jj,kk) = weight_k(kps(ik,:)*reci_cell_sc,reshape(G(ii,jj,kk,:),1,3),V(:,ib),natm,nx_sc,ny_sc,nz_sc,pos_sc,pos);
                    spectral(ii,jj,kk,ik,:) = reshape(spectral(ii,jj,kk,ik,:),[],1)+ weightk(ii,jj,kk)*exp(-0.5*(omega(ik,ib)-egrid(:)).^2/sigma^2)...
                        /sigma/sqrt(2*pi);
                end
            end
        end
    end
                %     for iev = 1:3*natm_sc
%         figure
%         plotevxy(pos_sc(:,1),pos_sc(:,2),V(1:3:3*natm_sc,iev),V(2:3:3*natm_sc,iev),V(3:3:3*natm_sc,iev))
%     end
    %save( fname, 'M' );
%    p = participation(V,mass3);


end
figure
for i = 1:natm_sc*3
    plot(linspace(0,1,nk),omega(:,i),'k','LineStyle','-')
    hold on
end
ylabel('Frequency (cm^{-1})')
xlabel('k')
% ylim([0,1750])
% figure
% plot(omega(1,:),p,'ko')
% xlabel('\omega (cm^{-1})')
% ylabel('P ratio')
% xlim([0,1750])
figure
X = reshape(kmeshz(:,:,:,:,:),[],1);
Y = reshape(emesh(:,:,:,:,:),[],1);
Z = reshape(spectral(:,:,:,:,:),[],1);
scatter(X,Y,20,Z,'filled')
save('X.mat','X');
save('Y.mat','X');
save('Z.mat','X');
colorbar
xlim([-0.5*reci_cell(3,3),0.5*reci_cell(3,3)])


end