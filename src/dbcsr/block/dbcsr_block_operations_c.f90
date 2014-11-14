!-----------------------------------------------------------------------------!
!   CP2K: A general program to perform molecular dynamics simulations         !
!   Copyright (C) 2000 - 2014  CP2K developers group                          !
!-----------------------------------------------------------------------------!

! *****************************************************************************
!> \brief Sets the diagonal of a square data block
!> \param[out] block_data     sets the diagonal of this data block
!> \param[in] diagonal        set diagonal of block_data to these values
!> \param[in] d               dimension of block
!> \par Off-diagonal values
!>      Other values are untouched.
! *****************************************************************************
  PURE SUBROUTINE set_block2d_diagonal_c (block_data, diagonal, d)
    INTEGER, INTENT(IN)                    :: d
    COMPLEX(kind=real_4), DIMENSION(d,d), INTENT(INOUT) :: block_data
    COMPLEX(kind=real_4), DIMENSION(d), INTENT(IN)      :: diagonal

    INTEGER                                :: i

!   ---------------------------------------------------------------------------

    FORALL (i = 1 : d)
       block_data(i,i) = diagonal(i)
    END FORALL
  END SUBROUTINE set_block2d_diagonal_c


! *****************************************************************************
!> \brief Gets the diagonal of a square data block
!> \param[in] block_data      gets the diagonal of this data block
!> \param[out] diagonal       values of the diagonal elements
!> \param[in] d               dimension of block
! *****************************************************************************
  PURE SUBROUTINE get_block2d_diagonal_c (block_data, diagonal, d)
    INTEGER, INTENT(IN)                 :: d
    COMPLEX(kind=real_4), DIMENSION(d,d), INTENT(IN) :: block_data
    COMPLEX(kind=real_4), DIMENSION(d), INTENT(OUT)  :: diagonal

    INTEGER                             :: i

!   ---------------------------------------------------------------------------

    FORALL (i = 1 : d)
       diagonal(i) = block_data(i, i)
    END FORALL
  END SUBROUTINE get_block2d_diagonal_c


! *****************************************************************************
!> \brief Copies a block subset
!> \param dst ...
!> \param dst_rs ...
!> \param dst_cs ...
!> \param dst_tr ...
!> \param src ...
!> \param src_rs ...
!> \param src_cs ...
!> \param src_tr ...
!> \param dst_r_lb ...
!> \param dst_c_lb ...
!> \param src_r_lb ...
!> \param src_c_lb ...
!> \param nrow ...
!> \param ncol ...
!> \param dst_offset ...
!> \param src_offset ...
!> \note see block_partial_copy_a 
! *****************************************************************************
  SUBROUTINE block_partial_copy_c(dst, dst_rs, dst_cs, dst_tr,&
       src, src_rs, src_cs, src_tr,&
       dst_r_lb, dst_c_lb, src_r_lb, src_c_lb, nrow, ncol,&
       dst_offset, src_offset)
    COMPLEX(kind=real_4), DIMENSION(:), &
      INTENT(INOUT)                          :: dst
    INTEGER, INTENT(IN)                      :: dst_rs, dst_cs
    INTEGER, INTENT(IN)                      :: src_offset, dst_offset
    LOGICAL                                  :: dst_tr
    COMPLEX(kind=real_4), DIMENSION(:), &
      INTENT(IN)                             :: src
    INTEGER, INTENT(IN)                      :: src_rs, src_cs
    LOGICAL                                  :: src_tr
    INTEGER, INTENT(IN)                      :: dst_r_lb, dst_c_lb, src_r_lb, &
                                                src_c_lb, nrow, ncol

    CHARACTER(len=*), PARAMETER :: routineN = 'block_partial_copy_c', &
      routineP = moduleN//':'//routineN

    INTEGER                                  :: col, row

