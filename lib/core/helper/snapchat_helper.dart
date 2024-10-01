// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:appcheck/appcheck.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sfs_editor/core/ads/ads_loader.dart';
import 'package:snapkit_flutter/snapkit_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:path_provider/path_provider.dart';

class SnapChatHelper {
  static Future<bool> _trySnapchatScheme() async {
    if (await canLaunchUrlString('snapchat://app')) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> get checkSnapchatInstalled async {
    if (Platform.isAndroid) {
      try {
        return await AppCheck().isAppEnabled("com.snapchat.android");
      } catch (e) {
        return false;
      }
    } else if (Platform.isIOS) {
      return await _trySnapchatScheme();
    }

    throw UnsupportedError("Unsupported platform");
  }

  static Future<void> sendImageToSnapChat(
      Uint8List media, BuildContext context) async {
    if (!await checkSnapchatInstalled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Snapchat is not installed"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (Platform.isAndroid) {
      Completer<File?> c = Completer<File?>();
      Image.memory(media)
          .image
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener((imageInfo, _) async {
        String path = (await getTemporaryDirectory()).path;
        ByteData? byteData =
            await imageInfo.image.toByteData(format: ImageByteFormat.png);
        ByteBuffer buffer = byteData!.buffer;
        File file = await File('$path/image.png').writeAsBytes(
            buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
        c.complete(file);
      }));
      final savedImage = await c.future;
      debugPrint('path: ${savedImage?.path}');
      SnapkitFlutter.instance
          .send(mediaType: SnapMediaType.photo, filePath: savedImage?.path);
    } else if (Platform.isIOS) {
      final appDir = await getApplicationDocumentsDirectory();
      final savedImage =
          await File('${appDir.path}/image.png').writeAsBytes(media);
      SnapkitFlutter.instance
          .send(mediaType: SnapMediaType.photo, filePath: savedImage.path);
    }
  }

  static Future<void> sendVideoToSnapChat(
      File? videoFile, BuildContext context) async {
    if (!await checkSnapchatInstalled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Snapchat is not installed"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    // XFile? videoFile;
    void whenFinished() {
      if (videoFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No video"),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      SnapkitFlutter.instance
          .send(mediaType: SnapMediaType.video, filePath: videoFile.path);
    }

    AdsLoader.loadInterstitialAd(whenFinished: whenFinished);
    // final ImagePicker picker = ImagePicker();
    // videoFile = await picker.pickVideo(
    //   source: ImageSource.gallery,
    //   maxDuration: const Duration(seconds: 60),
    // skipCompression: InAppPurchase.isPro
    // );

    await AdsLoader.showInterstitialAd(whenFinished: whenFinished);
  }
}
