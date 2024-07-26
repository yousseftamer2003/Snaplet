import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sfs_editor/core/ads/google_ads.dart';

class AdsLoader {
  static ValueNotifier<bool> stopAds = ValueNotifier(false);

  static final ValueNotifier<bool> isBannerAdLoading = ValueNotifier(true);

  static BannerAd? adBaner;
  static int _numBannerLoadAttempts = 0;
  static const int _maxBannerFailedLoadAttempts = 3;

  static final ValueNotifier<bool> isInterstitialAdLoading =
      ValueNotifier(true);

  static InterstitialAd? interstitialAd;
  static int _numInterstitialLoadAttempts = 0;
  static const int _maxInterstitialFailedLoadAttempts = 3;

  static final ValueNotifier<bool> isNativeAdLoading = ValueNotifier(true);

  static NativeAd? nativeAd;
  static int _numNativeLoadAttempts = 0;
  static const int _maxNativeFailedLoadAttempts = 3;

  static final ValueNotifier<bool> isAppOpenAdLoading = ValueNotifier(true);

  static AppOpenAd? appOpenAd;
  static int _numAppOpenLoadAttempts = 0;
  static const int _maxAppOpenFailedLoadAttempts = 3;

  static final Key _nativeAdKey = GlobalKey();
  static Key get nativeAdKey => _nativeAdKey;

  static final Key _adBannerKey = GlobalKey();
  static Key get adBannerKey => _adBannerKey;

  static AdManagerInterstitialAd? adManagerInterstitialAd;

