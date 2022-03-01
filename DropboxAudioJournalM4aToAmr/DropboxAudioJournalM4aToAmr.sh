#!/bin/bash

# ffmpeg is likely installed with the necessary options at ~/OneDrive/Projects/Mac/ffmpeg, but if not:
# Download ffmpeg source: git clone https://github.com/FFmpeg/FFmpeg.git
# cd ffmpeg
# ./configure --enable-version3 --enable-nonfree --enable-libopencore-amrnb
# make
# ~/OneDrive/Projects/Mac/ffmpeg/ffmpeg -i my_input.m4a -ar 8000 -ab 12.2k my_output.amr
#
# Script used for accessing DropBox is from https://github.com/andreafabrizi/Dropbox-Uploader

trim() {
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   
    printf '%s' "$var"
}

freeSpaceAtStart=`./Dropbox-Uploader/dropbox_uploader.sh space | grep Free | awk '{print $2}'`
echo "Starting script with $freeSpaceAtStart MB free on DropBox"

./Dropbox-Uploader/dropbox_uploader.sh list Audio\ Journal | grep m4a$ | awk '{ $1=""; $2=""; print}' | while IFS= read -r line; do
#echo " 2019-02-04 19-53.m4a" | while IFS='' read filename; do
  filename=$( trim "$line" )
  filename=${filename##*/}
  filenameSansExtension=${filename%%.*}
  destinationFileName="${filenameSansExtension}.amr"

  dropboxBasePath="Audio Journal"
  tempBasePath="temp"

  dropboxSourcePath="$dropboxBasePath/$filename"
  echo dropboxSourcePath
  echo $dropboxSourcePath
  dropboxDestinationPath="$dropboxBasePath/$destinationFileName"

  tempSourcePath="$tempBasePath/$filename"
  tempDestinationPath="$tempBasePath/$destinationFileName"

  # Download
  printf "Downloading $dropboxSourcePath"
  ./Dropbox-Uploader/dropbox_uploader.sh download "$dropboxSourcePath" "$tempSourcePath"
  if [ $? -ne 0 ];
  then
      echo "Failed to download a file. Stopping."
      exit 1
  fi

  # Convert
  # note that <&1- is used to prevent ffmpeg from eating characters from stdin, which messes up the file names for the rest of the loop
  ~/OneDrive/Projects/Mac/ffmpeg/ffmpeg <&1- -i "$tempSourcePath" -ar 8000 -ab 12.2k "$tempDestinationPath"
  if [ $? -ne 0 ];
  then
      echo "Failed to convert a file. Possibly you need to delete the temp .amr file and regenerate. Stopping."
      exit 1
  fi

  # Upload
  ./Dropbox-Uploader/dropbox_uploader.sh upload "${tempDestinationPath}" "${dropboxDestinationPath}"
  if [ $? -ne 0 ];
  then
      echo "Failed to upload a file. Stopping."
      exit 1
  fi

  # Check that the file was successfully uploaded by downloading and comparing
  ./Dropbox-Uploader/dropbox_uploader.sh download "${dropboxDestinationPath}" "${tempDestinationPath}_"
  if cmp -s "$tempDestinationPath" "${tempDestinationPath}_"; then
    rm "${tempDestinationPath}_"
  else
    printf 'Error: The uploaded file "%s" is different from the file downloaded after upload ("%s")\n' "$tempDestinationPath" "${tempDestinationPath}_"
    exit 1
  fi  

  # Delete local temp files
  rm "$tempSourcePath"
  rm "$tempDestinationPath"

  # Delete source file from Dropbox
  ./Dropbox-Uploader/dropbox_uploader.sh delete "${dropboxSourcePath}"
  if [ $? -ne 0 ];
  then
      echo "Failed to delete the source file from Dropbox. Stopping."
      exit 1
  fi

  echo "done with file. moving on"
done

freeSpaceAtEnd=`./Dropbox-Uploader/dropbox_uploader.sh space | grep Free | awk '{print $2}'`
echo "Ending script with $freeSpaceAtEnd MB free on DropBox"
spaceReclaimed=$((freeSpaceAtEnd-freeSpaceAtStart))
echo "$spaceReclaimed MB reclaimed"
