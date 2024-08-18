
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:provider/provider.dart';
import 'package:sfs_editor/constants/color.dart';
import 'package:sfs_editor/constants/strings.dart';
import 'package:sfs_editor/services/dark_mode_service.dart';
// import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

import 'package:url_launcher/url_launcher_string.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMood = true;
  Future<void> sendEmail() async{
    final Email email =Email(
      body: '',
      subject: 'Contact Support',
      recipients: ['Moatazforads@gmail.com'],
      isHTML: false
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
    // final InAppReview inAppReview = InAppReview.instance;
    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? darkMoodColor : Colors.white,
      appBar: AppBar(
        backgroundColor:
            themeProvider.isDarkMode ? darkMoodColor : Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/starryImages/insideLogo.png'),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomSettingsContainer(
              onTap: () {},
              image: 'assets/starryImages/dark.png',
              text: 'Dark Mode',
              switchIcon: Switch(
                value: isDarkMood,
                onChanged: (value) {
                  setState(() {
                    isDarkMood = !isDarkMood;
                    themeProvider.toggleTheme();
                  });
                },
                activeColor: Colors.white,
                activeTrackColor: Colors.black,
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            CustomSettingsContainer(
                onTap: () {
                  Share.share(
          'Check out this amazing app: Snaplet! Download it from [Google Play](https://play.google.com/store/apps/details?id=com.m3tz.sfs_editor&pcampaignid=web_share) and App store soon',
        );
                },
                text: 'Share Snaplet',
                image: 'assets/starryImages/shareicon.png'),
            SizedBox(
              height: 15.h,
            ),
            CustomSettingsContainer(
                onTap: sendEmail,
                text: 'Email support',
                image: 'assets/starryImages/emailicon.png'),
            const SizedBox(
              height: 30,
            ),
            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: themeProvider.isDarkMode
                        ? darkModeHeavey
                        : const Color.fromARGB(255, 229, 226, 226)),
                height: 175.h,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        'Privacy Policy',
                        style:  TextStyle(
                          fontWeight: FontWeight.w700,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      onTap: () {
                        launchUrlString(privacypolicyurl);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: Text(
                        'Terms and Conditions',
                        style:  TextStyle(
                          fontWeight: FontWeight.w700,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      onTap: () {
                        launchUrlString(termsAndConditionsUrl);
                      },
                    ),
                    const Divider(),
      //               ListTile(
      //                 title: Text(
      //                   'Like us?, rate us!',
      //                   style:  TextStyle(
      //                     fontWeight: FontWeight.w700,
      //                     color: themeProvider.isDarkMode
      //                         ? Colors.white
      //                         : Colors.black,
      //                   ),
      //                 ),
      //                 onTap:  () async {
      //   if (await inAppReview.isAvailable()) {
      //     inAppReview.requestReview();
      //   } else {
      //     inAppReview.openStoreListing();
      //   }
      // },
      //               ),
                    //const Divider(),
                    ListTile(
                      title: Text(
                        'Official Website',
                        style:  TextStyle(
                          fontWeight: FontWeight.w700,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      onTap:() async {
        const url = 'https://snaplet.art';
        launchUrlString(url);
      },
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class CustomSettingsContainer extends StatelessWidget {
  const CustomSettingsContainer(
      {super.key,
      required this.onTap,
      required this.text,
      this.switchIcon,
      required this.image});
  final void Function() onTap;
  final String text;
  final Widget? switchIcon;
  final String image;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60.h,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: themeProvider.isDarkMode
                ? darkModeHeavey
                : const Color.fromARGB(255, 229, 226, 226)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  image,
                  color: themeProvider.isDarkMode ? Colors.white : null,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  text,
                  style:  TextStyle(
                      fontWeight: FontWeight.w700,
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black),
                ),
              ],
            ),
            switchIcon ?? const Text(''),
          ],
        ),
      ),
    );
  }
}
