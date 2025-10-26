import 'package:flutter/material.dart';
import 'package:new_tag_and_seal_flutter_app/core/utils/constants.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: Constants.fontName,
  primaryColor: Constants.primaryColor,
  scaffoldBackgroundColor: Constants.whiteColor,
  appBarTheme: AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black),
  textTheme: TextTheme(bodyLarge: TextStyle(color: Constants.blackColor)),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(),
    prefixIconColor: Constants.blackColor,
    floatingLabelStyle: TextStyle(color: Constants.blackColor),
  ),
  colorScheme: ColorScheme.light(
    primary: Constants.primaryColor,
    secondary: Constants.whiteColor,
    tertiary: Constants.blackColor,
    surface: Constants.greyColor,
    background: Constants.whiteColor,
    error: Constants.dangerColor
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: Constants.fontName,
  primaryColor: Constants.primaryColor,
  scaffoldBackgroundColor: Constants.darkGreyColor,
  appBarTheme: AppBarTheme(backgroundColor: Constants.blackColor, foregroundColor: Constants.whiteColor),
  textTheme: TextTheme(bodyLarge: TextStyle(color: Constants.whiteColor)),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(),
    prefixIconColor: Constants.whiteColor,
    floatingLabelStyle: TextStyle(color: Constants.whiteColor),
  ),
  colorScheme: ColorScheme.dark(
    primary: Constants.primaryColor,
    secondary: Constants.blackColor,
    tertiary: Constants.whiteColor,
    surface: Constants.greyColor,
    background: Constants.veryDarkGreyColor,
    error: Constants.dangerColor
  ),
);