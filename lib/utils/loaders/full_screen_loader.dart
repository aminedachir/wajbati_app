import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wajbati_dz/utils/constants/colors.dart';
import 'package:wajbati_dz/utils/halpers/halper_functs.dart';

import '../loader_widgets/animation_loader.dart';

class YFullScreenLoader {
  static void openLoadingDialog(String text, String animation) {
    showDialog(
      context: Get.overlayContext!,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Container(
          color: THelperFunctions.isDarkMode(Get.context!) ? Ccolors.dark : Ccolors.white,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 250),
              YAnimationLoaderWidget(text: text, animation: animation),
            ],
          ),
        ),
      ),
    );
  }

  static stopLoading() {
    Navigator.of(Get.overlayContext!).pop();
  }
}
