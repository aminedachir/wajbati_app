import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TDeviceUtils {
  /// Hides the keyboard if it's visible
  static void hideKeyboard(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.focusedChild?.unfocus();
    }
  }

  /// Changes the status bar color
  static void setStatusBarColor(Color color) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: color),
    );
  }

  /// Checks if device is in landscape orientation
  static bool isLandscapeOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Checks if device is in portrait orientation
  static bool isPortraitOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Additional useful utility method - check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
  /// Enables/disables fullscreen mode
  static void setFullScreen(bool enable) {
    SystemChrome.setEnabledSystemUIMode(
      enable ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  /// Gets screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Gets screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Gets device pixel ratio
  static double getPixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// Gets status bar height
  static double getStatusBarHeight(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  /// Gets bottom safe area padding
  static double getBottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }
  static void vibrate(Duration duration) {
    HapticFeedback.vibrate();
    Future.delayed(duration, () => HapticFeedback.vibrate());
  }
  static double getAppBarHeight(){
    return kToolbarHeight;
  }
   static double getBottomNavigationBarHeight(){
    return kBottomNavigationBarHeight;
   }
  static Future<void> setPreferredOrientations(List<DeviceOrientation> orientations) async {
    await SystemChrome.setPreferredOrientations(orientations);
  }
  static void hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  static void showStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static bool isIOS() {
    return Platform.isIOS;
  }
  static bool isAndroid() {
    return Platform.isAndroid;
  }

  static void launchUrl(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}