program test_enzyme
    USE enzyme, ONLY: enzyme_autodiff
    IMPLICIT NONE
    real :: x, dx

    ! Test without an activity descriptor
    x = 3
    dx = 0
    CALL enzyme_autodiff(square, x, dx)
    WRITE(*,*) "dx: ", dx
    IF (ABS(dx - 6.0) < 1.0e-6) THEN ! x**2 --> 2x 
      WRITE(*,*) "Test passed!"
    ELSE
      WRITE(*,*) "Test failed!"
    END IF

CONTAINS

    REAL FUNCTION square( x )
        real, intent(in) :: x
        square = x**2
    END FUNCTION

END PROGRAM test_enzyme

