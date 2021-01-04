module dyn

contains

subroutine gen_dyn()

use util
use config
use view_struct

implicit none

integer(kind=4) :: nscx,nscy,nscz
integer(kind=4) :: i,j,counts
real(kind=8) :: kpoint1(3),kpoint2(3),kpoint3(3)
real(kind=8),allocatable :: kps(:,:)
real(kind=8),allocatable :: kabs(:)
integer(kind=4) :: nk

kpoint1 = (/0.0,0.0,0.0/)
kpoint2 = (/0.0,0.0,-0.5/)
kpoint3 = (/0.0,0.0,0.5/)

nscx = ceiling(dble(nx)/dble(nx_sc))
nscy = ceiling(dble(ny)/dble(ny_sc))
nscz = ceiling(dble(nz)/dble(nz_sc))

nk = 21 ! number of k points
allocate(kps(nk,3))
allocate(kabs(nk))
do i = 1,3
    kps(1:(nk-1)/2+1,i) = linspace(kpoint2(i),kpoint1(1),(nk-1)/2+1)    
end do

end subroutine

end module