!   ---------------------------------------------------------------------------
! Factors out the 4 combinations to remove branches from the inner loop.
!  rs is the logical row size so it always remains the leading dimension.
    IF (.NOT. dst_tr .AND. .NOT. src_tr) THEN
       FORALL (col = 0:ncol-1, row=0:nrow-1)
          dst(dst_offset+dst_r_lb+row + (dst_c_lb+col-1)*dst_rs) &
                = src(src_offset+src_r_lb+row+(src_c_lb+col-1)*src_rs)
       END FORALL
    ELSEIF (dst_tr .AND. .NOT. src_tr) THEN
       FORALL (col = 0:ncol-1, row=0:nrow-1)
          dst(dst_offset+dst_c_lb+col + (dst_r_lb+row-1)*dst_cs) &
              = src(src_offset+src_r_lb+row+(src_c_lb+col-1)*src_rs)
       END FORALL
    ELSEIF (.NOT. dst_tr .AND. src_tr) THEN
       FORALL (col = 0:ncol-1, row=0:nrow-1)
          dst(dst_offset+dst_r_lb+row + (dst_c_lb+col-1)*dst_rs) &
             = src(src_offset+src_c_lb+col+(src_r_lb+row-1)*src_cs)
       END FORALL
    ELSEIF (dst_tr .AND. src_tr) THEN
       FORALL (col = 0:ncol-1, row=0:nrow-1)
          dst(dst_offset+dst_c_lb+col + (dst_r_lb+row-1)*dst_cs)&
             = src(src_offset + src_c_lb+col+(src_r_lb+row-1)*src_cs)
       END FORALL
    ENDIF
  END SUBROUTINE block_partial_copy_c

! *****************************************************************************
!> \brief Copies a block subset
!> \param dst ...
!> \param dst_rs ...
!> \param dst_cs ...
!> \param dst_tr ...
!> \param src ...
!> \param src_rs ...
!> \param src_cs ...
!> \param src_tr ...
!> \param dst_r_lb ...
!> \param dst_c_lb ...
!> \param src_r_lb ...
!> \param src_c_lb ...
!> \param nrow ...
!> \param ncol ...
!> \param dst_offset ...
!> \note see block_partial_copy_a 
! *****************************************************************************
  SUBROUTINE block_partial_copy_1d2d_c(dst, dst_rs, dst_cs, dst_tr,&
       src, src_rs, src_cs, src_tr,&
       dst_r_lb, dst_c_lb, src_r_lb, src_c_lb, nrow, ncol,&
       dst_offset)
    COMPLEX(kind=real_4), DIMENSION(:), &
      INTENT(INOUT)                          :: dst
    INTEGER, INTENT(IN)                      :: dst_rs, dst_cs
    INTEGER, INTENT(IN)                      :: dst_offset
    LOGICAL                                  :: dst_tr
    COMPLEX(kind=real_4), DIMENSION(:,:), &
      INTENT(IN)                             :: src
    INTEGER, INTENT(IN)                      :: src_rs, src_cs
    LOGICAL                                  :: src_tr
    INTEGER, INTENT(IN)                      :: dst_r_lb, dst_c_lb, src_r_lb, &
                                                src_c_lb, nrow, ncol

    CHARACTER(len=*), PARAMETER :: routineN = 'block_partial_copy_1d2d_c', &
      routineP = moduleN//':'//routineN

    INTEGER                                  :: col, row

!   ---------------------------------------------------------------------------
! Factors out the 4 combinations to remove branches from the inner loop. rs is the logical row size so it always remains the leading dimension.
    IF (.NOT. dst_tr .AND. .NOT. src_tr) THEN
       FORALL (col = 0:ncol-1, row=0:nrow-1)
          dst(dst_offset+dst_r_lb+row + (dst_c_lb+col-1)*dst_rs) &
                = src(src_r_lb+row, src_c_lb+col)
       END FORALL
    ELSEIF (dst_tr .AND. .NOT. src_tr) THEN
       FORALL (col = 0:ncol-1, row=0:nrow-1)
          dst(dst_offset+dst_c_lb+col + (dst_r_lb+row-1)*dst_cs) &
              = src(src_r_lb+row, src_c_lb+col)
       END FORALL
    ELSEIF (.NOT. dst_tr .AND. src_tr) THEN
       FORALL (col = 0:ncol-1, row=0:nrow-1)
          dst(dst_offset+dst_r_lb+row + (dst_c_lb+col-1)*dst_rs) &
             = src(src_c_lb+col, src_r_lb+row)
       END FORALL
    ELSEIF (dst_tr .AND. src_tr) THEN
       FORALL (col = 0:ncol-1, row=0:nrow-1)
          dst(dst_offset+dst_c_lb+col + (dst_r_lb+row-1)*dst_cs)&
             = src(src_c_lb+col, src_r_lb+row)
       END FORALL
    ENDIF
  END SUBROUTINE block_partial_copy_1d2d_c
