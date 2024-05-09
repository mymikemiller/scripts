import 'dart:io';
import 'package:path/path.dart';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

var yt = YoutubeExplode();

main() async {
  /*
    For a youtube music liked music:
      Browse to https://music.youtube.com/playlist?list=LM
      Click the "..." and "Add to Queue"
      In the queue at the bottom, click the "..." there and "Add to Playlist"
      Add to "Mikey Likes It" or another playlist
      Browse to the playlist on YouTube (remove "music" from the url)
      remove "music" and "VL" from the beginning of the playlist id in the URL
  */

  final playlistPaths = [
    'https://www.youtube.com/watch?v=b4wHnf9VTRk&list=PLBKadB95sF45Xa1f3G8uZrDjgBRvNvhJ1',
  ];

  for (var playlistPath in playlistPaths) {
    await downloadPlaylist(playlistPath);
  }

  print('Done');

  yt.close();
}

void downloadPlaylist(String playlistPath) async {
  var playlist = await yt.playlists.get(playlistPath);

  var convertedDirectory =
      await new Directory('/Users/mikem/Downloads/converted')
          .create(recursive: true);

  var playlistTitle = playlist.title;
  print('Downloading videos from playlist: $playlistTitle');

  await for (var video in yt.playlists.getVideos(playlist.id)) {
    print('Downloading video ${video.id}: ${video.title}');

    var manifest = await yt.videos.streamsClient.getManifest(video.id);

    var streamInfo = manifest.audioOnly
        .where((element) => element.container == StreamContainer.mp4)
        .sortByBitrate()
        .last;

    final sanitizedTitle = video.title
        .replaceAll("/", "-"); // avoid slashes since they mess with the path

    final unconvertedFilePath =
        '/Users/mikem/Downloads/${sanitizedTitle}.${streamInfo.container}';
    final convertedFilePath =
        '${convertedDirectory.path}/${basenameWithoutExtension(unconvertedFilePath)}.mp3';

    // Skip the file if we already have the final converted file
    if (File(convertedFilePath).existsSync()) {
      print('Skipping file because it already exists as $convertedFilePath');
      continue;
    }

    if (streamInfo == null) {
      print(
          'Skipping video. Could not get download stream info for video ${video.id}: ${video.title}');
      continue;
    }

    // Get the actual stream
    var stream = yt.videos.streamsClient.get(streamInfo);

    var file = await new File(unconvertedFilePath).create(recursive: true);
    var fileStream = file.openWrite();

    // Pipe all the content of the stream into the file.
    print('piping file ${file.path}');
    await stream.pipe(fileStream);
    print('done piping file');

    // Close the file.
    await fileStream.flush();
    await fileStream.close();

    print('converting to mp3');
    await convert(file, convertedFilePath);
    print('done converting');
  }
}

Future<File> convert(File file, String outputPath) async {
  final localFilePath = file.path;

  final args = [
    '-i',
    '$localFilePath',
    '$outputPath',
  ];

  final processResult = await Process.run('ffmpeg', args);

  if (processResult.exitCode != 0) {
    throw 'ffmpeg convert error (exitCode $exitCode)';
  }

  final outputFile = File(outputPath);
  return outputFile;
}
