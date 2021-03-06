    
!==========================================================================
!   uEMEP model gauss_plume_second_order_rotated_func
!   Rotationally symetric Gaussian plume function to second order
!==========================================================================

    function gauss_plume_second_order_rotated_func(r,z,ay,by,az,bz,sig_y_0,sig_z_0,h)

    implicit none
    real r,z,ay,by,az,bz,sig_y_0,sig_z_0,h
    real gauss_plume_second_order_rotated_func
    real sig_th,sig_z,B,c
    real order_1,order_2
    real pi
    parameter (pi=3.141592)
    
    r=max(0.001,r)
    order_1=1.
    order_2=1.
    
    sig_th=(sig_y_0+ay*(exp(by*log(r))))/r
    sig_z=sig_z_0+az*(exp(bz*log(r)))

    B=-(sig_th**2)*(bz*(sig_z-sig_z_0)/r/sig_th+by*(r*sig_th-sig_y_0)/sig_z)

    if (B.gt.-1.) then
        !c=1./(2.*pi*sqrt(2.*pi)*r*sig_z*sqrt(1.+B))*tanh(2/sqrt(pi)*pi/(2.*sqrt(2.))/sig_th*sqrt(1.+B))*(exp((-(z-h)**2)/2./sig_z**2)+exp((-(z+h)**2)/2./sig_z**2))
        c=1./(2.*pi*sqrt(2.*pi)*r*sig_z*sqrt(1.+B))*erf(pi/(2.*sqrt(2.))/sig_th*sqrt(1.+B))*(exp((-(z-h)**2)/2./sig_z**2)+exp((-(z+h)**2)/2./sig_z**2))
    else
        c=1./(4.*pi*sig_th*r*sig_z)*(1-order_1*pi**2*(1.+B)/(24*sig_th**2)+order_2*pi**4*((1.+B**2)/(640.*sig_th**4)))*(exp((-(z-h)**2)/2./sig_z**2)+exp((-(z+h)**2)/2./sig_z**2))
    endif
    
    gauss_plume_second_order_rotated_func=c

    end function gauss_plume_second_order_rotated_func
    
    
!==========================================================================
!   uEMEP model gauss_plume_second_order_rotated_func
!   Rotationally symetric Gaussian plume function to second order vertically integrated from H1 to H2
!==========================================================================

    function gauss_plume_second_order_rotated_integral_func(r,z,ay,by,az,bz,sig_y_0,sig_z_0,h,H1,H2)

    implicit none
    real r,z,ay,by,az,bz,sig_y_0,sig_z_0,h,H1,H2
    real gauss_plume_second_order_rotated_integral_func
    real sig_th,sig_z,B,c_y_int,c_z_int
    real order_1,order_2
    real pi
    parameter (pi=3.141592)
    
    r=max(0.001,r)
    order_1=1.
    order_2=1.
    
    sig_th=(sig_y_0+ay*(exp(by*log(r))))/r
    sig_z=sig_z_0+az*(exp(bz*log(r)))

    B=-(sig_th**2)*(bz*(sig_z-sig_z_0)/r/sig_th+by*(r*sig_th-sig_y_0)/sig_z)

    c_z_int=sqrt(pi/2.)*sig_z*(erf((H2-h)/sqrt(2.)/sig_z)-erf((H1-h)/sqrt(2.)/sig_z)+erf((H2+h)/sqrt(2.)/sig_z)-erf((H1+h)/sqrt(2.)/sig_z))/(H2-H1)

    if (B.gt.-1.) then
        !c_int=1./(2.*pi*sqrt(2.*pi)*r*sig_z*sqrt(1.+B))*tanh(2/sqrt(pi)*pi/(2.*sqrt(2.))/sig_th*sqrt(1.+B))
        c_y_int=1./(2.*pi*sqrt(2.*pi)*r*sig_z*sqrt(1.+B))*erf(pi/(2.*sqrt(2.))/sig_th*sqrt(1.+B))
    else
        c_y_int=1./(4.*pi*sig_th*r*sig_z)*(1-order_1*pi**2*(1.+B)/(24*sig_th**2)+order_2*pi**4*((1.+B**2)/(640.*sig_th**4)))
    endif
    
    gauss_plume_second_order_rotated_integral_func=c_y_int*c_z_int
    
    end function gauss_plume_second_order_rotated_integral_func

