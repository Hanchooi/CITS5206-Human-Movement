.mode csv
.headers on
.import output/finalData.csv record_visited_loc
.import output/output_garmin.csv garmin

.output output/finalData.csv

UPDATE record_visited_loc
SET date = STRFTIME("%Y-%m-%d, %H:%M", date);
UPDATE garmin
SET time = STRFTIME("%Y-%m-%d, %H:%M", time);


SELECT loc.*, G.latitude AS garmin_lat, G.longitude AS garmin_long, G.altitude AS garmin_alt
FROM record_visited_loc AS loc
LEFT JOIN garmin AS G
    ON loc.date = G.time;

.output stdout