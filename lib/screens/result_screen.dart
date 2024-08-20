// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sfs_editor/constants/color.dart';
import 'package:sfs_editor/core/helper/snapchat_helper.dart';
import 'package:sfs_editor/core/in_app_purchase.dart';
import 'package:sfs_editor/presentation/common/dialog/snapchat_share_dialog.dart';
import 'package:sfs_editor/screens/image_to_image_screen.dart';
import 'package:sfs_editor/screens/tabs_screen.dart';
import 'package:sfs_editor/services/dark_mode_service.dart';
import 'package:sfs_editor/services/getimg_services.dart';
import 'package:sfs_editor/services/reward_ads_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:image/image.dart' as img;

class ResultScreen extends StatefulWidget {
  const ResultScreen(
      {super.key, this.editedvideo, this.editedImage, this.isEditor,required this.isVid});
  final File? editedvideo;
  final Uint8List? editedImage;
  final bool? isEditor;
  final bool isVid;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late VideoPlayerController controller;
  late VideoPlayerController _videoController;
  Uint8List? watermarkedImage;
  bool isSwitched = InAppPurchase.isPro || InAppPurchase.isProAI;
  bool isEditor = false;
  Uint8List? recievedImage;

  Future<void> makeWaterMark(Uint8List imageData) async {
    final watermarkData =
        await rootBundle.load('assets/starryImages/Snaplet water mark .png');
    final watermark = img.decodeImage(watermarkData.buffer.asUint8List());
    final image = img.decodeImage(imageData);
    if (image != null && watermark != null) {
      int x = 10;
      int y = 10;
      img.compositeImage(image, watermark, dstX: x, dstY: y);
      watermarkedImage = img.encodePng(image);
    }
  }
  
