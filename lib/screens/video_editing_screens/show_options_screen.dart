import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sfs_editor/screens/result_screen.dart';
import 'package:sfs_editor/screens/video_editing_screens/trimming_screen.dart';
import 'package:sfs_editor/widgets/edit_video_option.dart';
import 'package:video_player/video_player.dart';

class ShowOptionsScreen extends StatefulWidget {
  const ShowOptionsScreen({super.key, required this.file});
  final File file;

  @override
  State<ShowOptionsScreen> createState() => _ShowOptionsScreenState();
}

class _ShowOptionsScreenState extends State<ShowOptionsScreen> {
  late final dynamic editedVideo;
  late VideoPlayerController controller;
  double aspectRatio = 9 / 16;
  @override
  void initState() {
    editedVideo =widget.file;
    controller = VideoPlayerController.file(widget.file)
      ..initialize().then((value) {
        setState(() {
          controller.play();
        });
      });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void playPause() {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: AspectRatio(
                    aspectRatio: aspectRatio,
                    child: controller.value.isInitialized
                        ? VideoPlayer(controller)
                        : const Center(
                            child: CircularProgressIndicator(),
                          )),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: Container(
              height: MediaQuery.of(context).size.height / 15,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      )),
                  const Text(
                    'Edit Your Video',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx)=>  ResultScreen(editedvideo: editedVideo,isVid: true,))
                        );
                      },
                      icon: const Text(
                        'Done',
                        style: TextStyle(color: Colors.white,fontSize: 17),
                      ))
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          setState(() {
                            playPause();
                          });
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange,
                          ),
                          child: controller.value.isPlaying
                              ? const Icon(
                                  Icons.pause,
                                  size: 50,
                                )
                              : const Icon(
                                  Icons.play_arrow,
                                  size: 50,
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      EditVideoOption(iconData: Icons.cut, text: 'trim', onTap: () async {
                                editedVideo =
                                    await Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (ctx) => TrimmingScreen(
                                                  file: widget.file,
                                                )));
                                if (editedVideo != null) {
                                  setState(() {
                                    controller = VideoPlayerController.file(
                                        File(editedVideo))
                                      ..initialize().then((_) {
                                        setState(() {
                                          controller.play();
                                        });
                                      });
                                  });
                                }
                              },
                              ),
                      EditVideoOption(asset: 'assets/instalogo.png', text: '1:1', onTap: (){
                        setState(() {
                          aspectRatio = 1/1;
                        });
                      }),
                      EditVideoOption(iconData: Icons.snapchat, text: '9:16', onTap: (){
                        setState(() {
                          aspectRatio = 9 / 16;
                        });
                      }),
                      EditVideoOption(asset: 'assets/youtube.png', text: '16:9', onTap: (){
                        setState(() {
                          aspectRatio = 16/9;
                        });
                      }),
                      EditVideoOption(asset: 'assets/youtube.png', text: '4:3', onTap: (){
                        setState(() {
                          aspectRatio = 4/3;
                        });
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
