pro map_info_China
;this program is used to mapping information (from MEIC total emissions)
;MEIC resolution: 0.1 degree
FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_Get_Data
;********************************
num=93
Locate=dblarr(5,num)
filename = '/home/liufei/Data/Wind_sort/List_China.csv'
DELIMITER = ','
HEADERLINES = 1
Data= read_ascii(FILENAME, data_start=HEADERLINES,delimiter=DELIMITER)
Locate=Data.(0)
Dis=dblarr(num)
Dis=Locate[4,*]

nlon = 800
nlat = 500
grid = 0.1
lon = dblarr(nlon)
lat = dblarr(nlat)
lon = 70+grid/2+indgen(nlon)*grid
lat = 60-grid/2-indgen(nlat)*grid

pplon= fltarr(num)
pplat= fltarr(num)

;find the grid of city at MEIC resolution
For i=0,num-1 do begin
pplon[i] = max( where( ( lon ge (Locate[2,i]-grid/2)) and (lon le (Locate[2,i]+grid/2)) ,count1) )
pplat[i] = max( where( ( lat ge (Locate[1,i]-grid/2)) and (lat le (Locate[1,i]+grid/2)) ,count2) )

if pplon[i] eq -1 then begin
        pplon[i]=where(abs(lon-Locate[2,i]-grid/2) lt 10^(-5.0))
endif
if pplat[i] eq -1 then begin
        pplat[i]=where(abs(lat-Locate[1,i]-grid/2) lt 10^(-5.0))
endif

endfor



;**********************************
year1=2005
year2=2012
col=year2-year1+1
result=dblarr(col*4,num)
header_output=strarr(col*4)

For year=year1,year2 do begin

Yr4= string(year,format='(i4.4)')


;calculate the annual emissions
density1=dblarr(nlon,nlat)
density2=dblarr(nlon,nlat)
density3=dblarr(nlon,nlat)
density4=dblarr(nlon,nlat)
sum=dblarr(nlon,nlat)
pp=dblarr(nlon,nlat)

filename ='/home/liufei/Data/Parameters/MEIC_Emission/0.1/'+Yr4+'/'+Yr4+'__residential__NOx.nc'
fid=NCDF_OPEN(filename)
varid1=NCDF_VARID(fid,'z')
NCDF_VARGET, fid, varid1, density1
NCDF_CLOSE, fid

filename ='/home/liufei/Data/Parameters/MEIC_Emission/0.1/'+Yr4+'/'+Yr4+'__industry__NOx.nc'
fid=NCDF_OPEN(filename)
varid2=NCDF_VARID(fid,'z')
NCDF_VARGET, fid, varid2, density2
NCDF_CLOSE, fid

filename ='/home/liufei/Data/Parameters/MEIC_Emission/0.1/'+Yr4+'/'+Yr4+'__power__NOx.nc'
fid=NCDF_OPEN(filename)
varid3=NCDF_VARID(fid,'z')
NCDF_VARGET, fid, varid3, density3
NCDF_CLOSE, fid

filename ='/home/liufei/Data/Parameters/MEIC_Emission/0.1/'+Yr4+'/'+Yr4+'__transportation__NOx.nc'
fid=NCDF_OPEN(filename)
varid4=NCDF_VARID(fid,'z')
NCDF_VARGET, fid, varid4, density4
NCDF_CLOSE, fid


;z:nodata_value = -9999.
density1[where(density1 lt 0)]=0
density2[where(density2 lt 0)]=0
density3[where(density3 lt 0)]=0
density4[where(density4 lt 0)]=0

density1=reform(density1,nlon,nlat)
density2=reform(density2,nlon,nlat)
density3=reform(density3,nlon,nlat)
density4=reform(density4,nlon,nlat)

sum=density1+density2+density3+density4
pp=density3

;monthly emissions
;ozone period:may-sep
month1=5
month2=9

