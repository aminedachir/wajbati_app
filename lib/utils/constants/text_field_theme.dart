import 'package:flutter/material.dart';
import 'package:wajbati_dz/utils/constants/sizes.dart';
import 'colors.dart';

class TTextFormFieldTheme {
  TTextFormFieldTheme._();

  static InputDecorationTheme LightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: Ccolors.darkGrey,
    suffixIconColor: Ccolors.darkGrey,
    labelStyle: const TextStyle().copyWith(fontSize: Ssize.fontSizeMd, color: Ccolors.black),
    hintStyle: const TextStyle().copyWith(fontSize: Ssize.fontSizeSm, color: Ccolors.black),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal),
    floatingLabelStyle: const TextStyle().copyWith(color: Ccolors.black.withOpacity(0.8)),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(Ssize.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: Ccolors.grey),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(Ssize.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: Ccolors.grey),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(Ssize.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: Ccolors.dark),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(Ssize.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: Ccolors.warning),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(Ssize.inputFieldRadius),
      borderSide: const BorderSide(width: 2, color: Ccolors.warning),
    ),
  );
  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 2,
    prefixIconColor: Ccolors.darkGrey,
    suffixIconColor: Ccolors.darkGrey,
    // constraints: const BoxConstraints.expand(height: TSizes.inputFieldHeight),
    labelStyle: const TextStyle().copyWith(
      fontSize: Ssize.fontSizeMd,
      color: Ccolors.white,
    ),
    hintStyle: const TextStyle().copyWith(
      fontSize: Ssize.fontSizeSm,
      color: Ccolors.white,
    ),
    floatingLabelStyle: const TextStyle().copyWith(
      color: Ccolors.white.withOpacity(0.8),
    ),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(Ssize.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: Ccolors.darkGrey),
    ),
  );// InputDecorationTheme
}