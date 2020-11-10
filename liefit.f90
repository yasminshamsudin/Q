PROGRAM liefit
implicit none


#if defined (USE_MPI)
include "mpif.h"
#endif



CHARACTER (LEN=80) :: filnam
 
 
REAL :: vljp(100),vljw(100),velp(100),velw(100),dgobs(100),  &
    elcorr(100),bcl(100)
    
REAL (KIND=8) :: aw,ap,bw,bp,c,b2p,b2w,ap2
REAL (KIND=8) :: awmin,awmax,apmin,apmax
REAL (KIND=8) :: bpmin,bpmax,bwmin,bwmax
REAL (KIND=8) :: cmin,cmax
REAL (KIND=8) :: da,db,dc
REAL (KIND=8) :: apopt, awopt, bpopt, bwopt, copt
REAL (KIND=8) :: topaw, topap, topbw, topbp, topc
REAL (KIND=8) :: apmin2, apmax2, bpmin2, bpmax2
REAL (KIND=8) :: a,b,cw,cp,press,sum_min,sum,dg
REAL (KIND=8) :: averageobs, ssm ,sse, sst
REAL (KIND=8) :: spress, qsqloo, rsq, arsq, arsqtva, arsqapex
REAL (KIND=8) :: pre_press(100)


integer            ::request_recv(100)
INTEGER :: nlo, lig_excl, params
INTEGER (KIND=8) :: nligfac, nlofac, nligmlofac, pmut, &
	startpunkt, stoppunkt, muts_per_node

INTEGER :: current(4), includeit, datum(8), &
    permut(20000,4),POSITION, previous, i, j, k, nlig
LOGICAL :: newposition,  bwclass, bpclass, apelim, bpelim, out_of_range, compute

integer :: qdyn_ierr, nodeid, numnodes, ierr
integer	:: num_args
character(200)	:: inpfile
integer(4) iargc
external iargc






#if defined (USE_MPI)
write (*,*) 'using mpi'
  call MPI_Init(qdyn_ierr)
!  if (qdyn_ierr .ne. MPI_SUCCESS) call die('failure at MPI init')
  call MPI_Comm_rank(MPI_COMM_WORLD, nodeid, qdyn_ierr)
  call MPI_Comm_size(MPI_COMM_WORLD, numnodes, qdyn_ierr)

#endif





vljp(:) = 999
vljw(:) = 999
velp(:) = 999
velw(:) = 999
dgobs(:) = 999
elcorr(:) = 999
bcl(:) = 999


!write (*,*) 'nodeid: ',nodeid

#if defined (USE_MPI)
if (nodeid == 0) then
#endif



vljp(:) = 888
vljw(:) = 888
velp(:) = 888
velw(:) = 888
dgobs(:) = 888
elcorr(:) = 888
bcl(:) = 888

#if defined (USE_BATCH)

! read name of input file from the command line
num_args = iargc()
call getarg(num_args, inpfile)

write (*,*) 'Input file: ',inpfile

#endif

CALL getlin ('>>>Data file: ',filnam)
CALL openit (1,filnam,'old','formatted')
READ (1,*)
DO i=1,999
  READ (1,*,END=10) vljp(i),vljw(i),velp(i),velw(i), dgobs(i),elcorr(i),bcl(i)
!  write (*,*) vljp(i),vljw(i),velp(i),velw(i), dgobs(i),elcorr(i),bcl(i)
  nlig=nlig+1
END DO
10   WRITE (*,*) 'Number of ligands=',nlig

