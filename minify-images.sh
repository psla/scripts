#!/bin/bash

###
# PARAMETERS:
#  resulotion: i.e.: 900x or 1920x1080
#  source_dir: directory where pictures are located
#  target_dir: directory, where minified pictures are supposed to be located
###

targetres=$1
sourcedir=$2
targetdir=$3

if [ ! $# -eq 3 ]
then
        echo './minify-images.sh target_resolution source_dir dest_dir'
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
for i in `find . -iname "*.jpg"`
do
        dir=`dirname $i`
        if [ ! -d "$targetdir/$dir" ]
        then
                echo "directory $targetdir/$dir does not exists, creating"
                mkdir -p "$targetdir/$dir"
        fi
        echo "converting $i"

        if [ ! -f "$targetdir/$i" ]
        then
                convert -resize $targetres -quality 89 -auto-orient "$i" "$targetdir/$i"
        fi
done

# TODO: Add removing files, which no longer exists in source!

