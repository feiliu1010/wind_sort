pro locate_city_emis_USA
;this program is used to locate emissions of EDGAR
;EDGAR data resolution: 0.1 degree
FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data
;********************************
num=47
;num=63
Locate1=dblarr(5,num)
filename = '/home/liufei/Data/Wind_sort/City_list_USA.csv'
;filename = '/home/liufei/Data/Wind_sort/PP_list_USA.csv'
DELIMITER = ','
HEADERLINES = 1
Data= read_ascii(FILENAME, data_start=HEADERLINES,delimiter=DELIMITER)
Locate1=Data.(0)

nlon = 3600
nlat = 1800
grid = 0.1
lon = dblarr(nlon)
lat = dblarr(nlat)
lon = -180+grid/2+indgen(nlon)*grid
lat = 90-grid/2-indgen(nlat)*grid

pplon= fltarr(num)
pplat= fltarr(num)

;find the grid of city at EDGAR resolution
For i=0,num-1 do begin
pplon[i] = max( where( ( lon ge (Locate1[2,i]-grid/2)) and (lon le (Locate1[2,i]+grid/2)) ,count1) )
pplat[i] = max( where( ( lat ge (Locate1[1,i]-grid/2)) and (lat le (Locate1[1,i]+grid/2)) ,count2) )
;print,pplon[i],pplat[i]

if pplon[i] eq -1 then begin
        pplon[i]=where(abs(lon-Locate1[2,i]-grid/2) lt 10^(-5.0))
endif
if pplat[i] eq -1 then begin
        pplat[i]=where(abs(lat-Locate1[1,i]-grid/2) lt 10^(-5.0))
endif

endfor
;print,pplon

;**********************************
time1=2005
time2=2008
;every year has 1 data: annual NOX emissions
col=time2-time1+1
result=dblarr(col*1+1,num)
result[col*1,*]=Locate1[3,*]
header_output=strarr(col*1+1)
header_output[col*1]='name'

For times=time1,time2 do begin
	Yr4=string(times,format='(i4.4)')
        filename='/home/liufei/Data/Parameters/EDGAR/v42_NOx_'+Yr4+'_TOT.txt'
	nlines = FILE_LINES(filename)
	HEADERLINES = 3

	Locate = dblarr(3,nlines-HEADERLINES)
	unit   = dblarr(3,nlines-HEADERLINES)
        DELIMITER = ';'
        Data= read_ascii(FILENAME, data_start=HEADERLINES,delimiter=DELIMITER)
        Locate=Data.(0)
        unit=Locate
	;whether grid inside target area
	NOX		=dblarr(num)
	;NOX_OZone	=dblarr(num)
	num_tmp=size(unit)
	lat_tmp=unit[0,*]
        lon_tmp=unit[1,*]
	emis_tmp=unit[2,*]
	;print,size(lat_tmp)
	
	For i=0,num-1 do begin
	;For i=13,13 do begin
        	x = pplon[i]
 	        y = pplat[i]
		Dis_lon=Locate1[4,i]
		Dis_lat=Locate1[4,i]
		;split the target area in EDGAR
        	EDGAR_lat=lat_tmp(where((lat_tmp ge lat(y)-2) and (lat_tmp le lat(y)+2) and (lon_tmp ge lon(x)-2) and (lon_tmp le lon(x)+2)))
		EDGAR_lon=lon_tmp(where((lat_tmp ge lat(y)-2) and (lat_tmp le lat(y)+2) and (lon_tmp ge lon(x)-2) and (lon_tmp le lon(x)+2)))
		EDGAR_emis=emis_tmp(where((lat_tmp ge lat(y)-2) and (lat_tmp le lat(y)+2) and (lon_tmp ge lon(x)-2) and (lon_tmp le lon(x)+2)))


		num_tmp=size(EDGAR_emis)
		;print,num_tmp
                num_EDGAR=num_tmp[1]

		EDGAR=fltarr(3,num_EDGAR)		
		EDGAR[0,*]=EDGAR_lat
		EDGAR[1,*]=EDGAR_lon
		EDGAR[2,*]=EDGAR_emis
		
		;print,num_EDGAR
		;print,x,y,Dis_lon,Dis_lat
	        For j=0,num_EDGAR-1 do begin
		     ;print,lon[min([x+Dis_lon,nlon-1])]+grid/2
                     if (EDGAR[1,j] le lon[min([x+Dis_lon,nlon-1])]+grid/2) $ 
			 and (EDGAR[1,j] ge lon[max([x-Dis_lon,0])]-grid/2) $
                	 and (EDGAR[0,j] le lat[max([y-Dis_lat,0])]+grid/2) $ 
		         and (EDGAR[0,j] ge lat[min([y+Dis_lat,nlat-1])]-grid/2)  then begin    
			NOX[i]	 	 += EDGAR[2,j]
			;print, EDGAR[*,j]
			;NOX_OZone[i]     += unit[8,j]
			;print,NOX[i], lon[min([x+Dis_lon,nlon-1])]+grid/2,lon[max([x-Dis_lon,0])]-grid/2
                    endif
		endfor
        endfor
	
	result[(times-time1)*1,*]  =NOX
	;result[(times-time1)*2+1,*]=NOX_OZone
	
	header_output[(times-time1)*1]  =strcompress(string(Yr4+'_NOX'),/remove)
	;header_output[(times-time1)*2+1]=strcompress(string(Yr4+'_NOX_OZone'),/remove)

endfor


outfile ='/home/liufei/Data/Wind_sort/city_USA_EDGAR_info.asc'
;outfile ='/home/liufei/Data/Wind_sort/PP_USA_EDGAR_info.asc'
openw,lun,outfile,/get_lun,WIDTH=2500
printf,lun,header_output,result
close,lun
free_lun,lun

end
