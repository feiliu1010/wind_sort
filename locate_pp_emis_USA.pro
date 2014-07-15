pro locate_pp_emis_USA
;this program is used to locate emissions of single unit
;satellite data resolution: 0.18 degree
FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data
;********************************
num=63
Locate1=dblarr(4,num)
filename = '/home/liufei/Data/Wind_sort/PP_distance_list_USA.csv'
DELIMITER = ','
HEADERLINES = 1
Data= read_ascii(FILENAME, data_start=HEADERLINES,delimiter=DELIMITER)
Locate1=Data.(0)

nlon = 183*2
nlat = 113*2
grid = 0.18
lon = dblarr(nlon)
lat = dblarr(nlat)
lon = -130.32+grid/2+indgen(nlon)*grid
lat = 55.08-grid/2-indgen(nlat)*grid

pplon= fltarr(num)
pplat= fltarr(num)

;find the grid of pp at satellite resolution
For i=0,num-1 do begin
pplon[i] = max( where( ( lon ge (Locate1[1,i]-grid/2)) and (lon le (Locate1[1,i]+grid/2)) ,count1) )
pplat[i] = max( where( ( lat ge (Locate1[2,i]-grid/2)) and (lat le (Locate1[2,i]+grid/2)) ,count2) )
;print,pplon[i],pplat[i]

if pplon[i] eq -1 then begin
        pplon[i]=where(abs(lon-Locate1[1,i]-grid/2) lt 10^(-5.0))
endif
if pplat[i] eq -1 then begin
        pplat[i]=where(abs(lat-Locate1[2,i]-grid/2) lt 10^(-5.0))
endif

endfor
;print,Locate[1,0]
;print,pplon

;**********************************
time1=1
time2=5
;every year has 2 data: annual NOX emissions, ozone season NOX emissions
col=time2-time1+1
result=dblarr(col*2+1,num)
result[col*2,*]=Locate1[0,*]
header_output=strarr(col*2+1)
header_output[col*2]='PP_ID'

For times=time1,time2 do begin
	case times of
                1:Yr4='2005'
                2:Yr4='2007'
                3:Yr4='2009'
                4:Yr4='2010'
                else:Yr4='average'
        endcase


	case times of
;		2005
		1:num_pp=4998
;		2007
		2:num_pp=5172
;		2009
		3:num_pp=5492
;		2010
		4:num_pp=5587
		else:num_pp=6021
	endcase

        Locate = dblarr(15,num_pp)
        unit   = dblarr(15,num_pp)
        filename='/home/liufei/Data/Wind_sort/emission_plant_'+Yr4+'.csv'
        DELIMITER = ','
        HEADERLINES = 3
        Data= read_ascii(FILENAME, data_start=HEADERLINES,delimiter=DELIMITER)
        Locate=Data.(0)
        unit=Locate
	;whether pp inside target area
	NOX		=dblarr(num)
	NOX_OZone	=dblarr(num)
	For i=0,num-1 do begin
        	x = pplon[i]
 	        y = pplat[i]
		Dis_lon=Locate1[3,i]
		Dis_lat=Locate1[3,i]
		;print,x,y,Dis_lon,Dis_lat
	        For j=0,num_pp-1 do begin
		     ;print,lon[min([x+Dis_lon,nlon-1])]+grid/2
                     if (unit[5,j] le lon[min([x+Dis_lon,nlon-1])]+grid/2) $ 
			 and (unit[5,j] ge lon[max([x-Dis_lon,0])]-grid/2) $
                	 and (unit[4,j] le lat[max([y-Dis_lat,0])]+grid/2) $ 
		         and (unit[4,j] ge lat[min([y+Dis_lat,nlat-1])]-grid/2) then begin    
			NOX[i]	 	 += unit[7,j]
			NOX_OZone[i]     += unit[8,j]
			;print,NOX[i], lon[min([x+Dis_lon,nlon-1])]+grid/2,lon[max([x-Dis_lon,0])]-grid/2
                    endif
		endfor
        endfor
	
	result[(times-time1)*2,*]  =NOX
	result[(times-time1)*2+1,*]=NOX_OZone
	
	header_output[(times-time1)*2]  =strcompress(string(Yr4+'_NOX'),/remove)
	header_output[(times-time1)*2+1]=strcompress(string(Yr4+'_NOX_OZone'),/remove)

endfor


outfile ='/home/liufei/Data/Wind_sort/PP_USA_info.asc'
openw,lun,outfile,/get_lun,WIDTH=2500
printf,lun,header_output,result
close,lun
free_lun,lun

end