CALL prompt ('>>> Give min and max for aw,ap,bw,bp,c (enter  &
    0, 0 for b if b=b(class) and -99 -99 for ap or bp to eliminate it as a free parameter: ')
READ (*,*) awmin,awmax,apmin,apmax,bwmin,bwmax,bpmin,bpmax ,cmin,cmax



CALL prompt ('>>> Give stepsize for a,b,c: ')
READ (*,*) da,db,dc
! write (*,*) da
! write (*,*) db
! write (*,*) dc

CALL prompt ('>>> Give number of "leave outs": ')
READ (*,*) nlo


write (*,*) ' '
write (*,*) ' '
write (*,'(5a8) ') 'awmin','awmax','apmin','apmax','a_step'
write (*,'(5f8.3) ') awmin,awmax,apmin,apmax,da
write (*,*) ' '
write (*,'(5a8) ') 'bwmin','bwmax','bpmin','bpmax','b_step'
write (*,'(5f8.3) ') bwmin,bwmax,bpmin,bpmax ,db
write (*,*) ' '
write (*,'(3a8) ') 'cmin','cmax','c_step'
write (*,'(3f8.3) ') cmin,cmax,dc


write (*,*) ' '
133	format('Starting calculations at : ',i4,'-',i2,'-',i2,', time ',i2,':',i2,':',i2)
134	format('Calculations stopped at : ',i4,'-',i2,'-',i2,', time ',i2,':',i2,':',i2)

	call date_and_time(values=datum)
	write(*,133) datum(1),datum(2),datum(3),datum(5),datum(6),datum(7)  



#if defined (USE_MPI)
! END IF for masternode
end if




if (numnodes .gt. 1) then
	call init_nodes

	call MPI_barrier(MPI_COMM_WORLD,qdyn_ierr)

end if

#endif



! calculate some factorials
nligfac=1
DO j=1,nlig
!  WRITE (*, '(i20,i20,i20)') nligfac, nlig, j
  nligfac=nligfac*j
END DO

nlofac=1
DO j=1,nlo
  nlofac=nlofac*j
END DO

nligmlofac=1
DO j=1,nlig-nlo
  nligmlofac=nligmlofac*j
END DO



! create permutations of leave outs
pmut=nligfac/(nlofac*nligmlofac)

!WRITE (*, '(20i,20i,20i,20i)') nligfac, nlofac, nligmlofac, pmut

DO j=1,nlo
  current(j) = j
END DO

POSITION = nlo
newposition = .false.
current(nlo) = nlo - 1

previous = nlo

DO j=1,pmut
  DO i=1,nlo
    20   IF (current(POSITION) == (nlig - nlo + POSITION)) THEN
      POSITION = POSITION - 1
      newposition = .true.
      GO TO 20
    END IF
    
    IF (newposition) THEN
      current(POSITION) = current(POSITION) + 1
      DO k=POSITION+1,nlo
        current(k)=current(k-1)+1
      END DO
      POSITION = nlo
      newposition = .false.
      current(nlo)=current(nlo)-1
    END IF
    
    
    
    IF (i == nlo) THEN
      current(nlo)=current(nlo)+1
      previous = current(nlo)
    END IF
    
    permut(j,i)=current(i)
    
  END DO
END DO


!DO j=1,pmut
!  WRITE (*,'(4i10)') permut(j,1),permut(j,2),permut(j,3), permut(j,4)
  
!END DO


! numreg = 0


! Check if any parameters have been frozen or set to b(class)
apelim = .FALSE.
bpelim = .FALSE.
bwclass = .FALSE.
bpclass = .FALSE.

!Set top limits of parameters to slightly more (DO loop can miss them otherwise
  topaw=awmax+da/2.
  topap=apmax+da/2.
  topbw=bwmax+db/2.
  topbp=bpmax+db/2.
  topc=cmax+dc/2.



IF ((apmin == apmax) .and. (apmin == -99.)) THEN
	apelim = .TRUE.
	apmin2 = awmin
	apmax2 = awmax
	topap=apmax
	if (nodeid == 0) WRITE (*,*) 'Keeping ap fixed to aw'	
ELSE
	apmin2 = apmin
	apmax2 = apmax
END IF


IF ((bpmin == bpmax) .and. (bpmin == -99.)) THEN
	bpelim = .TRUE.
	bpmin2 = bwmin
	bpmax2 = bwmax
	topbp=bpmax
	if (nodeid == 0) WRITE (*,*) 'Keeping bp fixed to bw'	
ELSE                
	bpmin2 = bpmin
	bpmax2 = bpmax
END IF



IF (bwmin == bwmax) THEN
	IF (bwmin == 0.) THEN
		bwclass = .TRUE.
		topbw=bwmax
		if (nodeid == 0) WRITE (*,*) 'Keeping bw fixed to bw_class'
	END IF
END IF
 
IF (bpmin == bpmax) THEN
	IF (bpmin == 0.) THEN
		bpclass = .TRUE.
		topbp=bpmax
		if (nodeid == 0) WRITE (*,*) 'Keeping bp fixed to bp_class'
	END IF
END IF


if (nodeid == 0) WRITE (*,*) 'Leave ',nlo,' out:'
if (nodeid == 0) WRITE (*,'(a5,6a10)') 'Lig_out','err','aw','ap','bw','bp','c'










a=0.
b=0.
c=0.
aw=0.
bw=0.
cw=0.
ap=0.
bp=0.
cp=0.
b2w=0.
b2p=0.

press=0
compute = .true.

 


#if defined (USE_MPI)


muts_per_node = ceiling((pmut*1.) / (numnodes*1.))
!write (*,*) ' pmut: ',pmut, ' numnodes: ',numnodes,' muts_per_node: ', muts_per_node
startpunkt = muts_per_node * (nodeid ) + 1
stoppunkt = muts_per_node * (nodeid + 1)


if (stoppunkt > pmut) stoppunkt = pmut

!check if node is superfluous, i.e. all pmuts are taken by earlier nodes.
if (startpunkt > pmut) compute = .false.

if (.false.) then

write (*,*) 'nodeid: ', nodeid, ' startpunkt: ',startpunkt, ' stoppunkt: ',stoppunkt
write (*,*) ' '
write (*,*) ' '
write (*,'(5a8) ') 'awmin','awmax','apmin','apmax','a_step'
write (*,'(5f8.3) ') awmin,awmax,apmin,apmax,da
write (*,*) ' '
write (*,'(5a8) ') 'bwmin','bwmax','bpmin','bpmax','b_step'
write (*,'(5f8.3) ') bwmin,bwmax,bpmin,bpmax ,db
write (*,*) ' '
write (*,'(3a8) ') 'cmin','cmax','c_step'
write (*,'(3f8.3) ') cmin,cmax,dc
write (*,'(5a8) ') 'topaw','topap','topbw','topbp','topc'
write (*,'(5f8.3) ') topaw,topap,topbw,topbp ,topc
write (*,*) ' '
write (*,'(4a8) ') 'apelim','bpelim','bpclass','bwclass'
write (*,*) apelim,bpelim,bpclass,bwclass
write (*,*) ' '
write (*,*) 'vljw'
write (*,*) vljw
write (*,*) ' '
write (*,*) 'vljp'
write (*,*) vljp
write (*,*) ' '
write (*,*) 'elw'
write (*,*) velw
write (*,*) ' '
write (*,*) 'elp'
write (*,*) velp
write (*,*) ' '
write (*,*) 'bcl'
write (*,*) bcl
write (*,*) ' '
write (*,*) 'elcorr'
write (*,*) elcorr
write (*,*) ' '
write (*,*) 'dgobs'
write (*,*) dgobs
write (*,*) ' '


end if





#else
startpunkt = 1
stoppunkt = pmut

#endif
















DO j=startpunkt,stoppunkt
  
  sum_min=99999.
  DO aw=awmin,topaw,da
    DO ap2=apmin,topap,da
      DO bw=bwmin,topbw,db
        DO bp=bpmin,topbp,db
          DO c=cmin,topc,dc
            sum=0.
            DO i=1,nlig
              
!      check if i is one of the excluded ligs
!              includeit = .true.
              includeit = 1
              DO k=1,nlo
              	includeit = includeit * (i-permut(j,k))
!                IF (i == permut(j,k)) THEN
!                  includeit = .false.
!                END IF
              END DO
              
              IF (includeit /= 0) THEN
                
!    set b=b(class) if user enters 0.0 , 0.0 as bmin and bmax
!    need to use b2 instead of b because of do loop
                b2w=bw
                b2p=bp
                IF (bwclass) THEN
                    b2w=bcl(i)
                END IF
                
                IF (bpclass) THEN
                    b2p=bcl(i)
                END IF
                
!	set ap to aw if user enters 0 , 0 as apmin and apmax
		ap = ap2
		IF (apelim) THEN
			ap = aw

		END IF
                
		IF (bpelim) THEN
			b2p = b2w

		END IF

                dg=ap*vljp(i)-aw*vljw(i)+b2p*velp(i) -b2w*velw(i)+c
                sum=sum+(dg-dgobs(i)+elcorr(i))**2
              END IF
              
            END DO
!     write (*,*) a,b,c,sum_min,sum
            IF (sum < sum_min) THEN
              sum_min=sum
              awopt=aw
              bwopt=b2w
              apopt=ap
              bpopt=b2p
              copt=c


            END IF
          END DO
        END DO
      END DO
    END DO
  END DO
  
  
  !check if parameters are on the range boundary
  
!(awopt - awmin)*(awopt - awmax)*(apopt - apmin2)&
!  	*(apopt - apmax2)*(bwopt - bwmin)*(bwopt - bwmax)
!  		(bpopt - bpmin) (bpopt - bpmax)

  out_of_range = .FALSE.

  IF ((da/100. >= abs((awopt - awmin)*(awopt-awmax))) .and. (awmax /= awmin)) THEN
  	out_of_range = .TRUE.
!  	write (*,*) 'WARNING: AW Parameters out of range'
  ELSE IF ( (da/100. >= abs((apopt - apmin2)*(apopt-apmax2))) .and. (apmax2 /= apmin2) ) THEN
  	out_of_range = .TRUE.
!  	write (*,*) 'WARNING: AP Parameters out of range'
  ELSE IF ( (db/100. >= abs((bwopt - bwmin)*(bwopt-bwmax))) .and. (bwmax /= bwmin) ) THEN
  	out_of_range = .TRUE.
!  	write (*,*) 'WARNING: BW Parameters out of range'
  ELSE IF ( (db/100. >= abs((bpopt - bpmin2)*(bpopt-bpmax2))) .and. (bpmax2 /= bpmin2) ) THEN
  	out_of_range = .TRUE.
!  	write (*,*) 'WARNING: BP Parameters out of range'
  ELSE IF ( (dc/100. >= abs((copt - cmin)*(copt-cmax))) .and. (cmax /= cmin) ) THEN
  	out_of_range = .TRUE.
!  	write (*,*) 'WARNING: C Parameters out of range'
  END IF
  
  IF (out_of_range) THEN
  	write (*,*) 'WARNING: Parameters out of range'
  END IF




! Calculate PRESS for the left out ligands.
  DO k=1,nlo
    lig_excl = permut(j,k)
    
    IF (bwclass) THEN
        bwopt=bcl(lig_excl)
    END IF

    IF (bpclass) THEN
        bpopt=bcl(lig_excl)
    END IF
    
    IF (bpelim) THEN
	bpopt = bwopt

    END IF
    
    dg=apopt*vljp(lig_excl)-awopt*vljw(lig_excl)+bpopt*  &
        velp(lig_excl)-bwopt*velw(lig_excl)+copt
    press=press+(dg-dgobs(lig_excl)+elcorr(lig_excl))**2
    
    WRITE (*,'(i5,i5,f10.5,f10.5,f10.5,f10.5,f10.5,f10.5)') j,  &
        permut(j,k),ABS(dg-dgobs(lig_excl)+elcorr(lig_excl))  &
        ,awopt,apopt,bwopt,bpopt,copt
!  write (*,'(3(a,f10.5))') 'Optimum: a=',aopt,' b=',bopt,' c=',copt
    
  END DO
END DO

! The calculated press above is a sum of very many PRESSes.
! A good idea is to relate this to the PRESS for LOO
! LOO gives a sum of nlig PRESSes, we get nlig!/(nlo!*(nlig-nlo)!)*nlo PRESSes
! or pmut*nlo PRESSes. So we multiply our PRESS by
! nlig/(pmut*nlo)



#if defined (USE_MPI)

if (numnodes .gt. 1) then
write (*,*) 'node: ',nodeid,'  press:', press

if (nodeid .eq. 0) then        !master

do i = 1,numnodes-1

  call MPI_Recv(pre_press(i),1,MPI_REAL8,i,i,MPI_COMM_WORLD,request_recv(i) ,ierr)
  press = press + pre_press(i)
end do

end if


call MPI_Send(press, 1, MPI_REAL8, 0, nodeid,MPI_COMM_WORLD, ierr)

end if









!!!master node
if (nodeid == 0) then


write (*,*) 'press sum: ', press

#endif

press = press * nlig / (pmut * nlo)






sum_min=99999.
DO aw=awmin,topaw,da
  DO ap2=apmin,topap,da
    DO bw=bwmin,topbw,db
      DO bp=bpmin,topbp,db
        DO c=cmin,topc,dc
          sum=0.
          DO i=1,nlig
            
            b2w=bw
            b2p=bp
            IF (bwclass) THEN
                b2w=bcl(i)
            END IF
            IF (bpclass) THEN
                b2p=bcl(i)
            END IF
!	set ap to aw if user enters 0 , 0 as apmin and apmax
		ap = ap2
		IF (apelim) THEN
			ap = aw

		END IF
                
		IF (bpelim) THEN
			b2p = b2w

		END IF
            
            
            dg=ap*vljp(i)-aw*vljw(i)+b2p*velp(i)-b2w*velw(i)+c
            sum=sum+(dg-dgobs(i)+elcorr(i))**2
          END DO
!    write (*,*) aw,ap,bw,bp,c,sum_min,sum
          IF (sum < sum_min) THEN
            sum_min=sum
            awopt=aw
            bwopt=b2w
            apopt=ap
            bpopt=b2p
            copt=c
          END IF
        END DO
      END DO
    END DO
    
  END DO
!    write (*,*) aw,ap,bw,bp,c,sum_min,sum
  
END DO


!      write (*,*) 'PRESS=',press



! ************************************
! calulate the average of gObs
sum=0.
DO i=1,nlig
  sum=sum+dgobs(i)
END DO

averageobs=sum/REAL(nlig)

! ************************************






! *************************************
! calculate square sums and 'abs error' sum

sum=0.
ssm=0.
sse=0.
sst=0.

WRITE (*,*) 'All ligand optimization:'

DO i=1,nlig
  
  IF (bwmin == bwmax) THEN
    IF (bwmin == 0.) THEN
      bwopt=bcl(i)
    END IF
  END IF
  IF (bpmin == bpmax) THEN
    IF (bpmin == 0.) THEN
      bpopt=bcl(i)
    END IF
  END IF
  IF (bpelim) THEN
     bpopt = bwopt

  END IF
  
  dg=apopt*vljp(i)-awopt*vljw(i)+bpopt*velp(i)-bwopt*velw(i) +copt+elcorr(i)
  ssm=ssm+(dg-averageobs)**2
  sse=sse+(dg-dgobs(i))**2
  sst=sst+(dgobs(i)-averageobs)**2
  WRITE (*,'(i5,2f10.5)') i,dg,dgobs(i)
  sum=sum+ABS(dg-dgobs(i))
END DO


params=0

IF (awmin /= awmax) THEN
  params=params+1
END IF

IF (apmin /= apmax) THEN
  params=params+1
END IF

IF (bwmin /= bwmax) THEN
  params=params+1
END IF

IF (bpmin /= bpmax) THEN
  params=params+1
END IF

IF (cmin /= cmax) THEN
  params=params+1
END IF

spress=SQRT(press/REAL(nlig-params-1))


sum=sum/REAL(nlig)
qsqloo=1.-press/(sst)
rsq=1.-sse/sst
arsq=1.-(sse/sst)*REAL(nlig-1)/REAL(nlig-params)
arsqtva=1.-(REAL(nlig-1)/REAL(nlig-params))*(1.-rsq)
arsqapex=rsq-(REAL(params)/REAL(nlig-params-1))*(1.-rsq)

IF (bwmin == bwmax) THEN
  IF (bwmin == 0.) THEN
    bwopt=-1
  END IF
END IF

IF (bpmin == bpmax) THEN
  IF (bpmin == 0.) THEN
    bpopt=-1
  END IF
END IF



WRITE (*,'(3(a,f10.5))') 'Optimum: aw=',awopt,' ap=',apopt,  &
    ' bw=',bwopt,' bp=',bpopt,' c=',copt
WRITE (*,'(7a10)')'RMS','<|err|>','r2','q2loo','spressloo','press' ,'adj R2'
WRITE (*,'(7f10.5)') SQRT(sse/REAL(nlig)),sum,(1.-sse/(sst)),  &
    qsqloo, spress, press, arsq

WRITE (*, '(3(a,f10.5))') 'SST = ',sst,' SSM = ',ssm, ' SSE = ',sse

	call date_and_time(values=datum)
	write(*,134) datum(1),datum(2),datum(3),datum(5),datum(6),datum(7)  


#if defined (USE_MPI)

!!! master node
end if 



call MPI_Finalize(qdyn_ierr)








contains



subroutine init_nodes
   implicit none

   include "mpif.h"


   integer  :: MPI_AI_INTEGER, MPI_TINY_INTEGER
   
   external MPI_Address
   external MPI_Bcast

   call MPI_Bcast(awmin,  1, MPI_REAL8, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(awmax,  1, MPI_REAL8, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(apmin,  1, MPI_REAL8, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(apmax,  1, MPI_REAL8, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(bwmin,  1, MPI_REAL8, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(bwmax,  1, MPI_REAL8, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(bpmin,  1, MPI_REAL8, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(bpmax,  1, MPI_REAL8, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(cmin,  1, MPI_REAL8, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(cmax,  1, MPI_REAL8, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(da,  1, MPI_REAL8, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(db,  1, MPI_REAL8, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(dc,  1, MPI_REAL8, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(nlo,  1, MPI_INTEGER, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(nlig,  1, MPI_INTEGER, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(vljw,  nlig, MPI_REAL4, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(vljp,  nlig, MPI_REAL4, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(velp,  nlig, MPI_REAL4, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(velw,  nlig, MPI_REAL4, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(dgobs,  nlig, MPI_REAL4, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(elcorr, nlig, MPI_REAL4, 0, MPI_COMM_WORLD, ierr)
   call MPI_Bcast(bcl,  nlig, MPI_REAL4, 0, MPI_COMM_WORLD, ierr)

end subroutine init_nodes





#endif







END PROGRAM

























