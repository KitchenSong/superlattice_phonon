module view_struct

contains

subroutine gen_struct

implicit none
      natm_sc = nx_sc*ny_sc*nz_sc*natm;
pos_sc = zeros(natm_sc,3);
mass_sc = zeros(natm_sc,1);
count = 1;
sl_full = zeros(4*sum(sl),1);
interfaces_loc = zeros(length(sl)+1,1);
interfaces_loc(1) = -5.55/4;
for i = 1:length(sl)
    for j = 1:sl(i)
        for k = 1:4
            if k == 2 || k == 4
                sl_full(count) = 3; % 3 means As atom
            else
                ii = mod(i-1,2)+1;
                if ii == 1 
                    sl_full(count) = 1; % 1 means Ga
                else
                    sl_full(count) = 2; % 2 means Al
                end
            end
            count = count + 1;
        end
    end
    interfaces_loc(i+1) = 5.55 * (count-2)/4 ;
end

count = 1;
for i = 1:nx_sc
    for j = 1:ny_sc
        for k = 1:nz_sc
            for iat = 1:natm
                pos_sc(count+iat-1,:) = pos(iat,:) + [i-1,j-1,k-1]*cell;
%                 if  (iat == 1 || iat == 3)
%                     if pos_sc(count+iat-1,3)/ 5.5500<1-1.0d-4
%                         mass_sc(count+iat-1) =  masss(iat); % Ga
%                     else
%                         mass_sc(count+iat-1) = 26.981539; % Al
%                     end
%                 else
%                     mass_sc(count+iat-1) = masss(iat);
%                 end
               ii = int32(round(pos_sc(count+iat-1,3)/(5.55/4)))+1;
               if int32(sl_full(ii)) == 1
                   mass_sc(count+iat-1) =  masss(1); % Ga
                   if nmix > 0
                       for iii = 1:length(interfaces_loc)
                           if abs(pos_sc(count+iat-1,3) - interfaces_loc(iii))<5.55/2*nmix
                               distz = abs(pos_sc(count+iat-1,3) - interfaces_loc(iii))/(5.55/4*(nmix-0.5));
                               if rand < 0.8*exp(-distz^2)
                                   mass_sc(count+iat-1) =  26.981539; % Al
                               end
                           end
                       end
                   end
               elseif int32(sl_full(ii)) == 2
                   mass_sc(count+iat-1) =  26.981539; % Al
                   if nmix > 0
                       for iii = 1:length(interfaces_loc)
                           if abs(pos_sc(count+iat-1,3) - interfaces_loc(iii))<5.55/2*nmix
                               distz = abs(pos_sc(count+iat-1,3) - interfaces_loc(iii))/(5.55/4*(nmix/2-0.5));
                               if rand < 0.8*exp(-distz^2)
                                   mass_sc(count+iat-1) =   masss(1); % Ga
                               end
                           end
                       end
                   end
               else
                   mass_sc(count+iat-1) =  masss(2); % As
               end              
            end
            count = count + natm;
        end
    end
end
end subroutine
end module
