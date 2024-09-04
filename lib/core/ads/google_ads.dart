import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GoogleAds {
  static final GoogleAds _instance = GoogleAds._foo();

  GoogleAds._foo();

  static GoogleAds get instance => _instance;

  static final ValueNotifier<InitializationStatus?> _ads = ValueNotifier(null);

  ValueNotifier<InitializationStatus?> get ads {
    if (_ads.value == null) return _ads;
    return _ads;
  }

  static Future<void> initialize() async {
    final ads = MobileAds.instance.initialize();

    ads.then((value) => {
          _ads.value = value,
          value.adapterStatuses.forEach((key, value) {
            if (!kDebugMode) {
              if (value.state == AdapterInitializationState.notReady) {
                debugPrint("Adapter $key not ready");
              } else {
                debugPrint("Adapter $key is ready");
              }
            }
          })
        });
  }

  String get bannerAdUnitId => kDebugMode
      ? Platform.isAndroid
          // Debug Keys
          ? "ca-app-pub-3940256099942544/6300978111" // Android Debug Key
          : "ca-app-pub-3940256099942544/2934735716" // iOS Debug Key
      : Platform.isAndroid
          // Release Keys
          ? "ca-app-pub-1804755983693905/5821412473" // Android Release Key
          : "ca-app-pub-1804755983693905/5890900511"; // iOS Release Key

  String get interstitialAdUnitId => Platform.isAndroid
    ? "ca-app-pub-3523762960785202/4459387396" // Android Release Key
    : "ca-app-pub-3523762960785202/3721020799"; // iOS Release Key


  String get nativeAdUnitId => kDebugMode
      ? "/6499/example/native" // Debug Key
      : Platform.isAndroid
          ? "" // Android Release Key
          : ""; // iOS Release Key

  String get appOpenAdUnitId => kDebugMode
      ? "ca-app-pub-3940256099942544/3419835294" // Debug Key
      : Platform.isAndroid
          ? "" // Android Release Key
          : ""; // iOS Release Key

  final _adRequest = const AdRequest(
      // keywords: <String>['sports', 'football', 'soccer', 'livescore', 'livescores', 'live score', 'live scores'],
      // nonPersonalizedAds: true,
      );

  final _adManagerAdRequest = const AdManagerAdRequest();

  BannerAd createBannerAd(
      {required BannerAdListener listner, AdSize? size, AdRequest? request}) {
    return BannerAd(
      size: size ?? AdSize.banner,
      adUnitId: bannerAdUnitId,
      request: request ?? _adRequest,
      listener: listner,
    );
  }

  void loadAdManagerInterstitialAd(
      {required AdManagerInterstitialAdLoadCallback listner,
      AdManagerAdRequest? request}) {
    AdManagerInterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: request ?? _adManagerAdRequest,
      adLoadCallback: listner,
    );
  }

  void loadInterstitialAd(
      {required InterstitialAdLoadCallback listner, AdRequest? request}) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: request ?? _adRequest,
      adLoadCallback: listner,
    );
  }

  NativeAd createNativeAd(
      {required NativeAdListener listner,
      AdRequest? request,
      NativeTemplateStyle? nativeTemplateStyle}) {
    return NativeAd(
        adUnitId: nativeAdUnitId,
        request: request ?? _adRequest,
        listener: listner,
        nativeTemplateStyle: nativeTemplateStyle);
  }

  void loadAppOpenAd(
      {required AppOpenAdLoadCallback listner, AdRequest? request}) {
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: request ?? _adRequest,
      adLoadCallback: listner,
      // orientation: AppOpenAd.orientationPortrait,
    );
  }
}


