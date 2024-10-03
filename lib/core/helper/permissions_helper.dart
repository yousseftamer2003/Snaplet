import 'dart:io' show Platform;
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static final PermissionHandler _instance = PermissionHandler._internal();

  factory PermissionHandler() {
    return _instance;
  }

  PermissionHandler._internal();

  Future<bool> _requestPermission(Permission permission) async {
    var status = await permission.status;
    if (status.isGranted) {
      return true;
    }

    status = await permission.request();
    return status.isGranted;
  }

  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
      List<Permission> permissions) async {
    return await permissions.request();
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) {
        return true;
      } else if (Platform.isAndroid &&
          await Permission.manageExternalStorage.isGranted) {
        return true;
      } else if (await Permission.storage.request().isGranted) {
        return true;
      } else if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      } else if (await Permission.storage.isPermanentlyDenied) {
        await _openAppSettings();
        return false;
      }
    } else if (Platform.isIOS) {
      return await requestPhotoLibraryPermission();
    }
    return false;
  }

  Future<bool> requestCameraPermission() async {
    return await _requestPermission(Permission.camera);
  }

  Future<bool> requestLocationPermission() async {
    return await _requestPermission(Permission.location);
  }

  Future<bool> requestMicrophonePermission() async {
    return await _requestPermission(Permission.microphone);
  }

  Future<bool> requestPhotoLibraryPermission() async {
    return await _requestPermission(Permission.photos);
  }

  Future<bool> isPermissionGranted(Permission permission) async {
    return await permission.isGranted;
  }

  Future<bool> _openAppSettings() async {
    return await openAppSettings();
  }

  Future<void> requestTrackingPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.appTrackingTransparency.status;
      if (status == PermissionStatus.denied ||
          status == PermissionStatus.limited) {
        await Permission.appTrackingTransparency.request();
      } else if (status == PermissionStatus.permanentlyDenied) {
        await _openAppSettings();
      }
    }
  }

  // Future<void> requestTrackingPermission() async {
  //   if (Platform.isIOS) {
  //     final status = await AppTrackingTransparency.trackingAuthorizationStatus;
  //     if (status == TrackingStatus.notDetermined ||
  //         status == TrackingStatus.denied) {
  //       await AppTrackingTransparency.requestTrackingAuthorization();
  //     } else if (status == TrackingStatus.restricted) {
  //       await openAppSettings();
  //     }
  //   }
  // }

  Future<void> handlePermanentDenial(
      Permission permission, Function onOpenSettings) async {
    bool isPermanentlyDenied = await permission.isPermanentlyDenied;
    if (isPermanentlyDenied) {
      bool didOpenSettings = await _openAppSettings();
      if (didOpenSettings) {
        onOpenSettings();
      }
    }
  }
}
