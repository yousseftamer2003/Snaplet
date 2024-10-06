import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardAdsService with ChangeNotifier {
  String? errorMessage;
  RewardedInterstitialAd? rewardedInterstitialAd;
  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3523762960785202/7946213982'
      : 'ca-app-pub-3863114333197264/9190630399';

  void loadAd() {
    RewardedInterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {},
            onAdImpression: (ad) {},
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
            },
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              rewardedInterstitialAd = null;
              notifyListeners();
            },
            onAdClicked: (ad) {},
          );
          log('$ad loaded.');
          rewardedInterstitialAd = ad;
          notifyListeners();
        },
        onAdFailedToLoad: (LoadAdError error) {
          log('RewardedInterstitialAd failed to load: ${error.message}');
          if (error.message == 'No fill.') {
            errorMessage = error.message;
            notifyListeners();
          }
        },
      ),
    );
  }

  void showAd(BuildContext context, VoidCallback? onTapShare) {
    if (rewardedInterstitialAd != null) {
      rewardedInterstitialAd!.show(onUserEarnedReward: (ad, reward) {
        onTapShare!();
      });
    }else if(errorMessage != null && errorMessage == 'No fill.'){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ads are not available now. come back sooner')),
      );
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad has not reloaded yet, please wait a few seconds or check your internet')),
      );
    }
  }

  @override
  void dispose() {
    rewardedInterstitialAd?.dispose();
    super.dispose();
  }
}
