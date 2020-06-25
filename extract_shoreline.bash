#Script By Teguh Sulistian
#PPKLP - BIG
#Vertical Datum Correction From EGM2008 to MSL Indonesia

echo -n '1. Input DEM (Geoid): '
read input1
echo -n '2. Output File: '
read input2


#boundary
lat0=`gdalinfo "$input1" | grep "Lower Left" | awk -F "(" '{print $2}' | awk -F ", " '{print $2}' | sed -e 's/ //g' -e 's/)//g'`
lon0=`gdalinfo "$input1" | grep "Lower Left" | awk -F "(" '{print $2}' | awk -F ", " '{print $1}' | sed 's/ //g'`
latf=`gdalinfo "$input1" | grep "Upper Right" | awk -F "(" '{print $2}' | awk -F ", " '{print $2}' | sed -e 's/ //g' -e 's/)//g'`
lonf=`gdalinfo "$input1" | grep "Upper Right" | awk -F "(" '{print $2}' | awk -F ", " '{print $1}' | sed 's/ //g'`
#
# regriding data EGM2008 dengan input format NetCDF sesuai dengan area data DEMNAS.
res=`gdalinfo "$input1" | grep "Pixel Size = (" | awk -F"," '{print $1}' | sed -e 's/Pixel Size = (//g' | sed -e 's/ //g'`
#
gdal_translate -r cubicspline -tr $res $res -projwin $lon0 $latf $lonf $lat0 HAT.tif HAT_TEMP.tif
gdal_translate -r cubicspline -tr $res $res -projwin $lon0 $latf $lonf $lat0 MSL.tif MSL_TEMP.tif
gdal_translate -r cubicspline -tr $res $res -projwin $lon0 $latf $lonf $lat0 LAT.tif LAT_TEMP.tif	
#
# kalkulasi konversi datum
#
gdal_calc.py -A ${input1} -B MSL_TEMP.tif --outfile="DTM_MSL.tif" --calc="A-B"


# Extract Shoreline
gdal_contour -a elev DTM_HAT.tif HAT.shp -fl 0
gdal_contour -a elev DTM_MSL.tif MSL.shp -fl 0 
gdal_contour -a elev DTM_LAT.tif LAT.shp -fl 0
mkdir ${input2}
mv HAT.shp HAT.shx HAT.dbf MSL.shp MSL.shx MSL.dbf LAT.shp LAT.shx LAT.dbf ${input2}/ 

rm HAT_TEMP.tif MSL_TEMP.tif LAT_TEMP.tif HAT_TEMP.tif.aux.xml MSL_TEMP.tif.aux.xml LAT_TEMP.tif.aux.xml