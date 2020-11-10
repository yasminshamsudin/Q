!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!        By Masoud Kazemi 2013/08/09         !
!           revised 2014/06/02               !
!  top_parser module for writting fep files  !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

program cluster

implicit none

 real(4)                                                ::      matA(10000,2),dummy(10),Emin=999,Emax=-999 !3D matrix for saving all data points
 real(4)                                                ::      gaprange,xint
 real(4),allocatable                                    ::      avG(:),avG2(:),bincount(:)
 integer                                                ::      npnt,ipnt=0,u,msg,k,nbin=100,ibin
 character(len=50)                                      ::      ifilename,output,line



call getarg(1,ifilename)
call getarg(2,line)

if(len_trim(line) .gt. 0 ) then
        read(line,*),nbin
end if


u = freefile()

open (file=ifilename, unit=u, form="formatted", access="sequential", status="old", iostat=msg, action="read")
call errormsg(msg,"State file name could not be allocated.")


do while ( msg .eq. 0 ) 
        read (unit=u,fmt='(a)',iostat=msg) line
        call errormsg(msg,"Data is not readable...")

        if(len_trim(line) .gt. 0 ) then
        ipnt=ipnt+1
        read ( line ,fmt=*),dummy(1),matA(ipnt,1),dummy(2),matA(ipnt,2)
                if (matA(ipnt,1) .lt. Emin ) then
                        Emin = matA(ipnt,1)
                end if
                if (matA(ipnt,1) .gt. Emax ) then
                        Emax = matA(ipnt,1)
                end if

        end if
end do

!shift min max by -1 and 1 to avoid end point problem
Emin=Emin-1
Emax=Emax+1

!assign # points
npnt=ipnt

allocate(avG(nbin),avG2(nbin),bincount(nbin))

!initialize
avG(:)=0
avG2(:)=0
bincount(:)=0

!get interval and dx
gaprange=Emax-Emin
xint=gaprange/real(nbin)

do ipnt=1,npnt
        !find bin
        ibin=int((matA(ipnt,1)-Emin)/xint)+1
!        print*,ipnt,(matA(ipnt,k),k=1,2),ibin
        !sum over G
        avG(ibin)=avG(ibin)+(matA(ipnt,2))
        !sum over G2
        avG2(ibin)=avG2(ibin)+ ((matA(ipnt,2))*(matA(ipnt,2)))
        !bin points
        bincount(ibin)=bincount(ibin)+1
end do
        write(*,*),"          #    avG         sqrt(S)       SEM"
do ibin=1,nbin
        if (bincount(ibin) .gt. 0) then
        !average G
        avG(ibin)=avG(ibin)/bincount(ibin)
        !average G
        avG2(ibin)=avG2(ibin)/bincount(ibin)
        write(*,'(2X,f8.3,3X,f7.3,3X,f7.3,3X,f7.3)',iostat=msg),Emin+(ibin*xint)-(xint/2)    &
                            ,avG(ibin),sqrt(avG2(ibin)-(avG(ibin)**2)), sqrt(avG2(ibin)-(avG(ibin)**2))/sqrt(bincount(ibin))
        end if
end do















contains
!-----------------------------------------------------------------------------------------------------------------------------!
!                                                      freefile : get the free unit number                                    !
!-----------------------------------------------------------------------------------------------------------------------------!
integer function freefile()

        integer(4)                                        ::        u
        logical                                           ::        used

        do u = 20, 999                
                inquire(unit=u, opened=used)
                if(.not. used)  then
                        freefile = u
                        return
                end if
        end do

        !if we get here then we're out of unit numbers
        write(*,20)
        stop 

20        format('ERROR: Failed to find an unused unit number')

end function freefile
!-----------------------------------------------------------------------------------------------------------------------------!
!                                                                 subroutine errormsg                                         !
!-----------------------------------------------------------------------------------------------------------------------------!
subroutine errormsg(msg,emsg,filenam)
        integer(4)                ,intent(in)                   ::        msg
        character(len=*),intent(in)                             ::        emsg
        character(len=*),intent(in),optional                    ::        filenam
        if (present(filenam)) then
                if (msg > 0) then
                        print*, filenam, emsg,".   stoping program..."
                        stop
                end if
        else
                if (msg > 0) then
                        print*, emsg,".   stoping program..."
                        stop
                end if
        end if
end subroutine errormsg


end program cluster
