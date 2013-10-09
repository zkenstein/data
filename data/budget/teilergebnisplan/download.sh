# Download script for downloading the source in the current folder.
#
# Execute this script from within the same directory as work directory, like this:
#   
#   sh ./download.sh


SOURCE_URL="http://www.offenedaten-koeln.de/wp-content/plugins/download-monitor/download.php?id=4"
NAME="teilergebnisplan"
FINAL_FOLDER=$NAME
FILENAME=${NAME}.csv
USER_AGENT="datahub-cgn/0.1"

echo "Downloading $NAME to _source/$FILENAME"
rm -rf _source/*
mkdir -p _source
cd _source
wget -q -U $USER_AGENT -O $FILENAME $SOURCE_URL
cd ..

# remove dots from within figures
cat _source/$FILENAME|sed 's/\([0-9]\)\.\([0-9]\)/\1\2/g' > $FILENAME