#!/bin/bash

# Download list of popular tags,
# then download list of nodes for each tag
# and store in GeoJSON files.

# Bounding Box for Cologne
BBOX=50.8,6.7,51.1,7.2

# check some dependencies
which in2csv || { echo "csvkit is not installed. Exiting."; exit 1; }
which curl || { echo "curl is not installed. Exiting."; exit 1; }


### emergency (Top 30)

# Get popular tags and store as CSV
curl -s -X GET -d "key=emergency&page=1&rp=30&sortname=count&sortorder=desc" \
	http://taginfo.openstreetmap.org/api/4/key/values|in2csv -f json -k data \
	> tags_emergency.csv

# Get nodes per tag
for tag in $(csvcut -c 5 tags_emergency.csv|tail -n+2)
do
	echo "Fetching emergency:$tag"
	curl -s -X POST -d "[out:json];(node[\"emergency\"=\"$tag\"]($BBOX));out;" \
		http://overpass-api.de/api/interpreter \
		|in2csv -f json -k elements \
		|csvcut -c "id,lat,lon,tags/name" \
		|csvjson --lat lat --lon lon -k id -i 4 \
		> emergency/emergency_$tag.geojson
	sleep 1
done

rm tags_emergency.csv

# Remove empty files
for filename in $(ls emergency)
do
        if [ $(stat -c%s emergency/$filename) -eq 0 ]
        then
                echo "$filename is empty - removed"
		rm emergency/$filename
        fi
done


### amenity (Top 100)

# Get popular tags and store as CSV
curl -s -X GET -d "key=amenity&page=1&rp=100&sortname=count&sortorder=desc" \
	http://taginfo.openstreetmap.org/api/4/key/values|in2csv -f json -k data \
	> tags_amenity.csv

# Get nodes per tag
for tag in $(csvcut -c 5 tags_amenity.csv|tail -n+2)
do
	echo "Fetching amenity:$tag"
	curl -s -X POST -d "[out:json];(node[\"amenity\"=\"$tag\"]($BBOX));out;" \
		http://overpass-api.de/api/interpreter \
		|in2csv -f json -k elements \
		|csvcut -c "id,lat,lon,tags/name" \
		|csvjson --lat lat --lon lon -k id -i 4 \
		> amenity/amenity_$tag.geojson
	sleep 1
done

rm tags_amenity.csv

# Remove empty files
for filename in $(ls amenity)
do
        if [ $(stat -c%s amenity/$filename) -eq 0 ]
        then
                echo "$filename is empty - removed"
		rm amenity/$filename
        fi
done

