import 'package:flutter/material.dart';
import 'package:qtech_task/core/extensions/extensions.dart';
import 'package:qtech_task/core/utils/colors.dart';

class AppThemes {
  /// light
  static const String _primaryColorLight = '#645aa7';
  static const String _scaffoldBackgroundColorLight = '#FFFFFF';
  static const String _hoverColorLight = "#10D0C1";
  static const String _hintColorLight = "#999999";
  static const String _disabledColorLight = "#626262";
  static const String _indicatorColorLight = "#EDEEFF";
  static const String _focusColorLight = "#FEB95A";
  static const String _errorColorLight = "#FF445B";
  static const String _splashColorLight = "#FFFFFF";
  static const String mediumText = "#666666";
  static const Color secondaryGray = Color.fromRGBO(252, 252, 252, 1);

  static ThemeData get lightTheme => ThemeData(
    indicatorColor: _indicatorColorLight.color,

    primaryColor: _primaryColorLight.color,
    scaffoldBackgroundColor: _scaffoldBackgroundColorLight.color,
    textTheme: textLightTheme,
    hoverColor: _hoverColorLight.color,
    hintColor: _hintColorLight.color,
    primaryColorDark: Colors.white,

    primaryColorLight: Colors.black,
    cardColor: '#A5AAD2'.color,
    splashColor: _splashColorLight.color,
    disabledColor: _disabledColorLight.color,
    focusColor: _focusColorLight.color,
    canvasColor: _errorColorLight.color,

    fontFamilyFallback: ['Main'],
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: TextStyle(
        fontSize: 12,
        color: "#BDC1DF".color,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: TextStyle(
        fontSize: sizeH17,
        color: _hintColorLight.color,
        fontWeight: FontWeight.w300,
      ),
      fillColor: Colors.white,
      filled: true,

      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(14),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: "#BBB5DD".color),
        borderRadius: BorderRadius.circular(14),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: "#F2F2F2".color),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _primaryColorLight.color),
        borderRadius: BorderRadius.circular(14),
      ),
      // enabledBorder: OutlineInputBorder(
      //     borderSide: BorderSide(color: "##F2F2F2".color,),
      //     borderRadius: BorderRadius.circular(14)),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    ),

    // tabBarTheme: TabBarTheme(
    //   indicatorColor: _primaryColorLight.color,
    //   labelStyle: TextStyle(
    //       fontWeight: FontWeight.w500,
    //       fontSize: 14,
    //       color: _primaryColorLight.color),
    //   unselectedLabelStyle: const TextStyle(
    //       fontWeight: FontWeight.w500,
    //       fontSize: 14,
    //       color: colorNaturalGrey50),
    //   dividerColor: Colors.transparent,
    //   indicatorSize: TabBarIndicatorSize.tab,
    //   overlayColor:
    //       WidgetStateProperty.all(_scaffoldBackgroundColorLight.color),
    // ),
    dividerTheme: DividerThemeData(color: _indicatorColorLight.color),
    appBarTheme: AppBarTheme(
      backgroundColor: _scaffoldBackgroundColorLight.color,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: "#FFFFFF".color,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: colorNaturalGrey90,
        fontWeight: FontWeight.w700,
        fontSize: sizeH13,
        fontFamily: 'Main',
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      // selectedItemColor: _primaryColorLight.color,
      showUnselectedLabels: true,
      showSelectedLabels: true,
      selectedLabelStyle: TextStyle(
        color: _primaryColorLight.color,
        fontSize: 12,
      ),

      unselectedLabelStyle: TextStyle(color: Colors.red, fontSize: 12),

      type: BottomNavigationBarType.fixed,
      selectedIconTheme: IconThemeData(color: _primaryColorLight.color),

      //unselectedItemColor: "#AED489".color,
      enableFeedback: false,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(1000),
        borderSide: BorderSide.none,
      ),
      iconSize: 24,
      backgroundColor: '#FAF9FC'.color,
      elevation: 1,
    ),
    colorScheme: ColorScheme.light(
      secondaryContainer: '#FAF9FC'.color,
      secondary: secondaryGray,
      primaryContainer: "#FAF9FC".color,
      tertiaryContainer: '#2C3043'.color,
      primary: _primaryColorLight.color,
      error: "#FF445B".color,
      onSurfaceVariant: "#828ABA".color,
    ),
    timePickerTheme: TimePickerThemeData(
      elevation: 0,
      dialHandColor: "#C58FC2".color,
      dialTextColor: Colors.black,
      backgroundColor: Colors.white,
      hourMinuteColor: "#FAF9FC".color,
      dayPeriodTextColor: Colors.black,
      entryModeIconColor: Colors.transparent,
      dialBackgroundColor: "#FAF9FC".color,
      hourMinuteTextColor: Colors.black,
      dayPeriodBorderSide: BorderSide(color: "#663F97".color),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: "#F7F7FFD".color),
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      modalBackgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),

    // buttonTheme: ButtonThemeData(
    //
    //  ),
  );

  // static TextTheme get textDarkTheme => const TextTheme(
  //       labelLarge: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
  //       headlineMedium: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
  //       labelMedium: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
  //       headlineSmall: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
  //       labelSmall: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w300),
  //     );

  static TextTheme get textLightTheme => TextTheme(
    labelLarge: TextStyle(
      color: '#2F3148'.color,
      fontSize: 14,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: TextStyle(
      color: '#2F3148'.color,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
    headlineLarge: TextStyle(
      color: '#2F3148'.color,
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
    labelMedium: TextStyle(
      color: '#2F3148'.color,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: TextStyle(
      color: mediumText.color,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    headlineSmall: TextStyle(
      color: '#2F3148'.color,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    labelSmall: TextStyle(
      color: '#2F3148'.color,
      fontSize: 14,
      fontWeight: FontWeight.w300,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    ),
  );
}
