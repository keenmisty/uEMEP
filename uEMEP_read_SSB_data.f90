!uEMEP_read_SSB_data.f90
    
    
    subroutine uEMEP_read_SSB_data
 
    use uEMEP_definitions
    
    implicit none
    
    character(256) temp_name
    character(256) temp_str,temp_str1,temp_str2
    real temp_val
    integer unit_in
    integer exists
    integer count,index_val
    integer temp_int
    integer*8 ssb_id
    real dwe_todw,dwe_det,dwe_2dw,dwe_row,dwe_mult,dwe_com,dwe_oth,dwe_area
    real pop_tot,emp_tot
    integer i_ssb_index,j_ssb_index
    integer source_index,subsource_index
    integer t
    integer, allocatable :: count_subgrid(:,:)
    real, allocatable :: temp1_subgrid(:,:),temp2_subgrid(:,:),temp3_subgrid(:,:)
   
    real x_ssb,y_ssb
    real :: f_easting=2.e6
    integer SSB_file_index
    real :: ssb_dx=250.,ssb_dy=250.
    real heating_proxy
    integer :: use_region=0
    real y_32,x_32,lat_32,lon_32
    
    write(unit_logfile,'(A)') ''
	write(unit_logfile,'(A)') '================================================================'
	write(unit_logfile,'(A)') 'Reading SSB data  (uEMEP_read_SSB_data)'
	write(unit_logfile,'(A)') '================================================================'
    
    source_index=heating_index
    n_subsource(source_index)=1
    t=1

    !Initialise the use_grid array to false if population is to be used for the auto subgridding
    if (use_population_positions_for_auto_subgrid_flag) then
        use_subgrid=.false.
    endif
    
    !If dwellings are read then allocate the emission heating arrays. Other wise allocate the population arrays
    if (SSB_data_type.eq.dwelling_index) then
        proxy_emission_subgrid(:,:,source_index,:)=0.
        allocate (count_subgrid(emission_subgrid_dim(x_dim_index,source_index),emission_subgrid_dim(y_dim_index,source_index)))
        allocate (temp1_subgrid(emission_subgrid_dim(x_dim_index,source_index),emission_subgrid_dim(y_dim_index,source_index)))
        allocate (temp2_subgrid(emission_subgrid_dim(x_dim_index,source_index),emission_subgrid_dim(y_dim_index,source_index)))
        allocate (temp3_subgrid(emission_subgrid_dim(x_dim_index,source_index),emission_subgrid_dim(y_dim_index,source_index)))
    else
        allocate (count_subgrid(population_subgrid_dim(x_dim_index),population_subgrid_dim(y_dim_index)))
        allocate (temp1_subgrid(population_subgrid_dim(x_dim_index),population_subgrid_dim(y_dim_index)))
        allocate (temp2_subgrid(population_subgrid_dim(x_dim_index),population_subgrid_dim(y_dim_index)))
        allocate (temp3_subgrid(population_subgrid_dim(x_dim_index),population_subgrid_dim(y_dim_index)))
    endif
    
    count_subgrid=0
        
    SSB_file_index=SSB_data_type
    
    if (SSB_data_type.eq.dwelling_index) then
        pathfilename_heating(SSB_file_index)=trim(pathname_heating(SSB_file_index))//trim(filename_heating(SSB_file_index))
 
        !Test existence of the heating filename. If does not exist then use default
        inquire(file=trim(pathfilename_heating(SSB_file_index)),exist=exists)
        if (.not.exists) then
            write(unit_logfile,'(A,A)') ' ERROR: SSB file does not exist: ', trim(pathfilename_heating(SSB_file_index))
            stop
        endif
        
        temp_name=pathfilename_heating(SSB_file_index)
    else
        pathfilename_population(SSB_file_index)=trim(pathname_population(SSB_file_index))//trim(filename_population(SSB_file_index))
        
        !Test existence of the heating filename. If does not exist then use default
        inquire(file=trim(pathfilename_population(SSB_file_index)),exist=exists)
        if (.not.exists) then
            write(unit_logfile,'(A,A)') ' ERROR: SSB file does not exist: ', trim(pathfilename_population(SSB_file_index))
            stop
        endif
        
        temp_name=pathfilename_population(SSB_file_index)
       
    endif
    
 
    !Open the file for reading
    unit_in=20
    open(unit_in,file=temp_name,access='sequential',status='old',readonly)  
    write(unit_logfile,'(a)') ' Opening SSB file '//trim(temp_name)
    
    rewind(unit_in)

    subsource_index=1
    
    !Read header SSBID0250M;dwe_todw;dwe_det;dwe_2dw;dwe_row;dwe_mult;dwe_com;dwe_oth;dwe_area
    read(unit_in,'(A)') temp_str
    write(*,'(A)') 'Header: '//trim(temp_str)
    !read(unit_in,'(A)') temp_str
    !write(*,*) trim(temp_str)
    count=0
    do while(.not.eof(unit_in))
        ssb_id=0;dwe_todw=0;dwe_mult=0;pop_tot=0;emp_tot=0
        if (SSB_data_type.eq.dwelling_index) then
            
            !Read in file string    
            read(unit_in,'(A)') temp_str
            !Extract the ssb id for the coordinates
            index_val=index(temp_str,';',back=.false.);temp_str1=temp_str(1:index_val-1);temp_str=temp_str(index_val+1:);if (index_val.gt.1) read(temp_str1,*) ssb_id
            !Extract the total number of dwellings
            index_val=index(temp_str,';',back=.false.);temp_str1=temp_str(1:index_val-1);temp_str=temp_str(index_val+1:);if (index_val.gt.1) read(temp_str1,*) dwe_todw

            !Skip over some values not to be used
            index_val=index(temp_str,';',back=.false.);temp_str1=temp_str(1:index_val-1);temp_str=temp_str(index_val+1:);if (index_val.gt.1) read(temp_str1,*) temp_int
            index_val=index(temp_str,';',back=.false.);temp_str1=temp_str(1:index_val-1);temp_str=temp_str(index_val+1:);if (index_val.gt.1) read(temp_str1,*) temp_int
            index_val=index(temp_str,';',back=.false.);temp_str1=temp_str(1:index_val-1);temp_str=temp_str(index_val+1:);if (index_val.gt.1) read(temp_str1,*) temp_int
        
            !Extract the multiple dwellings number
            index_val=index(temp_str,';',back=.false.);temp_str1=temp_str(1:index_val-1);temp_str=temp_str(index_val+1:);if (index_val.gt.1) read(temp_str1,*) dwe_mult
            
        endif

        if (SSB_data_type.eq.population_index) then

            !Read in file string    
            read(unit_in,'(A)') temp_str
            !write(*,*) trim(temp_str)
            !Extract the ssb id for the coordinates
            index_val=index(temp_str,';',back=.false.);temp_str1=temp_str(1:index_val-1);temp_str=temp_str(index_val+1:);if (index_val.gt.1) read(temp_str1,*) ssb_id
            !write(*,*) trim(temp_str)
            !index_val=index(temp_str,';',back=.false.);temp_str1=temp_str(1:index_val-1);temp_str=temp_str(index_val+1:);if (index_val.gt.1) read(temp_str1,*) pop_tot
            read(temp_str,*) pop_tot
            !write (*,*) ssb_id,pop_tot,index_val
        endif
    
        if (SSB_data_type.eq.establishment_index) then

            !Read in file string    
            read(unit_in,'(A)') temp_str
            !write(*,*) trim(temp_str)
            !Extract the ssb id for the coordinates
            index_val=index(temp_str,';',back=.false.);temp_str1=temp_str(1:index_val-1);temp_str=temp_str(index_val+1:);if (index_val.gt.1) read(temp_str1,*) ssb_id
            !write(*,*) trim(temp_str)
            index_val=index(temp_str,';',back=.false.);temp_str1=temp_str(1:index_val-1);temp_str=temp_str(index_val+1:);if (index_val.gt.1) read(temp_str1,*) temp_int
            read(temp_str,*) pop_tot
            !write (*,*) ssb_id,pop_tot,index_val
        endif

        if (SSB_data_type.eq.kindergaten_index.or.SSB_data_type.eq.school_index) then

            !Read in file string    
            read(unit_in,'(A)') temp_str
            !write(*,'(a)') trim(temp_str)
            !Extract the ssb id for the coordinates
            index_val=index(temp_str,',',back=.false.);temp_str1=temp_str(1:index_val-1);temp_str=temp_str(index_val+1:);if (index_val.gt.1) read(temp_str1,*) x_ssb
            index_val=index(temp_str,',',back=.false.);temp_str1=temp_str(1:index_val-1);temp_str=temp_str(index_val+1:);if (index_val.gt.1) read(temp_str1,*) y_ssb
            index_val=index(temp_str,',',back=.false.);temp_str1=temp_str(1:index_val-1);temp_str=temp_str(index_val+1:);if (index_val.gt.1) read(temp_str1,*) temp_str2
            index_val=index(temp_str,',',back=.false.);temp_str1=temp_str(1:index_val-1);temp_str=temp_str(index_val+1:);if (index_val.gt.1) read(temp_str1,*) temp_int
            !write(*,'(a)') trim(temp_str)
            index_val=index(temp_str,',',back=.false.);temp_str1=temp_str(1:index_val-1);temp_str=temp_str(index_val+1:);if (index_val.gt.1) read(temp_str1,*) pop_tot
            !read(temp_str,*) pop_tot
            !write (*,*) x_ssb,y_ssb,pop_tot
        endif

        if (SSB_data_type.eq.home_index) then

            !Read in file string    
            read(unit_in,'(A)') temp_str
            !write(*,'(a)') trim(temp_str)
            !Extract the ssb id for the coordinates
            index_val=index(temp_str,',',back=.false.);temp_str1=temp_str(1:index_val-1);temp_str=temp_str(index_val+1:);if (index_val.gt.1) read(temp_str1,*) temp_str2
            index_val=index(temp_str,',',back=.false.);temp_str1=temp_str(1:index_val-1);temp_str=temp_str(index_val+1:);if (index_val.gt.1) read(temp_str1,*) y_ssb
            index_val=index(temp_str,',',back=.false.);temp_str1=temp_str(1:index_val-1);temp_str=temp_str(index_val+1:);if (index_val.gt.1) read(temp_str1,*) x_ssb
            !index_val=index(temp_str,',',back=.false.);temp_str1=temp_str(1:index_val-1);temp_str=temp_str(index_val+1:);if (index_val.gt.1) read(temp_str1,*) pop_tot
            read(temp_str,*) pop_tot
            !write (*,*) trim(temp_str2),y_32,x_32,pop_tot
            
            !Convert from UTM32 to 33
            !call UTM2LL(utm_zone-1,y_32,x_32,lat_32,lon_32)
            !write(*,*) lat_32,lon_32
            !call LL2UTM(1,utm_zone,lat_32,lon_32,y_ssb,x_ssb)
            !write(*,*) y_ssb,x_ssb
        endif

        count=count+1
        if (mod(count,100000).eq.0) write(*,*) count,ssb_id,dwe_todw,dwe_mult,pop_tot
        
        if  (dwe_todw.gt.0.or.pop_tot.gt.0) then
            
            !Convert id to grid centre coordinates that are already in UTM33 for SSB data
            if (SSB_data_type.eq.dwelling_index.or.SSB_data_type.eq.establishment_index.or.SSB_data_type.eq.population_index) then
                x_ssb=ssb_id/10000000-f_easting+ssb_dx/2.
                y_ssb=mod(ssb_id,10000000)+ssb_dy/2.
            endif
            
            !write(*,*) x_ssb,y_ssb
            !Convert lat lon to utm coords
            !call LL2UTM(1,utm_zone,ddlatitude,ddlongitude,y_ship,x_ship)
        
            !Add to heating emission proxy subgrid       
            if (SSB_data_type.eq.dwelling_index) then
                
                !Find the grid index it belongs to
                i_ssb_index=1+floor((x_ssb-emission_subgrid_min(x_dim_index,source_index))/emission_subgrid_delta(x_dim_index,source_index)+0.5)
                j_ssb_index=1+floor((y_ssb-emission_subgrid_min(y_dim_index,source_index))/emission_subgrid_delta(y_dim_index,source_index)+0.5)

                if (i_ssb_index.ge.1.and.i_ssb_index.le.emission_subgrid_dim(x_dim_index,source_index) &
                    .and.j_ssb_index.ge.1.and.j_ssb_index.le.emission_subgrid_dim(y_dim_index,source_index)) then

        
                    !Reduce the number of dwellings when they are in a multiple dwelling by factor of 3. i.e. the proxy is reduced in blocks with the assumption that only 1 in 3 use their wood heater
                    heating_proxy=dwe_todw
                    heating_proxy=max(0.,dwe_todw-dwe_mult)+dwe_mult/3.
                    proxy_emission_subgrid(i_ssb_index,j_ssb_index,source_index,subsource_index)=proxy_emission_subgrid(i_ssb_index,j_ssb_index,source_index,subsource_index)+heating_proxy
                    count_subgrid(i_ssb_index,j_ssb_index)=count_subgrid(i_ssb_index,j_ssb_index)+1
                    !write(*,*) count,proxy_emission_subgrid(i_ssb_index,j_ssb_index,source_index,subsource_index)
                endif
                    
            else
                
                !Find the grid index it belongs to in the population grid
                i_ssb_index=1+floor((x_ssb-population_subgrid_min(x_dim_index))/population_subgrid_delta(x_dim_index)+0.5)
                j_ssb_index=1+floor((y_ssb-population_subgrid_min(y_dim_index))/population_subgrid_delta(y_dim_index)+0.5)

                if (i_ssb_index.ge.1.and.i_ssb_index.le.population_subgrid_dim(x_dim_index) &
                    .and.j_ssb_index.ge.1.and.j_ssb_index.le.population_subgrid_dim(y_dim_index).and.pop_tot.gt.0) then

                    population_subgrid(i_ssb_index,j_ssb_index,SSB_data_type)=population_subgrid(i_ssb_index,j_ssb_index,SSB_data_type)+pop_tot
                    count_subgrid(i_ssb_index,j_ssb_index)=count_subgrid(i_ssb_index,j_ssb_index)+1
                    !write(*,*) count,proxy_emission_subgrid(i_ssb_index,j_ssb_index,source_index,subsource_index)
                    
                endif

                if (use_population_positions_for_auto_subgrid_flag) then
                    !Cover the grids when target grids are smaller than population grids
                    if (SSB_data_type.eq.population_index) then
                        use_region=floor(population_subgrid_delta(x_dim_index)/subgrid_delta(x_dim_index)/2.)
                    endif
                    
                    !Find the grid index it belongs to in the target grid
                    i_ssb_index=1+floor((x_ssb-subgrid_min(x_dim_index))/subgrid_delta(x_dim_index)+0.5)
                    j_ssb_index=1+floor((y_ssb-subgrid_min(y_dim_index))/subgrid_delta(y_dim_index)+0.5)
                    if (i_ssb_index-use_region.ge.1.and.i_ssb_index+use_region.le.subgrid_dim(x_dim_index) &
                        .and.j_ssb_index-use_region.ge.1.and.j_ssb_index+use_region.le.subgrid_dim(y_dim_index).and.pop_tot.gt.0) then
                         use_subgrid(i_ssb_index-use_region:i_ssb_index+use_region,j_ssb_index-use_region:j_ssb_index+use_region,:)=.true.
                    endif
                        
                endif

            endif
            
        endif
             
    enddo
    
    if (SSB_data_type.eq.dwelling_index) then
        write(unit_logfile,'(A,I)') 'Dwelling counts = ',count
        write(unit_logfile,'(A,es12.3)') 'Total dwellings = ',sum(proxy_emission_subgrid(1:emission_subgrid_dim(x_dim_index,source_index),1:emission_subgrid_dim(y_dim_index,source_index),source_index,subsource_index))
        write(unit_logfile,'(A,I,a,i,a)') 'Number of grid placements = ',sum(count_subgrid(1:emission_subgrid_dim(x_dim_index,source_index),1:emission_subgrid_dim(y_dim_index,source_index))),' of ',emission_subgrid_dim(x_dim_index,source_index)*emission_subgrid_dim(y_dim_index,source_index),' grids'
    else
        write(unit_logfile,'(A,I)') 'Population type index = ',SSB_data_type
        write(unit_logfile,'(A,I)') 'Population counts = ',count
        write(unit_logfile,'(A,es12.3)') 'Total population = ',sum(population_subgrid(:,:,SSB_data_type))
        write(unit_logfile,'(A,I,a,i,a)') 'Number of grid placements = ',sum(count_subgrid),' of ',subgrid_dim(x_dim_index)*subgrid_dim(y_dim_index),' grids'
    endif
    
    close(unit_in)
    
    
    deallocate (count_subgrid)

    !Find the number of subgrids to be used
    if (use_population_positions_for_auto_subgrid_flag.and.SSB_data_type.ne.dwelling_index) then
        count=0
        do j=1,subgrid_dim(y_dim_index)
        do i=1,subgrid_dim(x_dim_index)
            if (use_subgrid(i,j,allsource_index)) count=count+1
        enddo
        enddo
        write(unit_logfile,'(a,i,a,i)') ' Using population for subgrids. Number of subgrids to be calculated based on population = ', count,' of ',subgrid_dim(y_dim_index)*subgrid_dim(x_dim_index)
    endif
    
   
    if (save_intermediate_files) then
    if (SSB_data_type.eq.dwelling_index) then
        temp_name=trim(pathname_grid(proxy_emission_file_index(source_index)))//trim(filename_grid(proxy_emission_file_index(source_index)))//trim(subsource_str(subsource_index))//'_'//trim(var_name_nc(conc_nc_index,compound_index,allsource_index))//'_'//trim(file_tag)//'.asc'
        write(unit_logfile,'(a)')'Writing to: '//trim(temp_name)
        !write(*,*) emission_subgrid_dim(x_dim_index,source_index),emission_subgrid_dim(y_dim_index,source_index),emission_subgrid_delta(x_dim_index,source_index)
        !write(*,*) size(emission_subgrid,1),size(emission_subgrid,2),size(emission_subgrid,3),size(emission_subgrid,4),size(emission_subgrid,5)
        !write(*,*) size(x_emission_subgrid(1:emission_subgrid_dim(x_dim_index,source_index),1:emission_subgrid_dim(y_dim_index,source_index),source_index),1),size(x_emission_subgrid(1:emission_subgrid_dim(x_dim_index,source_index),1:emission_subgrid_dim(y_dim_index,source_index),source_index),2)
        !write(*,*) size(y_emission_subgrid(1:emission_subgrid_dim(x_dim_index,source_index),1:emission_subgrid_dim(y_dim_index,source_index),source_index),1),size(y_emission_subgrid(1:emission_subgrid_dim(x_dim_index,source_index),1:emission_subgrid_dim(y_dim_index,source_index),source_index),2)
       ! write(*,*) size(emission_subgrid(1:emission_subgrid_dim(x_dim_index,source_index),1:emission_subgrid_dim(y_dim_index,source_index),t,source_index,subsource_index),1),size(emission_subgrid(1:emission_subgrid_dim(x_dim_index,source_index),1:emission_subgrid_dim(y_dim_index,source_index),t,source_index,subsource_index),2)
        
        temp1_subgrid=proxy_emission_subgrid(1:emission_subgrid_dim(x_dim_index,source_index),1:emission_subgrid_dim(y_dim_index,source_index),source_index,subsource_index)
        temp2_subgrid=x_emission_subgrid(1:emission_subgrid_dim(x_dim_index,source_index),1:emission_subgrid_dim(y_dim_index,source_index),source_index)
        temp3_subgrid=y_emission_subgrid(1:emission_subgrid_dim(x_dim_index,source_index),1:emission_subgrid_dim(y_dim_index,source_index),source_index)
        !write(*,*) size(temp_subgrid,1),size(temp_subgrid,2)
        call write_esri_ascii_file(unit_logfile,temp_name,emission_subgrid_dim(x_dim_index,source_index),emission_subgrid_dim(y_dim_index,source_index),emission_subgrid_delta(x_dim_index,source_index), &
                temp1_subgrid,temp2_subgrid,temp3_subgrid)
    else
        
        temp_name=trim(pathname_grid(population_file_index(SSB_data_type)))//trim(filename_grid(population_file_index(SSB_data_type)))//'_'//trim(file_tag)//'.asc'
        write(unit_logfile,'(a)')'Writing to: '//trim(temp_name)
        !write(*,*) emission_subgrid_dim(x_dim_index,source_index),emission_subgrid_dim(y_dim_index,source_index),emission_subgrid_delta(x_dim_index,source_index)
        !write(*,*) size(emission_subgrid,1),size(emission_subgrid,2),size(emission_subgrid,3),size(emission_subgrid,4),size(emission_subgrid,5)
        !write(*,*) size(x_emission_subgrid(1:emission_subgrid_dim(x_dim_index,source_index),1:emission_subgrid_dim(y_dim_index,source_index),source_index),1),size(x_emission_subgrid(1:emission_subgrid_dim(x_dim_index,source_index),1:emission_subgrid_dim(y_dim_index,source_index),source_index),2)
        !write(*,*) size(y_emission_subgrid(1:emission_subgrid_dim(x_dim_index,source_index),1:emission_subgrid_dim(y_dim_index,source_index),source_index),1),size(y_emission_subgrid(1:emission_subgrid_dim(x_dim_index,source_index),1:emission_subgrid_dim(y_dim_index,source_index),source_index),2)
       ! write(*,*) size(emission_subgrid(1:emission_subgrid_dim(x_dim_index,source_index),1:emission_subgrid_dim(y_dim_index,source_index),t,source_index,subsource_index),1),size(emission_subgrid(1:emission_subgrid_dim(x_dim_index,source_index),1:emission_subgrid_dim(y_dim_index,source_index),t,source_index,subsource_index),2)
        
        temp1_subgrid=population_subgrid(:,:,SSB_data_type)
        temp2_subgrid=x_population_subgrid
        temp3_subgrid=y_population_subgrid
        !write(*,*) size(temp_subgrid,1),size(temp_subgrid,2)
        call write_esri_ascii_file(unit_logfile,temp_name,population_subgrid_dim(x_dim_index),population_subgrid_dim(y_dim_index),population_subgrid_delta(x_dim_index), &
                temp1_subgrid,temp2_subgrid,temp3_subgrid)
    endif
    endif

    deallocate (temp1_subgrid,temp2_subgrid,temp3_subgrid)
    
    end subroutine uEMEP_read_SSB_data
    