!==========================================================================
!   uEMEP model gauss_plume_cartesian_func
!   Cartesian Gaussian plume function
!==========================================================================

    function gauss_plume_cartesian_func(x_s,y_s,z_s,cos_val,sin_val,x_r,y_r,z_r,ay,by,az,bz,sig_y_0,sig_z_0,delta)

    implicit none
    real x_s,y_s,z_s,u_s,v_s,x_r,y_r,z_r
    real r,ay,by,az,bz,sig_y_0,sig_z_0,delta
    real gauss_plume_cartesian_func
    real sig_y,sig_z,x,y,th
    real cos_val,sin_val
    real pi,sig_limit
    parameter (pi=3.141592,sig_limit=4.)
    
    !r=sqrt((x_s-x_r)**2+(y_s-y_r)**2)
    !if (abs(u_s).lt.001) u_s=0.001
    !th=atan(v_s/u_s)
    !if (u_s.lt.0) th=th+pi
    !cos_val=cos(th)
    !sin_val=sin(th)
    x=(x_r-x_s)*cos_val+(y_r-y_s)*sin_val
    y=-(x_r-x_s)*sin_val+(y_r-y_s)*cos_val
    
    gauss_plume_cartesian_func=0.
    sig_y=sig_y_0+ay*exp(by*log(x))+x*abs(delta)
    if (x.ge.0.and.abs(y).lt.sig_y*sig_limit) then
        sig_z=sig_z_0+az*exp(bz*log(x))

        !write(*,*)sig_y_0,sig_y,sig_z_0,sig_z
        !gauss_plume_cartesian_func=1./(2.*pi*sig_y*sig_z)*exp((-y**2)/2./sig_y**2) &
        !    *(exp((-(z_r-z_s)**2)/2./sig_z**2)+exp((-(z_r+z_s)**2)/2./sig_z**2))
        gauss_plume_cartesian_func=1./(2.*pi*sig_y*sig_z)*exp(-y*y/2./sig_y/sig_y) &
            *(exp(-(z_r-z_s)*(z_r-z_s)/2./sig_z/sig_z)+exp(-(z_r+z_s)*(z_r+z_s)/2./sig_z/sig_z))
        
        
    endif
    
    end function gauss_plume_cartesian_func

!==========================================================================
!   uEMEP model gauss_plume_cartesian_integral_func
!   Cartesian Gaussian plume function
!==========================================================================

    function gauss_plume_cartesian_integral_func(x_s,y_s,z_s,cos_val,sin_val,x_r,y_r,z_r,ay,by,az,bz,sig_y_0,sig_z_0,H1,H2,delta)

    implicit none
    real x_s,y_s,z_s,u_s,v_s,x_r,y_r,z_r
    real r,ay,by,az,bz,sig_y_0,sig_z_0,H1,H2,delta
    real gauss_plume_cartesian_integral_func
    real sig_y,sig_z,x,y,th
    real cos_val,sin_val
    real pi,sig_limit
    parameter (pi=3.141592,sig_limit=4.)
    
    !r=sqrt((x_s-x_r)**2+(y_s-y_r)**2)
    !if (abs(u_s).lt.001) u_s=0.001
    !th=atan(v_s/u_s)
    !if (u_s.lt.0) th=th+pi
    !cos_val=cos(th)
    !sin_val=sin(th)
    x=(x_r-x_s)*cos_val+(y_r-y_s)*sin_val
    y=-(x_r-x_s)*sin_val+(y_r-y_s)*cos_val
    
    gauss_plume_cartesian_integral_func=0.
    sig_y=sig_y_0+ay*exp(by*log(x))+x*abs(delta)
    if (x.ge.0.and.abs(y).lt.sig_y*sig_limit) then
        sig_z=sig_z_0+az*exp(bz*log(x))

        !gauss_plume_cartesian_integral_func=1./(2.*pi*sig_y)*exp((-y**2)/2./sig_y**2) &
        !    *sqrt(pi/2.)*(erf((z_s-H1)/sqrt(2.)/sig_z)-erf((z_s-H2)/sqrt(2.)/sig_z)+erf((z_s+H2)/sqrt(2.)/sig_z)-erf((z_s+H1)/sqrt(2.)/sig_z))/(H2-H1)
        gauss_plume_cartesian_integral_func=1./(2.*pi*sig_y)*exp((-y*y)/2./(sig_y*sig_y)) &
            *sqrt(pi/2.)*(erf((z_s-H1)/sqrt(2.)/sig_z)-erf((z_s-H2)/sqrt(2.)/sig_z)+erf((z_s+H2)/sqrt(2.)/sig_z)-erf((z_s+H1)/sqrt(2.)/sig_z))/(H2-H1)
    endif
    
    end function gauss_plume_cartesian_integral_func

