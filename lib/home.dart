import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sfs_editor/constants/color.dart';
import 'package:sfs_editor/constants/strings.dart';
import 'package:sfs_editor/core/in_app_purchase.dart';
import 'package:sfs_editor/models/aimodels_model.dart';
import 'package:sfs_editor/models_data.dart';
import 'package:sfs_editor/screens/image_to_image_screen.dart';
import 'package:sfs_editor/screens/result_screen.dart';
import 'package:sfs_editor/services/dark_mode_service.dart';
import 'package:sfs_editor/services/getimg_services.dart';
import 'package:sfs_editor/services/reward_ads_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class NoOverscrollBehavior extends ScrollBehavior {
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  File? image;
  String? base64Image;
  int? selectedIndex;
  List<AiModels> texttoImage = [];
  List<AiModels> imagetoImage = [];
  List<AiModels> controlNet = [];
  AiModels? selectedModel;
  TextEditingController promptController = TextEditingController();
  bool isButtonEnabled = false;
  bool isAppropriate = true;
  SharedPreferences? prefs;
  int freeAttempts = 0;

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

  @override
  void initState() {
    super.initState();
    if (!(InAppPurchase.isPro || InAppPurchase.isProAI)) {
      Provider.of<RewardAdsService>(context, listen: false).loadAd();
    }
    if (!InAppPurchase.isProAI) {
      _init();
    }
    texttoImage = aiModelsData
        .where((element) => element.piplines.contains('text-to-image'))
        .toList();
    imagetoImage = aiModelsData
        .where((element) => element.piplines.contains('image-to-image'))
        .toList();
    controlNet = aiModelsData
        .where((element) => element.piplines.contains('controlnet'))
        .toList();
    promptController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    promptController.removeListener(_onTextChanged);
    promptController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      isButtonEnabled = promptController.text.isNotEmpty;
    });
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
    if (selectedModel == null) {
      Provider.of<GetIMageServices>(context, listen: false)
          .postEssential(promptController.text);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (ctx) => const ResultScreen(
                isEditor: false,
                isVid: false,
              )));
    } else {
      Provider.of<GetIMageServices>(context, listen: false)
          .postTextToText(promptController.text, selectedModel!);
    }
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => const ResultScreen(
              isEditor: false,
              isVid: false,
            )));
  }

  bool isContentAppropriate(String prompt) {
    for (var word in bannedWords) {
      RegExp regex =
          RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
      if (regex.hasMatch(prompt)) {
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
        backgroundColor:
            themeProvider.isDarkMode ? darkMoodColor : Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
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
                                            GradientText('Enter Prompt ',
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Colors.purple,
                                                    Colors.pink
                                                  ],
                                                ),
                                                style: GoogleFonts.nunito(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 24)),
                                            const Icon(Icons.edit,
                                                color: Colors.purple),
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
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                            RegExp(
                                                r'[a-zA-Z0-9\s!+-_@#$%^&*(),.?":{}|<>]'),
                                          ),
                                        ],
                                        controller: promptController,
                                        maxLines: null,
                                        decoration: InputDecoration(
                                          helperText:
                                              'Only English letters, numbers, and symbols are allowed.',
                                          hintText:
                                              'Type here a detailed description for what you want to see in your artwork',
                                          hintStyle: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: themeProvider.isDarkMode
                                                  ? Colors.white.withOpacity(0.4)
                                                  : Colors.black
                                                      .withOpacity(0.4)),
                                          hintMaxLines: 3,
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 20.0),
                                        ),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: themeProvider.isDarkMode
                                                ? Colors.white
                                                : Colors.black),
                                        onSaved: (value) async {
                                          setState(() {
                                            isAppropriate =
                                                isContentAppropriate(value!);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomButton(
                              icon: Icons.auto_awesome,
                              text: 'Image to Image',
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => ImageToImageScreen(
                                          imagetoImage: imagetoImage,
                                        )));
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            SizedBox(width: 19.w),
                            Text(
                              'Choose a ',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 20.sp),
                            ),
                            GradientText(
                              'Style',
                              gradient: const LinearGradient(
                                colors: [Colors.purple, Colors.pink],
                              ),
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 20.sp),
                            ),
                            const Text(
                              '(Optional)',
                              style: TextStyle(),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 18,
                          ),
                          child: SizedBox(
                            height: 217.h,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 13,
                                mainAxisSpacing: 22,
                                childAspectRatio: 10 / 9,
                              ),
                              itemCount: texttoImage.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                bool isSelected = selectedIndex == index;
                                bool isLocked = texttoImage[index].family ==
                                        'stable-diffusion-xl' &&
                                    !InAppPurchase.isProAI;
                                return GestureDetector(
                                  onTap: isLocked
                                      ? null
                                      : () {
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
                                              selectedModel = texttoImage[index];
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
                                          borderRadius:
                                              BorderRadius.circular(15.0),
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
                                          texttoImage[index].name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12.sp,
                                              color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            border: Border.all(
                                              color: Colors.pink,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      if (isLocked)
                                        InkWell(
                                          onTap: () {
                                            InAppPurchase.fetchOffers(context);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                              color: Colors.grey.withOpacity(0.8),
                                            ),
                                            child: const Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.lock),
                                                  Text(
                                                    'Pro',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
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
                        SizedBox(
                          height: 7.h,
                        ),
                        
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5,),
              Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 30.w,
                          ),
                          child: ElevatedButton(
                            onPressed: isButtonEnabled
                                ? () async {
                                    if (formKey.currentState!.validate()) {
                                      formKey.currentState!.save();
                                    }
                                    if (isAppropriate) {
                                      if (freeAttempts <= 5) {
                                        if (InAppPurchase.isPro ||
                                            InAppPurchase.isProAI) {
                                          bool hasInternet =
                                              await checkInternetConnection();
                                          if (hasInternet) {
                                            generateImage();
                                          } else {
                                            // ignore: use_build_context_synchronously
                                            showNoInternetDialog(context);
                                          }
                                        } else {
                                          Provider.of<RewardAdsService>(context,listen: false).showAd(context, generateImage);
                                        }
                                      } else {
                                        showMyDialog(context);
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'your text contains unAppropriate words please remove it')));
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
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18.sp),
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
                      const SizedBox(height: 5,),
            ],
          ),
        ),
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

class CustomButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.pink),
      label: Text(
        text,
        style: TextStyle(
            fontWeight: FontWeight.w700,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor:
            themeProvider.isDarkMode ? darkModeHeavey : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        side: BorderSide(color: Colors.grey.shade300),
        shadowColor: Colors.grey.shade300,
        elevation: 3,
      ),
    );
  }
}
