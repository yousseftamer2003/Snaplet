import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sfs_editor/core/in_app_purchase.dart';

class SnapChatShareDialog extends StatefulWidget {
  const SnapChatShareDialog({super.key, this.onTapShare});

  final VoidCallback? onTapShare;

  @override
  State<SnapChatShareDialog> createState() => _SnapChatShareDialogState();
}

class _SnapChatShareDialogState extends State<SnapChatShareDialog> {
  RewardedAd? rewardedAd;
  bool isLoadingAd = false;
  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3523762960785202/7946213982' 
      : 'ca-app-pub-3863114333197264/2535327369'; 

  void loadAd() {
    setState(() {
      isLoadingAd = true;
    });
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {},
            onAdImpression: (ad) {},
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
            },
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
            },
            onAdClicked: (ad) {},
          );
          debugPrint('$ad loaded.');
          setState(() {
            rewardedAd = ad;
            isLoadingAd = false;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          log('RewardedAd failed to load: $error');
          setState(() {
            isLoadingAd = false;
          });
        },
      ),
    );
  }

  @override
  void initState() {
    loadAd();
    super.initState();
  }

  void showAd() {
    if (rewardedAd != null) {
      rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        widget.onTapShare!();
        Navigator.of(context).pop();
      });
    } else {
      log('RewardedAd not loaded yet');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Dialog(
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.867),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/snapchat_icon.png', 
                width: 100,
              ),
              const SizedBox(height: 16),
              const Text(
                'Watch ad to be able to share media via Snapchat or get the premium version', 
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.yellow),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: isLoadingAd
                          ? null
                          : () {
                              setState(() {
                                isLoadingAd = true;
                              });
                              Future.delayed(const Duration(seconds: 10), () {
                                showAd();
                                setState(() {
                                  isLoadingAd = false;
                                });
                              });
                            },
                      child: Padding( 
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        child: isLoadingAd
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(color: Colors.yellow),
                                  SizedBox(width: 5.w),
                                  const Text('Loading...', style: TextStyle(color: Colors.yellow)),
                                ],
                              )
                            : const Text('Watch Ad', textAlign: TextAlign.center, style: TextStyle(color: Colors.yellow)),
                      ),
                    ),
                  ),
                  SizedBox(width: isLoadingAd? 5.w : 25.w),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () {
                        InAppPurchase.fetchOffers(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        child: Text('Get Premium', textAlign: TextAlign.center, style: TextStyle(color: Color.fromRGBO(0, 0, 0, 0.867))),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    rewardedAd?.dispose();
    super.dispose();
  }
}
