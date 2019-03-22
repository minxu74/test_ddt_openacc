module precision_m
  integer, parameter :: singleP = kind (0.0)
  integer, parameter :: doubleP = kind (0.0d0)

  integer, parameter :: fp_kind = singleP
  real(fp_kind), parameter :: one = 1.0_fp_kind
end module precision_m

module dptest
  use precision_m
  integer,parameter :: N = 1000

  type aggr
     real(fp_kind), allocatable :: a(:)
     real(fp_kind), allocatable :: b(:)
     real(fp_kind), allocatable :: c(:)
     !$acc policy<in_ab> copyin(a, b)
     !$acc policy<out_c> copyout(c)
  end type aggr

contains
  subroutine showP()
    print *, 'Testing N =', N, ', REAL *', fp_kind
  end subroutine showP
end module dptest

program main
  use dptest
  type(aggr) :: ag
  integer i, errcnt

  call showP()

  allocate(ag%a(N))
  allocate(ag%b(N))
  allocate(ag%c(N))

  !$acc enter data copyin(ag<in_ab>)

  !$acc parallel loop
  do i=1, N
     ag%a(i)  = sin(real(i))   *  sin(real(i))
     ag%b(i)  = cos(real(i))   *  cos(real(i))
     ag%c(i) = 0.0
  enddo
  !$acc end parallel loop

  !$acc parallel loop present(ag)
  do i=1, N
     ag%c(i) = ag%a(i) + ag%b(i)
  enddo
  !$acc end parallel loop

  !$acc exit data copyout(ag<out_c>)

  errcnt = 0
  do i=1, N
     if(abs(ag%c(i) - one) .GT. 1.0E-06) then
        errcnt = errcnt + 1
     endif
  end do

  if(errcnt /= 0) then
     Write (*, *) "FAILED"
  else
     Write (*, *) "PASSED"
  endif

  deallocate(ag%a)
  deallocate(ag%b)
  deallocate(ag%c)
end program main


