#!/bin/bash

### Country list
COUNTRIES="south-america/paraguay"
NOMINATIM="/var/Nominatim"

### Foreach country check if configuration exists (if not create one) and then import the diff
for COUNTRY in $COUNTRIES;
do
    DIR="$NOMINATIM/updates/$COUNTRY"
    FILE="$DIR/configuration.txt"
    if [ ! -f ${FILE} ];
    then
        /bin/mkdir -p ${DIR}
        /usr/bin/osmosis --rrii workingDirectory=${DIR}/.
        /bin/echo baseUrl=http://download.geofabrik.de/${COUNTRY}-updates > ${FILE}
        /bin/echo maxInterval = 0 >> ${FILE}
        cd ${DIR}
        /usr/bin/wget http://download.geofabrik.de/${COUNTRY}-updates/state.txt
    fi
    FILENAME=${COUNTRY//[\/]/_}
    /usr/bin/osmosis --rri workingDirectory=${DIR}/. --wxc ${FILENAME}.osc.gz
done

INDEX=0 # false

### Foreach diff files do the import
cd ${NOMINATIM}/updates
for OSC in *.osc.gz;
do
    ${NOMINATIM}/utils/update.php --import-diff ${NOMINATIM}/updates/${OSC} --no-npi
    INDEX=1
done

### Re-index if needed
if ((${INDEX}));
then
    ${NOMINATIM}/utils/update.php --index
fi

### Remove all diff files
rm -f ${NOMINATIM}/updates/*.osc.gz