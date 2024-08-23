import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:sfs_editor/core/in_app_purchase.dart';
import 'package:sfs_editor/screens/splashscreen.dart';
import 'package:sfs_editor/services/ai_tools_service.dart';
import 'package:sfs_editor/services/dark_mode_service.dart';
import 'package:sfs_editor/services/getimg_services.dart';
import 'package:sfs_editor/services/reward_ads_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  if (Platform.isIOS) {
    await InAppPurchase.initialize(apiKey: "appl_bopkNxuRZTZZJtaPXwVufWKhnvQ");
  } else if (Platform.isAndroid) {
    await InAppPurchase.initialize(apiKey: 'goog_rdHmnejivVNEsqqzYKvqqKWGZUZ');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GetIMageServices()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AiToolsProvider()),
        ChangeNotifierProvider(create: (_) => RewardAdsService()),
      ],
      child: ScreenUtilInit(
        minTextAdapt: true,
        designSize: const Size(360, 690),
        splitScreenMode: true,
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: themeProvider.getTheme,
              title: 'Snaplet',
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}
