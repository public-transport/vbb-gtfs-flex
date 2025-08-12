#!/bin/bash

set -e
set -o pipefail
# set -x

function echo_heading () {
	echo -e "\n\n$(tput -T xterm bold)$1$(tput -T xterm sgr0)\n"
}

export QSV_SKIP_FORMAT_CHECK='true'



echo_heading 'downloading & extracting the DELFI.BB GTFS feed'

# This GTFS feed is built using gtfs-hub:
# https://github.com/mfdz/gtfs-hub/blob/d1338336ccecd884a727f7efe60fa4263513be6a/makefile#L25-L27
wget -c -N -q 'https://gtfs.mfdz.de/DELFI.BB.gtfs.zip'

unzip -o -j -q -d gtfs DELFI.BB.gtfs.zip agency.txt
unzip -o -j -q -d gtfs DELFI.BB.gtfs.zip stops.txt

echo 'done!'


echo_heading 'generating agency.txt from DELFI.BB GTFS'

invalid_routes=$(qsv join --left \
	agency_id routes.txt \
	agency_id gtfs/agency.txt \
	| qsv search -s 'agency_id[1]' '^$' 2>/dev/null || true)
nr_of_invalid_routes="$(echo -n $(echo "$invalid_routes" | qsv behead | wc -l))"
if [ $nr_of_invalid_routes -gt 0 ]; then
	1>&2 echo "there are $nr_of_invalid_routes routes.txt rows with invalid/unknown agency_id:"
	1>&2 echo "$invalid_routes"
	exit 1
fi

# keep all gtfs/agency.txt rows referenced in routes.txt
qsv join --left \
	agency_id routes.txt \
	agency_id gtfs/agency.txt \
	| qsv select "$(head -n 1 gtfs/agency.txt | tr -d '\r\n')" \
	| qsv dedup -s agency_id \
	>agency.txt

echo 'done!'



echo_heading 'generating stops.txt from DELFI.BB GTFS'

invalid_stops=$(qsv join --left \
	location_id location_groups.txt \
	stop_id gtfs/stops.txt \
	| qsv search -s stop_id '^$' 2>/dev/null || true)
nr_of_invalid_stops="$(echo -n $(echo "$invalid_stops" | qsv behead | wc -l))"
if [ $nr_of_invalid_stops -gt 0 ]; then
	1>&2 echo "there are $nr_of_invalid_stops location_groups.txt rows with invalid/unknown location_id/stop_id:"
	1>&2 echo "$invalid_stops"
	exit 1
fi

# location_type=[123] is invalid with GTFS-Flex
# OTP does not accept location_type=4 (boarding area)
invalid_loc_types='^[1234]$'
invalid_stops=$(qsv join --left \
	location_id location_groups.txt \
	stop_id gtfs/stops.txt \
	| qsv search -s location_type "$invalid_loc_types" 2>/dev/null || true)
nr_of_invalid_stops="$(echo -n $(echo "$invalid_stops" | qsv behead | wc -l))"
if [ $nr_of_invalid_stops -gt 0 ]; then
	1>&2 echo "there are $nr_of_invalid_stops location_groups.txt rows whose stop has an invalid location_type:"
	1>&2 echo "$invalid_stops"
	exit 1
fi

# determine columns for stops.txt
# remove columns referencing other (non-existent) files
# put stop_id first manually
stops_columns="stop_id,$(qsv headers -j gtfs/stops.txt \
	| grep -v -x stop_id \
	| grep -v -x level_id \
	| perl -pe 'chomp if eof' | tr '\r\n' ',')"

# keep all gtfs/stops.txt rows referenced in location_groups.txt
qsv join --left \
	location_id location_groups.txt \
	stop_id gtfs/stops.txt \
	| qsv select "$stops_columns" \
	| qsv dedup -s stop_id \
	>stops.txt

echo 'done!'



echo_heading 'creating gtfs-flex.zip'
zip -j -9 -q gtfs-flex.zip *.txt
ls -lh gtfs-flex.zip



# echo_heading 'validating GTFS feed'

# Google's GTFS Validator doesn't seem to have a Docker image.
# see https://github.com/google/transitfeed/wiki/FeedValidator
# The MoblityData GTFS Validator currently doesn't support GTFS-Flex v2.
# see https://github.com/MobilityData/gtfs-validator/issues/1067#issuecomment-990253322
# GTFSVTOR doesn't support GTFS-Flex v2.
# todo
# docker run -it --rm -v $PWD:/gtfs mfdz/gtfsvtor -o /gtfs/validation-results.html /gtfs
