import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/colors.dart';
import '../halpers/halper_functs.dart';


/// A utility class to display snackbars for success, warnings, and errors.
class YLoaders {
  static hideSnackBar() => ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
  static customToost({required message}){
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
          elevation: 0,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.transparent,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: THelperFunctions.isDarkMode(Get.context!) ? Ccolors.darkerGrey.withValues(alpha: 0.9) : Ccolors.grey.withValues(alpha: 0.9),
            ),
            child: Center(child: Text(message,style: Theme.of(Get.context!).textTheme.labelLarge,),),
          ))
    );
  }
  /// Displays a success snackbar.
  static successSnackBar({required String title,  message = '', duration = 3}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: Colors.greenAccent,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: duration),
      margin: const EdgeInsets.all(10),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  /// Displays a warning snackbar.
  static warningSnackBar({required String title, String message = ''}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: Colors.orangeAccent,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      icon: const Icon(Icons.warning, color: Colors.white),
    );
  }

  /// Displays an error snackbar for failures.
  static errorSnackBar({required String title, String message = ''}) {
    Get.snackbar(
      title,
      message,
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: Colors.redAccent,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(15),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }
}