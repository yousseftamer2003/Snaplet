// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sfs_editor/constants/color.dart';
import 'package:sfs_editor/core/ads/ads_loader.dart';
import 'package:sfs_editor/screens/result_screen.dart';
import 'package:sfs_editor/screens/video_editing_screens/show_options_screen.dart';
import 'package:sfs_editor/services/dark_mode_service.dart';

class EditOptionScreen extends StatefulWidget {
  const EditOptionScreen({super.key});

  @override
  State<EditOptionScreen> createState() => _EditOptionScreenState();
}

class _EditOptionScreenState extends State<EditOptionScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode? darkMoodColor : Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 14.h,
          ),
          Row(
            children: [
              SizedBox(
                width: 15.w,
              ),
              GradientText(
                'Edit and share',
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.pink],
                ),
                style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                fontSize: 20.sp
              ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 17.w,
              ),
              Expanded(
                  child: Text(
                'Upload an image or video, apply edits, and share your creation directly to Snapchat.',
                style:  TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16.sp 
              ),
              )),
            ],
          ),
          SizedBox(
            height: 85.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () async {
                  Uint8List imageData;
                  final ImagePicker picker = ImagePicker();
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    imageData = await image.readAsBytes();
                    var editedImage = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageEditor(
                          image: imageData,
                        ),
                      ),
                    );
                    await AdsLoader.showInterstitialAd();
                    if (editedImage != null) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => ResultScreen(
                                editedImage: editedImage,
                                isEditor: true,
                                isVid: false,
                              )));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("No image"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Container(
                  width: 160.w,
                  height: 145.h,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: themeProvider.isDarkMode? darkModeHeavey : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.7),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: const Offset(-1, -1),
                      ),
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.7),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/starryImages/2.png',
                          width: 100.w,
                          color: themeProvider.isDarkMode? Colors.white : Colors.black,
                        ),
                        GradientText(
                          "Edit Image",
                          gradient: const LinearGradient(
                            colors: [Colors.purple, Colors.pink],
                          ),
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              InkWell(
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.video,
                    allowCompression: false,
                  );
                  if (result != null) {
                    final file = File(result.files.single.path!);
                    if (!mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ShowOptionsScreen(
                          file: file,
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  width: 160.w,
                  height: 145.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: themeProvider.isDarkMode? darkModeHeavey : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.7),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: const Offset(-1, -1),
                      ),
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.7),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/starryImages/1.png",
                          width: 100.w,
                          color: themeProvider.isDarkMode? Colors.white : Colors.black,
                        ),
                         GradientText(
                          "Edit Video",
                          gradient: const LinearGradient(
                            colors: [Colors.purple, Colors.pink],
                          ),
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(this.text,
      {super.key, required this.gradient, this.style});

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style,
      ),
    );
  }
}
