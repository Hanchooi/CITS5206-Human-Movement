.mode csv
.headers on
.import output/finalData.csv records
.import data/visited_places.csv visitedPlaces

.output output/finalData.csv

SELECT 
R.*, CASE
	WHEN speed >= 0.5 AND speed <= 1.1 THEN 'Swimming'
	WHEN speed >= 1.1 AND speed <= 2.7 THEN 'Walking'
	WHEN speed >= 2.7 AND speed <= 3.6 THEN 'Running'
	WHEN speed >= 3.6 AND speed <= 6.9 THEN 'E-scooter'
	WHEN speed >= 6.9 AND speed <= 11.1 THEN 'Cycling'
	WHEN speed >= 11.1 AND speed <= 19.2 THEN 'Car'
	WHEN speed >= 19.2 AND speed <= 20.0 THEN 'Bus'
	WHEN speed >= 20.0 AND speed <= 36.0 THEN 'Train'
	ELSE 'Stationary'
END AS 'mode_of_transport', VP.locationName AS vis_name, 
VP.Activity1 AS vis_activity1, VP.Activity2 AS vis_activity2, VP.Activity3 AS vis_activity3,VP.latitude AS vis_lat, VP.longitude AS vis_long
FROM records AS R
LEFT JOIN visitedPlaces AS VP
    ON ROUND(R.latitude,4) = ROUND(VP.latitude,4)
        AND ROUND(R.longitude,4) = ROUND(VP.longitude,4);

.output stdout
