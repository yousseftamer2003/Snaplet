import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sfs_editor/constants/color.dart';
import 'package:sfs_editor/constants/strings.dart';
import 'package:sfs_editor/core/in_app_purchase.dart';
import 'package:sfs_editor/models/aimodels_model.dart';
import 'package:sfs_editor/screens/result_screen.dart';
import 'package:sfs_editor/services/dark_mode_service.dart';
import 'package:sfs_editor/services/getimg_services.dart';
import 'package:image/image.dart' as img;
import 'package:sfs_editor/services/reward_ads_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoOverscrollBehavior extends ScrollBehavior {
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class ImageToImageScreen extends StatefulWidget {
  const ImageToImageScreen(
      {super.key, required this.imagetoImage, this.resuseImage});
  final List<AiModels> imagetoImage;
  final Uint8List? resuseImage;

  @override
  State<ImageToImageScreen> createState() => _ImageToImageScreenState();
}

class _ImageToImageScreenState extends State<ImageToImageScreen> {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController promptController = TextEditingController();
  String? base64Image;
  int cropTrials = 0;
  bool isAppropriate = true;
  int? selectedIndex;
  bool isButtonEnabled = false;
  bool isAspectRatioEqual = false;
  File? image;
  SharedPreferences? prefs;
  int freeAttempts = 0;
  AiModels selectedModel = AiModels(
    id: 'stable-diffusion-xl-v1-0',
    name: 'Stable Diffusion XL',
    family: 'stable-diffusion-xl',
    piplines: ["text-to-image", "image-to-image", "inpaint"],
  );
  void _onTextChanged() {
    setState(() {
      isButtonEnabled = promptController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    promptController.addListener(_onTextChanged);
    if (!InAppPurchase.isProAI) {
      _init();
    }
    if(!(InAppPurchase.isPro || InAppPurchase.isProAI)){
      Provider.of<RewardAdsService>(context,listen: false).loadAd();
    }
    super.initState();
  }

  @override
  void dispose() {
    promptController.removeListener(_onTextChanged);
    promptController.dispose();
    super.dispose();
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
      await prefs?.setInt('free_attempts', 0);
      await prefs?.setString('last_attempt_date', _getTodayDateString());
    }
    freeAttempts = prefs?.getInt('free_attempts') ?? 0;
  }

  void _incrementAttempts() async {
    setState(() {
      freeAttempts++;
    });
    await prefs?.setInt('free_attempts', freeAttempts);
    await prefs?.setString('last_attempt_date', _getTodayDateString());
  }

  Future<void> showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // User must tap a button to dismiss the dialog.
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your free attempts are done for today.'),
                Text('Come back tomorrow or get Pro!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Get Pro'),
              onPressed: () {
                InAppPurchase.fetchOffers(context);
              },
            ),
          ],
        );
      },
    );
  }

  void generateImage() {
    if (!InAppPurchase.isProAI) {
      _incrementAttempts();
    }
    if (isAspectRatioEqual) {
      final image = base64Decode(base64Image!);
      final decodedImage = img.decodeImage(image);
      final resizedImage = img.copyResize(
        decodedImage!,
        width: selectedModel.family == 'stable-diffusion-xl' ? 1024 : 512,
        height: selectedModel.family == 'stable-diffusion-xl' ? 1024 : 512,
      );
      final resizedBytes = img.encodeJpg(resizedImage);
      setState(() {
        base64Image = base64Encode(resizedBytes);
      });
    }
    Provider.of<GetIMageServices>(context, listen: false).postImagetoImage(
        selectedModel,
        promptController.text,
        base64Image ?? base64Encode(widget.resuseImage!));
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => const ResultScreen(
              isEditor: false,
              isVid: false,
            )));
  }

  bool isContentAppropriate(String prompt) {
    for (var word in  bannedWords) {
    if (prompt.toLowerCase().contains(word.toLowerCase())) {
      return false;
    }
  }
  
  return true;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        backgroundColor: themeProvider.isDarkMode ? darkMoodColor : Colors.white,
        appBar: AppBar(
          backgroundColor:
              themeProvider.isDarkMode ? darkMoodColor : Colors.white,
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
              setState(() {
                cropTrials =0 ;
              });
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color:
                        themeProvider.isDarkMode ? darkModeHeavey : Colors.white,
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
                                          fontSize: 24.sp),
                                    ),
                                    const Icon(Icons.edit, color: Colors.purple),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 30.h,
                            ),
                            Form(
                              key: formKey,
                              child: TextFormField(
                                controller: promptController,
                                maxLines: null,
                                inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s!+-_@#$%^&*(),.?":{}|<>]'),),
                                ],
                                decoration: InputDecoration(
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25.sp,
                                  ),
                                  hintText:
                                      'Type here a detailed description for what you want to see in your artwork',
                                  helperText: 'Only English letters, numbers, and symbols are allowed.',
                                  hintStyle: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: themeProvider.isDarkMode
                                          ? Colors.white.withOpacity(0.4)
                                          : Colors.black.withOpacity(0.4),
                                      fontSize: 14.sp),
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
                                        onSaved: (value) async{
                                          setState(()  {
                                            isAppropriate =  isContentAppropriate(value!);
                                          });
                                        },
                              ),
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
                    Text(
                      'Select ',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 19.sp),
                    ),
                    GradientText(
                      'Image to generate from',
                      gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.pink],
                      ),
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 19.sp),
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
                      color: themeProvider.isDarkMode
                          ? darkModeHeavey
                          : Colors.white,
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
                                widget.resuseImage == null
                                    ? Image.asset(
                                        'assets/starryImages/2.png',
                                        height: 200,
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : null,
                                      )
                                    : Container(
                                        width: 150,
                                        height: 150,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.pink,
                                            width: 1,
                                          ),
                                          image: DecorationImage(
                                            image:
                                                MemoryImage(widget.resuseImage!),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                widget.resuseImage == null
                                    ? GradientText(
                                        'Choose Image',
                                        gradient: const LinearGradient(
                                          colors: [Colors.purple, Colors.pink],
                                        ),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 22.sp),
                                      )
                                    : const Text(''),
                              ],
                            )
                          : Column(
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
                                      image:
                                          MemoryImage(base64Decode(base64Image!)),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
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
                            (base64Image != null || widget.resuseImage != null) &&
                            isAspectRatioEqual
                        ? () {
                          if (formKey.currentState!.validate()) {
                                    formKey.currentState!.save();
                                  }
                                  if(isAppropriate){
                                    if (freeAttempts <= 2) {
                              if(InAppPurchase.isPro || InAppPurchase.isProAI){
                                      generateImage();
                                    }else{
                                      Provider.of<RewardAdsService>(context,listen: false).showAd(context, generateImage);
                                    }
                            } else {
                              showMyDialog(context);
                            }
                                  }else{
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('your text contains unAppropriate words please remove it')));
                                  }
                                  if (formKey.currentState!.validate()) {
                                    formKey.currentState!.save();
                                  }
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
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Generate',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 19.sp),
                          ),
                        ),
                        const Align(
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: 18),
                    Text(
                      'Choose a ',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 23.sp),
                    ),
                    GradientText(
                      'Style',
                      gradient: const LinearGradient(
                        colors: [Colors.purple, Colors.pink],
                      ),
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 23.sp),
                    ),
                    const Text(
                      '(Optional)',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 18,
                  ),
                  child: SizedBox(
                    height: 280,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 22,
                        childAspectRatio: 10 / 8,
                      ),
                      itemCount: widget.imagetoImage.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        bool isSelected = selectedIndex == index;
                        bool isLocked = widget.imagetoImage[index].family ==
                                'stable-diffusion-xl' &&
                            !InAppPurchase.isProAI;
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
                                selectedModel = widget.imagetoImage[index];
                              }
                            });
                          },
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.asset(
                                  images[index],
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
                                  widget.imagetoImage[index].name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.sp,
                                    color: Colors.white,
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
                              if (isLocked)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16.0),
                                    color: Colors.grey.withOpacity(0.8),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.lock),
                                        Text(
                                          'Pro',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
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
              ],
            ),
          ),
        )),
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
