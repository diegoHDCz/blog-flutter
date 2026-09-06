import 'package:blog_diego/core/theme/app_pallet.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final darkThemeMode = ThemeData.dark();

  static  OutlineInputBorder _border([Color color =  AppPallet.primaryLight]) =>  OutlineInputBorder(
    borderSide: BorderSide(color:color, width: 3.0),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  );

  static final lightThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppPallet.backgroundColor,
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: _border(),
      focusedBorder: _border(AppPallet.primaryLight.withValues(alpha: 0.85)),
      contentPadding: const EdgeInsets.all(22.0),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallet.backgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(
        color: AppPallet.primaryLight,
        size: 26,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppPallet.primaryLight.withValues(alpha: 0.15),
      selectedColor: AppPallet.primaryLight.withValues(alpha: 0.25),
      labelStyle: const TextStyle(color: AppPallet.primaryLight),
      secondaryLabelStyle: const TextStyle(color: AppPallet.primaryLight),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}