! *****************************************************************************
!> \brief Copies a block subset
!> \param dst ...
!> \param dst_rs ...
!> \param dst_cs ...
!> \param dst_tr ...
!> \param src ...
!> \param src_rs ...
!> \param src_cs ...
!> \param src_tr ...
!> \param dst_r_lb ...
!> \param dst_c_lb ...
!> \param src_r_lb ...
!> \param src_c_lb ...
!> \param nrow ...
!> \param ncol ...
!> \param src_offset ...
!> \note see block_partial_copy_a
! *****************************************************************************
  SUBROUTINE block_partial_copy_2d1d_c(dst, dst_rs, dst_cs, dst_tr,&
       src, src_rs, src_cs, src_tr,&
       dst_r_lb, dst_c_lb, src_r_lb, src_c_lb, nrow, ncol,&
       src_offset)
    COMPLEX(kind=real_4), DIMENSION(:,:), &
      INTENT(INOUT)                          :: dst
    INTEGER, INTENT(IN)                      :: dst_rs, dst_cs
    INTEGER, INTENT(IN)                      :: src_offset
    LOGICAL                                  :: dst_tr
    COMPLEX(kind=real_4), DIMENSION(:), &
      INTENT(IN)                             :: src
    INTEGER, INTENT(IN)                      :: src_rs, src_cs
    LOGICAL                                  :: src_tr
    INTEGER, INTENT(IN)                      :: dst_r_lb, dst_c_lb, src_r_lb, &
                                                src_c_lb, nrow, ncol

    CHARACTER(len=*), PARAMETER :: routineN = 'block_partial_copy_2d1d_c', &
      routineP = moduleN//':'//routineN

    INTEGER                                  :: col, row

!   ---------------------------------------------------------------------------
! Factors out the 4 combinations to remove branches from the inner loop. rs is the logical row size so it always remains the leading dimension.
    IF (.NOT. dst_tr .AND. .NOT. src_tr) THEN
       FORALL (col = 0:ncol-1, row=0:nrow-1)
          dst(dst_r_lb+row, dst_c_lb+col) &
                = src(src_offset+src_r_lb+row+(src_c_lb+col-1)*src_rs)
       END FORALL
    ELSEIF (dst_tr .AND. .NOT. src_tr) THEN
       FORALL (col = 0:ncol-1, row=0:nrow-1)
          dst(dst_c_lb+col, dst_r_lb+row) &
              = src(src_offset+src_r_lb+row+(src_c_lb+col-1)*src_rs)
       END FORALL
    ELSEIF (.NOT. dst_tr .AND. src_tr) THEN
       FORALL (col = 0:ncol-1, row=0:nrow-1)
          dst(dst_r_lb+row, dst_c_lb+col) &
             = src(src_offset+src_c_lb+col+(src_r_lb+row-1)*src_cs)
       END FORALL
    ELSEIF (dst_tr .AND. src_tr) THEN
       FORALL (col = 0:ncol-1, row=0:nrow-1)
          dst(dst_c_lb+col, dst_r_lb+row)&
             = src(src_offset + src_c_lb+col+(src_r_lb+row-1)*src_cs)
       END FORALL
    ENDIF
  END SUBROUTINE block_partial_copy_2d1d_c
