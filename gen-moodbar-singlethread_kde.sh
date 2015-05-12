#!/bin/bash
# The main challenge was the ' in the sed command that had to be back single quotes - madmouse
# added a songs processed counter
# enhanced counter with an process indicator (total - done)
# to execute run ./gen-moodbar-singlethread.sh in the base directory 
# it will recursively create hidden .mood files in each directory
# 3.09.2013 added the perc function
# 05.05.2015 amended for KDE
# 12.05.2015 added FLAC count support

DIR=${1:-.}
LAST=.moodbar-lastreadsong
C_RET=0
SONG_NR=1
TOTAL_MP3=0
TOTAL_FLAC=0
TOTAL_ALL=0
TOTAL_MOOD=0
SONG_TOGO=0
SONG_PERC=0
TOTAL_MP3=`find "$DIR" -name "*.mp3" -print | wc -l`
TOTAL_FLAC=`find "$DIR" -name "*.flac" -print | wc -l`
echo "$TOTAL_MP3 <<< Total MP3s"
echo "$TOTAL_FLAC <<< Total FLACs"
echo "$TOTAL_ALL <<< Total MP3s + FLACsC"
TOTAL_MOOD=`find "$DIR" -name "*.mood" -print | wc -l`
echo "$TOTAL_MOOD <<< Total MOODs processed already"
SONG_TOGO=$(((TOTAL_MP3 + TOTAL_FLAC)-TOTAL_MOOD))
echo "$SONG_TOGO <<< Total Files to process stil ..."
#DISPLAY=:0 notify-send "MOODBAR" "Processings $SONG_TOGO songs ..."
DISPLAY=:0 kdialog --passivepopup "Processings $SONG_TOGO songs ..."
#echo " >>> $TOT_MP3 <<< Total MP3s to process"
#find 2 -name "*.mood" -print | wc -l
control_c() # run if user hits control-c
{
echo "$1" > "$LAST"
echo "Exiting…"
exit
}

if [ -e "$LAST" ]; then
read filetodelete < "$LAST"
rm "$filetodelete" "$LAST"
fi
exec 9< <(find "$DIR" -type f -regextype posix-awk -iregex '.*\.(mp3|ogg|flac|wma)') # you may need to add m4a and mp4
while read i
do
TEMP="${i%.*}.mood"
OUTF=`echo "$TEMP" | sed 's#\(.*\)/\([^,]*\)#\1/.\2#'`

trap 'control_c "$OUTF"' INT
if [ ! -e "$OUTF" ] || [ "$i" -nt "$OUTF" ]; then
moodbar -o "$OUTF" "$i" || { C_RET=1; echo "An error occurred!" >&2; }
echo " >>> $SONG_NR out of $SONG_TOGO <<< Songs processed so far .... "
SONG_NR=$((SONG_NR+1))
SONG_PERC=$((100*SONG_NR/SONG_TOGO))
echo "$SONG_PERC"
#(for j in $(seq 0 1 2); do echo "$SONG_PERC"; sleep 0.1; done) | zenity --progress
fi
done <&9 | zenity --progress --auto-close
exec 9<&-
DISPLAY=:0 kdialog --passivepopup "Done ..."
exit $C_RET
