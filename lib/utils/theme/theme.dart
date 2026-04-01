import 'package:flutter/material.dart';
import 'custom_theme/text_theme.dart';
import 'custom_theme/appbar_theme.dart';
import 'custom_theme/button_sheet_theme.dart';
import 'custom_theme/button_theme.dart';
import 'custom_theme/chip_theme.dart';
import 'custom_theme/checkbox_theme.dart';
import 'custom_theme/text_field_theme.dart';
import 'custom_theme/outlined_bottom_theme.dart';

class TAppTheme {
  TAppTheme._();

  /// Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    textTheme: ThemeText.lightTextTheme,
    chipTheme: CChipTheme.lightChipTheme,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppbarTheme.lightAppBarTheme,
    checkboxTheme: CCheckboxTheme.lightCheckboxTheme,
    bottomSheetTheme: BottonSheetTheme.lightButtonSheetTheme,
    elevatedButtonTheme: ThemeButton.lightElevatedButtonTheme,
    outlinedButtonTheme: OutlinedBottomTheme.lightOutlinedBottomTheme,
    inputDecorationTheme: TextFieldTheme.lightInputDecorationTheme,
  );

  /// Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    textTheme: ThemeText.darkTextTheme,
    chipTheme: CChipTheme.darkChipTheme,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppbarTheme.darkAppBarTheme,
    checkboxTheme: CCheckboxTheme.darkCheckboxTheme,
    bottomSheetTheme: BottonSheetTheme.darkButtonSheetTheme,
    elevatedButtonTheme: ThemeButton.darkElevatedButtonTheme,
    outlinedButtonTheme: OutlinedBottomTheme.darkOutlinedBottomTheme,
    inputDecorationTheme: TextFieldTheme.darkInputDecorationTheme,
  );
}