! *****************************************************************************
!> \brief Copies a block subset
!> \param dst ...
!> \param dst_rs ...
!> \param dst_cs ...
!> \param dst_tr ...
!> \param src ...
!> \param src_rs ...
!> \param src_cs ...
!> \param src_tr ...
!> \param dst_r_lb ...
!> \param dst_c_lb ...
!> \param src_r_lb ...
!> \param src_c_lb ...
!> \param nrow ...
!> \param ncol ...
!> \note see block_partial_copy_a
! *****************************************************************************
  SUBROUTINE block_partial_copy_2d2d_c(dst, dst_rs, dst_cs, dst_tr,&
       src, src_rs, src_cs, src_tr,&
       dst_r_lb, dst_c_lb, src_r_lb, src_c_lb, nrow, ncol)
    COMPLEX(kind=real_4), DIMENSION(:,:), &
      INTENT(INOUT)                          :: dst
    INTEGER, INTENT(IN)                      :: dst_rs, dst_cs
    LOGICAL                                  :: dst_tr
    COMPLEX(kind=real_4), DIMENSION(:,:), &
      INTENT(IN)                             :: src
    INTEGER, INTENT(IN)                      :: src_rs, src_cs
    LOGICAL                                  :: src_tr
    INTEGER, INTENT(IN)                      :: dst_r_lb, dst_c_lb, src_r_lb, &
                                                src_c_lb, nrow, ncol

    CHARACTER(len=*), PARAMETER :: routineN = 'block_partial_copy_2d2d_c', &
      routineP = moduleN//':'//routineN

    INTEGER                                  :: col, row

!   ---------------------------------------------------------------------------
! Factors out the 4 combinations to remove branches from the inner loop. rs is the logical row size so it always remains the leading dimension.
    IF (.NOT. dst_tr .AND. .NOT. src_tr) THEN
       FORALL (col = 0:ncol-1, row=0:nrow-1)
          dst(dst_r_lb+row, dst_c_lb+col) &
                = src(src_r_lb+row, src_c_lb+col)
       END FORALL
    ELSEIF (dst_tr .AND. .NOT. src_tr) THEN
       FORALL (col = 0:ncol-1, row=0:nrow-1)
          dst(dst_c_lb+col, dst_r_lb+row) &
              = src(src_r_lb+row, src_c_lb+col)
       END FORALL
    ELSEIF (.NOT. dst_tr .AND. src_tr) THEN
       FORALL (col = 0:ncol-1, row=0:nrow-1)
          dst(dst_r_lb+row, dst_c_lb+col) &
             = src(src_c_lb+col, src_r_lb+row)
       END FORALL
    ELSEIF (dst_tr .AND. src_tr) THEN
       FORALL (col = 0:ncol-1, row=0:nrow-1)
          dst(dst_c_lb+col, dst_r_lb+row)&
             = src(src_c_lb+col, src_r_lb+row)
       END FORALL
    ENDIF
  END SUBROUTINE block_partial_copy_2d2d_c


! *****************************************************************************
!> \brief Copy a block
!> \param[out] extent_out     output data
!> \param[in] extent_in       input data
!> \param[in] n               number of elements to copy
!> \param[in] out_fe          first element of output
!> \param[in] in_fe           first element of input
! *****************************************************************************
  PURE SUBROUTINE block_copy_c(extent_out, extent_in, n, out_fe, in_fe)
    INTEGER, INTENT(IN)                           :: n, out_fe, in_fe
    COMPLEX(kind=real_4), DIMENSION(*), INTENT(OUT)  :: extent_out
    COMPLEX(kind=real_4), DIMENSION(*), INTENT(IN)   :: extent_in

    CHARACTER(len=*), PARAMETER :: routineN = 'block_transpose_d', &
      routineP = moduleN//':'//routineN

!   ---------------------------------------------------------------------------

    extent_out(out_fe : out_fe+n-1) = extent_in(in_fe : in_fe+n-1)
  END SUBROUTINE block_copy_c


! *****************************************************************************
!> \brief Copy and transpose block.
!> \param[out] extent_out     output matrix in the form of a 1-d array
!> \param[in] extent_in       input matrix in the form of a 1-d array
!> \param[in] rows input matrix size
!> \param[in] columns input matrix size
! *****************************************************************************
  PURE SUBROUTINE block_transpose_copy_c(extent_out, extent_in,&
       rows, columns)
    COMPLEX(kind=real_4), DIMENSION(:), INTENT(OUT) :: extent_out
    COMPLEX(kind=real_4), DIMENSION(:), INTENT(IN)  :: extent_in
    INTEGER, INTENT(IN)                :: rows, columns

    CHARACTER(len=*), PARAMETER :: routineN = 'block_transpose_copy_c', &
      routineP = moduleN//':'//routineN

