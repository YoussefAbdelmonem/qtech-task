import 'dart:io';

import 'package:flutter/material.dart';

const colorTextBlack = Colors.black;
const colorTextWhite = Colors.white;
const colorTextMediumGrey = Color(0xffA7A7A7);
const colorGreen = Color(0xff89C48B);
const colorDarkGreen = Color(0xff45A59F);

const colorBlue = Color(0xff1D5CA2);
const colorBlack = Color(0xff272526);
const colorLightGrey = Color(0xffC8C8C8);
const colorMediumGrey = Color(0xffA7A7A7);
const colorWhite = Color(0xffFFFFFF);
const colorDarkGrey = Color(0xff7C7C7C);
const colorDarkTone = Color(0xff6A6D70);
const colorMainProvider = Color(0xff44A49E);
const colorCategoriesBg = Color(0xff4ecf2f3);
const colorRate = Color(0xffFFB319);
const colorNaturalGrey100 = Color(0xff000000);
const colorNaturalGrey90 = Color(0xff191919);
const colorNaturalGrey50 = Color(0xff808080);
const colorNaturalGrey60 = Color(0xff666666);
const colorNaturalGrey70 = Color(0xff4D4D4D);
const colorNaturalGrey80 = Color(0xff333333);
const colorNaturalGrey40 = Color(0xff999999);
const colorNaturalGrey30 = Color(0xffB3B3B3);
const colorNaturalGrey10 = Color(0xffE5E5E5);
const colorNaturalGrey5 = Color(0xffF2F2F2);

// const colorNaturalGrey = Color(0xff);
// const colorNaturalGrey = Color(0xff);
// const colorNaturalGrey = Color(0xff);
//background: var(--Natural-grey-90, #191919);
const double sizeH13 = 22;
const double sizeH14 = 20;
const double sizeH15 = 18;
const double sizeH16 = 16;
const double sizeH17 = 14;
const double sizeH18 = 12;
var colorGreyForShimmerItem = Colors.grey.withOpacity(.2);
var colorBaseShimmer = Colors.grey.withOpacity(.4);
var colorHighlightColorShimmer = Colors.grey.withOpacity(.8);
MaterialColor buildMaterialColor(Color color) {
  List strengths = [.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
  final int r = color.red, g = color.green, b = color.blue;
  Map<int, Color> swatch = {};
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

class AppTheme {
  AppTheme._();

  static const String apiKey = "";
  static const String defaultImage =
      "https://cdn.pixabay.com/photo/2024/04/18/14/31/ai-generated-8704440_640.jpg";
  static const String defaultPersonImage =
      "https://hips.hearstapps.com/hmg-prod/images/cristiano-ronaldo-of-portugal-reacts-as-he-looks-on-during-news-photo-1725633476.jpg?crop=0.666xw:1.00xh;0.180xw,0&resize=640:*";

  static const androidUrl =
      "https://play.google.com/store/apps/details?id=com.alalmiyalhura.allin";
  static const iosUrl = "https://apps.apple.com/app/";
  static String link = Platform.isIOS ? iosUrl : androidUrl;

  static const String fontName = 'Main';
  static const String boldFont = 'Bold';
}
