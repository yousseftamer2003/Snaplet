import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';

class TrimmingScreen extends StatefulWidget {
  const TrimmingScreen({super.key, required this.file});
  final File file;
  @override
  TrimmingScreenState createState() => TrimmingScreenState();
}

class TrimmingScreenState extends State<TrimmingScreen> {
  final _trimmer = Trimmer();
  late VideoPlayerController _controller;
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;
  bool _progressVisibility = false;


void _loadVideo() => _trimmer.loadVideo(videoFile: widget.file);

  _saveVideo() {
    setState(() {
      _progressVisibility = true;
    });

    _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      ffmpegCommand:
            '-filter:v "crop=320:150"',
        customVideoFormat: '.mp4',
      onSave: (outputPath) {
        setState(() {
          _progressVisibility = false;
        });
        Navigator.pop(context,outputPath);
      },
    );
  }


  @override
  void initState() {
    super.initState();
    _loadVideo();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text('Cut from your video'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: Container(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Visibility(
                    visible: _progressVisibility,
                    child: const LinearProgressIndicator(
                      backgroundColor: Colors.red,
                    ),
                  ),
                  
                  Expanded(child: VideoViewer(trimmer: _trimmer)),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TrimViewer(
                        trimmer: _trimmer,
                        viewerHeight: 50.0,
                        viewerWidth: MediaQuery.of(context).size.width,
                        durationStyle: DurationStyle.FORMAT_MM_SS,
                        maxVideoLength: Duration(
                          seconds: _trimmer
                              .videoPlayerController!.value.duration.inSeconds,
                        ),
                        editorProperties: TrimEditorProperties(
                          borderPaintColor: Colors.orange,
                          borderWidth: 4,
                          borderRadius: 5,
                          circlePaintColor: Colors.orange.shade800,
                        ),
                        areaProperties:
                            TrimAreaProperties.edgeBlur(thumbnailQuality: 10),
                        onChangeStart: (value) => _startValue = value,
                        onChangeEnd: (value) => _endValue = value,
                        onChangePlaybackState: (value) => setState(
                          () => _isPlaying = value,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    child: _isPlaying
                        ? const Icon(
                            Icons.pause,
                            size: 80.0,
                            color: Colors.white,
                          )
                        : const Icon(
                            Icons.play_arrow,
                            size: 80.0,
                            color: Colors.white,
                          ),
                    onPressed: () async {
                      final playbackState = await _trimmer.videoPlaybackControl(
                        startValue: _startValue,
                        endValue: _endValue,
                      );
                      setState(() => _isPlaying = playbackState);
                    },
                  ),
                  ElevatedButton(
                    onPressed: _progressVisibility
                        ? null
                        : () async {
                            _saveVideo().then(
                              (outputPath) {
                                debugPrint('OUTPUT PATH: $outputPath');
                                final snackBar = SnackBar(
                                  content: Text(
                                      'Video Saved successfully\n$outputPath'),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white
                          ),
                    child: const Text('SAVE'),
                  ),
                ],
              ),
            ),
          ),
        );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