!==========================================================================
!   uEMEP model gauss_plume_second_order_rotated_vector_func
!   Rotationally symetric Gaussian plume function to second order
!==========================================================================

    subroutine gauss_plume_second_order_rotated_vector_sub(r,z,ay,by,az,bz,sig_y_0,sig_z_0,h,output,i_dim,j_dim)

    implicit none
    
    integer i_dim,j_dim
    real, allocatable, intent(in out) :: r(:,:)
    real, allocatable :: output(:,:)
    real z,ay,by,az,bz,sig_y_0,sig_z_0,h
    real, allocatable :: sig_th(:,:)
    real, allocatable :: sig_z(:,:)
    real, allocatable :: B(:,:)
    real order_1,order_2
    real pi
    parameter (pi=3.141592)
    
    !i_dim=size(r,1)
    !j_dim=size(r,2)
    
    if (.not.allocated(r)) allocate(r(i_dim,j_dim))
    if (.not.allocated(output)) allocate(output(i_dim,j_dim))
    allocate(sig_th(i_dim,j_dim))
    allocate(sig_z(i_dim,j_dim))
    allocate(B(i_dim,j_dim))


    where (r.eq.0) r=0.001
    order_1=1.
    order_2=1.
    
    sig_th=(sig_y_0+ay*(exp(by*log(r))))/r
    sig_z=sig_z_0+az*(exp(bz*log(r)))

    B=-(sig_th**2)*(bz*(sig_z-sig_z_0)/r/sig_th+by*(r*sig_th-sig_y_0)/sig_z)

    where (B.gt.-1.) 
        !c=1./(2.*pi*sqrt(2.*pi)*r*sig_z*sqrt(1.+B))*tanh(2/sqrt(pi)*pi/(2.*sqrt(2.))/sig_th*sqrt(1.+B))*(exp((-(z-h)**2)/2./sig_z**2)+exp((-(z+h)**2)/2./sig_z**2))
        output=1./(2.*pi*sqrt(2.*pi)*r*sig_z*sqrt(1.+B))*erf(pi/(2.*sqrt(2.))/sig_th*sqrt(1.+B))*(exp((-(z-h)**2)/2./sig_z**2)+exp((-(z+h)**2)/2./sig_z**2))
    elsewhere
        output=1./(4.*pi*sig_th*r*sig_z)*(1-order_1*pi**2*(1.+B)/(24*sig_th**2)+order_2*pi**4*((1.+B**2)/(640.*sig_th**4)))*(exp((-(z-h)**2)/2./sig_z**2)+exp((-(z+h)**2)/2./sig_z**2))
    end where
    
    !gauss_plume_second_order_rotated_vector_func=c

    end subroutine gauss_plume_second_order_rotated_vector_sub

