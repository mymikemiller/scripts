#!/bin/zsh
for filepath in $*; do
  base=${filepath:h}
  filename=${filepath:t}
  outfile=${base}/SBS_${filename}
  ffmpeg -i ${filepath} -c copy -metadata:s:v:0 stereo_mode=2 "${outfile}"
done