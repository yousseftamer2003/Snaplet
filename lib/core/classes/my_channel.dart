import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MyChannel {
  static const platform = MethodChannel('com.flutter.dev/sfs_channel');

  static Future<void> sendImageMedia(String path) async {
    try {
      final response = await platform.invokeMethod('send_media', {"path": path, "mimeType": "image/*"}); 
      if (response != null) {
        debugPrint("Response: $response");
      } else {
        debugPrint("Response: null");
      }
    } catch (e) {
      debugPrint('Error: $e');
    }  
  }
}