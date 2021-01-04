module util

implicit none

real(kind=8),parameter  :: pi=3.141592653589793238d0
real(kind=8),parameter  :: angbohr = 1.889725989d0
real(kind=8),parameter  :: bohr2ang = 0.529177d0 
real(kind=8),parameter  :: mass_proton = 1.6726219d-27
real(kind=8),parameter  :: eleVolt = 1.602176634d-19
complex(kind=8),parameter :: i_imag=cmplx(0,1,kind=8)
contains

function linspace(k1,k2,nk) result(k)

real(kind=8) :: k1,k2
integer(kind=4) :: nk
integer(kind=4) :: i
real(kind=8),allocatable :: k(:)

allocate(k(nk))
do i = 1,nk
    k(i) = dble(i-1)/dble(nk-1)*(k2-k1) + k1 
end do

end function


end module