!   ---------------------------------------------------------------------------

    extent_out(1:rows*columns) = RESHAPE(TRANSPOSE(&
         RESHAPE(extent_in(1:rows*columns), (/rows, columns/))), (/rows*columns/))
  END SUBROUTINE block_transpose_copy_c

! *****************************************************************************
!> \brief Copy a block
!> \param[out] extent_out     output matrix in the form of a 2-d array
!> \param[in] extent_in       input matrix in the form of a 1-d array
!> \param[in] rows input matrix size
!> \param[in] columns input matrix size
! *****************************************************************************
  PURE SUBROUTINE block_copy_2d1d_c(extent_out, extent_in,&
       rows, columns)
    INTEGER, INTENT(IN)                           :: rows, columns
    COMPLEX(kind=real_4), DIMENSION(rows,columns), INTENT(OUT) :: extent_out
    COMPLEX(kind=real_4), DIMENSION(:), INTENT(IN)             :: extent_in

    CHARACTER(len=*), PARAMETER :: routineN = 'block_transpose_copy_2d1d_c', &
      routineP = moduleN//':'//routineN

!   ---------------------------------------------------------------------------

    extent_out = RESHAPE(extent_in, (/rows, columns/))
  END SUBROUTINE block_copy_2d1d_c

! *****************************************************************************
!> \brief Copy a block
!> \param[out] extent_out     output matrix in the form of a 1-d array
!> \param[in] extent_in       input matrix in the form of a 1-d array
!> \param[in] rows input matrix size
!> \param[in] columns input matrix size
! *****************************************************************************
  PURE SUBROUTINE block_copy_1d1d_c(extent_out, extent_in,&
       rows, columns)
    INTEGER, INTENT(IN)                           :: rows, columns
    COMPLEX(kind=real_4), DIMENSION(rows*columns), INTENT(OUT) :: extent_out
    COMPLEX(kind=real_4), DIMENSION(rows*columns), INTENT(IN)  :: extent_in

    CHARACTER(len=*), PARAMETER :: routineN = 'block_transpose_copy_1d1d_c', &
      routineP = moduleN//':'//routineN

!   ---------------------------------------------------------------------------

    extent_out(:) = extent_in(:)
  END SUBROUTINE block_copy_1d1d_c

! *****************************************************************************
!> \brief Copy a block
!> \param[out] extent_out     output matrix in the form of a 2-d array
!> \param[in] extent_in       input matrix in the form of a 2-d array
!> \param[in] rows input matrix size
!> \param[in] columns input matrix size
! *****************************************************************************
  PURE SUBROUTINE block_copy_2d2d_c(extent_out, extent_in,&
       rows, columns)
    INTEGER, INTENT(IN)                           :: rows, columns
    COMPLEX(kind=real_4), DIMENSION(rows,columns), INTENT(OUT) :: extent_out
    COMPLEX(kind=real_4), DIMENSION(rows,columns), INTENT(IN)  :: extent_in

    CHARACTER(len=*), PARAMETER :: routineN = 'block_transpose_copy_2d2d_c', &
      routineP = moduleN//':'//routineN

!   ---------------------------------------------------------------------------

    extent_out(:,:) = extent_in(:,:)
  END SUBROUTINE block_copy_2d2d_c


! *****************************************************************************
!> \brief Copy and transpose block.
!> \param[out] extent_out     output matrix in the form of a 2-d array
!> \param[in] extent_in       input matrix in the form of a 1-d array
!> \param[in] rows input matrix size
!> \param[in] columns input matrix size
! *****************************************************************************
  PURE SUBROUTINE block_transpose_copy_2d1d_c(extent_out, extent_in,&
       rows, columns)
    INTEGER, INTENT(IN)                           :: rows, columns
    COMPLEX(kind=real_4), DIMENSION(columns,rows), INTENT(OUT) :: extent_out
    COMPLEX(kind=real_4), DIMENSION(:), INTENT(IN)             :: extent_in

    CHARACTER(len=*), PARAMETER :: routineN = 'block_transpose_copy_2d1d_c', &
      routineP = moduleN//':'//routineN

