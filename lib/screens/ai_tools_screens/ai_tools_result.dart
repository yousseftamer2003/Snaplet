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
import 'package:sfs_editor/services/ai_tools_service.dart';
import 'package:sfs_editor/services/dark_mode_service.dart';
import 'package:sfs_editor/services/getimg_services.dart';
import 'package:sfs_editor/widgets/generating_widget.dart';
import 'package:share_plus/share_plus.dart';

class AiToolsResult extends StatefulWidget {
  const AiToolsResult({super.key});

  @override
  State<AiToolsResult> createState() => _AiToolsResultState();
}

class _AiToolsResultState extends State<AiToolsResult> {
  Uint8List? watermarkedImage;
  
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
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode? darkMoodColor : Colors.white,
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode? darkMoodColor : Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/starryImages/snaplet-logo high small3 edited.png',width: 35,),
            const Text('Snaplet',style: TextStyle(
          fontWeight: FontWeight.w700,
          ),),
            SizedBox(
              width: 52.w,
            )
          ],
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const TabsScreen()),
              (Route<dynamic> route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Consumer<AiToolsProvider>(
          builder: (context, aitoolProvider, _) {
            if(aitoolProvider.imageData == null){
              return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GeneratingWidget(),
                      SizedBox(height: 5,),
                      Text('generating...')
                    ],
                  ),
                );
            }else{
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
                            image: DecorationImage(
                                    image: MemoryImage(aitoolProvider.imageData!),
                                    fit: BoxFit.fill),
                          ),
                        ),
                      ],
                    )
                    ),
                    
                  const SizedBox(
                    height: 10,
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
                            sendEmail(aitoolProvider.imageData);
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
                        saveImage(aitoolProvider.imageData!);
                        },
                        icon: Icons.download,
                        text: 'Save',
                      ),
                      CustomRoundedButon(
                        onTap: () async{
                          final modelProvider = Provider.of<GetIMageServices>(context,listen: false);
                          await modelProvider.getAllModels();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => ImageToImageScreen(
                                resuseImage: aitoolProvider.imageData,
                                  imagetoImage: modelProvider.allmodels
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
                          image: aitoolProvider.imageData,
                        ),
                      ),
                    );
                    if(editedddImage != null){
                      setState(() {
                      aitoolProvider.imageData = editedddImage;
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
                                              if(InAppPurchase.isPro){
                                                SnapChatHelper.sendImageToSnapChat(aitoolProvider.imageData!,context);
                                              }else{
                                                if (aitoolProvider.imageData != null) {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        SnapChatShareDialog(
                                                      onTapShare: () {
                                                        SnapChatHelper
                                                            .sendImageToSnapChat(
                                                                aitoolProvider.imageData!,
                                                                context);
                                                      },
                                                    ),
                                                  );
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
                                            )),
                                        ElevatedButton(
                                            onPressed: () async {
                                              if (aitoolProvider.imageData != null) {
                                                  final temp =
                                                      await getTemporaryDirectory();
                                                  final path =
                                                      '${temp.path}/image.jpg';
                                                  File(path).writeAsBytesSync(
                                                      aitoolProvider.imageData!);
                                                  XFile file = XFile(path);
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
                        child: const Text(
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
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const TabsScreen()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 30),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
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
    final themeProvider = Provider.of<ThemeProvider>(context);
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
                size: 40,
                color: themeProvider.isDarkMode? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
        Text(text),
      ],
    );
  }
}