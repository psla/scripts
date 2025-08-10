#!/bin/bash
DIR=/mnt/nas/public/wspolne/Skany/done

declare -A cache
inotifywait  --format="%c %e %f" -m -e move $DIR |
  while read id event file; do
    if [ "$event" = "MOVED_FROM" ]; then
      cache[$id]=$file
    fi
    if [ "$event" = "MOVED_TO" ]; then
      if [ "${cache[$id]}" ]; then
        echo "processing ..."
        echo ${cache[$id]}
        echo $file
        #rename "s%{$cache[$id].OCR}%$file.OCR%" $DIR/${cache[$id]}*
        echo find . -name "${cache[$id]}.OCR*" -type f
        for f in $(find $DIR -name "${cache[$id]}.OCR*" -type f); do
          echo "moving $f"
          mv "$f" "$DIR/$file${f#$DIR/${cache[$id]}}";
        done
        unset cache[$id]
      else
        echo "mismatch for $id"
      fi
      fi
    done