!==========================================================================
!   uEMEP model gauss_plume_cartesian_trajectory_func
!   Cartesian Gaussian plume function that does not calculate direction but uses distance x and perpendicular distance y as input.
!   These are precalculated
!==========================================================================

    !function gauss_plume_cartesian_func(x_s,y_s,z_s,u_s,v_s,x_r,y_r,z_r,ay,by,az,bz,sig_y_0,sig_z_0)
    function gauss_plume_cartesian_trajectory_func(x,y,z_s,z_r,ay,by,az,bz,sig_y_0,sig_z_0,delta)

    implicit none
    real x,y,z_s,z_r
    real ay,by,az,bz,sig_y_0,sig_z_0,delta
    real gauss_plume_cartesian_trajectory_func
    real sig_y,sig_z,th
    real pi,sig_limit
    parameter (pi=3.141592,sig_limit=4.)
    
    !r=sqrt((x_s-x_r)**2+(y_s-y_r)**2)
    !if (abs(u_s).lt.001) u_s=0.001
    !th=atan(v_s/u_s)
    !if (u_s.lt.0) th=th+pi
    !cos_val=cos(th)
    !sin_val=sin(th)
    !x=(x_r-x_s)*cos_val+(y_r-y_s)*sin_val
    !y=-(x_r-x_s)*sin_val+(y_r-y_s)*cos_val
    
    gauss_plume_cartesian_trajectory_func=0.
    sig_y=sig_y_0+ay*exp(by*log(x))+x*abs(delta)
    if (x.ge.0.and.abs(y).lt.sig_y*sig_limit) then
        sig_z=sig_z_0+az*exp(bz*log(x))

        gauss_plume_cartesian_trajectory_func=1./(2.*pi*sig_y*sig_z)*exp((-y*y)/2./(sig_y*sig_y)) &
            *(exp((-(z_r-z_s)*(z_r-z_s))/2./(sig_z*sig_z))+exp((-(z_r+z_s)*(z_r+z_s))/2./(sig_z*sig_z)))
    endif
    
    end function gauss_plume_cartesian_trajectory_func

!==========================================================================
!   uEMEP model gauss_plume_cartesian_trajectory_integral_func
!   Cartesian Gaussian plume function
!==========================================================================

    function gauss_plume_cartesian_trajectory_integral_func(x,y,z_s,z_r,ay,by,az,bz,sig_y_0,sig_z_0,H1,H2,delta)

    implicit none
    real x,y,z_s,z_r
    real r,ay,by,az,bz,sig_y_0,sig_z_0,H1,H2,delta
    real gauss_plume_cartesian_trajectory_integral_func
    real sig_y,sig_z,th
    real pi,sig_limit
    parameter (pi=3.141592,sig_limit=4.)
    
    !r=sqrt((x_s-x_r)**2+(y_s-y_r)**2)
    !if (abs(u_s).lt.001) u_s=0.001
    !th=atan(v_s/u_s)
    !if (u_s.lt.0) th=th+pi
    !cos_val=cos(th)
    !sin_val=sin(th)
    !x=(x_r-x_s)*cos_val+(y_r-y_s)*sin_val
    !y=-(x_r-x_s)*sin_val+(y_r-y_s)*cos_val
    
    gauss_plume_cartesian_trajectory_integral_func=0.
    sig_y=sig_y_0+ay*exp(by*log(x))+x*abs(delta)
    if (x.ge.0.and.abs(y).lt.sig_y*sig_limit) then
        sig_z=sig_z_0+az*exp(bz*log(x))

        !gauss_plume_cartesian_integral_func=1./(2.*pi*sig_y)*exp((-y**2)/2./sig_y**2) &
        !    *sqrt(pi/2.)*(erf((z_s-H1)/sqrt(2.)/sig_z)-erf((z_s-H2)/sqrt(2.)/sig_z)+erf((z_s+H2)/sqrt(2.)/sig_z)-erf((z_s+H1)/sqrt(2.)/sig_z))/(H2-H1)
        gauss_plume_cartesian_trajectory_integral_func=1./(2.*pi*sig_y)*exp((-y*y)/2./(sig_y*sig_y)) &
            *sqrt(pi/2.)*(erf((z_s-H1)/sqrt(2.)/sig_z)-erf((z_s-H2)/sqrt(2.)/sig_z)+erf((z_s+H2)/sqrt(2.)/sig_z)-erf((z_s+H1)/sqrt(2.)/sig_z))/(H2-H1)
    endif
    
    end function gauss_plume_cartesian_trajectory_integral_func

