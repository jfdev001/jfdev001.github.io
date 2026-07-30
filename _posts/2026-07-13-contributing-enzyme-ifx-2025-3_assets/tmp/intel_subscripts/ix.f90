program test
    real :: x(3), y

    x = [2,3,4]
    call selectFirst(3, x, 2, y)

    print *, y

contains

    ! subroutine selectFirst(n, x, y)
    !     integer, intent(in) :: n
    !     real, intent(in) :: x(n)
    !     real, intent(out) :: y
    !
    !     y = x(1)
    ! end subroutine
    !
    subroutine selectFirst(n, x, i, y)
        integer, intent(in) :: n
        integer, intent(in) :: i
        real, intent(in) :: x(n)
        real, intent(out) :: y

        y = x(i)
    end

end program
