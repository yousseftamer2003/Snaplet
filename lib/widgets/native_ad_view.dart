import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sfs_editor/core/ads/ads_loader.dart';

GlobalKey adBannerKey = GlobalKey();

Widget bannerAdView() {
  return FutureBuilder(
    future: AdsLoader.loadAdBanner(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container(height: 50);
      }
      return StatefulBuilder(
        builder: (context, setState) {
          return ValueListenableBuilder(
          valueListenable: AdsLoader.stopAds,
          builder: (context, stop, _) {
            return stop
              ? const SizedBox.shrink()
              : ValueListenableBuilder(
                  valueListenable: AdsLoader.isBannerAdLoading,
                  builder: (context, value, child) {
                    if (AdsLoader.adBaner == null || value) {
                      return Container(height: 50);
                    }
                    
                    return SizedBox(
                      width: AdsLoader.adBaner!.size.width.toDouble(),
                      height: AdsLoader.adBaner!.size.height.toDouble(),
                      child: AdWidget(
                        ad: AdsLoader.adBaner!,
                      ),
                    );
                  },
                );
            }
          );
        }
      );
    }
  );
}

Widget nativeAdView() {
  return FutureBuilder(
    future: AdsLoader.loadNativeAd(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Container(height: 50);
      }
      return StatefulBuilder(
        builder: (context, setState) {
          return ValueListenableBuilder(
          valueListenable: AdsLoader.stopAds,
          builder: (context, stop, _) {
            return stop
              ? const SizedBox.shrink()
              : ValueListenableBuilder(
                  valueListenable: AdsLoader.isNativeAdLoading,
                  builder: (context, value, child) {
                    if (AdsLoader.nativeAd == null || value) {
                      return Container(height:  90);
                    }
                    
                    return ConstrainedBox(
                      constraints: const BoxConstraints(
                      minWidth: 320, // minimum recommended width
                      minHeight: 90, // minimum recommended height
                      maxWidth: 400,
                      maxHeight: 200,
                    ),
                      child: AdWidget(
                        ad: AdsLoader.nativeAd!,
                      ),
                    );
                  },
                );
            }
          );
        }
      );
    }
  );
}