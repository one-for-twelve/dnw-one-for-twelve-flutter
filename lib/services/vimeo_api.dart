import 'dart:convert';
import 'package:http/http.dart' as http;

class VimeoApi {
  static Future<VideoStream> getStreamingUrl(String videoId) async {
    final resp =
        await http.get(Uri.https('player.vimeo.com', '/video/$videoId/config'));
    final result = json.decode(resp.body);

    final duration = result['video']['duration'];

    final streamProfilesMap =
        result['request']['files']['progressive'] as List<dynamic>;
    final streamProfiles = streamProfilesMap
        .map(
          (profile) => VideoStreamProfile(
            int.parse(profile['width'].toString()),
            int.parse(profile['height'].toString()),
            profile['url'].toString(),
          ),
        )
        .toList();

    streamProfiles.sort((p1, p2) => p1.width.compareTo(p2.width));
    final streamProfile = streamProfiles.first;

    return VideoStream(
        streamProfile.width, streamProfile.height, streamProfile.url, duration);
  }
}

class VideoStreamProfile {
  final int width;
  final int height;
  final String url;

  VideoStreamProfile(this.width, this.height, this.url);
}

class VideoStream {
  final int width;
  final int height;
  final String url;
  final int duration;

  VideoStream(this.width, this.height, this.url, this.duration);
}
