#!/bin/bash
# Does incremental analysis of RBN skimmer activity
#set -x

# Move to correct folder to allow cron execution on RPi
[ -d "/home/sm7iun/rbnstats" ] && cd /home/sm7iun/rbnstats

FOLDER="rbndata"
NEWFILE="$FOLDER/`date -u --date="1 days ago" +%Y%m%d`.txt"
NEWDATE="`date -u --date="1 days ago" +%Y%m%d`"
OLDFILE="$FOLDER/`date -u --date="11 days ago" +%Y%m%d`.txt"

rm -rf $OLDFILE

echo "Downloading RBN data for:" $NEWDATE

wget --quiet --no-hsts http://www.reversebeacon.net/raw_data/dl.php?f=$NEWDATE -O $FOLDER/.rbndata.zip

FILESIZE=$(stat -c%s $FOLDER/.rbndata.zip)

if [[ $FILESIZE != "0" ]]; then
  gunzip < $FOLDER/.rbndata.zip > $FOLDER/.rbndata.csv
  echo "Downloaded "$((`wc -l < $FOLDER/.rbndata.csv` - 2))" spots."
  EPOCHDATE=$(($(date --utc --date="$date" +%s)/86400))
  # Process
  cat $FOLDER/.rbndata.csv | ./parse.bash $EPOCHDATE > $NEWFILE
  echo "Parsing done, result #"$EPOCHDATE" saved in" $NEWFILE
else
  echo "Failed to download RBN data"
  exit
fi
./updatestats.bash
./updatestatsp.bash
./upload.bash
exit