density1=dblarr(nlon,nlat)
density2=dblarr(nlon,nlat)
density3=dblarr(nlon,nlat)
density4=dblarr(nlon,nlat)
sum_month=dblarr(nlon,nlat)
pp_month=dblarr(nlon,nlat)
For month=month1,month2 do begin
	;if month >9, here need change
	Mon= string(month,format='(i1.1)')
	Mon2= string(month,format='(i2.2)')

	filename ='/home/liufei/Data/Parameters/MEIC_Emission/0.1/monthly/'+Yr4+'/'+Mon+'/'+Yr4+'_'+Mon2+'__residential__NOx.nc'
	fid=NCDF_OPEN(filename)
	varid1=NCDF_VARID(fid,'z')
	NCDF_VARGET, fid, varid1, density1
	NCDF_CLOSE, fid
	
	filename ='/home/liufei/Data/Parameters/MEIC_Emission/0.1/monthly/'+Yr4+'/'+Mon+'/'+Yr4+'_'+Mon2+'__industry__NOx.nc'
	fid=NCDF_OPEN(filename)
	varid2=NCDF_VARID(fid,'z')
	NCDF_VARGET, fid, varid2, density2
	NCDF_CLOSE, fid

	filename ='/home/liufei/Data/Parameters/MEIC_Emission/0.1/monthly/'+Yr4+'/'+Mon+'/'+Yr4+'_'+Mon2+'__power__NOx.nc'
	fid=NCDF_OPEN(filename)
	varid3=NCDF_VARID(fid,'z')
	NCDF_VARGET, fid, varid3, density3
	NCDF_CLOSE, fid

	filename ='/home/liufei/Data/Parameters/MEIC_Emission/0.1/monthly/'+Yr4+'/'+Mon+'/'+Yr4+'_'+Mon2+'__transportation__NOx.nc'
	fid=NCDF_OPEN(filename)
	varid4=NCDF_VARID(fid,'z')
	NCDF_VARGET, fid, varid4, density4
	NCDF_CLOSE, fid
	
	;z:nodata_value = -9999.
	density1[where(density1 lt 0)]=0
	density2[where(density2 lt 0)]=0
	density3[where(density3 lt 0)]=0
	density4[where(density4 lt 0)]=0

	density1=reform(density1,nlon,nlat)
	density2=reform(density2,nlon,nlat)
	density3=reform(density3,nlon,nlat)
	density4=reform(density4,nlon,nlat)
	
	sum_month+=density1+density2+density3+density4
	pp_month+=density3
endfor

emis=dblarr(num)
emis_month=dblarr(num)
emis_pp=dblarr(num)
emis_pp_month=dblarr(num)
For i=0,num-1 do begin
        x = pplon[i]
        y = pplat[i]
        delta=Dis[i]
        For j=-delta,delta do begin
	For k=-delta,delta do begin
	    if (x+j lt nlon) and (x+j ge 0) and (y+k lt nlat) and (y+k ge 0) then begin
		emis[i]      +=sum[x+j,y+k]
		emis_pp[i]   +=pp[x+j,y+k]
		emis_month[i]+=sum_month[x+j,y+k]
		emis_pp_month[i]+=pp_month[x+j,y+k]
	    endif
	endfor
	endfor
endfor;num

result[(year-year1),*]=emis
result[col+(year-year1),*]=emis_pp
result[col*2+(year-year1),*]=emis_month
result[col*3+(year-year1),*]=emis_pp_month
header_output[(year-year1)]=strcompress(string(year,format='(i4.4)')+'_total_emis',/remove)
header_output[col+(year-year1)]=strcompress(string(year,format='(i4.4)')+'_pp_emis',/remove)
header_output[col*2+(year-year1)]=strcompress(string(year,format='(i4.4)')+'_ozone_emis',/remove)
header_output[col*3+(year-year1)]=strcompress(string(year,format='(i4.4)')+'_ozone_pp_emis',/remove)
endfor; year


outfile ='/home/liufei/Data/Wind_sort/map_emission_China.asc'
openw,lun,outfile,/get_lun,WIDTH=2500
printf,lun,header_output,result
close,lun
free_lun,lun

end
