The .app version of the scripts was created based on this stackoverflow answer: https://apple.stackexchange.com/a/359429. It allows the script with the same name to access the paths of files dragged-and-dropped onto it. This .app file can be duplicated and renamed to match any .zsh script filename, and the files can be accessed inside the script via $*

# 3dSbsToYoutube

Drag and drop one or more video files onto 3dSbsToYoutube.app and a copy will be created with "SBS_" prepended to the file name. This copy will have its stereo_mode metadata set to 2 which will cause YouTube to maintain the SBS format instead of displaying only one side. The .app file is used because mac does not support dragging and dropping files onto a script file, apparently.

# ConcatenateVideos

Drag and drop multiple video files onto ConcatenateVideos.app and an output file named the same as the first file with "CONCAT_" prepended will be created by losslessly (and quickly) concatenating all videos together. The order of files will be displayed for confirmation before concatenating, and the script may need to be edited if they are not in the desired order. The concatenated video will lose the matadata that YouTube uses to recognize that the video is spherical, so Spatial Media Medatata Injector (see below) can be used on the concatenated video before upload.

# Spatial Media Metadata Injector (YouTube 360 enabler)

This tool from Google (https://github.com/google/spatial-media/releases/tag/v2.0) injects metadata into videos to allow YouTube to recognize the video as interactive 360 video, instead of displaying the source equirectangular video. This is not necessary when uploading a video produced by Vuze XR Studio, but because videos lose their metadata when concatenated, the metadata needs to be injected into the final video before upload.

# FacebookDisable360

Use as a bookmarklet on the page when uploading images to an album to disable the 360 feature. Useful when uploading 3D SBS photos.
