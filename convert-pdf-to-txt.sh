#!/bin/bash
INCOMING_DIR=/mnt/nas/public/wspolne/Skany/incoming
TMP_DIR=/mnt/nas/public/wspolne/Skany/tmp
OUTPUT_DIR=/mnt/nas/public/wspolne/Skany/done
#while RES=$(inotifywait -e create $DIR --format %f .)
#     do echo RES is $RES at `date`; done 

#inotifywait -m -r -e create --format '%w%f' "${DIR}" | while read NEWFILE
inotifywait -m -e create --format '%w%f' "${INCOMING_DIR}" | while read NEWFILE
do
  echo "File '${NEWFILE}' was created"
  sleep 1
  # Tif allows multi-page data, though it is BIG
  convert -density 300 "${NEWFILE}" $TMP_DIR/input.tif
  RENAMED=`date +'%Y-%m-%d_%H_%M'`_scan.pdf
  FILENAME=`date +'%Y-%m-%d_%H_%M'`_scan.pdf
  mv "${NEWFILE}" $OUTPUT_DIR/$RENAMED
  tesseract -l eng+pol $TMP_DIR/input.tif "$OUTPUT_DIR/${FILENAME}.OCR" pdf
  tesseract -l eng+pol $TMP_DIR/input.tif "$OUTPUT_DIR/${FILENAME}.OCR"
  rm $TMP_DIR/input.tif
done
