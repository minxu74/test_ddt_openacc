
module dptest
        type dp1
          real,pointer :: a(:)
          real,pointer :: b(:)
          real,pointer :: c(:)
          integer :: n
        end type
end module

program main
        use dptest
        type(dp1)::v1
        real, target, allocatable :: a(:)
        real, target, allocatable :: b(:)
        real, target, allocatable :: c(:)
        integer n
        integer i, j
        real sum

        n = 100

        allocate(a(n))
        allocate(b(n))
        allocate(c(n))
        v1%n = n
        v1%a => a
        v1%b => b
        v1%c => c

!$acc enter data copyin(a, b, c, v1) 

!$acc enter data attach(v1%a, v1%b, v1%c)   

!$acc serial present(v1)
!$acc loop gang vector
        do i=1,n
                v1%a(i)  = sin(real(i))   *  sin(real(i))
                v1%b(i)  = cos(real(i))   *  cos(real(i))
        end do
!$acc end serial

!$acc serial present(v1)  
!$acc loop gang vector
        do i=1,n
                v1%c(i) = v1%a(i) + v1%b(i)
        enddo
!$acc end serial

!$acc exit data detach(v1%a, v1%b, v1%c)   
!$acc exit data copyout(v1%c) delete(v1%a, v1%b) 
!$acc exit data delete(v1)
        sum = 0

        do i=1,n
                sum = sum + v1%c(i)
        end do
        DEALLOCATE (a, b, c)
        sum = sum/n

        if( sum /= 1.0) then
          Print *, "FAILED"
          print *, sum
        else
          Print *, "PASSED"
        endif

end program

