import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sfs_editor/constants/strings.dart';
import 'package:sfs_editor/models/aimodels_model.dart';
import 'package:sfs_editor/screens/ai_tools_screens/ai_tools_result.dart';
import 'package:sfs_editor/services/ai_tools_service.dart';
import 'package:image/image.dart' as img;
import 'package:sfs_editor/services/dark_mode_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoOverscrollBehavior extends ScrollBehavior {
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class ToolsPromptScreen extends StatefulWidget {
  const ToolsPromptScreen(
      {super.key,
      required this.isUpscale,
      required this.isFixFace,
      this.models});
  final bool isUpscale;
  final bool isFixFace;
  final List<AiModels>? models;

  @override
  State<ToolsPromptScreen> createState() => _ToolsPromptScreenState();
}

class _ToolsPromptScreenState extends State<ToolsPromptScreen> {
  TextEditingController promptController = TextEditingController();
  String? base64Image;
  int? selectedIndex;
  File? image;
  int cropTrials = 0;
  Uint8List? maskedImage;
  bool isButtonEnabled = false;
  bool isAspectRatioEqual = false;
  AiModels selectedModel = AiModels(
      id: 'stable-diffusion-xl-v1-0',
      name: 'Stable Diffusion XL',
      family: 'stable-diffusion-xl',
      piplines: ['text-to-image', 'image-to-image', 'inpaint', 'ip-adapter']);
  SharedPreferences? prefs;
  SharedPreferences? prefsFixFace;
  int upScaleAttempts = 0;
  int fixFaceAttempts = 0;

