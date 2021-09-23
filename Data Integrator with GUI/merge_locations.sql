.mode csv
.headers on
.import output/finalData.csv record_visited
.import data/locations.csv locations

.output output/finalData.csv

SELECT RV.*, L.locationName AS loc_name, L.latitude AS loc_lat, L.longitude AS loc_long
FROM record_visited AS RV
LEFT JOIN 
    locations AS L    
    ON ROUND(RV.latitude,4) = ROUND(L.latitude,4)
        AND ROUND(RV.longitude,4) = ROUND(L.longitude,4);

.output stdout