import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  var currentTheme = ThemeMode.system.obs;

  void toggleTheme() {
    currentTheme.value = currentTheme.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  void setTheme(ThemeMode mode) => currentTheme.value = mode;
}