  String _getTodayDateString() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(now);
  }

  bool _isNewDay(String? lastAttemptDate) {
    return lastAttemptDate != _getTodayDateString();
  }

  Future<void> _init() async {
    prefs = await SharedPreferences.getInstance();
    final String? lastAttemptDate = prefs?.getString('last_attempt_date');
    final bool isNewDay = _isNewDay(lastAttemptDate);

    if (isNewDay) {
      await prefs?.setInt('upscale_attempts', 0);
      await prefs?.setString('last_attempt_date', _getTodayDateString());
    }
    upScaleAttempts = prefs?.getInt('upscale_attempts') ?? 0;
  }

  Future<void> _initFixFace() async{
    prefsFixFace = await SharedPreferences.getInstance();
    final String? lastFixfaceAttemptDate = prefsFixFace?.getString('last_fix_attempt_date');

    final bool isNewDay = _isNewDay(lastFixfaceAttemptDate);

    if (isNewDay) {
      await prefs?.setInt('fixface_attempts', 0);
      await prefs?.setString('last_fix_attempt_date', _getTodayDateString());
    }
    fixFaceAttempts = prefs?.getInt('fixface_attempts') ?? 0;
  }

  void _incrementAttempts() async {
    setState(() {
      upScaleAttempts++;
    });
    await prefs?.setInt('upscale_attempts', upScaleAttempts);
    await prefs?.setString('last_attempt_date', _getTodayDateString());
  }

  void _incrementfixFaceAttempts() async {
    setState(() {
      fixFaceAttempts++;
    });
    await prefs?.setInt('fixface_attempts', fixFaceAttempts);
    await prefs?.setString('last_attempt_date', _getTodayDateString());
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageTemporary = File(pickedFile.path);
      final bytes = await imageTemporary.readAsBytes();
      setState(() {
        base64Image = base64Encode(bytes);
        isAspectRatioEqual = isOnetoOne(base64Image);
      });
    } else {
      log('No image selected.');
    }
  }

  bool isOnetoOne(String? image) {
    if (image == null) return false;
    Uint8List unitImage = base64Decode(image);
    img.Image? decodedImage = img.decodeImage(unitImage);
    if (decodedImage == null) return false;
    return decodedImage.width == decodedImage.height;
  }

  void _onTextChanged() {
    if (!widget.isUpscale && !widget.isFixFace) {
      setState(() {
        isButtonEnabled = promptController.text.isNotEmpty;
      });
    } else {
      setState(() {
        isButtonEnabled = true;
      });
    }
  }

  @override
  void initState() {
    if(widget.isUpscale){
      _init();
    }else if(widget.isFixFace){
      _initFixFace();
    }
    if (widget.isUpscale || widget.isFixFace) {
      _onTextChanged();
    }
    promptController.addListener(_onTextChanged);
    super.initState();
  }

  @override
  void dispose() {
    promptController.removeListener(_onTextChanged);
    promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
          child: ScrollConfiguration(
        behavior: NoOverscrollBehavior(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (!widget.isUpscale && !widget.isFixFace)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
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
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    GradientText(
                                      'Enter Prompt ',
                                      gradient: const LinearGradient(
                                        colors: [Colors.purple, Colors.pink],
                                      ),
                                      style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 24),
                                    ),
                                    const Icon(Icons.edit, color: Colors.purple),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 30.h,
                            ),
                            TextFormField(
                              controller: promptController,
                              maxLines: null,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25.sp,
                                ),
                                hintText:
                                    'Type here a detailed description for what you want to see in your artwork',
                                hintStyle: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black.withOpacity(0.4)),
                                hintMaxLines: 3,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 20.0),
                              ),
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black),
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Row(
                children: [
                  SizedBox(width: 20.w),
                  const Text(
                    'Select ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  GradientText(
                    widget.isUpscale
                        ? 'Image to UpScale'
                        : widget.isFixFace
                            ? 'Image to Fix'
                            : 'Image to generate from',
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.pink],
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  pickImage();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
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
                    child: base64Image == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/starryImages/2.png',
                                height: 200,
                              ),
                              const GradientText(
                                'Choose Image',
                                gradient: LinearGradient(
                                  colors: [Colors.purple, Colors.pink],
                                ),
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 24),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                mainAxisAlignment: maskedImage != null
                                    ? MainAxisAlignment.spaceAround
                                    : MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.pink,
                                        width: 1,
                                      ),
                                      image: DecorationImage(
                                        image: MemoryImage(
                                            base64Decode(base64Image!)),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  maskedImage != null
                                      ? Container(
                                          width: 150,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.pink,
                                              width: 1,
                                            ),
                                            image: DecorationImage(
                                              image: MemoryImage(maskedImage!),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        )
                                      : const Text(''),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              widget.models != null
                                  ? ElevatedButton(
                                      onPressed: () async {
                                        final maskedImageff = await Navigator
                                                .of(context)
                                            .push(MaterialPageRoute(
                                                builder: (ctx) => ImageEditor(
                                                      image: base64Decode(
                                                          base64Image!),
                                                    )));
                                        if (maskedImageff != null) {
                                          img.Image? decodedMaskedImage =
                                              img.decodeImage(maskedImageff);
                                          if (decodedMaskedImage != null) {
                                            img.Image resizedMaskedImage = img
                                                .copyResize(decodedMaskedImage,
                                                    width: 512, height: 512);
                                            final resizedMaskedBytes = img
                                                .encodeJpg(resizedMaskedImage);
                                            setState(() {
                                              maskedImage = Uint8List.fromList(
                                                  resizedMaskedBytes);
                                            });
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Go Paint'))
                                  : const SizedBox(),
                              isAspectRatioEqual
                                  ? const SizedBox()
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_outlined,
                                          color: Colors.red,
                                        ),
                                        Text(
                                          cropTrials < 1? 'the image\'s aspect ratio has to be 1:1' : 'check you have done it 1:1 please',
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                              isAspectRatioEqual
                                  ? const SizedBox()
                                  : ElevatedButton(
                                      onPressed: () async {
                                        cropTrials++;
                                        final croppedImage = await Navigator.of(
                                                context)
                                            .push(MaterialPageRoute(
                                                builder: (ctx) => ImageCropper(
                                                    image: base64Decode(
                                                        base64Image!))));
                                        img.Image? decodedImage =
                                            img.decodeImage(croppedImage);
                                        setState(() {
                                          base64Image =
                                              base64Encode(croppedImage);
                                          if (decodedImage!.width ==
                                              decodedImage.height) {
                                            isAspectRatioEqual = true;
                                          }
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Go crop'))
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                child: ElevatedButton(
                  onPressed: isButtonEnabled &&
                          base64Image != null &&
                          isAspectRatioEqual
                      ? () {
                          if (!widget.isUpscale &&
                              !widget.isFixFace &&
                              widget.models == null) {
                            Provider.of<AiToolsProvider>(context, listen: false)
                                .instruct(promptController.text, base64Image!);
                          } else if (widget.isUpscale) {
                            if(upScaleAttempts <= 2){
                              _incrementAttempts();
                              if (isAspectRatioEqual) {
                              final image = base64Decode(base64Image!);
                              final decodedImage = img.decodeImage(image);
                              final resizedImage = img.copyResize(decodedImage!,
                                  width: 1024, height: 1024);
                              final resizedBytes = img.encodeJpg(resizedImage);
                              setState(() {
                                base64Image = base64Encode(resizedBytes);
                              });
                            }
                            Provider.of<AiToolsProvider>(context, listen: false)
                                .upScale(promptController.text, base64Image!);
                            }else{
                              ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('you have finished trials for today'))
                            );
                            }
                          } else if (widget.isFixFace) {
                          if(fixFaceAttempts <= 1){
                            _incrementfixFaceAttempts();
                            Provider.of<AiToolsProvider>(context, listen: false)
                                .fixFace(promptController.text, base64Image!);
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('you have finished trials for today'))
                            );
                          }
                          } else if (widget.models != null) {
                            log(promptController.text);
                            log(selectedModel.id);
                            Provider.of<AiToolsProvider>(context, listen: false)
                                .inpainting(
                                    selectedModel,
                                    promptController.text,
                                    base64Image!,
                                    base64Encode(maskedImage!));
                          }
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => const AiToolsResult()));
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 17,
                      horizontal: 17,
                    ),
                    backgroundColor:
                        isButtonEnabled ? Colors.black : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Generate',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 20),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.arrow_forward,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.models != null) ...[
                const Row(
                  children: [
                    SizedBox(width: 18),
                    Text(
                      'Choose a ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                    GradientText(
                      'Style',
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.pink],
                      ),
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
                    ),
                    Text('(Optional)')
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 18,
                  ),
                  child: SizedBox(
                    height: 125.h,
                    child: ScrollConfiguration(
                      behavior: MyCustomScrollBehavior(),
                      child: GridView.builder(
                        physics: const ClampingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisSpacing: 22,
                          childAspectRatio: 10 / 8,
                        ),
                        itemCount: widget.models!.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          bool isSelected = selectedIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (selectedIndex == index) {
                                  selectedIndex = null;
                                  selectedModel = AiModels(
                                    id: 'stable-diffusion-xl-v1-0',
                                    name: 'Stable Diffusion XL',
                                    family: 'stable-diffusion-xl',
                                    piplines: [
                                      "text-to-image",
                                      "image-to-image",
                                      "inpaint"
                                    ],
                                  );
                                } else {
                                  selectedIndex = index;
                                  selectedModel = widget.models![index];
                                }
                              });
                            },
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Image.asset(
                                    inpaint[index],
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.6),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  right: 10,
                                  child: Text(
                                    widget.models![index].name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      shadows: const [
                                        Shadow(
                                          blurRadius: 2.0,
                                          color: Colors.black,
                                          offset: Offset(1.0, 1.0),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.0),
                                      border: Border.all(
                                        color: Colors.pink,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      )),
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

class MyCustomScrollBehavior extends ScrollBehavior {
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
