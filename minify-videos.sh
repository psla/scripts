#!/bin/bash

###
# PARAMETERS:
#  resolution: i.e.: 900x or 1920x1080
#  source_dir: directory where pictures are located
#  target_dir: directory, where minified pictures are supposed to be located
###
# install: aptitude install ffmpeg
###

targetres=$1
sourcedir=$2
targetdir=$3
vbitrate="4000k"
abitrate="192k"

# verify if is running
pidfile=/tmp/minify-videos.pid
if [ -e $pidfile ]; then
  pid=`cat $pidfile`
  if kill -0 &>1 > /dev/null $pid; then
    echo "Already running"
    exit 1
  else
    rm $pidfile
  fi
fi
echo $$ > $pidfile

if [ ! $# -eq 3 ]
then
        echo './minify-videos.sh target_resolution source_dir dest_dir'
        exit
fi

if [ ! -d "$sourcedir" ]
then
        echo Source does not point the directory
        exit
fi

if [ ! -d "$targetdir" ]
then
        echo Destination directory does not exists. Creating
        mkdir -p "$targetdir"
fi


IFS="
"

cd "$sourcedir"
for i in `find . -iname "*.mts"`
do
        dir=`dirname $i`
        if [ ! -d "$targetdir/$dir" ]
        then
                echo "directory $targetdir/$dir does not exists, creating"
                mkdir -p "$targetdir/$dir"
        fi
        echo "converting $i"

        if [ ! -f "$targetdir/$i.avi" ]
        then
		echo avconv -i "$i" -vcodec libxvid -b $vbitrate -acodec libmp3lame -ac 2 -b:a $abitrate -deinterlace -s $targetres "$targetdir/$i.avi"
		avconv -i "$i" -vcodec libxvid -b $vbitrate -acodec libmp3lame -ac 2 -b:a $abitrate -deinterlace -s $targetres "$targetdir/$i.avi"
        fi
done

# TODO: Add removing files, which no longer exists in source!