!   ---------------------------------------------------------------------------

    extent_out = TRANSPOSE(RESHAPE(extent_in, (/rows, columns/)))
  END SUBROUTINE block_transpose_copy_2d1d_c

! *****************************************************************************
!> \brief Copy and transpose block.
!> \param[out] extent_out     output matrix in the form of a 1-d array
!> \param[in] extent_in       input matrix in the form of a 2-d array
!> \param[in] rows input matrix size
!> \param[in] columns input matrix size
! *****************************************************************************
  PURE SUBROUTINE block_copy_1d2d_c(extent_out, extent_in,&
       rows, columns)
    COMPLEX(kind=real_4), DIMENSION(:), INTENT(OUT)            :: extent_out
    INTEGER, INTENT(IN)                           :: rows, columns
    COMPLEX(kind=real_4), DIMENSION(rows,columns), INTENT(IN)  :: extent_in

    CHARACTER(len=*), PARAMETER :: routineN = 'block_copy_1d2d_c', &
      routineP = moduleN//':'//routineN

!   ---------------------------------------------------------------------------

    extent_out = RESHAPE(extent_in, (/rows*columns/))
  END SUBROUTINE block_copy_1d2d_c


! *****************************************************************************
!> \brief Copy and transpose block.
!> \param[out] extent_out     output matrix in the form of a 1-d array
!> \param[in] extent_in       input matrix in the form of a 2-d array
!> \param[in] rows input matrix size
!> \param[in] columns input matrix size
! *****************************************************************************
  PURE SUBROUTINE block_transpose_copy_1d2d_c(extent_out, extent_in,&
       rows, columns)
    COMPLEX(kind=real_4), DIMENSION(:), INTENT(OUT)            :: extent_out
    INTEGER, INTENT(IN)                           :: rows, columns
    COMPLEX(kind=real_4), DIMENSION(rows,columns), INTENT(IN)  :: extent_in

    CHARACTER(len=*), PARAMETER :: routineN = 'block_transpose_copy_1d2d_c', &
      routineP = moduleN//':'//routineN

!   ---------------------------------------------------------------------------

    extent_out = RESHAPE(TRANSPOSE(extent_in), (/rows*columns/))
  END SUBROUTINE block_transpose_copy_1d2d_c


! *****************************************************************************
!> \brief In-place block transpose.
!> \param[in,out] extent      Matrix in the form of a 1-d array
!> \param[in] rows input matrix size
!> \param[in] columns input matrix size
! *****************************************************************************
  PURE SUBROUTINE block_transpose_inplace_c(extent, rows, columns)
    INTEGER, INTENT(IN)                      :: rows, columns
    COMPLEX(kind=real_4), DIMENSION(rows*columns), &
      INTENT(INOUT)                          :: extent

    CHARACTER(len=*), PARAMETER :: routineN = 'block_transpose_inplace_c', &
      routineP = moduleN//':'//routineN

    INTEGER :: r, c
!   ---------------------------------------------------------------------------

    FORALL (r = 1:columns, c = 1:rows)
       extent(r + (c-1)*columns) = extent(c + (r-1)*rows)
    END FORALL
  END SUBROUTINE block_transpose_inplace_c


! *****************************************************************************
!> \brief Copy data from a double real array to a data area
!>
!> There are no checks done for correctness!
!> \param[in] dst        destination data area
!> \param[in] lb         lower bound for destination (and source if
!>                       not given explicity)
!> \param[in] data_size  number of elements to copy
!> \param[in] src        source data array
!> \param[in] source_lb  (optional) lower bound of source
! *****************************************************************************
  SUBROUTINE dbcsr_data_set_ac (dst, lb, data_size, src, source_lb)
    TYPE(dbcsr_data_obj), INTENT(INOUT)      :: dst
    INTEGER, INTENT(IN)                      :: lb, data_size
    COMPLEX(kind=real_4), DIMENSION(:), INTENT(IN)        :: src
    INTEGER, INTENT(IN), OPTIONAL            :: source_lb
    CHARACTER(len=*), PARAMETER :: routineN = 'dbcsr_data_set_ac', &
         routineP = moduleN//':'//routineN
    INTEGER                                  :: lb_s, ub, ub_s
    TYPE(dbcsr_error_type)                   :: error