  static Future<void> _loadNativeAd() async {
    if (stopAds.value) return;

    nativeAd = GoogleAds.instance.createNativeAd(
      listner: NativeAdListener(
        onAdLoaded: (ad) {
          nativeAd = ad as NativeAd;
          if (kDebugMode) {
            print("===========Native Ad Loaded============");
          }
          _numNativeLoadAttempts = 0;
          isNativeAdLoading.value = false;
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            print("===========Native Ad Failed============");
            print('$ad onAdFailedToLoad: "${error.message}"');
          }
          isNativeAdLoading.value = true;
          _numNativeLoadAttempts += 1;

          if (_numNativeLoadAttempts < _maxNativeFailedLoadAttempts) {
            nativeAd = null;
            loadNativeAd();
          }
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        // Required: Choose a template.
        templateType: TemplateType.small,
        // Optional: Customize the ad's style.
        mainBackgroundColor: Colors.white,
        cornerRadius: 10.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.cyan,
          backgroundColor: Colors.red,
          style: NativeTemplateFontStyle.monospace,
          size: 16.0
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.red,
          backgroundColor: Colors.cyan,
          style: NativeTemplateFontStyle.italic,
          size: 16.0
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.green,
          backgroundColor: Colors.black,
          style: NativeTemplateFontStyle.bold,
          size: 16.0
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.brown,
          backgroundColor: Colors.amber,
          style: NativeTemplateFontStyle.normal,
          size: 16.0
        )
      )
    );
  }

  static Future<void> loadNativeAd() async {
    if (stopAds.value) return;

    if (nativeAd == null) {
      log("Warning: attemp to show native before load");
      await _loadNativeAd();
      return;
    }

    await nativeAd!.load();
  }

  static void resetNativeAd() async {
    if (stopAds.value ) return;

    if (adBaner != null && isBannerAdLoading.value) return null;

    await adBaner?.dispose();
    isBannerAdLoading.value = true;
    showBannerAd();
  }

  static void loadInterstitialAd({void Function()? whenFinished, bool show = false}) {
    if (stopAds.value) return;

    GoogleAds.instance.loadInterstitialAd(
      listner: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          if (kDebugMode) {
            debugPrint("============= Interstitial Loaded ============");
          }
          interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
          if (interstitialAd == null) {
            if (kDebugMode) {
              debugPrint("Warning: attemp to show interstitial before load");
            }
            return;
          } else {
            interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (InterstitialAd ad) {
                if (kDebugMode) {
                  debugPrint("$ad onAdShowedFullScreenContent.");
                }
              },
              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                if (kDebugMode) {
                  debugPrint('"$ad" onAdShowedFullScreenContent');
                }
                ad.dispose();
                interstitialAd = null;
                if (whenFinished != null) whenFinished();
              },
        
              onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
                if (kDebugMode) {
                  debugPrint('"${error.message}" onAdFailedToShowFullScreenContent');
                }
                ad.dispose();
                if(whenFinished != null) whenFinished();
              },

            );
          }

          if(show) {
            showInterstitialAd(
              whenFinished: whenFinished
            );
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (kDebugMode) {
            debugPrint("============= Interstitial Faild to Load ============");
            debugPrint('InterstitialAd failed to load: ${error.message}.');
          }
          _numInterstitialLoadAttempts += 1;
          interstitialAd = null;

          if (_numInterstitialLoadAttempts < _maxInterstitialFailedLoadAttempts) {
            loadInterstitialAd(whenFinished: whenFinished, show: show);
          } else {
            if (whenFinished != null) whenFinished();
          }
        },
      ),
    );
  }

  static Future<void> showInterstitialAd({void Function()? whenFinished}) async {
    debugPrint("Show Interstitial");
    if (stopAds.value) {
      if (whenFinished != null) whenFinished();
      return;
    }

    if (interstitialAd == null) {
      loadInterstitialAd(whenFinished: whenFinished, show: true);
      return;
    }

    try {
      await interstitialAd!.show();
    } catch (e) {
      loadInterstitialAd(whenFinished: whenFinished, show: true);
    }
  }

  static Future<void> loadAdBanner() async {
    if (stopAds.value) return;

    await adBaner?.dispose();

    try {
      adBaner = GoogleAds.instance.createBannerAd(
        listner: BannerAdListener(
          onAdLoaded: (ad) {
            adBaner = ad as BannerAd;
          if (!kDebugMode) {
              debugPrint("===========Banner Ad Loaded============");
          }
            _numBannerLoadAttempts = 0;
            isBannerAdLoading.value = false;
          },
          onAdFailedToLoad: (ad, error) {
            if (!kDebugMode) {
              debugPrint("===========Banner Ad Failed============");
              debugPrint('$ad onAdFailedToLoad: "${error.message}"');
         }
            isBannerAdLoading.value = true;
            _numBannerLoadAttempts += 1;

            if (_numBannerLoadAttempts < _maxBannerFailedLoadAttempts) {
              loadAdBanner();
            }
          },
        ),
      )..load();

    } catch (e) {
     if (!kDebugMode) {
        debugPrint("============= Banner Exception  ============");
        debugPrint(e.toString());
      }
      adBaner = null;
    }
  }

  static void showBannerAd() {
    if (stopAds.value) return;

    if (adBaner == null) {
      log("Warning: attemp to show banner before load");
      loadAdBanner();
      return;
    }

    adBaner!.load();
  }

  static void loadAppOpenAd() {
    if (stopAds.value) return;

    GoogleAds.instance.loadAppOpenAd(
      listner: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          if (!kDebugMode) {
            debugPrint("============= App Open Loaded ============");
          }
          appOpenAd = ad;
          _numAppOpenLoadAttempts = 0;
          if (appOpenAd == null) {
            if (!kDebugMode) {
              debugPrint("Warning: attemp to show app open before load");
            }
            return;
          } else {
            appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (AppOpenAd ad) {
                if (!kDebugMode) {
                  debugPrint("$ad onAdShowedFullScreenContent.");
                }
              },
              onAdDismissedFullScreenContent: (AppOpenAd ad) {
                if (!kDebugMode) {
                  debugPrint('"$ad" onAdShowedFullScreenContent');
                }
                ad.dispose();
              },
              onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
                if (!kDebugMode) {
                  debugPrint('"${error.message}" onAdFailedToShowFullScreenContent');
                }
                ad.dispose();
                if (_numAppOpenLoadAttempts < _maxAppOpenFailedLoadAttempts) {
                  loadAppOpenAd();
                }
              },
            );
          }

          showAppOpenAd();
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (!kDebugMode) {
            debugPrint("============= App Open Faild to Load ============");
            debugPrint('AppOpenAd failed to load: ${error.message}.');
          }
          _numAppOpenLoadAttempts += 1;
          appOpenAd = null;

          if (_numAppOpenLoadAttempts < _maxAppOpenFailedLoadAttempts) {
            loadAppOpenAd();
          }
        },
      ),
    );
  }

  static void showAppOpenAd() {
    if (stopAds.value) return;

    if (appOpenAd == null) {
      log("Warning: attemp to show app open before load");
      loadAppOpenAd();
      return;
    }

    appOpenAd!.show();
    // appOpenAd = null;
  }
}
