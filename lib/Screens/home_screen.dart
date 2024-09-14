import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, String>> videos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    try {
      final snapshot = await _firestore.collection('video_links').get();
      final List<Map<String, String>> fetchedVideos = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'title': data['title']?.toString() ?? 'No title',
          'link': data['link']?.toString() ?? '',
        };
      }).toList();
      setState(() {
        videos = fetchedVideos;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching videos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return VideoPlayerWidget(
            videoUrl: video['link']!,
            title: video['title']!,
          );
        },
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late YoutubePlayerController _controller;
  bool isVideoValid = true;  // Track whether the video is valid

  @override
  void initState() {
    super.initState();

    String? videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    // Check if videoId is valid, otherwise handle invalid URLs
    if (videoId == null || videoId.isEmpty) {
      setState(() {
        isVideoValid = false;
      });
      print('Invalid video URL: ${widget.videoUrl}');
    } else {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    if (isVideoValid) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isVideoValid) {
      return Center(
        child: Text(
          'Invalid video URL or video not available',
          style: const TextStyle(
            color: Colors.red,
            fontSize: 18,
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.amber,
          onReady: () {
            print('Player is ready');
          },
          onEnded: (metaData) {
            print('Video ended: ${metaData.videoId}');
          },
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.black54,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            });
          },
          child: Center(
            child: _controller.value.isPlaying
                ? const SizedBox.shrink()
                : const Icon(Icons.play_arrow, color: Colors.white, size: 64),
          ),
        ),
      ],
    );
  }
}