!   ---------------------------------------------------------------------------
    IF (debug_mod) THEN
       CALL dbcsr_assert (ASSOCIATED (dst%d),&
            dbcsr_fatal_level, dbcsr_caller_error, routineN,&
            "Target data area must be setup.",__LINE__,error)
       CALL dbcsr_assert (SIZE(src) .GE. data_size,&
            dbcsr_fatal_level, dbcsr_caller_error, routineN,&
            "Not enough source data.",__LINE__,error)
       CALL dbcsr_assert (dst%d%data_type .EQ. dbcsr_type_complex_4, dbcsr_failure_level,&
            dbcsr_caller_error, routineN, "Data type mismatch.",__LINE__,error)
    ENDIF
    ub = lb + data_size - 1
    IF (PRESENT (source_lb)) THEN
       lb_s = source_lb
       ub_s = source_lb + data_size-1
    ELSE
       lb_s = lb
       ub_s = ub
    ENDIF
    dst%d%c_sp(lb:ub) = src(lb_s:ub_s)
  END SUBROUTINE dbcsr_data_set_ac

! *****************************************************************************
!> \brief ...
!> \param m ...
!> \param blk ...
!> \param alpha ...
!> \param imin ...
!> \param imax ...
! *****************************************************************************
  PURE SUBROUTINE block_2d_add_on_diag_c(m, blk, alpha, imin, imax)
    INTEGER, INTENT(IN)                      :: m
    COMPLEX(kind=real_4), INTENT(INOUT), DIMENSION(m,m)   :: blk
    COMPLEX(kind=real_4), INTENT(IN)                      :: alpha
    INTEGER, INTENT(IN), OPTIONAL            :: imin, imax

    CHARACTER(len=*), PARAMETER :: routineN = 'block_2d_add_on_diag_c', &
      routineP = moduleN//':'//routineN

    INTEGER                                  :: i

!   ---------------------------------------------------------------------------

    IF(PRESENT(imin).AND.PRESENT(imax)) THEN
       FORALL (i = MAX(1,imin):MIN(m,imax))
          blk(i,i) = blk(i,i) + alpha
       END FORALL
    ELSE
       FORALL (i = 1:m)
          blk(i,i) = blk(i,i) + alpha
       END FORALL
    ENDIF
  END SUBROUTINE block_2d_add_on_diag_c

! *****************************************************************************
!> \brief ...
!> \param m ...
!> \param blk ...
!> \param alpha ...
!> \param imin ...
!> \param imax ...
! *****************************************************************************
  PURE SUBROUTINE block_add_on_diag_c(m, blk, alpha, imin, imax)
    INTEGER, INTENT(IN)                      :: m
    COMPLEX(kind=real_4), INTENT(INOUT), DIMENSION(m*m)   :: blk
    COMPLEX(kind=real_4), INTENT(IN)                      :: alpha
    INTEGER, INTENT(IN), OPTIONAL            :: imin, imax

    CHARACTER(len=*), PARAMETER :: routineN = 'block_add_on_diag_c', &
      routineP = moduleN//':'//routineN

!   ---------------------------------------------------------------------------

    IF(PRESENT(imin).AND.PRESENT(imax)) THEN
       CALL block_2d_add_on_diag_c(m, blk, alpha, imin, imax)
    ELSE
       CALL block_2d_add_on_diag_c(m, blk, alpha, 1, m)
    ENDIF
  END SUBROUTINE block_add_on_diag_c

! *****************************************************************************
!> \brief ...
!> \param block_a ...
!> \param block_b ...
!> \param len ...
! *****************************************************************************
  PURE SUBROUTINE block_add_c(block_a, block_b, len)
    INTEGER, INTENT(IN)                    :: len
    COMPLEX(kind=real_4), DIMENSION(len), INTENT(INOUT) :: block_a
    COMPLEX(kind=real_4), DIMENSION(len), INTENT(IN)    :: block_b
    block_a(1:len) = block_a(1:len) + block_b(1:len)
  END SUBROUTINE block_add_c