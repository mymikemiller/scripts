#!/bin/zsh

# Generate and run commend like the following, which will concatenate all video files specified as arguments:
# mkfifo temp1 temp2
# ffmpeg -y -i "infile1.mp4" -c copy -bsf:v h264_mp4toannexb -f mpegts temp1 2> /dev/null & \
# ffmpeg -y -i "infile2.mp4" -c copy -bsf:v h264_mp4toannexb -f mpegts temp2 2> /dev/null & \
# ffmpeg -f mpegts -i "concat:temp1|temp2" -c copy -bsf:a aac_adtstoasc outfile.mp4

read \?"Press [Enter] to concatenate the following videos:
${(F)@}"

command=""
pipes=()
for ((i = 1; i <= $#; i++ )); do
    filename=${*: $i:1}; # slice the i'th element from the args array

    # create the pipes with names temp1, temp2..tempn
    pipename=temp$i
    mkfifo $pipename
    pipes+=("$pipename")

    # Append to the ffmpg command
    command+="ffmpeg -y -i \"$filename\" -c copy -bsf:v h264_mp4toannexb -f mpegts $pipename 2> /dev/null & "
done

# Name the output file the same as the first paramater, with CONCAT_ prepended
firstParam=$1
base=${firstParam:h}
outfilename=${firstParam:t}
outfilepath=${base}/CONCAT_${outfilename}

# Complete the command
command+="ffmpeg -f mpegts -i \"concat:${(j:|:)pipes}\" -c copy -bsf:a aac_adtstoasc \"$outfilepath\""

# echo $command
eval $command