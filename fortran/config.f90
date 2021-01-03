module config

implicit none

integer(kind=4) :: natm,ntype,ibrav
real(kind=8)    :: celldm(6)
real(kind=8),allocatable :: masss(:),pos(:,:)
real(kind=8) :: cell(3,3),cell_sc_dfpt(3,3)
integer(kind=4) :: nx,ny,nz
real(kind=8),allocatable ::fc(:,:,:,:,:,:,:)
real(kind=8) :: epsil(3,3)
real(kind=8),allocatable :: born(:,:,:)
character(len=30) :: filename_input
real(kind=8)      :: sigma ! width for delta function in cm-1
real(kind=8)      :: az ! the period length in z direction

namelist /configlist/sigma,filename_input,az
contains
    
subroutine load_configure()

use util
    
implicit none

integer(kind=4) :: i,j,itemp,jtemp,alpha,beta,iatm,jatm
integer(kind=4) :: idx,jdx,kdx
character(len=30) :: label
real(kind=8)   :: vol,fctemp

open(1,file="config",status="old")
read(1,nml=configlist)
close(1)
open(23,file=trim(adjustl(filename_input)),status='old',action='read')
read(23,*) ntype,natm,ibrav,celldm
do i = 1,3
    read(23,*) cell(i,:)
end do
! number of orbitals

allocate(masss(ntype))
allocate(pos(natm,3))
masss(:) = 0.0d0

do i = 1,ntype
    read(23,*) itemp, label, vol 
    masss(i) = ele_mass(label)
end do
do i = 1,natm
    read(23,*) itemp,jtemp, pos(i,:)
end do
pos(:,:) = pos(:,:) * celldm(1) * bohr2ang
cell(:,:) = cell(:,:) * celldm(1) * bohr2ang
read(23,*) label
allocate(born(natm,3,3))
if (trim(adjustl(label)) .eq. 'T') then
    do i = 1,3
        read(23,*) epsil(i,:)
    end do
    do i = 1,natm
        read(23,*) itemp
        do j = 1,3
            read(23,*) born(itemp,j,:)
        end do
    end do
end if
read(23,*) nx,ny,nz
cell_sc_dfpt(1,:) = nx*cell(1,:)
cell_sc_dfpt(2,:) = ny*cell(2,:)
cell_sc_dfpt(3,:) = nz*cell(3,:)
allocate(fc(3,3,natm,natm,nx,ny,nz))
do i = 1, (natm*3)**2
    read(23,*) alpha,beta,iatm,jatm
    do j = 1,nx*ny*nz
        read(23,*) idx,jdx,kdx,fctemp
        fc(alpha,beta,iatm,jatm,idx,jdx,kdx) = fctemp
    end do
end do
close(23)
! acoustic sum rule
do i = 1,3
    do j = 1,3
        do idx = 1,natm
            fc(i,j,idx,idx,1,1,1) = -sum(fc(i,j,idx,:,:,:,:))&
            +fc(i,j,idx,idx,1,1,1)
        end do
    end do
end do



end subroutine

function ele_mass(ele) result(m)

implicit none

character(len=30),intent(in) :: ele
real(kind=8)    :: m

if (trim(adjustl(ele)) .eq. 'Si') then
    m = 28.0855
else if (trim(adjustl(ele)) .eq. 'Ga') then
    m = 69.723
else if (trim(adjustl(ele)) .eq. 'As') then
    m = 74.921595
end if

end function ele_mass



end module