  Future<void> saveVideoToGallery(String url) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final result = await ImageGallerySaver.saveFile(url);
      final isSuccess = result["isSuccess"];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isSuccess ? 'Video Saved to Gallery!' : 'Failed to Save Video'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission Denied'),
        ),
      );
    }
  }

  Future<void> saveImage(Uint8List imageData) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final result = await ImageGallerySaver.saveImage(imageData);
      final isSuccess = result["isSuccess"];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isSuccess ? 'Image Saved to Gallery!' : 'Failed to Save Image'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission Denied'),
        ),
      );
    }
  }

  void isEditorCheck() {
    if (widget.isEditor != null) {
      if (widget.isEditor!) {
        isEditor = true;
      } else {
        isEditor = false;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if(!(InAppPurchase.isPro || InAppPurchase.isProAI)){
      Provider.of<RewardAdsService>(context,listen: false).loadAd();
    }
    if (widget.editedvideo != null) {
      _videoController = VideoPlayerController.file(widget.editedvideo!)
        ..initialize().then((_) {
          setState(() {});
          _videoController.play();
          _videoController.setLooping(true);
        });
    }
    controller =
        VideoPlayerController.asset('assets/videos/generatingsmall.mp4')
          ..initialize().then((_) {
            setState(() {});
            controller.play();
            controller.setLooping(true);
          });
  }
  void changeSwitch(){
                                setState(() {
                                isSwitched = !isSwitched;
                              });
                              }

  Future<void> sendEmail(Uint8List? recievedImage) async {
  if (recievedImage == null) {
    
    return;
  }

  
  final Directory tempDir = await getTemporaryDirectory();

  final String filePath = '${tempDir.path}/image.png';
  final File imageFile = File(filePath);
  await imageFile.writeAsBytes(recievedImage);

  
  final Email email = Email(
    body: '',
    subject: 'Report inappropriate content',
    recipients: ['Moatazforads@gmail.com'],
    isHTML: false,
    attachmentPaths: [filePath],
  );

  String platformResponse;

  try {
    await FlutterEmailSender.send(email);
    platformResponse = 'success';
  } catch (error) {
    log('$error');
    platformResponse = error.toString();
  }

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(platformResponse),
    ),
  );
}

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async{
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: themeProvider.isDarkMode? darkMoodColor : Colors.white,
        appBar: AppBar(
          backgroundColor: themeProvider.isDarkMode? darkMoodColor : Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/starryImages/snaplet-logo high small3 edited.png',
                width: 35,
              ),
              const Text(
                'Snaplet',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                width: 52.w,
              )
            ],
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                              MaterialPageRoute(builder: (ctx)=> const TabsScreen())
                            );
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Center(
          child: Consumer<GetIMageServices>(
            builder: (context, getImageProvider, _) {
              if (getImageProvider.imageData == null &&
                  widget.editedImage == null &&
                  widget.editedvideo == null) {
                return Center(
                  child: controller.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child: VideoPlayer(controller),
                        )
                      : Image.asset('assets/starryImages/insideLogo.png'),
                );
              } else {
                isEditorCheck();
                  if(widget.isVid){
                    recievedImage =null;
                  }else{
                  recievedImage =
                    isEditor ? widget.editedImage : getImageProvider.imageData;
                }
                if(recievedImage != null){
                  makeWaterMark(recievedImage!);
                }
                return Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 25),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: widget.editedvideo == null
                                  ? DecorationImage(
                                      image: MemoryImage(recievedImage!),
                                      fit: BoxFit.fill)
                                  : null,
                            ),
                            child: widget.editedvideo != null
                                ? AspectRatio(
                                    aspectRatio:
                                        _videoController.value.aspectRatio,
                                    child: VideoPlayer(_videoController),
                                  )
                                : null,
                          ),
                          !isSwitched
                              ? Positioned(
                                  top: 30,
                                  left: 45,
                                  child: Image.asset(
                                    'assets/starryImages/Snaplet water mark .png',
                                    width: 100,
                                  ))
                              : const Text('')
                        ],
                      ),
                    ),
                  if(!(InAppPurchase.isPro || InAppPurchase.isProAI))
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome),
                              Text(
                                'Remove Watermark',
                                style: TextStyle(fontSize: 16),
                              ),
                              Icon(
                                Icons.lock,
                                size: 13,
                              )
                            ],
                          ),
                          Switch(
                            activeColor: Colors.white,
                            activeTrackColor: Colors.black,
                            value: isSwitched,
                            onChanged: (value) {
                              Provider.of<RewardAdsService>(context,listen: false).showAd(context, changeSwitch);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Report inappropriate contenret:'),
                          ElevatedButton(onPressed: (){
                            sendEmail(recievedImage);
                          }, child: const Text('Report'))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CustomRoundedButon(
                          onTap: () async {
                            if (widget.editedvideo == null) {
                              if(InAppPurchase.isPro || InAppPurchase.isProAI){
                              saveImage(recievedImage!);
                              }else{
                                if (isSwitched) {
                                saveImage(recievedImage!);
                              } else {
                                await saveImage(watermarkedImage!);
                              }
                              }
                            } else {
                              saveVideoToGallery(widget.editedvideo!.path);
                            }
                          },
                          icon: Icons.download,
                          text: 'Save',
                        ),
                        CustomRoundedButon(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (ctx) => ImageToImageScreen(
                                    resuseImage: recievedImage,
                                    imagetoImage: getImageProvider.allmodels
                                        .where((element) => element.piplines
                                            .contains('image-to-image'))
                                        .toList())));
                          },
                          icon: Icons.restart_alt_outlined,
                          text: 'Reuse',
                        ),
                        CustomRoundedButon(
                          onTap: () async {
                            var editedddImage = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageEditor(
                                  image: recievedImage,
                                ),
                              ),
                            );
                            if (editedddImage != null) {
                              setState(() {
                                recievedImage = editedddImage;
                              });
                            }
                          },
                          icon: Icons.edit,
                          text: 'Edit',
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.white,
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          ElevatedButton(
                                              onPressed: () {
                                                if(InAppPurchase.isPro || InAppPurchase.isProAI){
                                                  if(widget.editedvideo != null){
                                                    SnapChatHelper.sendVideoToSnapChat(widget.editedvideo,context);
                                                  }else{
                                                    SnapChatHelper.sendImageToSnapChat(recievedImage!,context);
                                                  }
                                                }else{
                                                  if (widget.editedvideo != null) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        SnapChatShareDialog(
                                                      onTapShare: () {
                                                        SnapChatHelper
                                                            .sendVideoToSnapChat(
                                                                widget
                                                                    .editedvideo,
                                                                context);
                                                      },
                                                    ),
                                                  );
                                                } else if (recievedImage !=
                                                    null) {
                                                  if (isSwitched) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          SnapChatShareDialog(
                                                        onTapShare: () {
                                                          SnapChatHelper
                                                              .sendImageToSnapChat(
                                                                  recievedImage!,
                                                                  context);
                                                        },
                                                      ),
                                                    );
                                                  } else {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          SnapChatShareDialog(
                                                        onTapShare: () {
                                                          SnapChatHelper
                                                              .sendImageToSnapChat(
                                                                  watermarkedImage!,
                                                                  context);
                                                        },
                                                      ),
                                                    );
                                                  }
                                                }
                                                }
                                                
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 10),
                                                backgroundColor: Colors.black,
                                                foregroundColor:
                                                    const Color.fromARGB(
                                                        255, 216, 213, 213),
                                              ),
                                              child: const Text(
                                                'share live Snap',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 20,
                                                ),
                                              )
                                              ),
                                          ElevatedButton(
                                              onPressed: () async {
                                                if (recievedImage != null) {
                                                  if (isSwitched) {
                                                    final temp =
                                                        await getTemporaryDirectory();
                                                    final path =
                                                        '${temp.path}/image.jpg';
                                                    File(path).writeAsBytesSync(recievedImage!);
                                                    XFile file = XFile(path);
                                                    Share.shareXFiles([file]);
                                                  } else{ 
                                                    final temp =
                                                        await getTemporaryDirectory();
                                                    final path =
                                                        '${temp.path}/image.jpg';
                                                    File(path).writeAsBytesSync(
                                                        watermarkedImage!);
                                                        XFile file = XFile(path);
                                                    Share.shareXFiles([file]);
                                                  }
                                                } else if (widget.editedvideo != null) {
                                                  XFile file = XFile(widget.editedvideo!.path);
                                                    Share.shareXFiles([file]);
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 10),
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 216, 213, 213),
                                                foregroundColor: Colors.black,
                                              ),
                                              child: const Text(
                                                'other apps',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 20,
                                                ),
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 55),
                            backgroundColor:
                                const Color.fromARGB(255, 216, 213, 213),
                            foregroundColor: Colors.black,
                          ),
                          child:  const Text(
                            'Share',
                            style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 25,
                                                ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (ctx)=> const TabsScreen())
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 30),
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                          child:  const Text(
                            'Regenerate',
                            style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 25,
                                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class CustomRoundedButon extends StatelessWidget {
  const CustomRoundedButon(
      {super.key, required this.icon, required this.text, required this.onTap});
  final IconData icon;
  final String text;
  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 216, 213, 213)),
            child: Center(
              child: Icon(
                icon,
                size: 35,
                color: Colors.black
              ),
            ),
          ),
        ),
        Text(text),
      ],
    );
  }
}
